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
    selectInput(ns("dataset"), 
                choices = list("Meterology" = "meteorology"),
                label = "Data"),
    selectInput(ns("variable"),
                choices = list("PPT" = "ppt",
                               "Avg. Temperature" = "avg.t",
                               "PAR" = "par"),
                selected = "PPT",
                label = "Variable name"),
    selectInput(ns("station"),
                choices = list("HOG2" = "HOG2",
                               "OYSM" = "OYSM",
                               "PHCK2" = "PHCK2"),
                selected = "HOG2",
                label = "Station")
  )
}
    
#' ts_vis Server Function
#'
#' @noRd 
mod_ts_vis_server <- function(input, output, session){
  ns <- session$ns
  
  dataframe <- reactive({
    df <- eval(parse(text = paste0("vcrshiny::",input$dataset))) 
    df %<>%
      filter(station == input$station) %>% 
      dplyr::select(datetime, input$variable)
  })
  
  return(dataframe)
}

    
## To be copied in the UI
# mod_ts_vis_ui("ts_vis_ui_1")
    
## To be copied in the server
# callModule(mod_ts_vis_server, "ts_vis_ui_1")
 
