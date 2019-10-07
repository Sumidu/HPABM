using Random
using LightGraphs
using CSV
using Logging
using DataFrames
#using BenchmarkTools

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

    @debug "Message from $source to $target with $message"

    s_a = agents[source]
    s_a.state = agent_sent
    t_a = agents[target]

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


function evaluateMessage(agent, message)
    affective_process = sqrt(message.affective_value * agent.affective_attitude)
    cognitive_process = sqrt(message.cognitive_value * agent.cognitive_attitude)
    eval = sqrt(affective_process * cognitive_process)
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
        length(agents),
        start_agent,
        count(isNew, agents),
        count(isSending, agents),
        count(hasSeen, agents),
        count(hasRejected, agents),
        count(hasSent, agents),
        message.cognitive_value,
        message.affective_value
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
         :agent_count,
         :start_agent,
         :new_agents,
         :sending,
         :seen,
         :rejected,
         :sent,
         :cognitive_value,
         :affective_value
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
    message_gen;
    runid::Int64 = 1,
)

    pseudo_seed = Random.rand(rng, Int32)

    agents = [agent_gen(rng) for i = 1:agent_count]
    network = network_gen(rng = rng, agents = agents)

    start_agent = rand(rng, 1:agent_count)
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




function print_progress(i::Int64, max::Int64)
    if i % (max / 10) == 0
        @info "Finished slice $(Int(round(10*i/max, digits=0))) of 10 slices"
    end
end


"""
Run the *run* method in
"""
function batchrun(
    ;
    batches::Int64 = 10,
    agents = 100:100,
    steps::Int64 = 25,
    agent_generator,
    network_generator,
    message_generator,
)



    rngs = [x = Random.MersenneTwister(i) for i = 1:batches]

    dv = Vector{Tuple}()
    #data_store = Array{DataFrames.DataFrame}
    #Threads.@threads
    Threads.@thread for agent_count in agents
        @info "Starting run with $batches batches, $agent_count agents, $steps steps."
        for i = 1:batches
            dv_step = run_simulation(
                rngs[i],
                agent_count,
                steps,
                agent_generator,
                network_generator,
                message_generator,
                runid = i,
                )

            append!(dv, dv_step)
            print_progress(i, batches)
        end
    end

    return tuple2df(dv)
end



function generateRandomNetwork_d3(; rng, agents)
    return generateRandomNetwork(rng = rng, agents = agents, density = 3)
end


df = batchrun(
    batches = 1000,
    agents = 4039:4039,
    steps = 100,
    agent_generator = generateRandomAgent,
    network_generator = generateFacebook,
    message_generator = generateRandomMessage,
)


@info "Writing file... $(size(df,1)) lines"
CSV.write("output/results.csv", df)
@info "done."

checkstring = Random.randstring(MersenneTwister(abs(df[!, :pseudo_seed][1])))
@info "Result checksum string $checkstring"
