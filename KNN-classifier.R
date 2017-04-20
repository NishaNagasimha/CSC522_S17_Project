setwd("/home/mr/Grive/01.ALDA/Project-Alda/")
library("reshape2")
set.seed(123)
# Read the ratings data
data <- read.csv("data/ratings.csv", header = TRUE)
# remove the timestamps
data <- data[, -ncol(data)]

trainIdx <- sample(1:nrow(data), size = 0.6*nrow(data))
trainData <- data[trainIdx, ]
trainData <- acast(trainData, userId ~ movieId)
trainData <- as.matrix(trainData)

testData <- data[-trainIdx, ]

trainData_k <- data[trainIdx, ]

casted_data <- acast(data, userId ~ movieId)
casted_data <- as.matrix(casted_data)
movie_user <- t(casted_data)



#normalizing the data with user mean and standard deviation
for(i in 1:numUsers){
  temp <- trainData[i,]
  meant <- mean(temp[!is.na(temp)])
  sdt <- sd(temp[!is.na(temp)])
  temp <- (temp-meant)/sdt
  new_mean <- mean(temp[!is.na(temp)])
  temp[is.na(temp)] <- new_mean
  trainData[i, ] <- temp
}

# Finding out the distance matrix between every pair of users
distance_matrix <- dist(trainData)
distance_matrix <- as.matrix(distance_matrix)


kval <- c(4,5,6,7,8)
error <- vector()
for(k in kval){
  error <- c(error, get_train_error(k, trainData_k))
}
train_error <- cbind(kval, error)
