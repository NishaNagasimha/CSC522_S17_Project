#Code to recommend genres of the users using KMeans
#KMeans clustering approach to recommend top 5 genres

import re
import numpy as np
from sklearn.metrics import mean_squared_error
from sklearn.cluster import KMeans
from scipy.stats.stats import pearsonr
from itertools import groupby
from collections import Counter
import time

#List to map the 19 different genres
genre = []

#Load all the users from the movielens dataset
u = []
def getUser(file):
	f = open(file, "r")
	text = f.read()
	u_records = re.split("\n+", text)
	for record in u_records:
		val = record.split('|', 5)
		u.append(val)
	return u

#Load all the movies from the movielens dataset
i = []
def getItem(file):
	f = open(file, "r")
	text = f.read()
	i_records = re.split("\n+", text)
	for record in i_records:
		val = record.split('|', 24)
		i.append(val)
	return i

#Load all the ratings from the movielens dataset
r = []
def getRating(file):
	f = open(file, "r")
	text = f.read()
	r_records = re.split("\n+", text)
	for record in r_records:
		val = record.split('\t', 4)
		r.append(val)
	return r

users = getUser("dataset/u.user")
movies = getItem("dataset/u.item")
rating = getRating("dataset/u.base")
#test = getRating("u1.test")
rating.pop()

a = len(users)

b = len(movies)

l = len(rating)

#Generating the user-movie matrix with ratings
user_movie_matrix = np.zeros((a,b))
#t = len(test)
#test_matrix = np.zeros((a,b))

#user_movie_matrix = [[0 for x in range(b)] for y in range(b)]
#print user_movie_matrix[943][1682]
 '''for t in test:
 	print t
 	k = int(t[0])
 	j = int(t[1])
 	res = int(t[2])
 	#print "k", k
 	#print "j",j
 	#print r
 	test_matrix[k][j] = res'''

for r in rating:
	k = int(r[0])
	j = int(r[1])
	res = int(r[2])
	user_movie_matrix[k][j] = res

movies.pop()

#Extracting the genre fields from movie data
genre = []
for movie in movies:
	item =[]
	for i in range(5,24):
		item.append(movie[i])
	genre.append(item)

#Clustering (KMeans) the movies based on genres
genre = np.array(genre)
cluster = KMeans(n_clusters=19, random_state=0).fit_predict(genre)

#Genre map
genre_name = ["unknown", "action", "adventure", "animation", "childrens", "comedy", "crime", "documentary","drama", "fantasy", "film_noir", "horror", "musical", "mystery","romance", "sci_fi", "thriller", "war", "western"]

recommend = {}
c = b-1

#For each user, extracting the genres which he has rated greater than equal to 3 (Here 3 is our threshold)
#Genre of a movie is taken from the KMeans cluster found above
for i in range(0,a):
	g_list = []
	for j in range(0,c):
		if user_movie_matrix[i][j] >= 3:
			g_list.append(cluster[j])
	recommend[i] = g_list

#Counting the most common genre which the user has rated greater than or equal to 3 and taking the top 5 from it
final = {}
for k, v in recommend.iteritems():
	rec = {}
	#tuple = (element, count)
	rec = Counter(v).most_common(len(v))
	length = len(rec)
	top5 = []

	if length < 5:
		for i in range(0,length):
			top5.append(rec[i])
	else:
		for i in range(0,5):	
			top5.append(rec[i])	
	final[k] = top5

#Mapping the genre Id to genre name to identify the top 5 genres which each user prefers
top_genre = {}
for k, v in final.iteritems():
	gen = []
	for x in v:
		z = x[0]
		gen.append(genre_name[z])
	top_genre[k] = gen

for k, v in top_genre.iteritems():
	print "User id: ",k
	for y in range(0, len(v)):
		print "Top ",(y+1)," genre: ", v[y]
		time.sleep(0.1)
	time.sleep(0.9)

# Calculating mean squared error
'''actual_y = []
y_pred = []
 
for i in range(0, a):
    for j in range(0, b):
         actual_y.append(test_matrix[i][j])
         y_pred.append(user_movie_matrix[i][j])
 print "Mean Squared Error: %f" % mean_squared_error(actual_y, y_pred)
 
 #Pearson Coefficient
 l = []
 p = []
 for i in range(0, len(users)):
 	l.append(users[i][j])
 
 p = pearsonr(l,l])[0]'''
