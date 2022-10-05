
getPopulationData = function(year){
  dataFolder = file.path('data', 'population')
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
    assign(dataObjName, data) # object should not be named 'shp' in the saved file
    save(list = dataObjName, file = dataFile)
  } else {
    print(paste('load data for', year, 'from disk'))
    load(file = dataFile)
  }
  get(dataObjName)
}
# pop1 = getPopulationData(2002)
# pop2 = getPopulationData(2021)

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
