# load the brain connectivity matrix and labels 
matrix <- read.delim('data/raw/AveragedMatrix.txt', header = FALSE, sep = ' ')
short_labels <- read.delim('data/raw/region_names_abbrev_file.txt', header = FALSE)
long_labels <- read.delim('data/raw/region_names_full_file.txt', header = FALSE)

# pre-process the matrix for network analysis

# 1. negative correlations are absolutized 
# here we only focus strength/magnitude of correlation instead of direction
matrix <- abs(matrix)

# 2. thresholding of edges (to keep only the strongest edges)

# this shows you quartiles of the correlations in the matrix 
quantile(c(as.matrix(matrix)), probs = seq(0, 1, 0.1)) # if you want more fine-grained quartiles change 0.1 to 0.05

matrix[matrix < 0.174] <- 0 # here we force all values less than 0.174 to be 0 (i.e., only keeping the top 20%)

# 3. create an unweighted, undirected matrix

matrix[matrix > 0] <- 1 # any positive values are converted to 1 

# final clean up 
matrix <- as.matrix(matrix)
colnames(matrix) <- short_labels$V1 # add node labels 
rownames(matrix) <- short_labels$V1 # add node labels 

# you should be able to now convert the "matrix" object into a network object

# notice you have options here: 
# you can choose a different threshold for the edges (2.)
# you can decide to analyze a weighted or unweighted network (by skipping line 20, 3.)

# the short labels can be cross-referenced with the long labels for further interpretation.
merged <- data.frame(short_label = short_labels$V1, long_label = long_labels$V1)
head(merged)