# This is a file were I test stuff!
# not part of the project
# but part for learning


using Distributions
using Random
d2 = MvNormal([0.;0.],
              [1. 0.4;0.4 1.])


x = rand(d2,1000)


using Statistics

cor(x[1,:], x[2, :])
