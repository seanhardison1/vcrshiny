#' 02_ts_vis UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_02_ts_vis_ui <-function(id) {
  ns <- shiny::NS(id)
  
  shiny::tagList(
    shiny::mainPanel(
      plotly::plotlyOutput(ns("plot1"))
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
  
  plot1_obj <- reactive({
    
    # Get variable names
    variable <- rlang::sym(plot1vars$variable())
    
    ylabel <- switch(plot1vars$variable(),
                     "ppt" = "Precipitation (ml)",
                     "avg.t" = "Avg. temperature (°C)",
                     "min.t" = "Minimum temperature (°C)",
                     "avg.rh" = "Avg. Relative Humidity",
                     "min.rh" = "Min. Relative Humidity",
                     "max.rh" = "Max Relative Humidity"
    )
    
    if (!is.null(plot1vars$station())){
      df <- vcrshiny::meteorology %>% 
        dplyr::filter(station %in% plot1vars$station())
    } else {
      df <- vcrshiny::meteorology
    }
    
    #plot data
    p <- ggplot(data = df) +
      geom_line(aes(x = datetime, y = get(paste(variable)),
                    color = station)) +
      theme_bw() +
      ylab(ylabel)
    
    return(ggplotly(p))
  })
  
  output$plot1 <- renderPlotly({
    plot1_obj()
  })
  
}
    
## To be copied in the UI
# mod_02_ts_vis_ui("02_ts_vis_ui_1")
    
## To be copied in the server
# callModule(mod_02_ts_vis_server, "02_ts_vis_ui_1")
 
