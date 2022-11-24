#install.packages('osmdata')
library(osmdata)
library(sf)
library(ggplot2)

bbox1 = getbb("Bernhardsthal", format_out = 'data.frame')
bbox2 = getbb("Austria, Rabensburg", format_out = 'data.frame')
bbox2 = getbb("Austria, Rabensburg", format_out = 'd')
bbox = rbind(bbox1, bbox2)
st_bbox(c(xmin = 16.1, xmax = 16.6, ymax = 48.6, ymin = 47.9), crs = st_crs(4326))

available_features ()

dat = osmdata_sf(q = add_osm_feature(opq = opq("Bernhardsthal"), key = "water"))

ggplot() +
  geom_sf(data = dat$osm_lines, color = 'lightblue') + 
  geom_sf(data = dat$osm_polygons, color = 'blue', fill = 'lightblue')
