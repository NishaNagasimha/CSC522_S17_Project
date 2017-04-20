setwd("/home/mr/Grive/01.ALDA/Project-Alda/")
# Read the ratings data
data <- read.csv("data/ratings.csv", header = TRUE)
# remove the timestamps
data <- data[, -ncol(data)]


