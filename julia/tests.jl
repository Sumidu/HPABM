# Test file for the individual functions
using Random
using LightGraphs
using CSV
using Logging
using BenchmarkTools

include("network_generators.jl")
include("agent_generators.jl")
include("message_generator.jl")


using GraphPlot
using SNAPDatasets

g = barabasi_albert(100, 1)

g2 = watts_strogatz(100, 50, 0.1)

gplot(g)


g = static_scale_free(100, 200, 2.4, seed = 2)

gplot(g)


g = SNAPDatasets.loadsnap(:facebook_combined)


g = SNAPDatasets.loadsnap(:ego_twitter_u)
gplot(g)
