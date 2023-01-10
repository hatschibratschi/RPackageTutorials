#install.packages('osmdata')
library(osmdata)
library(sf)
library(ggplot2)

bbox1 = getbb("Bernhardsthal", format_out = 'data.frame')
bbox2 = getbb("Austria, Rabensburg", format_out = 'data.frame')
bbox2 = getbb("Austria, Rabensburg", format_out = 'd')
bbox = rbind(bbox1, bbox2)
st_bbox(c(xmin = 16.1, xmax = 16.6, ymax = 48.6, ymin = 47.9), crs = st_crs(4326))

available_features()

dat = osmdata_sf(q = add_osm_feature(opq = opq("Bernhardsthal"), key = "water"))

ggplot() +
  geom_sf(data = dat$osm_lines, color = 'lightblue') + 
  geom_sf(data = dat$osm_polygons, color = 'blue', fill = 'lightblue')

# get all motorways in austria ---------------------------------------------
# v1
# https://www.openstreetmap.org/relation/3392503
dat <- opq_osm_id (id = 59622, type = 'relation') %>%
  opq_string () %>%
  osmdata_sf ()
ggplot() +
  geom_sf(data = dat$osm_lines)

st_bbox(dat$osm_lines)

ggplot() +
  geom_sf(data = dat$osm_lines, color = 'lightblue') + 
  geom_sf(data = dat$osm_polygons, color = 'blue', fill = 'lightblue')

#v2
bbox2 = getbb("Bernhardsthal")
bbox2[1,1] = 9.5307487
bbox2[1,2] = 17.1607728
bbox2[2,1] = 46.3722987
bbox2[2,2] = 49.0205249
bbox2

q = add_osm_features(opq  = opq(bbox = bbox2), features = c(
    "\"operator\"=\"Asfinag\""
    , "\"operator\"=\"ASFINAG\""
    , "\"ref\"=\"A14\""
))
dat = osmdata_sf(q)

ggplot() +
  geom_sf(data = dat$osm_lines, color = 'lightblue') + 
  geom_sf(data = dat$osm_polygons, color = 'blue', fill = 'lightblue')
