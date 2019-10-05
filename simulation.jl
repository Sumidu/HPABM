using Random
using LightGraphs


# The agent type
 mutable struct OpinionAgent
    # Two personality variables
    extraversion::Float64
    openness::Float64

    cognitive_attitude::Float64
    affective_attitude::Float64

    noticing_threshold::Float64

    posting_threshold::Float64


    # 0 new
    # 1 sending
    # 2 seen, but not sent
    # 3 rejected
    # 4 sent
    state::Int64
end


function hasSeen(agent)
    if agent.state == 2
        return true
    end
    return false
end

function hasRejected(agent)
    if agent.state == 3
        return true
    end
    return false
end

function hasSent(agent)
    if agent.state == 4
        return true
    end
    return false
end

struct OpinionMessage
        cognitive_value::Float64
        affective_value::Float64
end



function generateRandomAgent()
    a = OpinionAgent(0,0,0,0,0,0,0)
    a.extraversion = rand()
    a.openness = rand()
    a.cognitive_attitude = rand()
    a.affective_attitude = rand()
    a.posting_threshold = rand()
    a.noticing_threshold = rand()
    return a
end

function generateRandomMessage()
    a = OpinionMessage(rand(), rand())
    return a
end





function generateNetworkLiMinai(agents, community_count, community_size, ve, a)
    #am ::Array{Int64,2}
    community_list = []

    for i in 1:community_count
        com_g = []
    end


    g = SimpleGraph(agent_count)
end

#g = generateNetworkLiMinai(agents, 40, 4, 3, 0.9)

function generateNetwork(agents)
    agent_count = length(agents)
    edge_count = agent_count * 2
    default_edge_weight = 1
    g = SimpleGraph(agent_count)

    rng = MersenneTwister()
    sp = Random.Sampler(rng, 1:agent_count)
    for i in 1:edge_count
        x = rand(rng, sp)
        y = rand(rng, sp)
        add_edge!(g, x, y)
    end
    return g
end







function message_spread!(agents, source, target, message::OpinionMessage, debug = false)
    if debug
        println("Message from $source to $target with $message")
    end

    s_a = agents[source]
    s_a.state = 4
    t_a = agents[target]

    # noticing?
    if message.affective_value < t_a.noticing_threshold
        t_a.state = 3 # rejected
        return
    end

    # evaluation
    affective_process = sqrt(message.affective_value * t_a.affective_attitude)
    cognitive_process = sqrt(message.cognitive_value * t_a.cognitive_attitude)
    eval = sqrt(affective_process * cognitive_process)

    #resending?
    if eval > t_a.posting_threshold
        t_a.state = 1 # sending
        return
    else
        t_a.state = 2 # seen but not resending
        return
    end

end


function step_model(agents, network, message)
    for agent in shuffle(1:length(agents))
        if agents[agent].state == 1
            for target in LightGraphs.all_neighbors(network, agent)
                message_spread!(agents, agent, target, message)
            end
        end
    end
end

using CSV
# run simulation
function run(agent_count, max_ticks)
    agents = [generateRandomAgent() for i in 1:agent_count]
    g = generateNetwork(agents)

    start_agent = rand(1:agent_count)
    agents[start_agent].state = 1

    mes = generateRandomMessage()

    for i in 1:max_ticks
        step_model(agents, g, mes)
        #println("Tick: $i")
    end
    return (agents,g)
end


Random.seed!(1)
@time (agents, network) = run(1000000, 100)




count(hasSeen, agents)
count(hasRejected, agents)
count(hasSent, agents)

CSV.write("output/agents.csv", agents)
CSV.write("output/edgelist.csv", edges(network))
