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
    `Precipitation (ml)` = "ppt",
    `Avg. Temperature (°C)` = "avg.t",
    `Min. Temperature (°C)` = "min.t",
    `Avg. Relative Humidity (%)` = "avg.rh",
    `Min. Relative Humidity (%)` = "min.rh",
    `Max Relative Humidity (%)` = "max.rh",
    `Avg. Wind Speed (m/s)` = "avg.ws",
    `Avg. Wind Angle (°)` = "avg.wang",
    `St. Dev. of Wind Direction (°)` = "std.wang",
    `Solar Radiation (kJ/m^2)` = "rad.sol",
    `PAR (mmol/m^2/hr)` = "par",
    `Soil Temperature (°C)` = "soil.t"
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
 
