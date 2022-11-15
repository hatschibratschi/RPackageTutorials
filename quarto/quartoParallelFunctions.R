f2 = function(x) x*20

p1 = function(cl, myList){
  parLapply(cl = cl
            , X = myList
            , fun = function(l){
              print(paste(Sys.time() ))
              # return
              paste0(l, f2(x1))
            }
  )
}

runParallel = function(myList
                       , coresPerCent
                       , clusterLog
                       , x1, f1, f2
                       ){

  cores = round(detectCores() * coresPerCent)
  cl = makeCluster(cores, outfile = clusterLog)
  clusterExport(cl, varlist = c("x1", 'f1', 'f2')) # add objects to cluster
  
  r = parLapply(cl = cl
            , X = myList
            , fun = function(l){
              print(paste(Sys.time() ))
              # return
              paste0(l, f2(x1))
            }
  )
  stopCluster(cl);rm(cl)
  r
}