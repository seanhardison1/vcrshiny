#' 01_var_select UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#' 
#' @noRd
#' 
#' @importFrom shiny NS tagList 
#' 

mod_01_var_select_ui <- function(id){
  ns <- NS(id)
  
  tagList(
    shiny::selectInput(
      ns("variable"),
      "Select variable",
      choices = list("Precipitation (ml)" = "ppt",
                      "Avg. air temperature (°C)" = "avg.t",
                      "Avg. wind speed (m/s)" = "avg.ws",
                      "Relative tide level (m)" = "relative_tide_level",
                      "Water temperature (°C)" = "water_temperature"),
      selected = list("Avg. air Temperature (°C)" = "avg.t"),
      multiple = TRUE
    ),
    
    shiny::sliderInput(
      ns("period"),
      "Select time period",
      min = Sys.Date() - lubridate::years(10),
      max = Sys.Date(),
      value = c(Sys.Date() - months(lubridate::month(12)),
                Sys.Date()),
      timeFormat="%b-%Y"
    ),
    
    shinyWidgets::radioGroupButtons(
      ns("agg_step"), 
      label = "Aggregate data", 
      choices = c("One hour","One day", "One week","One month"),
      selected = "One hour",
      size = "xs"
    ),
    
    textOutput(ns("text"))
  )
  
}

#' 01_var_select Server Function
#'
#'
#' @noRd 
mod_01_var_select_server <- function(input, output, session) {
  ns <- session$ns
  
  
  
  output$text <- renderText({ 
      text <- vector()
      for (i in 1:length(input$variable)) {
        text[i] <- switch(input$variable[i],
                          "ppt" = "precipitation (ml)",
                          "avg.t" = "air temperature (°C)",
                          "avg.ws" = "wind Speed (m/s)",
                          "relative_tide_level" ="relative tide level (m)",
                          "water_temperature"  = "water temperature (°C)")
      }
      # browser()
      paste0("You've selected ",ifelse(length(text) > 1, paste(text[1],text[2],sep = " and "),text),". ",
                                       "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus suscipit non justo 
                                       id semper. Phasellus eu dui arcu. Integer ac ultrices risus, non maximus arcu. Donec
                                       ullamcorper rhoncus tortor, vitae vehicula ex elementum consequat. Pellentesque at 
                                       eleifend tellus. Nam sed rutrum odio, in tincidunt orci. Duis et condimentum sem, 
                                       ac sollicitudin justo. Nunc scelerisque non libero sed congue.") 
    })
  
  # time_period <- 
  #   tibble::tibble(end = Sys.time()) %>%
  #     dplyr::mutate(start = end -  months(lubridate::month(12)),
  #                   value = end -  months(lubridate::month(2)))
  # 
  # observe({
  #   updateSliderInput(
  #     session,
  #     "period",
  #     value = c(time_period$value,
  #               time_period$end),
  #     timeFormat="%b-%Y",
  #     step = 7
  #   )
  # })
  
  observeEvent(input$variable, {
    if (length(input$variable) > 2) {
      shinyjs::alert("Only two variables may be displayed at one time.")
      shinyjs::reset("variable")
    } 
  })
  
  return(
    list(
      period = reactive({ input$period }),
      variable = reactive({ input$variable }),
      dataset = reactive({ input$dataset }),
      agg_step = reactive({ input$agg_step })
    )
  )
}

## To be copied in the UI
# mod_01_var_select_ui("01_var_select_ui_1")

## To be copied in the server
# callModule(mod_01_var_select_server, "01_var_select_ui_1")

