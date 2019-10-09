# Analysis File


using RCall, CSV
using DataFrames, DataFramesMeta

df = CSV.read("output/results.csv")

num_runs = df[!,:runid][size(df)[1]]
@info "Read $num_runs batches"

alpha_value = min(500/num_runs, 1)
R"library(tidyverse)"

R"ggplot($df) + aes(x = step, y = seen/agent_count, group = factor(runid), color = affective_value) + geom_line(alpha = $alpha_value)"


using Gadfly

Gadfly.with_theme(:dark) do
    plot(df, x=:step, y=:seen, color=:runid)
end


plot([sin],0,20)

using Compose

using Gadfly
function Gadfly.show(io::IO, m::MIME"application/prs.juno.plotpane+html", p::Plot)
    buf = IOBuffer()
    svg = SVGJS(buf, Compose.default_graphic_width,
                Compose.default_graphic_height, false)
    draw(svg, p)
    show(io, "text/html", svg)
end
