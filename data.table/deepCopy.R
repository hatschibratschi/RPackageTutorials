library(data.table)
dt = data.table(col1 = letters[1:10], col2 = 1:10)
unique(dt$col1)

dt2 = dt
dt[,col1 := 'x']
unique(dt2$col1)

dt3 = copy(dt)
dt[,col1 := 'y']
unique(dt3$col1)
