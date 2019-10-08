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

function myplot(g, filename = "networkplot.pdf"; nodesize_multiplier = 2)
    nodesize = [log(degree(g, v)+3)/10 for v in vertices(g)]
    nodefillc = [RGBA(0.1,0.1,0.1, 0.66) for v in vertices(g)]
    plt = gplot(g, nodesize = nodesize * nodesize_multiplier, nodefillc = nodefillc)
    draw(PDF("output/" * filename, 8cm, 8cm), plt)
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
myplot(g, "facebook.pdf")


# Barabasi
g = barabasi_albert(network_size, 1, seed = 1)
pruneIsolatedVertices!(g)
myplot(g, "barabasi_albert.pdf")


# Watts
g = watts_strogatz(network_size, 4, 0.8, seed = rand(rng,Int64))
pruneIsolatedVertices!(g)
myplot(g, "watts_strogatz.pdf")

# scalefree

g = static_scale_free(network_size, network_size * 2, 2.5, seed = 1)
pruneIsolatedVertices!(g)
myplot(g, "scale_free.pdf")
