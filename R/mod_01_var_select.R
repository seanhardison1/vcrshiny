#' 01_var_select UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#' 
#' @noRd
#' 
#' @importFrom shiny NS tagList 
mod_01_var_select_ui <- function(id){
  ns <- NS(id)
  
  # define choices for X and Y variable selection
  station_choices <- list(
    "HOG2" = "HOG2",
    "OYSM" = "OYSM",
    "PHCK2" = "PHCK2"
  )
  variable_choices <- list(
    `Precipitation` = "ppt",
    `Avg. Temperature` = "avg.t",
    `Min. Temperature` = "min.t",
    `Avg. Relative Humidity` = "avg.rh",
    `Min. Relative Humidity` = "min.rh",
    `Max Relative Humidity` = "max.rh"
  )
  
  tagList(
    shiny::selectizeInput(
      ns("station"),
      "Select station",
      choices = station_choices,
      selected = NULL,
      multiple = TRUE
    ),
    
    shiny::selectInput(
      ns("variable"),
      "Select variable",
      choices = variable_choices,
      selected = "ppt"
    )
  )
}
    
#' 01_var_select Server Function
#'
#'
#' @noRd 
mod_01_var_select_server <- function(input, output, session) {
  ns <- session$ns
  
  return(
    list(
      station = shiny::reactive({ input$station }),
      variable = shiny::reactive({ input$variable })
    )
  )
}
    
## To be copied in the UI
# mod_01_var_select_ui("01_var_select_ui_1")

## To be copied in the server
# callModule(mod_01_var_select_server, "01_var_select_ui_1")
 
