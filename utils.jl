# Utils files helpful to generate sensible numbers
"""
converts any number to a range of 0..1 by tanh
"""
function nrange(x)
    (tanh(x) + 1) / 2
end
