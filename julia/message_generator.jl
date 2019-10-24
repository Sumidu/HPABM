## File for generating the messages


# Messages of different valence
struct OpinionMessage
    cognitive_value::Float64
    affective_value::Float64
end




"""
    Generate a random opinion message with cognitive_value from U(0,1)
"""
function generateRandomMessage(rng)
    a = OpinionMessage(rand(rng), rand(rng))
    return a
end


"""
    generates the message used in the Paper
"""
function generateFourTypeMessage(rng)
    message_case = rand(rng, 1:4)

    if message_case == 1
        return OpinionMessage(0.2, 0.8)
    end
    if message_case == 2
        return OpinionMessage(0.8, 0.8)
    end
    if message_case == 3
        return OpinionMessage(0.8, 0.2)
    end
    if message_case == 4
        return OpinionMessage(0.2, 0.2)
    end
end





function generateNormalRandomMessage(rng)
    a = OpinionMessage(randn(rng), randn(rng))
    return a
end
