using SNAPDatasets


function pruneIsolatedVertices!(g)
    v_remove = Int64[]
    for v in vertices(g)
        if degree(g,v) < 1
            push!(v_remove, v)
        end
    end
    rem_vertices!(g, v_remove)
end

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

function generateStochasticBlockModel(;rng, agents, cluster = 20)
    agent_count = length(agents)
    #rng = MersenneTwister(1)
    #agent_count = 4000

    nsize = agent_count #Int(round(agent_count / cluster))
    cluster = div(nsize, 100)
    minclustersize = 7
    csize = rand(rng, cluster)
    csizesum = sum(csize)
    clustersizes = zeros(Int64, cluster)
    for i in 1:cluster
        clustersizes[i] = minclustersize +
        div((nsize-(minclustersize*cluster)) * csize[i],csizesum) + 1

    end
    clustersizes[1] = max((clustersizes[1] + (nsize - sum(clustersizes))), minclustersize)

    sigma = zeros(Real, cluster, cluster)

    for i in 1:cluster
        for j in i:cluster
            if(i == j)
                #sigma[i,j] = Int(round(min(max_edges * (1-rand(rng)*rand(rng)) + 1, clustersizes[i]))) -1
                sigma[i,j] = clustersizes[i] * rand(rng, 0.01:0.0001:0.05)

            else
                #sigma[i,j] = 0.1*rand(rng) *rand(rng)* min(clustersizes[i], clustersizes[j])
                if rand(rng) < 0.6
                    sigma[i,j] = 0
                else
                    sigma[i,j] = rand(rng, 0:0.0001:0.01)
                end
            end

        end
    end

    println(sigma)
    println(clustersizes)
    g = stochastic_block_model(sigma, clustersizes, seed = rand(rng, Int64))
    @info "created."
    pruneIsolatedVertices!(g)
    g
end

function generateBarabasi(;rng, agents, density = 2)
    agent_count = length(agents)
    #edge_count = Int(round(agent_count * density))
    #rng = MersenneTwister(1)
    #agent_count = 100
    g = barabasi_albert(agent_count, 4, seed = rand(rng, Int64))

    return g
end


function generateWattsStrogatz(;rng, agents, density = 2)
    agent_count = length(agents)
    edge_count = Int(round(agent_count * density))
    # rng = MersenneTwister(1)
    # agent_count = 100
    # edge_count = 200
    # density = 2
    g = watts_strogatz(agent_count, 4, 0.8, seed = rand(rng,Int64))
    return g
end

function generateScaleFree(;rng, agents, density = 2)
    agent_count = length(agents)
    edge_count = Int(round(agent_count * density))
    # rng = MersenneTwister(1)
    # agent_count = 100
    # edge_count = 200
    g = static_scale_free(agent_count, edge_count, 2.5, seed = rand(rng,Int64))
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

function generateRandomNetwork_d3(; rng, agents)
    return generateRandomNetwork(rng = rng, agents = agents, density = 3)
end
