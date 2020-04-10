#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {
  # List the first level callModules here
  data <- callModule(mod_ts_vis_server, "ts_vis_ui_1") 
  
  output$dygraph <- renderDygraph({
    col <- names(data())[3]
    tydygraphs::dygraph(data(), col)
  })
}
