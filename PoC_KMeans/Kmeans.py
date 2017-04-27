#Code to recommend genres of the users using KMeans
#KMeans

import re
import numpy as np
from sklearn.metrics import mean_squared_error
from sklearn.cluster import KMeans
from scipy.stats.stats import pearsonr
from itertools import groupby
from collections import Counter
import time

genre = []


u = []
def getUser(file):
	f = open(file, "r")
	text = f.read()
	u_records = re.split("\n+", text)
	for record in u_records:
		val = record.split('|', 5)
		u.append(val)
	return u

i = []
def getItem(file):
	f = open(file, "r")
	text = f.read()
	i_records = re.split("\n+", text)
	for record in i_records:
		val = record.split('|', 24)
		i.append(val)
	return i


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
rating.pop()

a = len(users)

b = len(movies)

l = len(rating)

user_movie_matrix = np.zeros((a,b))

#user_movie_matrix = [[0 for x in range(b)] for y in range(b)]
#print user_movie_matrix[943][1682]

for r in rating:
	k = int(r[0])
	j = int(r[1])
	res = int(r[2])
	user_movie_matrix[k][j] = res

movies.pop()

genre = []
for movie in movies:
	item =[]
	for i in range(5,24):
		item.append(movie[i])
	genre.append(item)

genre = np.array(genre)

#kmeans_cluster = KMeans(n_clusters=19, random_state=0).fit_predict(genre)

#print kmeans_cluster[1]

cluster = KMeans(n_clusters=19, random_state=0).fit_predict(genre)

genre_name = ["unknown", "action", "adventure", "animation", "childrens", "comedy", "crime", "documentary","drama", "fantasy", "film_noir", "horror", "musical", "mystery","romance", "sci_fi", "thriller", "war", "western"]

recommend = {}

c = b-1

for i in range(0,a):
	g_list = []
	for j in range(0,c):
		if user_movie_matrix[i][j] >= 3:
			g_list.append(cluster[j])
	recommend[i] = g_list

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
		
#print final

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


