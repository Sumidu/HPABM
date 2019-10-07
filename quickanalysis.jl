# Analysis File


using RCall, CSV
using DataFrames, DataFramesMeta

df = CSV.read("output/results.csv")

num_runs = df[!,:runid][size(df)[1]]
@info "Read $num_runs batches"

alpha_value = min(500/num_runs, 1)
R"library(tidyverse)"

R"ggplot($df) + aes(x = step, y = seen/agent_count, group = factor(runid), color = affective_value) + geom_line(alpha = $alpha_value)"
