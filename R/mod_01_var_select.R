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
    fluidRow(
      column(8, align="left",
             shiny::selectInput(
               ns("variable"),
               "Select variable",
               choices = list("Precipitation (cu in)" = "ppt",
                              "Avg. air temperature (°F)" = "avg.t",
                              "Avg. wind speed (ft/s)" = "avg.ws",
                              "Relative tide level (ft)" = "relative_tide_level",
                              "Water temperature (°F)" = "water_temperature"),
               selected = list("Relative tide level (ft)" = "relative_tide_level"),
               multiple = TRUE
             )
      ),
      column(4, align = "center",
             br(),
             br(),
             shinyWidgets::prettyCheckbox(
               inputId = ns("ref_check"), label = "Include reference*", 
               icon = icon("check"), value = F
             ),
      )
    ),

    shiny::sliderInput(
      ns("period"),
      "Select time period",
      min = Sys.Date() - lubridate::years(1),
      max = Sys.Date(),
      value = c(Sys.Date() - months(lubridate::month(1)),
                Sys.Date()),
      timeFormat="%b-%Y"
    ),
    
    fluidRow(
      column(7, 
           shinyWidgets::radioGroupButtons(
             ns("agg_step"), 
             label = "Aggregate data", 
             choices = c("One hour","One day", "One week","One month"),
             selected = "One hour",
             size = "xs"
          )
        ),
      column(5,
             br(),
         mod_03_data_download_ui(id = "03_data_download_ui_1")

       )
     ),
    # textOutput(ns("text"))
    br(),
    p("*Reference shading refers to the long-term time series mean (2006-present for tidal data and 1991-present for 
      meteorological data) +/- 2 standard deviations.")
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
      if (length(input$variable) > 0){
        for (i in 1:length(input$variable)) {
          text[i] <- switch(input$variable[i],
                            "ppt" = "precipitation (cu in)",
                            "avg.t" = "air temperature (°F)",
                            "avg.ws" = "wind Speed (ft/s)",
                            "relative_tide_level" ="relative tide level (ft)",
                            "water_temperature"  = "water temperature (°F)")
        }
      } else {
        shinyjs::alert("A variable must be selected for the plot to appear.")
      }
    })
  
  observeEvent(input$variable, {
    # browser()
    if (any(length(input$variable) == 2, input$variable %in% c("water_temperature",
                                                            "avg.t"))){
      shinyjs::hideElement("ref_check")
    } else if (length(input$variable) > 2) {
      shinyjs::alert("Only two variables may be displayed at one time.")
      shinyjs::reset("variable")
    } else if (length(input$variable) == 1) {
      shinyjs::showElement("ref_check")
    }
  })  
  
  observeEvent(input$agg_step, {
    if (input$agg_step != "One hour"){
      shinyjs::hideElement("ref_check")
    } else {
      shinyjs::showElement("ref_check")
    }
  })

  return(
    list(
      period = reactive({ input$period }),
      variable = reactive({ input$variable }),
      dataset = reactive({ input$dataset }),
      agg_step = reactive({ input$agg_step }),
      ref_check = reactive({ input$ref_check })
    )
  )
}

## To be copied in the UI
# mod_01_var_select_ui("01_var_select_ui_1")

## To be copied in the server
# callModule(mod_01_var_select_server, "01_var_select_ui_1")

