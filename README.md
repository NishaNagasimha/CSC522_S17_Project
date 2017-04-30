# RecommendationSystem
CSC 522: Automated learning and Data Anaysis Project

Collaborative Filtering (ALS technique)
Code - MovieRecommend.ipynb
1) Make sure you have Spark configured onto the system
2) Need ipython or jupyter notebook to view the code
Code is well commented to understand the preprocessing, model building with parameter tuning and finally recommending

Implementation of KNN-classifier to report the accuracy
Code - KNN-classifier.R
1) Install a package "reshape2"
2) Set the working directory to the place where data exists
3) SSE calculated for validation data for every K value from 5 to 30 takes time. You can edit that part to run for 4 to 5 values of K to make the code run faster
  This code is less efficient in terms of time taken and can be modified to form cluster of users based on Genres or the rating 
  similarities to comoute the distance measures between users belonging to the same cluster
  

