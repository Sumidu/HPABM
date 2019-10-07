### Agent Generators

@enum AgentState agent_new = 0 agent_sending = 1 agent_seen = 2 agent_rejected = 3 agent_sent = 4


# The agent type
mutable struct OpinionAgent
    # Two personality variables
    extraversion::Float64
    openness::Float64

    # latent process model
    cognitive_attitude::Float64
    affective_attitude::Float64

    # Thresholds
    noticing_threshold::Float64
    posting_threshold::Float64

    # Agent state for model
    state::AgentState
end



# Test functions for agent_state
function isNew(agent)
    if agent.state == agent_new
        return true
    end
    return false
end

function isSending(agent)
    if agent.state == agent_sending
        return true
    end
    return false
end


function hasSeen(agent)
    if agent.state == agent_seen
        return true
    end
    return false
end

function hasRejected(agent)
    if agent.state == agent_rejected
        return true
    end
    return false
end

function hasSent(agent)
    if agent.state == agent_sent
        return true
    end
    return false
end



function generateRandomAgent(rng::MersenneTwister)
    a = OpinionAgent(0, 0, 0, 0, 0, 0, agent_new)
    a.extraversion = rand(rng)
    a.openness = rand(rng)
    a.cognitive_attitude = rand(rng)
    a.affective_attitude = rand(rng)
    a.posting_threshold = rand(rng)
    a.noticing_threshold = rand(rng)
    return a
end

function generateNormalRandomAgent(rng::MersenneTwister)
    a = OpinionAgent(0, 0, 0, 0, 0, 0, agent_new)
    a.extraversion = randn(rng)
    a.openness = randn(rng)
    a.cognitive_attitude = randn(rng)
    a.affective_attitude = randn(rng)
    a.posting_threshold = randn(rng)
    a.noticing_threshold = randn(rng)
    return a
end
