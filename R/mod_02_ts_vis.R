#' 02_ts_vis UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#' @importFrom shiny NS tagList 
#' 
#' 

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
    
    if(!is.null(plot1vars$variable())){
      
      ylabel <- NULL 
      for (i in 1:length(plot1vars$variable())){
        ylabel[i] <- switch(plot1vars$variable()[i],
                            "ppt" = "Precipitation (cu in)",
                            "avg.t" = "Air temperature (°F)",
                            "avg.ws" = "Wind Speed (ft/s)",
                            "relative_tide_level" ="Relative tide level (ft)",
                            "water_temperature"  = "Water temperature (°F)"
        )
      }
      
      # trim to selected time range
      df2 <- vcrshiny::vcr_phys_vars[paste0(plot1vars$period()[1],"/",plot1vars$period()[2])]
      df2 <- df2[, plot1vars$variable()]
      
      # aggregate data if selected
      if (plot1vars$agg_step() != "One hour"){
        
        # browser()
        agg_step <-
          switch(plot1vars$agg_step(),
                 "One day" = "1440",
                 "One week" = "10080",
                 "One month" = "43800")
        
        df2 <- xts::period.apply(df2,
                                 INDEX = xts::endpoints(df2, "mins", k = as.numeric(agg_step)),
                                 FUN =  mean, na.rm = T)
      }
      
      
      # create a plot from one or two variables  
      if (length(plot1vars$variable()) == 1){
        print(tail(df2))
        p <- dygraphs::dygraph(df2) %>% 
          dygraphs::dySeries(plot1vars$variable(), 
                             label = ylabel) %>%
          dygraphs::dyAxis("y",label = ylabel) %>% 
          dygraphs::dyOptions(connectSeparatedPoints = F) 
        
      } else if (length(plot1vars$variable()) == 2) {
        p <- dygraphs::dygraph(df2) %>% 
          dygraphs::dySeries(plot1vars$variable()[1], 
                             label = ylabel[1]) %>%
          dygraphs::dyAxis("y",label = ylabel[1]) %>%
          
          dygraphs::dySeries(plot1vars$variable()[2], axis = 'y2') %>% 
          dygraphs::dyAxis("y2",label = ylabel[2]) %>% 
          dygraphs::dyOptions(connectSeparatedPoints = F) 
      } 
      output <- list(p = p,
                     df = df2)
      output
      
      # if no choices, return an empty plot
    } else {
      output <- list(p = NULL,
                     df = NULL)
      output
    }
    
  })
  
  callModule(mod_03_data_download_server,
             id = "03_data_download_ui_1",
             df_in = plot1_obj()[[2]])
  
  output$plot1 <- dygraphs::renderDygraph({
    plot1_obj()[[1]]
  })
  
}

## To be copied in the UI
# mod_02_ts_vis_ui("02_ts_vis_ui_1")

## To be copied in the server
# callModule(mod_02_ts_vis_server, "02_ts_vis_ui_1")