# Resting-State Brain Network Analysis

## Overview

This repository contains the data and R code used to examine the
topological structure of a resting-state functional brain network,
with a particular focus on small-world organization.

This project was conducted as part of PL4246 Network Analysis at the
National University of Singapore.

## Data

The analysis uses an averaged resting-state functional connectivity
matrix derived from Biswal et al. (2010).

The network contains 177 brain regions. Functional connections were
constructed from the correlation matrix and thresholded before being
converted into an undirected, unweighted network.

## Repository Structure

- `data/raw/`: original input data
- `data/processed/`: processed network objects
- `scripts/`: R scripts used for network construction and analysis
- `output/figures/`: generated figures
- `output/tables/`: generated analysis outputs
- `report/`: project report and related files

## Reproducing the Analysis

1. Download or clone this repository.
2. Open `resting-state-brain-network-analysis.Rproj`.
3. Ensure that the required R packages are installed.
4. Run the scripts in numerical order.

## Required R Packages

- igraph
- here

## Author

Siqi Wang  
National University of Singapore