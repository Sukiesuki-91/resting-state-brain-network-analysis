------------------------------------------------------------------------

# Resting-State Brain Network Analysis

## Required R Packages

The complete package list for the main analysis (`scripts/01`–`07`) is declared below so that the marker can check their R installation before running any code. Run this setup block before the numbered scripts:

``` r
library(igraph)     # Graph construction, network metrics, and communities
library(here)       # Paths relative to the project root
library(dplyr)      # Table manipulation and activation summaries
library(spreadr)    # Spreading-activation simulations
library(ggplot2)    # Figures
library(patchwork)  # Combine anatomical views
```

The optional `scripts/unused_integration_bridging.R` additionally requires `influenceR`; it is not needed to reproduce the main analysis. Base R functions do not require additional package installation. Installation commands appear under **Reproducing the Analysis**.

## Overview

This repository contains the data and R code used to examine the topology, community structure, and default mode network (DMN) segregation and integration of a resting-state functional brain network.

The analysis covers basic network characteristics, small-world organization, Louvain community detection, comparisons between a predefined DMN core and random node groups, and spreading activation from the DMN.

This project was conducted as part of final project for PL4246 Networks in Psychology at the National University of Singapore.

## Data and Network Construction

The analysis uses an averaged resting-state functional connectivity matrix derived from Biswal et al. (2010), covering 177 brain regions. Input files in `data/raw/` are:

- `AveragedMatrix.txt`: functional connectivity matrix.
- `region_names_abbrev_file.txt`: abbreviated region labels.
- `region_names_full_file.txt`: full region labels.
- `F1000-MNI-rest2vec-coordinates.csv`: MNI coordinates used for anatomical plots.

The construction script takes the absolute value of correlations, retains values at or above the fixed threshold of **0.174** (approximately the strongest 20% of matrix entries), and binarizes retained connections. The resulting graph is undirected and unweighted, with self-loops excluded. Positive and negative correlations are therefore treated alike based on their magnitude.

## Repository Structure

- `data/raw/`: input connectivity matrix, region labels, and coordinates.
- `scripts/`: numbered analysis scripts and an unused exploratory script.
- `output/figures/`: exported PNG figures.
- `output/tables/`: exported CSV analysis summaries and community assignments.
- `reference/`: reference materials and original example code.
- `resting-state-brain-network-analysis.Rproj`: RStudio project file.

The four raw inputs and the seven numbered scripts required for the main workflow are included, together with exported tables and figures. The final written report is not currently included in this repository.

`reference/dataset2.R` preserves the original preprocessing example, and `reference/dataset2.pdf` is the accompanying dataset reference material. These are supplementary resources, not additional workflow steps. The example script uses paths from its original context; use `scripts/01_network_construction.R` for this project's input paths.

## Analysis Workflow

| Script | Analysis |
|------------------------------------|------------------------------------|
| `01_network_construction.R` | Load and threshold the connectivity matrix, attach region labels, and construct `brain_network`. |
| `02_network_analysis.R` | Compute node and edge counts, mean degree, average shortest path length, global clustering, degree assortativity, connected components, diameter, and density. |
| `03_small_world_analysis.R` | Compare observed clustering and path length with 100 random graphs matched on node and edge counts, and calculate the small-world index. |
| `04_community_detection.R` | Detect Louvain communities, export membership and size tables, and compare modularity with edge-betweenness, Walktrap, and Infomap solutions. |
| `05_dmn_segregation.R` | Evaluate the predefined DMN-versus-rest partition and internal DMN density and clustering against 1,000 random 15-node groups. |
| `06_integration_dmn.R` | Simulate collective spreading activation from the DMN over 10 time steps and export cumulative reach and its plot. |
| `07_visualisation.R` | Plot Louvain communities in axial, sagittal, and coronal MNI projections, and highlight DMN core regions in an axial view. |

### Script Inputs and Package Dependencies

Number prefixes specify execution order; the remaining filename describes the analysis. These scripts share objects in one R session and are not standalone. The table lists direct package dependencies, including packages called through `package::function()`.

