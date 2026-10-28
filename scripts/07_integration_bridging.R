#install.packages ('influenceR')
#install.packages ('spreadr')

library(igraph)
library(here)
library(influenceR)
library(spreadr)

# 1. Compute bridging score for all brain regions

bridge_score <- bridging(brain_network)

# 2. Create node-level bridging table

bridging_data <- data.frame(
  roi_index = seq_len(vcount(brain_network)),
  node = V(brain_network)$name,
  region = long_labels[[1]],
  bridge_score = bridge_score
)

# 3. Rank regions by bridging score
bridging_data <- bridging_data[
  order(-bridging_data$bridge_score),
]

bridging_data$bridge_rank <- seq_len(nrow(bridging_data))

head(bridging_data, 5)

# 4. Identify potential key bridges of this network

degree(brain_network)[c(29, 161, 82, 128, 109)]

# RTP1 has an exceptionally high bridging score but degree = 1.
# Its high score likely reflects the importance of its only edge in
# preventing isolation rather than a genuine cross-network bridging role.
# Therefore, RTP1 is not considered as a spreading-activation seed.

# 5. Spreading activation simulation

spread_index <- c(161, 82, 128, 109)

spread_nodes <- V(brain_network)$name[spread_index]

spread_results <- list()

for (i in seq_along(spread_nodes)) {
  
  start_run <- data.frame(
    node = spread_nodes[i],
    activation = 100
  )
  
  spread_results[[i]] <- spreadr(
    network = brain_network,
    start_run = start_run,
    retention = 0.5,
    decay = 0,
    suppress = 0,
    time = 3,
    include_t0 = TRUE
  )
  
  # Keep track of which region was used as the seed
  spread_results[[i]]$seed <- spread_nodes[i]
}

result <- do.call(
  rbind,
  spread_results
)

# Summarise spreading results
spreading_summary <- result |>
  dplyr::filter(activation > 0) |>
  dplyr::group_by(seed, time) |>
  dplyr::summarise(
    activated_nodes = dplyr::n(),
    .groups = "drop"
  )

write.csv(
  spreading_summary,
  here(
    "output",
    "tables",
    "spreading_activation_summary.csv"
  ),
  row.names = FALSE
)