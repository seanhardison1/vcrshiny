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
  
  tagList(
    shiny::selectInput(
      ns("dataset"),
      "Select data",
      choices = list("Meteorology" = "meteorology",
                     "Tides & temperature" = "tides"),
      selected = "tides"
    ), 
    
    shiny::selectInput(
      ns("variable"),
      "Select variable",
      choices = list("Avg. Temperature (°C)" = "avg.t"),
      # selected = list("Avg. Temperature (°C)" = "avg.t"),
      selected = "",
      multiple = TRUE
    ),
    
    shiny::sliderInput(
      ns("period"),
      "Select time period",
      min = as.Date("2019-05-05"),
      max = as.Date("2019-09-05"),
      value = c(as.Date("2019-09-05"),
                as.Date("2019-05-05")),
      timeFormat="%b-%Y"
    )
  )
}
    
#' 01_var_select Server Function
#'
#'
#' @noRd 
mod_01_var_select_server <- function(input, output, session) {
  ns <- session$ns

  
  var_choices <- reactive({
    
    if (input$dataset == "meteorology"){
      vars <- 
        list(var_choices = 
             list(
                "Precipitation (ml)" = "ppt",
                "Avg. Temperature (°C)" = "avg.t",
                "Min. Temperature (°C)" = "min.t",
                "Avg. Relative Humidity (%)" = "avg.rh",
                "Min. Relative Humidity (%)" = "min.rh",
                "Max Relative Humidity (%)" = "max.rh",
                "Avg. Wind Speed (m/s)" = "avg.ws",
                "Avg. Wind Angle (°)" = "avg.wang",
                "St. Dev. of Wind Direction (°)" = "std.wang",
                "Solar Radiation (kJ/m^2)" = "rad.sol",
                "PAR (mmol/m^2/hr)" = "par",
                "Soil Temperature (°C)" = "soil.t")
      )
    } else if (input$dataset == "tides"){
      vars <-
        list(var_choices = 
             list(
        "Relative tide level (m)" = "relative_tide_level",
        "Water temperature (°C)" = "water_temperature"#,
      ))
    } 
  })
  
  
  time_period <- reactive({
    
    dft <- eval(parse(text = paste0("vcrshiny::",
                                    input$dataset)))
    print(zoo::index(dft[nrow(dft)]))
    tibble::tibble(end = zoo::index(dft[nrow(dft)])) %>%
                   dplyr::mutate(start = end -  months(lubridate::month(6)),
                                 value = end -  months(lubridate::month(2)))

  })
  
  
  
  observe({
    updateSelectInput(
      session, 
      "variable",
      choices = var_choices()$var_choices,
      selected = var_choices()$var_choices[1]
    )
  })
  
  observeEvent(input$variable, {
    if (length(input$variable) == 2){
      shinyjs::disable("variable")
    }
  })
  
  observe({
    updateSliderInput(
      session,
      "period",
      min = time_period()$start,
      max = time_period()$end,
      value = c(time_period()$value,
                time_period()$end),
      timeFormat="%b-%Y",
      step = 7
    )
  })
  
  return(
    list(
      period = reactive({ input$period }),
      dataset = reactive({ input$dataset }),
      variable = reactive({ input$variable })
    )
  )
}
    
## To be copied in the UI
# mod_01_var_select_ui("01_var_select_ui_1")

## To be copied in the server
# callModule(mod_01_var_select_server, "01_var_select_ui_1")
 
