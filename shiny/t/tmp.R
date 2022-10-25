head(faithful)

x    <- faithful[, 2]
bins <- seq(min(x), max(x), length.out = 30)

# draw the histogram with the specified number of bins
hist(x, breaks = bins, col = 'darkgray', border = 'white',
     xlab = 'Waiting time to next eruption (in mins)',
     main = 'Histogram of waiting times')

summary(faithful$waiting)
sort(faithful$waiting)
sort(faithful$eruptions)

plot(faithful$eruptions, main = 'x')
plot(faithful$waiting)
plot(x = faithful$eruptions, y = faithful$waiting)

plot(density(faithful$eruptions))
plot(density(faithful$waiting))


