using Random
using LightGraphs
using CSV
using Logging
using DataFrames
using BenchmarkTools

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
function step_model(rng, agents, network, message)
    for agent in shuffle(rng, 1:length(agents))
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
function run_simulation(rng, agent_count, max_ticks, message_gen; runid::Int64 = 1)

    #TODO: Make more flexible to determine the generators from the arguments
    # This would allow to run batches from determined runs

    df = DataFrame(runid = Int64[],
                    seed = Int32[],
                    stepid = Int64[],
                    new_agents = Int64[],
                    sending = Int64[],
                    seen = Int64[],
                    rejected = Int64[],
                    sent = Int64[]
                     )

    pseudo_seed = Random.rand(rng, Int32)

    agents = [generateRandomAgent(rng) for i = 1:agent_count]
    g = generateNetwork(rng, agents)

    start_agent = rand(rng, 1:agent_count)
    agents[start_agent].state = agent_sending

    mes = message_gen(rng)

    for i = 1:max_ticks
        step_model(rng, agents, g, mes)

        # add to df
        push!(df, Dict(:runid => runid,
                    :seed => pseudo_seed,
                    :stepid => i,
                    :new_agents => count(isNew, agents),
                    :sending => count(isSending, agents),
                    :seen => count(hasSeen, agents),
                    :rejected => count(hasRejected, agents),
                    :sent => count(hasSent, agents)))
        #println("Tick: $i")
    end
    return df
end


function print_progress(i::Int64, max::Int64)
    if i % (max/10) == 0
        @info "Finished slice $(round(10*i/max, digits=2)) of 10 slices"
    end
end


"""
Run the *run* method in
"""
function batchrun(;batches::Int64 = 10, agents::Int64 = 100, steps::Int64 = 25)
    @info "Starting run with $batches batches, $agents agents, $steps steps."

    df = DataFrame()

    Random.seed!(1)


    rngs = [x = Random.MersenneTwister(i) for i in 1:batches]

    #data_store = Array{DataFrames.DataFrame}
    for i in 1:batches
        df_step = run_simulation(rngs[i], agents, steps, generateRandomMessage, runid = i)

        append!(df, df_step)
        print_progress(i, batches)
    end

    return df
end




df = batchrun(batches = 1000, agents = 1000, steps = 25)

df




df[!,:seed]


using RCall

R"library(ggplot2)"
R"ggplot($df) + aes(x = stepid, y = seen, group = factor(runid)) + geom_line(alpha = 0.1)"


#CSV.write("output/agents.csv", agents)
#CSV.write("output/edgelist.csv", edges(network))
