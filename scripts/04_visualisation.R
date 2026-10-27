# Visualisation

library(igraph)

#shortest path
distance_matrix <- distances(brain_network, weights = NA)
brain_paths <- distance_matrix[lower.tri(distance_matrix)]
hist(brain_paths, main = 'functional brain network')