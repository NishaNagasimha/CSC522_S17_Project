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

restData <- data[-trainIdx, ]

testIdx <- sample(nrow(restData), nrow(restData)/2)
testData <- restData[testIdx, ]
validationData <- restData[-testIdx,]

trainData_k <- data[trainIdx, ]

casted_data <- acast(data, userId ~ movieId)
casted_data <- as.matrix(casted_data)
movie_user_matrix <- t(casted_data)
normalized_data <- casted_data

#normalizing the training data with user mean and standard deviation
user_mean <- vector()
user_sd <- vector()
numUsers <- nrow(casted_data)
for(i in 1:numUsers){
  temp <- trainData[i,]
  meant <- mean(temp[!is.na(temp)])
  sdt <- sd(temp[!is.na(temp)])
  user_mean[i] <- meant
  user_sd[i] <- sdt
  temp <- (temp-meant)/sdt
  new_mean <- mean(temp[!is.na(temp)])
  temp[is.na(temp)] <- new_mean
  trainData[i, ] <- temp
  
  temp <- casted_data[i,]
  meant <- mean(temp[!is.na(temp)])
  sdt <- sd(temp[!is.na(temp)])
  temp <- (temp-meant)/sdt
  new_mean <- mean(temp[!is.na(temp)])
  temp[is.na(temp)] <- new_mean
  normalized_data[i, ] <- temp
}

# Finding out the distance matrix between every pair of users
distance_matrix <- dist(trainData, method = "manhattan")
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


get_error <- function(k, predData){
  return_error <- 0
  for(i in 1:nrow(predData)){
    userid <- predData[i, 1]
    movieid <- predData[i, 2]
    #print (movieid)
    movieid <- movie_map[movie_map$ActualID==movieid, 2]
    u_rate <- predData[i, 3]
    watched_users <- movie_user[[movieid]]
    temp_dist <- data.frame()
    if (length(watched_users) == 1){
      return_error <- return_error + u_rate^2
      
    }else{
      for(j in watched_users){
        if(j != userid)temp_dist <- rbind(temp_dist, c(j, distance_matrix[userid, j], normalized_data[j, movieid]))
      }
        temp_dist<- temp_dist[order(temp_dist[2]), ]
        temp_dist <- temp_dist[1:k,]
        nearest_k_ratings <- temp_dist[,3]
        nearest_k_ratings <- nearest_k_ratings[!is.na(nearest_k_ratings)]
        pred_rating <- mean(nearest_k_ratings)*user_sd[userid] + user_mean[userid]
        return_error <- return_error + ((pred_rating - u_rate)^2)
      }
    }
  return (return_error)
}


#kval <- c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20)
# Takes about 10mins
kval <- c(5:30)
sse <- vector()
for(k in kval){
  print (k)
  sse <- c(sse, get_error(k, validationData))
}

validation_errors <- cbind(kval, sse)
plot(validation_errors, xlab = "K", ylab = "SSE")

plot(validation_errors[,1], validation_errors[,2], main="Manhattan measure", xlab = "K", ylab = "SSE") 
lines(validation_errors[,1], validation_errors[,2], type = "line") 

testerror <- get_error(15, testData)
testerror
