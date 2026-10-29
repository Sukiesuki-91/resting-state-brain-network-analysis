# Literature-defined DMN segregation analysis

library(igraph)
library(here)

# 1. Define literature-based DMN core regions
dmn_core_index <- c(
  3, 6, 7, 12, 17, 
  27, 40, 48, 50, 67,
  70, 130, 144, 155, 174
)

# 2. Predefined DMN vs non-DMN modularity

# Community 1: 15 DMN core regions
# Community 2: all remaining 162 regions
dmn_membership <- rep(2, vcount(brain_network))
dmn_membership[dmn_core_index] <- 1

Q_dmn <- modularity(brain_network, membership = dmn_membership, weights = NA)

# 3. Observed internal DMN structure

dmn_subgraph <- induced_subgraph(
  brain_network, 
  vids = dmn_core_index
)

gorder(dmn_subgraph)
gsize(dmn_subgraph)

# Edge density of DMN subgraph
dmn_density <- edge_density(dmn_subgraph)
# Global clustering coefficient of DMN subgraph
dmn_clustering <- transitivity(dmn_subgraph, type = "global")

# 4. Random 15-node groups (benchmark)

set.seed(123)

n_sim <- 1000
Q_random15 <- numeric(n_sim)
density_random <- numeric(n_sim)
clustering_random <- numeric(n_sim)

for (i in 1:n_sim) {
  
  # Randomly select 15 regions
  random_idx <- sample(
    seq_len(vcount(brain_network)),
    size = 15
  )
  
  # ---- Modularity ----
  random_membership <- rep(2, vcount(brain_network))
  random_membership[random_idx] <- 1
  
  Q_random15[i] <- modularity(
    brain_network,
    membership = random_membership,
    weights = NA
  )
  
  # ---- Density & clustering ----
  random_subgraph <- induced_subgraph(
    brain_network,
    vids = random_idx
  )
  
  density_random[i] <- edge_density(random_subgraph)
  
  clustering_random[i] <- transitivity(
    random_subgraph,
    type = "global"
  )
}

# 5. Compare observed DMN with random benchmark

# Modularity
Q_dmn
mean(Q_random15)
sd(Q_random15)

# Edge density 
dmn_density
mean(density_random)
sd(density_random)
# Global clustering 
dmn_clustering
mean(clustering_random)
sd(clustering_random)

# 6. Summary in table and exports

dmn_segregation_summary <- data.frame(
  measure = c(
    "Modularity",
    "Edge density",
    "Global clustering"
  ),
  
  observed = c(
    Q_dmn,
    dmn_density,
    dmn_clustering
  ),
  
  random_mean = c(
    mean(Q_random15),
    mean(density_random),
    mean(clustering_random)
  ),
  
  random_sd = c(
    sd(Q_random15),
    sd(density_random),
    sd(clustering_random)
  )
)

write.csv(
  dmn_segregation_summary,
  here(
    "output",
    "tables",
    "dmn_segregation_summary.csv"
  ),
  row.names = FALSE
)