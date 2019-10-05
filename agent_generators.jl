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



function generateRandomAgent()
    a = OpinionAgent(0, 0, 0, 0, 0, 0, agent_new)
    a.extraversion = rand()
    a.openness = rand()
    a.cognitive_attitude = rand()
    a.affective_attitude = rand()
    a.posting_threshold = rand()
    a.noticing_threshold = rand()
    return a
end
