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
movie_user_matrix <- t(casted_data)



#normalizing the data with user mean and standard deviation
numUsers <- nrow(casted_data)
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

# Finding out user_list by movie index
movie_user <- list()
for(i in 1:nrow(movie_user_matrix)){
  temp <- as.vector(which(!is.na(movie_user_matrix[i, ])))
  movie_user[[length(movie_user)+1]] <- temp
}

# Map movieid to an index
movieId <- read.csv("movieind.csv", header = FALSE)
movie_map <- data.frame()
for (i in 1:nrow(movieId)){
  movie_map <- rbind(movie_map, c(movieId[i,], i))
}
names(movie_map) <- c("ActualID", "MappedID")


get_train_error <- function(k, predData){
  train_error <- 0
  for(i in 1:nrow(predData)){
    userid <- predData[i, 1]
    movieid <- predData[i, 2]
    movieid <- movie_map[movie_map$ActualID==movieid, 2]
    u_rate <- predData[i, 3]
    watched_users <- movie_user[[movieid]]
    temp_dist <- data.frame()
    for(j in watched_users){
        temp_dist <- rbind(temp_dist, c(j, distance_matrix[userid, j], casted_data[j, movieid]))
    }
    temp_dist<- temp_dist[order(temp_dist[2]), ]
    temp_dist <- temp_dist[1:k,]
    nearest_k_ratings <- temp_dist[,3]
    nearest_k_ratings <- nearest_k_ratings[!is.na(nearest_k_ratings)]
    pred_rating <- mean(nearest_k_ratings)
    train_error <- train_error + ((pred_rating - u_rate)^2)
  }
  return (sqrt(train_error))
}

print (get_train_error(3, trainData_k))

kval <- c(3)
error <- vector()
for(k in kval){
  error <- c(error, get_train_error(k, trainData_k))
}
train_error <- cbind(kval, error)
