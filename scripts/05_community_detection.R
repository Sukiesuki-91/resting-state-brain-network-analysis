# Use Louvain Method to Detect Community
library(igraph)

set.seed(1)

brain_louvain <- cluster_louvain(brain_network, weights = NA)

# 1. membership of nodes in each community
data.frame(node = V(brain_network)$name, community = brain_louvain$membership) |>
  head(5)

# 2. distribution of nodes across communities
table(brain_louvain$membership)

# 3. modularity of the network
modularity(brain_louvain)