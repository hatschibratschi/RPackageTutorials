if(FALSE){
  install.packages('remotes')
  remotes::install_github("statistikat/STATcubeR")
  remotes::install_github("qfes/rdeck")
}

library(rdeck)
library(data.table)
library(sf)


# functions ---------------------------------------------------------------
tidySfForRdeck = function(sf){
  # set crs
  sf = st_transform(sf, crs = st_crs(4326))
  # change all geometries to MULTIPOLYGON
  st_geometry(sf) = sf::st_cast(st_geometry(sf), "MULTIPOLYGON")
  sf
}


# load objects ------------------------------------------------------------
nc = sf::st_read(system.file("shape/nc.shp", package="sf"))
nc = tidySfForRdeck(nc)

if(FALSE){
  plot(nc$geometry)
}

