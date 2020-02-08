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

"""
    function to create a usabe plot of networks
"""
function myplot(g, title = "Title"; nodesize_multiplier = 2)
    nodesize = [log(degree(g, v)+3)/10 for v in vertices(g)]
    nodefillc = [RGBA(0.1,0.1,0.1, 0.66) for v in vertices(g)]
    plt = gplot(g, nodesize = nodesize * nodesize_multiplier, nodefillc = nodefillc)
    plt = Gadfly.title(plt, title)
    plt
end

"""
    saves the plot to a pdf file using Cairo
"""
function saveplot(plt, filename = "networkplot.pdf")
    draw(PDF(joinpath("output/", filename), 12cm, 12cm), plt)
end


"""
    remove isolated vertices for nice printing
"""
function pruneIsolatedVertices!(g)
    v_remove = Int64[]
    for v in vertices(g)
        if degree(g,v) < 1
            push!(v_remove, v)
        end
    end
    rem_vertices!(g, v_remove)
end


const network_size = 1000

# use a single random number generator to ensure all figures look the same
rng = MersenneTwister(1)

#-----------------
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
plt2 = myplot(g, "Barábasi Albert")


# Watts
g = watts_strogatz(network_size, 4, 0.8, seed = rand(rng,Int64))
pruneIsolatedVertices!(g)
plt3 = myplot(g, "Watts Strogatz")

# scalefree

g = static_scale_free(network_size, network_size * 30, 2.1, seed = 1)
pruneIsolatedVertices!(g)
plt4 = myplot(g, "Scale Free Network")

# stochastic blockmodel (2 types)

nsize = Int(round(network_size / 3))

g = stochastic_block_model([10 2 0.1; 1 10 0.1; 1 1 10], repeat([nsize], 3))
plt5 = myplot(g, "Stochastic Block Model (3 Blocks)")
saveplot(plt5, "sbm.pdf")

# Create a grid plot
plt = gridstack([plt1 plt2; plt3 plt4; plt5 plt5])
plt = Gadfly.title(plt, "Different network generators")

saveplot(plt, "allnets.pdf")
