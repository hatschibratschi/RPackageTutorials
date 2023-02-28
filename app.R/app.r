library(shiny)
library(gridlayout)
library(ggplot2)

ui <- navbarPage(
  title = "Chick Weights",
  selected = "Distributions",
  collapsible = TRUE,
  theme = bslib::bs_theme(),
  tabPanel(
    title = "Distributions",
    grid_container(
      layout = c(
        "facetOption",
        "dists"
      ),
      row_sizes = c(
        "165px",
        "1fr"
      ),
      col_sizes = "1fr",
      gap_size = "10px",
      grid_card_plot(area = "dists"),
      grid_card(
        area = "facetOption",
        title = "Distribution Plot Options",
        radioButtons(
          inputId = "distFacet",
          label = "Facet distribution by",
          choices = list(
            `Diet Option` = "Diet",
            `Measure Time` = "Time"
          )
        )
      )
    )
  )
)

server <- function(input, output) {
  output$linePlots <- renderPlot({
    obs_to_include <- as.integer(ChickWeight$Chick) <= input$numChicks
    chicks <- ChickWeight[obs_to_include, ]

    ggplot(
      chicks,
      aes(
        x = Time,
        y = weight,
        group = Chick
      )
    ) +
      geom_line(alpha = 0.5) +
      ggtitle("Chick weights over time")
  })

  output$dists <- renderPlot({
    ggplot(
      ChickWeight,
      aes(x = weight)
    ) +
      facet_wrap(input$distFacet) +
      geom_density(fill = "#fa551b", color = "#ee6331") +
      ggtitle("Distribution of weights by diet")
  })
}

shinyApp(ui, server)
