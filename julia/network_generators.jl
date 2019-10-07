using SNAPDatasets


## This file contains the different network generators
function generateNetworkLiMinai(agents, community_count, community_size, ve, a)
    #am ::Array{Int64,2}
    community_list = []

    for i = 1:community_count
        com_g = []
    end

    # fail reimplement soon
    g = SimpleGraph(agent_count)
    @error "Not implemented yet"
end



function generateBarabasi(;rng, agents, density = 2)
    agent_count = length(agents)
    #edge_count = Int(round(agent_count * density))
    #rng = MersenneTwister(1)
    #agent_count = 100
    g = barabasi_albert(agent_count, 1, seed = rand(rng, Int64))

    return g
end

function generateFacebook(;rng, agents)
    agent_count = length(agents)
    #agent_count = 4039
    g = SNAPDatasets.loadsnap(:facebook_combined)
    verts = length(vertices(g))
    if agent_count > verts
        @error "Too many agents for Facebook Generator (max. $verts)"
    end


    while agent_count < length(vertices(g))
        delme = rand(rng, 1:length(vertices(g)))
        rem_vertex!(g, delme)
    end

    return g
end


# Function to generate  random network.
# edges are drawn from uniform distribution over agents
function generateRandomNetwork(;rng, agents, density = 2)
    agent_count = length(agents)
    edge_count = Int(round(agent_count * density))
    g = SimpleGraph(agent_count)

    sp = Random.Sampler(rng, 1:agent_count)
    for i = 1:edge_count
        x = rand(rng, sp)
        y = rand(rng, sp)
        add_edge!(g, x, y)
    end
    return g
end
