library(data.table)
dt = data.table(col1 = letters[1:10], col2 = 1:10)

# rows
dt[col1 == 'c']

x = 'col1'
dt[get(x) == 'c']
