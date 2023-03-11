library(sf)
library(ggplot2)
library(cowplot)
library(rnaturalearth)
library(rmapshaper)

# template
# https://ec.europa.eu/eurostat/documents/345175/7451602/2021-NUTS-0-map.pdf

# download data -----------------------------------------------------------
# https://ec.europa.eu/eurostat/web/gisco/geodata/reference-data/administrative-units-statistical-units/nuts

# maps --------------------------------------------------------------------
# world
world = ne_countries(scale = "large", returnclass = "sf") # medium
print(object.size(world), units='auto')

worldSmall = ms_simplify(world, keep_shapes = TRUE)
print(object.size(worldSmall), units='auto')

iWorld = ms_innerlines(worldSmall)
print(object.size(iWorld), units='auto')

if(FALSE){
  plot(worldSmall$geometry)
  plot(iWorld, add=TRUE, col='brown')
  
  bbox = st_bbox(worldSmall[worldSmall$continent == 'Africa',])
  ggplot2::ggplot() +
    geom_sf(data = worldSmall, fill = 'gray', color = 'darkblue', linewidth = 0.4) +
    geom_sf(data = iWorld, color = 'black', linewidth = 0.4) +
    coord_sf(xlim = c(bbox$xmin, bbox$xmax), ylim = c(bbox$ymin, bbox$ymax), expand = FALSE) +
    theme_void() +
    theme(panel.background = element_rect(fill = "aliceblue"))
}

# eu
#eu = st_read(dsn = 'data/eurostat/NUTS_RG_20M_2021_3035/NUTS_RG_20M_2021_3035.shp')
euDetail = st_read(dsn = 'data/eurostat/NUTS_RG_03M_2021_3035/NUTS_RG_03M_2021_3035.shp')
print(object.size(euDetail), units='auto')
eu = ms_simplify(euDetail, keep_shapes = TRUE)
print(object.size(eu), units='auto')
#plot(eu[eu$LEVL_CODE == 0,]$geometry)

world = st_transform(world, crs = st_crs(eu))
worldSmall = st_transform(worldSmall, crs = st_crs(eu))
iWorld = st_transform(iWorld, crs = st_crs(eu))

# nuts3 non continental NUTS_ID
euNoneContinental.NUTS_ID = c('PT2', 'PT30', 'ES7', 'ES64', 'FRY', 'NO0B')
euNoneContinental = eu[eu$NUTS_ID %in% euNoneContinental.NUTS_ID,]
euNoneContinentalUnion = st_union(euNoneContinental$geometry)
if(FALSE){
  plot(eu[eu$LEVL_CODE == 0,]$geometry)
  plot(euNoneContinentalUnion, add = TRUE, col = 'red')
}

# remove non continental areas from level 0
euContinentalNUTS0 = st_difference(eu[eu$LEVL_CODE == 0,]$geometry, euNoneContinentalUnion)
#plot(euContinentalNUTS0)

iEuContinental = ms_innerlines(euContinentalNUTS0)
#plot(iEuContinental)

# small and oversea eu
eu[startsWith(eu$NAME_LATN, "Martin"),]

euOverseasNUTS_ID = c('ES7', 'FRY1', 'FRY2', 'FRY3', 'FRY4', 'FRY5')
euOverseas = euDetail[euDetail$NUTS_ID %in% euOverseasNUTS_ID,]
# plot(euOverseas$geometry)

# facet map ---------------------------------------------------------------
graph <- function(x){
  d = euOverseas[x,]
  title = paste0(d$NAME_LATN, ' (', d$CNTR_CODE,')')
  bbox = st_bbox(d)
  bboxDist = max(st_distance(st_cast(st_as_sfc(bbox), 'POINT'))) # max distance inside bbox
  bbox = st_bbox(st_buffer(d, bboxDist * 0.2)) 
  ggplot2::ggplot() +
    geom_sf(data = world, fill = 'gray', color = 'darkblue') +
    geom_sf(data = iWorld, color = 'black') +
    geom_sf(data = d, fill = 'brown') +
    coord_sf(xlim = c(bbox$xmin, bbox$xmax), ylim = c(bbox$ymin, bbox$ymax), expand = FALSE) +
    ggtitle(title) +
    theme_void() +
    theme(panel.background = element_rect(fill = "aliceblue"))
}
graph(2)

plot_list <- lapply(X = 1:nrow(euOverseas), FUN = graph)

g <- cowplot::plot_grid(plotlist = plot_list, ncol = 3)
g
