# Analysis File


using RCall, CSV

df = CSV.read("output/results.csv")

R"library(ggplot2)"
R"ggplot($df) + aes(x = step, y = seen, group = factor(runid)) + geom_line(alpha = 0.1)"