| Script | Required prior objects or files | Packages used |
|------------------------|------------------------|------------------------|
| `01_network_construction.R` | Connectivity matrix and two label files in `data/raw/` | `igraph` |
| `02_network_analysis.R` | `brain_network` from `01` | `igraph` |
| `03_small_world_analysis.R` | `brain_network` from `01` | `igraph` |
| `04_community_detection.R` | `brain_network` and `long_labels` from `01` | `igraph`, `here`, `dplyr` |
| `05_dmn_segregation.R` | `brain_network` from `01` | `igraph`, `here` |
| `06_integration_dmn.R` | `brain_network` from `01`; `dmn_core_index` from `05` | `igraph`, `here`, `dplyr`, `spreadr`, `ggplot2` |
| `07_visualisation.R` | `brain_network` from `01`; `brain_louvain` from `04`; coordinate CSV | `igraph`, `here`, `ggplot2`, `dplyr`, `patchwork` |
| `unused_integration_bridging.R` (optional) | `brain_network` and `long_labels` from `01` | `igraph`, `here`, `influenceR`, `spreadr`, `dplyr` |

The small-world index is calculated as `SWI = (C_observed / C_random) / (L_observed / L_random)`, using global clustering and average shortest path length. The random graphs are sampled with `sample_gnm()` and match the observed graph's node and edge counts, rather than its degree sequence.

### DMN Segregation and Integration

The scripts define a literature-based DMN core using 15 one-based ROI indices:

``` r
c(3, 6, 7, 12, 17, 27, 40, 48, 50, 67, 70, 130, 144, 155, 174)
```

This predefined core is separate from the data-driven Louvain communities. Segregation is assessed using modularity for a two-group partition (15 DMN regions versus the remaining 162 regions), plus density and global clustering within the DMN subgraph. The exported summary reports observed values and the means and standard deviations from random groups.

For integration, all 15 DMN regions form a single seed set with total initial activation of 100, distributed equally. The `spreadr` simulation uses retention of 0.5, decay of 0, suppression of 0, and 10 time steps, including time zero in its raw results. A node is counted as reached once its activation meets or exceeds 1% of the initial activation per seed (`(100 / 15) * 0.01`). The exported cumulative counts cover steps 1–10 and include seed nodes reached at time zero.

`scripts/unused_integration_bridging.R` contains an exploratory bridging-score and individual-seed spreading analysis. It is not part of the numbered workflow and additionally requires `influenceR`.

## Reproducing the Analysis

Use **R 4.1 or later**, as the scripts use the native pipe operator (`|>`).

1.  Download or clone this repository and open `resting-state-brain-network-analysis.Rproj` in RStudio.

2.  Install the required packages:

    ``` r
    install.packages(c("igraph", "here", "dplyr", "spreadr", "ggplot2", "patchwork"))
    ```

3.  Start a fresh R session with the repository root as the working directory. Do not restore a saved `.RData` workspace: the scripts should create their own objects from the supplied inputs. Run the package setup block at the beginning of this README, then ensure the output directories exist:

    ``` r
    dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)
    dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)
    ```

4.  Run scripts `01` through `07` in numerical order **in the same R session**. Later scripts reuse objects created by earlier scripts, including `brain_network`, `long_labels`, `brain_louvain`, and `dmn_core_index`. Run interactively in RStudio to inspect console results, plots, and the `View(community_table)` call in script `04`.

Scripts `03`, `04`, and `05` set the random seed to 123. Package versions are not pinned, so exact results may vary across software versions. Running the workflow again overwrites its exported files.

To inspect the software environment used for a run, execute `sessionInfo()` after completing the workflow. To run the optional exploratory analysis, install `influenceR` separately with `install.packages("influenceR")`; it exports `output/tables/spreading_activation_summary.csv`, which is not a main-workflow output.

## Generated Outputs

| Location | File | Contents |
|------------------------|------------------------|------------------------|
| `output/tables/` | `louvain_community_membership.csv` | ROI indices, abbreviated and full region labels, and Louvain community assignments. |
| `output/tables/` | `louvain_community_summary.csv` | Number of nodes in each Louvain community. |
| `output/tables/` | `dmn_segregation_summary.csv` | Observed DMN measures and random-group means and standard deviations. |
| `output/tables/` | `dmn_collective_spreading.csv` | Cumulative nodes reached at each of the 10 time steps. |
| `output/figures/` | `dmn_collective_spreading.png` | Cumulative reach of activation seeded collectively from the DMN. |
| `output/figures/` | `louvain_community_anatomical_distribution.png` | Anatomical distribution of communities in three MNI projections. |
| `output/figures/` | `dmn_core_louvain_communities.png` | DMN core regions coloured by Louvain community in an axial projection. |

Basic network statistics, the small-world index, and alternative-method modularity values are inspected in R and are not automatically exported.

## Author

Siqi Wang\
National University of Singapore
