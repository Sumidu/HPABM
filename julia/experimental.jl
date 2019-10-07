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




function getTuple()
    return ("asd", 123, "123")
end


getTuple()

a = Vector{Tuple}()

a[1] = getTuple()
push!(a, (123,123,123))
t = getTuple()
push!(a, t)

d = DataFrame(a)
names!(d, [:a, :b, :c])


using Statistics

test = [x = randn() for i in 1:100]

test


function nrange(x)
    (tanh(x) + 1) / 2
end



function testRangeRun(range)
    for i in range
        println(i)
    end
end

testRangeRun(2:2)
