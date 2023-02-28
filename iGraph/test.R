#install.packages('igraph')
library(igraph)

g = graph_from_data_frame(data.frame(id1 = c(1:6), id2 = c(2,3,4,1,6,7)))
g = graph_from_data_frame(data.frame(id1 = c(1:6), id2 = c(11:15,1)))
g = graph_from_data_frame(data.frame(id1 = c(1:6), id2 = c(2,3,1,5,4,7))) 
g = graph_from_data_frame(data.frame(id1 = c(1:6), id2 = c(2,3,1,5,4,7)), directed = FALSE)
g
plot(g)
any_loop(g)

g <- graph(c(1, 1, 2, 2, 3, 3, 4, 5))
plot(g)
any_loop(g)

# from https://stackoverflow.com/questions/55091438/r-igraph-find-all-cycles
FindCycles = function(g) {
  Cycles = NULL
  for(v1 in V(g)) {
    if(degree(g, v1, mode="in") == 0) { next }
    GoodNeighbors = neighbors(g, v1, mode="out")
    GoodNeighbors = GoodNeighbors[GoodNeighbors > v1]
    for(v2 in GoodNeighbors) {
      TempCyc = lapply(all_simple_paths(g, v2,v1, mode="out"), function(p) c(v1,p))
      TempCyc = TempCyc[which(sapply(TempCyc, length) > 3)]
      TempCyc = TempCyc[sapply(TempCyc, min) == sapply(TempCyc, `[`, 1)]
      Cycles  = c(Cycles, TempCyc)
    }
  }
  Cycles
}

FindCycles(g)
