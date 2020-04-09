#' ts_vis UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_ts_vis_ui <- function(id){
  ns <- NS(id)
  tagList(
    selectInput(ns("dataset"), choices = list("Tides" = "tides",
                                              "Meterology" = "meteorology"),
                label = "Data")
  )
}
    
#' ts_vis Server Function
#'
#' @noRd 
mod_ts_vis_server <- function(input, output, session){
  ns <- session$ns
  
  dataframe <- reactive({
    eval(parse(text = paste0("vcrshiny::",input$dataset)))
  })

  return(dataframe)
}

    
## To be copied in the UI
# mod_ts_vis_ui("ts_vis_ui_1")
    
## To be copied in the server
# callModule(mod_ts_vis_server, "ts_vis_ui_1")
 
