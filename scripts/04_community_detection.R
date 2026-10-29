# Community detection
library(igraph)
library(here)

set.seed(123)

# 1. Primary community detection: Louvain
brain_louvain <- cluster_louvain(brain_network, weights = NA)

# 2. Evaluate detected community structure 
modularity(brain_louvain)
length(brain_louvain)
sizes(brain_louvain)

# 3. Create community membership table
community_table <- data.frame(
  roi_index = seq_len(vcount(brain_network)),
  node = V(brain_network)$name,
  region = long_labels[[1]],
  community = membership(brain_louvain)
) |>
  dplyr::arrange(community, roi_index)

View(community_table)

# 4. Community size summary
community_summary <- community_table |>
  dplyr::count(community, name = "n_nodes")

community_summary

# 5. Export results
write.csv(
  community_table,
  here("output", "tables", "louvain_community_membership.csv"),
  row.names = FALSE
)

write.csv(
  community_summary,
  here("output", "tables", "louvain_community_summary.csv"),
  row.names = FALSE
)

# 6. Sensitivity check using alternative community detection methods
brain_edge <- cluster_edge_betweenness(brain_network, weights = NA)
brain_walktrap <- cluster_walktrap(brain_network, weights = NA)
brain_infomap <- cluster_infomap(brain_network)

modularity(brain_edge)
modularity(brain_walktrap)
modularity(brain_infomap)
