#' 02_ts_vis UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#' @importFrom shiny NS tagList 
mod_02_ts_vis_ui <-function(id) {
  ns <- NS(id)
  
  shiny::tagList(
    shiny::mainPanel(
      dygraphs::dygraphOutput(ns("plot1"))
    )
  )
}
    
#' 02_ts_vis Server Function
#'
#' @noRd
mod_02_ts_vis_server <- function(input, 
                                 output, 
                                 session, 
                                 plot1vars) {
  ns <- session$ns
  
  plot1_obj <- shiny::reactive({
    
    ylabel <- switch(plot1vars$variable(),
                     "ppt" = "Precipitation (ml)",
                     "avg.t" = "Avg. Temperature (°C)",
                     "min.t" = "Min. Temperature (°C)",
                     "avg.rh" = "Avg. Relative Humidity (%)",
                     "min.rh" = "Min. Relative Humidity (%)",
                     "max.rh" = "Max Relative Humidity (%)",
                     "avg.ws" = "Avg. Wind Speed (m/s)",
                     "avg.wang" = "Avg. Wind Angle (°)",
                     "std.wang" = "St. Dev. of Wind Direction (°)",
                     "rad.sol" = "Solar Radiation (kJ/m^2)",
                     "par" = "PAR (mmol/m^2/hr)",
                     "soil.t" = "Soil Temperature (°C)",
                     "relative_tide_level" ="Relative tide level (m)",
                     "water_temperature"  = "Water temperature (°C)",
                     "barometric_pressure" = "Barometric pressure (mm)"
                     )
    
    if (plot1vars$variable() == "") return()
  

      df <- eval(parse(text = paste0("vcrshiny::", plot1vars$dataset())))
      
      df <- df[df$datetime >= plot1vars$period()[1] &
                 df$datetime < plot1vars$period()[2],]
      

      if (!plot1vars$station() %in% unique(df$station)) {
        return()
      } else {
        df <- df[df$station == plot1vars$station(), ]
      }    
      # browser()
      p <- df %>% 
        tydygraphs::dygraph(!! rlang::sym(plot1vars$variable())) %>% 
        
        dygraphs::dySeries(paste(plot1vars$variable(), 
                                 plot1vars$station(), 
                                 sep = "_"), 
                           label = paste(plot1vars$station(),"-", ylabel)) %>% 
        
        dygraphs::dyAxis("y",label = ylabel) %>% 
        dygraphs::dyOptions(connectSeparatedPoints = TRUE)
      
  })
  
  output$plot1 <- dygraphs::renderDygraph({
    plot1_obj()
  })
 
}
    
## To be copied in the UI
# mod_02_ts_vis_ui("02_ts_vis_ui_1")
    
## To be copied in the server
# callModule(mod_02_ts_vis_server, "02_ts_vis_ui_1")
 
