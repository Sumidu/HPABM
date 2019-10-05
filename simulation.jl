using Random
using LightGraphs
using CSV

include("network_generators.jl")
include("agent_generators.jl")
include("message_generator.jl")


"""
This function determines message spreading.
...
# Arguments
- `agents::Array{OpinionAgent}`: Array containting the agents.
...
"""
function message_spread!(
    agents,
    source,
    target,
    message::OpinionMessage,
    debug = false,
)
    if debug
        println("Message from $source to $target with $message")
    end

    s_a = agents[source]
    s_a.state = agent_sent
    t_a = agents[target]

    # noticing?
    if message.affective_value < t_a.noticing_threshold
        t_a.state = agent_rejected # rejected
        return
    end

    # evaluation
    affective_process = sqrt(message.affective_value * t_a.affective_attitude)
    cognitive_process = sqrt(message.cognitive_value * t_a.cognitive_attitude)
    eval = sqrt(affective_process * cognitive_process)

    #resending?
    if eval > t_a.posting_threshold
        t_a.state = agent_sending # sending
        return
    else
        t_a.state = agent_seen # seen but not resending
        return
    end

end



"""
Function to run an individual simulation step
"""
function step_model(agents, network, message)
    for agent in shuffle(1:length(agents))
        if agents[agent].state == agent_sending
            for target in LightGraphs.all_neighbors(network, agent)
                message_spread!(agents, agent, target, message)
            end
        end
    end
end


"""
Function to run the whole simulation using agent_count agents and max_ticks as
a limitation to the simulation length
"""
function run(agent_count, max_ticks, message_gen)

    #TODO: Make more flexible to determine the generators from the arguments
    # This would allow to run batches from determined runs

    agents = [generateRandomAgent() for i = 1:agent_count]
    g = generateNetwork(agents)

    start_agent = rand(1:agent_count)
    agents[start_agent].state = agent_sending

    mes = message_gen()

    for i = 1:max_ticks
        step_model(agents, g, mes)
        #println("Tick: $i")
    end
    return (agents, g)
end



"""
Run the *run* method in
"""
function batchrun()
end


Random.seed!(1)
@time (agents, network) = run(10^3, 100, generateRandomMessage)




count(hasSeen, agents)
count(hasRejected, agents)
count(hasSent, agents)

CSV.write("output/agents.csv", agents)
CSV.write("output/edgelist.csv", edges(network))
