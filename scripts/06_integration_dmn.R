# DMN spread-activation simulation (integration)

library(igraph)
library(here)
library(spreadr)

dmn_nodes <- V(brain_network)$name[dmn_core_index]

# Treat the whole DMN as one seed set,
# while keeping total initial activation = 100
start_run_dmn <- data.frame(
  node = dmn_nodes,
  activation = rep(100 / length(dmn_nodes), length(dmn_nodes))
)

dmn_spread <- spreadr(
  network = brain_network,
  start_run = start_run_dmn,
  retention = 0.5,
  decay = 0,
  suppress = 0,
  time = 10,
  include_t0 = TRUE
)

# Threshold = 1% of the initial activation per seed node (100/15)
activation_threshold <- (100 / length(dmn_nodes)) * 0.01

dmn_threshold_hits <- dmn_spread |>
  dplyr::filter(activation >= activation_threshold) |>
  dplyr::group_by(node) |>
  dplyr::summarise(
    first_time = min(as.numeric(time)),
    .groups = "drop"
  )

dmn_cumulative <- data.frame(
  time = 1:10,
  cumulative_nodes_reached = sapply(
    1:10,
    function(t) sum(dmn_threshold_hits$first_time <= t)
  )
)

print(dmn_cumulative)

write.csv(
  dmn_cumulative,
  here(
    "output",
    "tables",
    "dmn_collective_spreading.csv"
  ),
  row.names = FALSE
)

# Trend in cumulative spreading activation from the DMN
library(ggplot2)

p_spread <- ggplot(
  dmn_cumulative,
  aes(x = time, y = cumulative_nodes_reached)
) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  geom_hline(
    yintercept = 177,
    linetype = "dashed"
  ) +
  scale_x_continuous(
    breaks = 1:10
  ) +
  scale_y_continuous(
    limits = c(0, 177),
    breaks = seq(0, 177, by = 25)
  ) +
  labs(
    x = "Time step",
    y = "Cumulative nodes reached"
  ) +
  theme_classic(base_size = 12)

print(p_spread)

ggsave(
  here(
    "output",
    "figures",
    "dmn_collective_spreading.png"
  ),
  plot = p_spread,
  width = 6,
  height = 4,
  dpi = 300
)