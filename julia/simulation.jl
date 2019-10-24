#
# This file contains the main simulation
# It contains a simulation method that can be called from
# a batch runner.
#



using Random
using LightGraphs
using CSV
using Logging
using DataFrames
using Dates

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
    message::OpinionMessage
)

    @debug "Message from $source to $target with $message"

    s_a = agents[source]
    s_a.state = agent_sent
    t_a = agents[target]

    if hasSeen(t_a) || hasSent(t_a) || hasRejected(t_a)
        return
    end

    # noticing?
    if message.affective_value < t_a.noticing_threshold
        t_a.state = agent_rejected # rejected
        return
    end

    # evaluation
    eval = evaluateMessage(t_a, message)

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
    The dual process model evaluation function. (not used alternative strat.)
"""
function evaluate2Message(agent, message)
    affective_process = sqrt(message.affective_value * agent.affective_attitude)
    cognitive_process = sqrt(message.cognitive_value * agent.cognitive_attitude)
    eval = sqrt(affective_process * cognitive_process)
    return eval
end

"""
    The dual process model evaluation function.
"""
function evaluateMessage(agent, message)
    affective_process = (message.affective_value + agent.affective_attitude)/2
    cognitive_process = (message.cognitive_value + agent.cognitive_attitude)/2
    eval = sqrt(affective_process * cognitive_process)
    return eval
end

"""
Function to run an individual simulation step
"""
function step_model(rng, agents, network, message)
    for agent in shuffle(rng, 1:length(agents))
        if agents[agent].state == agent_sending
            for target in LightGraphs.all_neighbors(network, agent)
                message_spread!(agents, agent, target, message)
            end
        end
    end
end

function evaluate(runid, pseudo_seed, step, agents, network, start_agent, message)
    return (
        runid,
        pseudo_seed,
        step,
        start_agent,
        count(isNew, agents),
        count(isSending, agents),
        count(hasSeen, agents),
        count(hasRejected, agents),
        count(hasSent, agents),
        message.cognitive_value,
        message.affective_value,
        length(edges(network))
    )
end

function tuple2df(tuple_array)
    res = DataFrame(tuple_array)
    names!(
        res,
        [
         :runid,
         :pseudo_seed,
         :step,
         :start_agent,
         :new_agents,
         :sending,
         :seen,
         :rejected,
         :sent,
         :cognitive_value,
         :affective_value,
         :edge_count
        ],
    )
    return res
end


"""
Function to run the whole simulation using agent_count agents and max_ticks as
a limitation to the simulation length
"""
function run_simulation(
    rng,
    agent_count,
    max_ticks,
    agent_gen,
    network_gen,
    message_gen,
    random_start_agent = false;
    runid::Int64 = 1,
)

    pseudo_seed = Random.rand(rng, Int32)

    #agent_count = 100
    agents = [agent_gen(rng) for i = 1:agent_count]
    # sort all agents by criterion extraversion
    sort!(agents, by = a -> a.extraversion, rev = true )

    # generate network
    network = network_gen(rng = rng, agents = agents)

    # get the permuation ordering of the network by degree centrality
    ordering = sortperm(degree(network), rev = true)

    # apply permuation on agents
    agents = agents[ordering]

    if random_start_agent
        start_agent = rand(rng, 1:agent_count)
    else
        start_agent = findmax(degree(network))[2]
    end
    agents[start_agent].state = agent_sending

    message = message_gen(rng)

    res = Vector{Tuple}()

    for i = 1:max_ticks

        # if no more senders
        if !any(isSending.(agents))
            break;
        end

        step_model(rng, agents, network, message)

        # add to df
        push!(
            res,
            evaluate(runid, pseudo_seed, i, agents, network, start_agent, message),
        )
    end
    return res
end
