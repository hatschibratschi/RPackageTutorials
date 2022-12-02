if(FALSE){
  install.packages('remotes')
  remotes::install_github("statistikat/STATcubeR")
  remotes::install_github("qfes/rdeck")
}

library(rdeck)
library(data.table)
library(sf)
library(viridisLite)

# functions ---------------------------------------------------------------
tidySfForRdeck = function(sf){
  # set crs
  sf = st_transform(sf, crs = st_crs(4326))
  # change all geometries to MULTIPOLYGON
  st_geometry(sf) = sf::st_cast(st_geometry(sf), "MULTIPOLYGON")
  # set name of geometry-column
  st_geometry(sf) = 'geometry'
  sf
}

# load objects ------------------------------------------------------------
nc = sf::st_read(system.file("shape/nc.shp", package="sf"))
nc = tidySfForRdeck(nc)

ncCenter = sf::st_centroid(nc)
ncCenter = sf::st_buffer(ncCenter, dist = 10000)
ncCenter = tidySfForRdeck(ncCenter)

if(FALSE){
  plot(nc$geometry)
}

