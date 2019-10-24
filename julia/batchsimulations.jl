#
#   This is the main simulation runner
#
#   This file gets all simulation functions from the simulation.jl
#   The configuration is loaded by a configfile.jl

include("simulation.jl")
import Slacker

"""
    reports a progess output
"""
function print_progress(i::Int64, max::Int64)
    if i % (max / 10) == 0
        rightnow = Dates.Time(Dates.now())
        @info "Finished slice $(Int(round(10*i/max, digits=0))) of 10 slices"
        @debug "$rightnow"
    end
end

"""
Run the *run* method in
"""
function batchrun(
    ;
    batches::Int64 = 10,
    agent_count::Int64 = 100,
    steps::Int64 = 25,
    agent_generator,
    network_generator,
    message_generator,
)

    # generate a different RNG for each batch (used for parallelization)
    rngs = [x = Random.MersenneTwister(i) for i = 1:batches]

    dv = Vector{Tuple}()
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

    return tuple2df(dv)
end





## Here the configuration is loaded that determines the runconfiguration
include("config_haapie.jl") # this is the actual study configuration
#include("config_demo.jl") # this is a demo configuration that runs quickly

# Create full factorial design
config = [(b, a, s, ag, ng, mg) for b in batches, a in agent_range, s in step, ag in agent_generators, ng in network_generators, mg in message_generators]

@info "This configuration creates $(length(config)) different settings."

# start new output
df = DataFrame()

# run each configuration
start_time = time()
for conf in config
    @info "Running config $conf"
    @time df1 = batchrun(
        batches = conf[1],
        agent_count = conf[2],
        steps = conf[3],
        agent_generator = conf[4],
        network_generator = conf[5],
        message_generator = conf[6],
    )
    rows = nrow(df1)
    #df2 = DataFrame(config = [splat_config(conf) for i in 1:rows])
    df2 = DataFrame(
        batches = [conf[1] for i in 1:rows],
        agent_count = [conf[2] for i in 1:rows],
        steps = [conf[3] for i in 1:rows],
        agent_generator = [string(conf[4]) for i in 1:rows],
        network_generator = [string(conf[5]) for i in 1:rows],
        message_generator = [string(conf[6]) for i in 1:rows])
    df1 = hcat(df1, df2)
    append!(df, df1)
end
total_runtime = time() - start_time

# Write the output to a csv file for later use
@info "Writing file... $(size(df,1)) lines"
fn_out = joinpath("output", "results.csv")
CSV.write(fn_out, df)
@info "done."

ms = Dates.Millisecond(Int(round(total_runtime * 1000)))
rt = Dates.canonicalize(Dates.CompoundPeriod(ms))

# generate a finished message
message = "The $(length(config)) simulations on $(gethostname()) have completed in $rt."


# has slack been configured?

if Slacker.hasConfig()
    Slacker.sendMessage(message)
else
    @info message
end
