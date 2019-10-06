## File for generating the messages


# Messages of different valence
struct OpinionMessage
    cognitive_value::Float64
    affective_value::Float64
end





function generateRandomMessage(rng)
    a = OpinionMessage(rand(rng), rand(rng))
    return a
end
