quarto_run(
  input = 'quarto/quartoShinySimple.qmd',
  render = TRUE,
  port = getOption("shiny.port"),
  host = getOption("shiny.host", "127.0.0.1"),
  browse = TRUE
)
