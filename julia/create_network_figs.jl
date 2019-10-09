# Tool to generate Network images

using LightGraphs
using GraphPlot
using SNAPDatasets
using Random
using Compose
using Cairo
using Fontconfig
using Colors
import Graphs
import Gadfly

function myplot(g, title = "Title"; nodesize_multiplier = 2)
    nodesize = [log(degree(g, v)+3)/10 for v in vertices(g)]
    nodefillc = [RGBA(0.1,0.1,0.1, 0.66) for v in vertices(g)]
    plt = gplot(g, nodesize = nodesize * nodesize_multiplier, nodefillc = nodefillc)
    plt = Gadfly.title(plt, title)
    plt
end

function saveplot(plt, filename = "networkplot.pdf")
    draw(PDF(joinpath("output/", filename), 12cm, 12cm), plt)
end


function pruneIsolatedVertices!(g)
    v_remove = Int64[]
    for v in vertices(g)
        if degree(g,v) < 1
            push!(v_remove, v)
        end
    end
    rem_vertices!(g, v_remove)
end


const network_size = 500

rng = MersenneTwister(1)
# Facebook
g = SNAPDatasets.loadsnap(:facebook_combined)
while network_size < length(vertices(g))
    delme = rand(rng, 1:length(vertices(g)))
    rem_vertex!(g, delme)
    pruneIsolatedVertices!(g)
end
plt1 = myplot(g, "Facebook")


# Barabasi
g = barabasi_albert(network_size, 1, seed = 1)
pruneIsolatedVertices!(g)
plt2 = myplot(g, "Barabasi Albert")


# Watts
g = watts_strogatz(network_size, 4, 0.8, seed = rand(rng,Int64))
pruneIsolatedVertices!(g)
plt3 = myplot(g, "Watts Strogatz")

# scalefree

g = static_scale_free(network_size, network_size * 2, 2.5, seed = 1)
pruneIsolatedVertices!(g)
plt4 = myplot(g, "Scale Free Network")


plt = gridstack([plt1 plt2; plt3 plt4])

plt = Gadfly.title(plt, "Different network generators")
saveplot(plt, "allnets.pdf")
