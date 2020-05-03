batches = 1000
agent_range = [1000, 2000, 4039]
step = 100
agent_generators = [generateRandomAgent, generatePersonalityAgent]
network_generators = [generateRandomNetwork, generateBarabasi, generateScaleFree,
    generateWattsStrogatz, generateFacebook, generateStochasticBlockModel]
message_generators = [generateFourTypeMessage,]
