library(sf)
library(ggplot2)

# load shapes -------------------------------------------------------------
shp500m = sf::st_read(dsn = 'data/stat.at/OGDEXT_RASTER_1_STATISTIK_AUSTRIA_L000500_LAEA/STATISTIK_AUSTRIA_L000500_LAEA.shp')
shp500m$NAME = NULL
names(shp500m) = c('rasterID', 'geometry')

load('data/maps/communeShp.rdata') # communeShp
names(communeShp) = c('gemID', 'gemName', 'geometry')
communeShp

crsS = st_crs(shp500m)    # 3035
crsC = st_crs(communeShp) # 31287

gem1 = communeShp[communeShp$gemName == 'Bernhardsthal',]

ggplot() +
  geom_sf(data = gem1, fill = NA) + 
  ggtitle(label = paste('Bernhardsthal. crs:', st_crs(gem1)$input))

# 1. version to change projection ----------------------------------------
gem1 = communeShp[communeShp$gemName == 'Bernhardsthal',]
gem1 = sf::st_transform(gem1, crsS)
#shp500m = sf::st_transform(shp500m, crsC) # or to the other crs
st_crs(gem1) == st_crs(shp500m)
i = sf::st_intersection(gem1, shp500m)
i

#bbox = st_bbox(gem1) 
ggplot() +
  geom_sf(data = gem1, fill = NA) + 
  geom_sf(data = shp500m[shp500m$rasterID %in% i$rasterID,], fill = NA) + 
  ggtitle(label = paste('Bernhardsthal. crs:', st_crs(gem1)$input)) #+ 
  #coord_sf(xlim = c(bbox[1], bbox[3]), ylim = c(bbox[2], bbox[4]), expand = FALSE, crs = st_crs(bbox))

# 2. version to change projection ----------------------------------------
gem1 = communeShp[communeShp$gemName == 'Bernhardsthal',]
gem1 = sf::st_transform(gem1, crsS)

gem1 = sf::st_transform(gem1, 'EPSG:31256')
shp500m = sf::st_transform(shp500m, 'EPSG:31256')
st_crs(gem1) == st_crs(shp500m)
i = sf::st_intersection(gem1, shp500m)
i
