#setwd("C:/Users/kanni/Documents")
library("reshape2")
set.seed(123)
data <- read.csv("ratings.csv", header = TRUE)
data <- data[, -ncol(data)]
trainidx <- sample(1:nrow(data), size = 0.8*nrow(data))
test <- data[-trainidx, ]
tdata <- data[trainidx, ]
head(tdata)
nrow(data)
# Converting into matrix of numUsers * numMovies
tdata <- acast(tdata, userId ~ movieId)
copy <- tdata
copy[is.na(copy)] <- NA
tdata <- as.matrix(tdata)

# Normalizing the data and replacing NA's to zero
norm_data <- t(scale(t(tdata), center=T, scale=F)) #center=T so mean is subtracted from all the values, scale=F there is no scaling done after centering
norm_data[is.na(norm_data)] <- 0

no_users <- nrow(norm_data)
no_movies <- ncol(norm_data)

#Cosine distance calculation
cosine_dist <- function(u1, u2){ #for two users, cosine of ratings for all movies that they watched
    numerator <- sum(norm_data[u1,]*norm_data[u2,])
    modx<-sqrt(sum(norm_data[u1,]*norm_data[u1,]))
    mody<-sqrt(sum(norm_data[u2,]*norm_data[u2,]))
    return (numerator/(modx*mody))
}


#Finding out cosine similarities between all users
distance_matrix <- matrix(0, nrow = no_users, ncol = no_users)
for(u1 in 1:no_users-1){
  for(u2 in (1+u1):no_users){
    distance_matrix[u1, u2] <- distance_matrix[u2, u1] <- cosine_dist(u1, u2)
  }
}
cos_dist <- as.dist(distance_matrix) #convert into a distance matrix

k <- 15
k_clusters <- kmeans(cos_dist, centers = k)#kmeans clustering
k_clusters$cluster
c.df <- data.frame(c(1:no_users), k_clusters$cluster)#dataframe with user and cluster
#c.df[1, c.df[,2]==2]

clusters <- list()
for(i in 1:k){
  clusters[[i]] <- c.df[c.df[,2]==i, 1]#whenever c.df[,2]==i i.e.,cluster=i then TRUE, so that user is put into cluster list
}

test_error <- 0
for(i in 1:nrow(test)){
  uid <- test[i,1] #userid
  mid <- test[1,2] #movieid	
  r <- test[1,3] #rating
  cid <- k_clusters$cluster[[uid]] #cluster
  peers <- clusters[[cid]] #other users in same cluster
  temp <- 0
  n <- 0
  for(i in peers){
    if (!is.na(copy[i, mid])){
      n <- n+1
      temp <- temp+copy[i, mid] #adding all the ratings of the peers for the same movie 
    }
  }
  err <- ((r-(temp/n))*(r-(temp/n)))
  test_error <- test_error + err	#adding estimated rating of every (user,movie) pair in test data to test_error 
}
test_error
