# Visualise Louvain communities and the predefined DMN core anatomically.
# install.packages("patchwork")

library(igraph)
library(here)
library(ggplot2)
library(dplyr)
library(patchwork)

# community visualisation
coords <- read.csv(
  here(
    "data",
    "raw",
    "F1000-MNI-rest2vec-coordinates.csv"
  )
)
# Convert 0-based index to 1-based ROI index
coords$roi_index <- coords$X + 1

community_coords <- data.frame(
  roi_index = seq_len(vcount(brain_network)),
  node = V(brain_network)$name,
  region = long_labels[[1]],
  community = membership(brain_louvain)
)

community_coords <- merge(
  community_coords,
  coords[, c(
    "roi_index",
    "hemi",
    "mni_x",
    "mni_y",
    "mni_z"
  )],
  by = "roi_index"
)

community_coords$community <- factor(
  community_coords$community
)

# Axial view
p_axial <- ggplot(
  community_coords,
  aes(
    x = mni_x,
    y = mni_y,
    colour = community
  )
) +
  geom_point(
    size = 3,
    alpha = 0.8
  ) +
  coord_fixed() +
  theme_minimal() +
  labs(
    title = "Axial view",
    x = "Left ← MNI x → Right",
    y = "Posterior ← MNI y → Anterior",
    colour = "Community"
  ) +
  theme(
    panel.grid.minor = element_blank()
  )

p_axial

# Sagittal view
p_sagittal <- ggplot(
  community_coords,
  aes(
    x = mni_y,
    y = mni_z,
    colour = community
  )
) +
  geom_point(
    size = 3,
    alpha = 0.8
  ) +
  coord_fixed() +
  theme_minimal() +
  labs(
    title = "Sagittal view",
    x = "Posterior ← MNI y → Anterior",
    y = "Inferior ← MNI z → Superior",
    colour = "Community"
  ) +
  theme(
    panel.grid.minor = element_blank()
  )

p_sagittal

# Coronal view
p_coronal <- ggplot(
  community_coords,
  aes(
    x = mni_x,
    y = mni_z,
    colour = community
  )
) +
  geom_point(
    size = 3,
    alpha = 0.8
  ) +
  coord_fixed() +
  theme_minimal() +
  labs(
    title = "Coronal view",
    x = "Left ← MNI x → Right",
    y = "Inferior ← MNI z → Superior",
    colour = "Community"
  ) +
  theme(
    panel.grid.minor = element_blank()
  )

p_coronal

# Combine three views and export
community_plot <-
  p_axial +
  p_sagittal +
  p_coronal +
  plot_layout(guides = "collect") +
  plot_annotation(
    title = "Anatomical distribution of Louvain communities"
  )

community_plot

ggsave(
  here(
    "output",
    "figures",
    "louvain_community_anatomical_distribution.png"
  ),
  community_plot,
  width = 15,
  height = 5,
  dpi = 300
)

# Highlight DMN core graph
dmn_core_index <- c(
  3, 6, 7, 12, 17,
  27, 40, 48, 50, 67,
  70, 130, 144, 155, 174
)

community_coords <- community_coords |>
  mutate(
    dmn_status = ifelse(
      roi_index %in% dmn_core_index,
      "DMN core",
      "Other"
    )
  )

# in axial view
p_dmn <- ggplot() +
  
  # All other brain regions in background
  geom_point(
    data = community_coords |>
      filter(dmn_status == "Other"),
    aes(
      x = mni_x,
      y = mni_y
    ),
    colour = "grey80",
    size = 2,
    alpha = 0.5
  ) +
  
  # Highlight DMN core, coloured by Louvain community
  geom_point(
    data = community_coords |>
      filter(dmn_status == "DMN core"),
    aes(
      x = mni_x,
      y = mni_y,
      colour = community
    ),
    size = 5
  ) +
  
  coord_fixed() +
  
  theme_minimal() +
  
  labs(
    title = "Core DMN regions across Louvain communities",
    subtitle = "Axial projection in MNI space",
    x = "Left ← MNI x → Right",
    y = "Posterior ← MNI y → Anterior",
    colour = "Community"
  )

p_dmn

ggsave(
  here(
    "output",
    "figures",
    "dmn_core_louvain_communities.png"
  ),
  plot = p_dmn,
  width = 8,
  height = 7,
  dpi = 300
)