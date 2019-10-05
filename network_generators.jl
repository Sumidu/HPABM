## This file contains the different network generators
function generateNetworkLiMinai(agents, community_count, community_size, ve, a)
    #am ::Array{Int64,2}
    community_list = []

    for i = 1:community_count
        com_g = []
    end


    g = SimpleGraph(agent_count)
end

#g = generateNetworkLiMinai(agents, 40, 4, 3, 0.9)


# Function to generate  random network.
# edges are drawn from uniform distribution over agents
function generateNetwork(agents, density = 2)
    agent_count = length(agents)
    edge_count = agent_count * density
    g = SimpleGraph(agent_count)

    rng = MersenneTwister()
    sp = Random.Sampler(rng, 1:agent_count)
    for i = 1:edge_count
        x = rand(rng, sp)
        y = rand(rng, sp)
        add_edge!(g, x, y)
    end
    return g
end
