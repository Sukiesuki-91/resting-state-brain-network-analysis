# Function to compute Small World Index (SWI)

compute_swi <- function(graph){
  nodes <- length(V(graph))
  edges_count <- length(E(graph))
  
  # Observed metrics
  Cobs <- mean(igraph::transitivity(graph, type = "global")) #use global C
  Lobs <- mean_distance(graph, directed = FALSE)
  
  # Simulations (how many random graphs to generate)
  sims = 100
  
  # Output buffer
  output <- matrix(0, nrow = sims, ncol = 2)
  
  # Run simulations
  for (i in 1:sims){
    # Make random graph
    bufg <- sample_gnm (nodes, edges_count, directed = FALSE, loops = FALSE)
    # Get metrics
    output[i,1] <- transitivity(bufg, type = "global")
    output[i,2] <- mean_distance(bufg, directed = FALSE)
  }
  
  # Find mean for each measure from simulations
  crand <- mean(output[,1])
  lrand <- mean(output[,2])
  
  # Compute Small World Index
  SWI = (Cobs / Lobs) / (crand / lrand)
  
  # Return values
  return(c(Cobs, Lobs, crand, lrand, SWI))
}

# Check for brain network's SWI
set.seed(123)
compute_swi(brain_network)
# SWI is 2.22
