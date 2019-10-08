# This is a demo configuration helpful in testing the procedure
# It should run very fast, as only small networks are generated
batches = 10
agent_range = [100]
step = 15
agent_generators = [generateRandomAgent, generatePersonalityAgent]
network_generators = [generateRandomNetwork, generateBarabasi, generateScaleFree, generateWattsStrogatz, generateFacebook]
message_generators = [generateFourTypeMessage,]
