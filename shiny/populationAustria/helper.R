# objects -----------------------------------------------------------------
# maps
load('data/maps/communeShp.rdata') # communeShp
load('data/maps/nuts2shp.rdata') # nuts2shp

polygonLayerId = uuid::UUIDgenerate()

# functions ---------------------------------------------------------------
map = function(){
  year1 = 2002 # input$years[1]
  year2 = 2021 # input$years[2]
  
  # get data
  pop1 = getPopulationData(year1)
  pop2 = getPopulationData(year2)
  
  print('pop and area...')
  pop = popChange(pop1, pop2)
  pop = getAreaData(pop, communeShp, data.id = 'gkz', sf.id = 'id')
  
  print('tidy shps...')
  pop = tidySfForRdeck(pop)
  nuts2shp = tidySfForRdeck(nuts2shp)
  
  pop$change = paste0(round(pop$diff, 2) * 100, '%')
  
  print('plot...')
  options(warn=-1) # disable warning for api-key
  p = rdeck(map_style = NULL
            , initial_bounds = sf::st_bbox(pop)
            , theme = "light") |>
    add_polygon_layer(
        id = polygonLayerId
      , name = 'Population change'
      , data = pop
      , get_polygon = geometry
      , get_line_width = 100
      , get_line_color = '#b1b1b1'
      , get_fill_color = scale_color_category(col = 'cut'
                                              , palette = getColors(pop))
      , pickable = TRUE
      , tooltip = c(name, change)
    ) |>
    add_polygon_layer(
      data = nuts2shp
      , name = 'nuts2 areas'
      , get_polygon = geometry
      , get_line_width = 200
      , get_line_color = '#010101'
      , filled = FALSE
    )
  options(warn=0)
  p
}

createFolder = function(p){
  if(!file.exists(p)){
    dir.create(p, recursive = TRUE)
  }
}

getPopulationData = function(year){
  dataFolder = file.path('data', 'population')
  createFolder(dataFolder)
  dataFile = file.path(dataFolder, paste0('pop', year, '.rdata'))
  dataObjName = paste0('pop', year)
  
  if(!file.exists(dataFile)){
    library(STATcubeR)
    extTableName = paste0("OGD_bevstandjbab2002_BevStand_", year)
    print(paste('download data for', year))
    d = od_table(extTableName)
    
    # tidy data
    data = d$tabulate()
    data = setDT(data)
    # sum by group
    data = data[,.(pop = sum(Number))
                , by = .(time = `Time section`
                         , gem = `Commune (aggregation by political district)`)]
    # convert gkz-column to 5 digits
    data$gkz = stringr::str_extract_all(string = as.character(data$gem), pattern = '<\\d{5}>')
    data$gkz = as.numeric(stringr::str_extract_all(data$gkz, '\\d{5}'))
    # return only those 3 cols
    data = data[,.(time, gkz, pop)]
    
    # save data
    assign(dataObjName, data) # object should not be named 'data' in the saved file
    save(list = dataObjName, file = dataFile)
  } else {
    print(paste('load data for', year, 'from disk'))
    load(file = dataFile)
  }
  get(dataObjName)
}

popChange = function(pop1, pop2){
  
  # pop1Year = min(year(pop1$time))
  # pop2Year = min(year(pop2$time))

  popChange = merge(pop1[,.(gkz, pop1 = pop)]
                    , pop2[,.(gkz, pop2 = pop)]
                    , all.x = TRUE)
  # get codes for district and federal states from gkz for later use
  popChange[, `:=` (  district = floor(gkz / 100)
                      , federalstate = floor(gkz / 10000))]
  
  communeChange = popChange[,.(gkz, pop1, pop2)][,diff := (pop2 - pop1) / pop1][]
  communeChange
}

getAreaData = function(data, sf, data.id, sf.id, breakSize = 10){
  # combine pop and sf data by ids
  d = merge(sf, data, by.x = sf.id, by.y = data.id, all.x = 'TRUE')
  
  # create the breaks for the new change groups
  q=breakSize
  breaks = seq(min(floor(data$diff * q) / q, na.rm = TRUE)
               , max(ceiling(data$diff * q) / q, na.rm = TRUE)
               , by = 1/q)
  breaks = round(breaks, log10(q) + 1)
  stopifnot("breakSize is too big or bad"=anyDuplicated(breaks) == 0)
  print(paste0('break groups created at: ', paste(breaks, collapse = ', ')))
  
  # create the change groups with the cut-function
  d$cut = cut(d$diff , breaks)
  d
}

getColors = function(sf){
  
  # get count of cut-groups below and above zero
  t = table(sf[sf$diff < 0,]$cut) > 0
  nNeg = length(t[t == TRUE])
  nPos = length(t[t == FALSE])
  
  col = c(
    colorRampPalette(c('darkblue', 'lightblue'))( nNeg )
    , rev(colorRampPalette(c('darkgreen', 'lightgreen'))( nPos ))
  )
  names(col) = as.character(levels(sf$cut))
  col
}

tidySfForRdeck = function(sf){
  # set crs
  sf = st_transform(sf, crs = st_crs(4326))
  # change all geometries to MULTIPOLYGON
  st_geometry(sf) = sf::st_cast(st_geometry(sf), "MULTIPOLYGON")
  sf
}
