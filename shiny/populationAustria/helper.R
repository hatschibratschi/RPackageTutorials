rm(list = ls())

# project variables  ------------------------------------------------------
communeLayerId = uuid::UUIDgenerate()
communeBorderColor = '#ffffff'  # '#b1b1b1'
communeLineWidth = 100

regionLayerId = uuid::UUIDgenerate()
regionBorderColor = '#ffffff' # '#010101'
regionLineWidth = 500

# functions ---------------------------------------------------------------
downloadUnZipShp = function(url, shpPath, zipPath, shpDir){
  # unzip file if shp does not exist
  if(!file.exists(shpPath)){
    # download zip-file if it does not exist
    if(!file.exists(zipPath)){
      print(paste('download file', url))
      download.file(url = url
                    , destfile = zipPath)
    }
    # unzip file if not unzipped
    print(paste('unzip file', zipPath))
    utils::unzip(zipfile = zipPath
                 , exdir = shpDir)
    file.remove(zipPath)
  }
}

createLoadShp = function(shpRdata, shpPath, shpObjName, shpDir){
  if(!file.exists(shpRdata)){
    print(paste('read shape file', shpPath))
    shp = sf::st_read(dsn = shpPath)
    names(shp) = tolower(names(shp))
    # simplify
    shp = sf::st_simplify(x = shp, dTolerance = 20)
    assign(shpObjName, shp) # object should not be named 'shp' in the saved file
    save(list = shpObjName, file = shpRdata)
    unlink(x = shpDir, recursive = TRUE)
  } else {
    print(paste('load rdata with shape', shpRdata))
    load(file = shpRdata)
  }
  get(shpObjName)
}

loadShp = function(url, shpFile, rDataFile){
  shpDir = file.path('data', 'maps', tools::file_path_sans_ext(basename(url)))
  zipPath = file.path('data', 'maps', basename(url))
  shpPath = file.path(shpDir, shpFile)
  shpRdata = file.path('data', 'maps', rDataFile)
  shpObjName = tools::file_path_sans_ext(rDataFile)
  
  if(!file.exists(shpRdata)){
    downloadUnZipShp(url, shpPath, zipPath, shpDir)
  }
  createLoadShp(shpRdata, shpPath, shpObjName, shpDir)
}

map = function(){
  year1 = 2002 # input$years[1]
  year2 = 2021 # input$years[2]
  
  # get data
  pop1 = getPopulationData(year1)
  pop2 = getPopulationData(year2)
  
  print('pop and area...')
  pop = popChange(pop1, pop2)
  pop = getAreaData(pop, communeShp, data.id = 'id', sf.id = 'id')
  
  print('tidy shps...')
  pop = tidySfForRdeck(pop)
  nuts2shp = tidySfForRdeck(nuts2shp)
  
  pop$change = paste0(round(pop$diff, 2) * 100, '%')
  
  print('plot...')
  options(warn=-1) # disable warning for api-key
  p = rdeck(map_style = NULL
            , initial_bounds = sf::st_bbox(st_buffer(nuts2shp, 25000))
            , theme = "light") |>
    add_polygon_layer(
        id = communeLayerId
      , name = 'Population change'
      , data = pop
      , get_polygon = geometry
      , get_line_width = get('communeLineWidth')
      , get_line_color = get('communeBorderColor')
      , get_fill_color = scale_color_category(col = 'cut'
                                              , palette = getColors(pop))
      , pickable = TRUE
      , tooltip = c(name, change)
    ) |>
    add_polygon_layer(
        id = regionLayerId
      , data = nuts2shp
      , name = 'regions'
      , get_polygon = geometry
      , get_line_width = get('regionLineWidth')
      , get_line_color = get('regionBorderColor')
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

getPopulationData = function(year, level = 'commune'){
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
  # set aggregation level
  d = get(dataObjName)
  if (level == 'commune'){
    setnames(d, 'gkz', 'id')
  } else if (level == 'district'){
    # set new id -> districtId eg. 101, 102
    d[,id := round(d$gkz / 100)]
    d = d[,.(pop = sum(pop)), by = .(time, id)]
  } else if (level == 'state'){
    # set new id -> stateId eg. 1, 2 (not nuts2 ids. these must be changed)
    d[,id := round(d$gkz / 10000)]
    d = d[,.(pop = sum(pop)), by = .(time, id)]
  }
  print(paste('return getPopulationData for', level))
  print(head(d))
  d
}

popChange = function(pop1, pop2){
  
  print('head pop1 and pop2')
  print(head(pop1))
  print(head(pop2))
  
  popChange = merge(pop1[,.(id, pop1 = pop)]
                    , pop2[,.(id, pop2 = pop)]
                    , all.x = TRUE)

  communeChange = popChange[,.(id, pop1, pop2)][,diff := (pop2 - pop1) / pop1][]
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

# load data ---------------------------------------------------------------
# * load shp data ---------------------------------------------------------
# commune shp
communeShp = loadShp(url = 'https://data.statistik.gv.at/data/OGDEXT_GEM_1_STATISTIK_AUSTRIA_20220101.zip'
                     , shpFile = 'STATISTIK_AUSTRIA_GEM_20220101.shp'
                     , rDataFile = 'communeShp.rdata')
# nuts2 shp
nuts2shp = loadShp(url = 'https://data.statistik.gv.at/data/OGDEXT_NUTS_1_STATISTIK_AUSTRIA_NUTS2_20160101.zip'
                   , shpFile = 'STATISTIK_AUSTRIA_NUTS2_20160101.shp'
                   , rDataFile = 'nuts2shp.rdata')
# district shp
districtShp = loadShp(url = 'https://data.statistik.gv.at/data/OGDEXT_POLBEZ_1_STATISTIK_AUSTRIA_20220101.zip'
                      , shpFile = 'STATISTIK_AUSTRIA_POLBEZ_20220101.shp'
                      , rDataFile = 'districtShp.rdata')

# * init load all population data -----------------------------------------
if(FALSE){
  sapply(2011:2019, getPopulationData)
}

# test --------------------------------------------------------------------
if (FALSE){
  getwd()
  setwd('../..')
  load(file = 'shiny/populationAustria/data/maps/communeShp.rdata')
  communeShp
  load(file = 'shiny/populationAustria/data/maps/districtShp.rdata')
  districtShp
  load(file = 'shiny/populationAustria/data/maps/nuts2shp.rdata')
  nuts2shp
  plot(st_buffer(nuts2shp$geometry, 50000)) # dist in meters
  plot(nuts2shp$geometry, add = TRUE)
  st_bbox(st_buffer(nuts2shp, 0))
  st_bbox(nuts2shp)
  
  
  setwd('shiny/populationAustria/')
  (pop1 = getPopulationData(2002))
  (pop1 = getPopulationData(2002, 'district'))
  (pop1 = getPopulationData(2002, 'state'))
  pop2 = getPopulationData(2021)
  
  print('pop and area...')
  pop = popChange(pop1, pop2)
  pop = getAreaData(pop, communeShp, data.id = 'id', sf.id = 'id')
  
  levelShp = nuts2shp
  levelShp = levelShp(order)
}
