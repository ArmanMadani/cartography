# How Could We Make it Better
# San Francisco's Casual Carpool System

library(tidyverse)
library(cluster)
library(factoextra)
library(ggmap)

# Made a dataset of points covering *most* of San Francisco Proper
setwd('~/Desktop/urban_logistics/03_carpool/')
sf <- read.csv('data/sfproper.csv')
nrow(sf)

# Geometric Configuration
GEOCODE <- as.numeric(geocode('San Francisco', source = 'dsk'))
ZOOM <- 12
MAPTYPE <- "roadmap"
COLOR <- "bw"
KEY <- "AIzaSyBK_Hy9UP5q8krCWRtKUpnxVULP2CZN-XM"
STYLE <- c(feature = "all", element = "labels", visibility = "off")
map <- get_googlemap(center = GEOCODE, zoom = ZOOM, maptype = MAPTYPE, color = COLOR,
  style = STYLE, key = KEY)
axes_formatting <- theme(
  axis.text = element_blank(),
  axis.line = element_blank(),
  axis.ticks = element_blank(),
  panel.border = element_blank(),
  panel.grid = element_blank(),
  axis.title = element_blank()
)

# Distance Matrix between on a Small Sample of Points 
sf_sample_distmat <- sf[sample(nrow(sf), nrow(sf) * 0.001),]
distance <- get_dist(sf_sample_distmat)
fviz_dist(distance, 
  show_labels = FALSE, 
  gradient = list(low = "#00AFBB", mid = "white", high = "#32CD32"))

# Randomly sampling the points from the lat/lons for graphing/clustering
sf_sample <- sf[sample(nrow(sf), nrow(sf) * 0.0035),]
nrow(sf_sample)
ggmap(map) + geom_point(data = sf_sample)

# Arbitrarily picking 6 centroids (will find optimal using elbox plot later)
k6 <- kmeans(na.omit(sf_sample), centers = 6, nstart = 25)
fviz_cluster(k6, data = sf_sample, geom = "point", show.clust.cent = TRUE, 
  ellipse = TRUE, shape = 'circle') + coord_flip()

# Elbow Plot and Silhouette Plot
fviz_nbclust(sf_sample, kmeans, method = "wss")
fviz_nbclust(sf_sample, kmeans, method = "silhouette")

# Add clusters to original dataframe
clusters <- factor(k6$cluster)
sf_sample$clusters <- clusters

# Add points back to map using clusters for color value:
ggmap(map) + geom_point(data = sf_sample, aes(colour = clusters)) +
  labs(colour = "Carpool Zone") + ggtitle('')

# Just to illustrate my point further and show how kmeans works,
# we'll cherry pick some coordinates from 3 distinct areas within 
# San Francisco
sf_cp <- read.csv('data/sf_cherrypicked.csv')
nrow(sf_cp)
ggmap(map) + geom_point(data = sf_cp)

# Clustering
k3 <- kmeans(na.omit(sf_cp), centers = 3, nstart = 25)
fviz_cluster(k3, data = sf_cp, geom = "point", show.clust.cent = TRUE, 
  ellipse = TRUE, shape = 'circle') + coord_flip()

# Elbow/Silhouette Graphs
set.seed(123)
fviz_nbclust(sf_cp, kmeans, method = "wss")
fviz_nbclust(sf_cp, kmeans, method = "silhouette")

# Add clusters to cherrypicking dataframe
cp_clusters <- factor(k3$cluster)
sf_cp$clusters <- cp_clusters

# Add points to the map using clusters for color value: 
ggmap(map) + geom_point(data = sf_cp, aes(colour = clusters)) +
  labs(colour = "Carpool Zone")
