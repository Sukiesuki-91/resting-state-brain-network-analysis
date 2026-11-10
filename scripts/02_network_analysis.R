# Calculate descriptive statistics for the functional brain network.

library(igraph)

# Basic network characteristics
summary(brain_network)
gorder(brain_network)
gsize(brain_network)

# Average degree
mean(degree(brain_network))

# Average shortest path length (ASPL)
mean_distance(brain_network, directed = FALSE, weights = NA)

# Global clustering coefficient
transitivity(brain_network, type = "global")

# Assortative mixing by degree
assortativity_degree(brain_network, directed = FALSE)

# Components
components(brain_network)$no

# Network diameter
diameter(brain_network)

# Network density
edge_density(brain_network)