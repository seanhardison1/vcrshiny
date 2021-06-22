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
                                 plot1vars,
                                 df) {
  ns <- session$ns

  plot1_obj <- shiny::reactive({
    
    print(head(df))
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
      # browser()
      # trim to selected time range
      df2 <- df[paste0(plot1vars$period()[1],"/",plot1vars$period()[2])]
      df2 <- df2[, plot1vars$variable()]
      
      # browser()
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
      
      
      # browser()
      # print(plot1vars$ref_step())
      # create a plot from one or two variables  
      if (length(plot1vars$variable()) == 1){
        # print(tail(df2))
        p <- dygraphs::dygraph(df2) %>% 
          dygraphs::dySeries(plot1vars$variable(), 
                             label = ylabel) %>%
          dygraphs::dyAxis("y",label = ylabel) %>% 
          dygraphs::dyOptions(connectSeparatedPoints = F,
                              useDataTimezone = TRUE) %>% 
          
          {if (plot1vars$variable() == "ppt" & 
               plot1vars$ref_check() &
               plot1vars$agg_step() == "One hour")
            dygraphs::dyShading(.,from = vcrshiny::extremes$precip_mean -
                                  vcrshiny::extremes$precip_2_sd, 
                                to = vcrshiny::extremes$precip_mean +
                                  vcrshiny::extremes$precip_2_sd, axis = "y")
            else if (plot1vars$variable() == "relative_tide_level" & 
                     plot1vars$ref_check() &
                     plot1vars$agg_step() == "One hour")
              dygraphs::dyShading(.,from = vcrshiny::extremes$tides_mean -
                                    vcrshiny::extremes$tides_2_sd, 
                                  to = vcrshiny::extremes$tides_mean +
                                    vcrshiny::extremes$tides_2_sd, axis = "y")
            else if (plot1vars$variable() == "avg.ws" & 
                     plot1vars$ref_check() &
                     plot1vars$agg_step() == "One hour")
              dygraphs::dyShading(.,from = vcrshiny::extremes$wind_speed_mean -
                                    vcrshiny::extremes$wind_speed_2_sd, 
                                  to = vcrshiny::extremes$wind_speed_mean +
                                    vcrshiny::extremes$wind_speed_2_sd, axis = "y")
            else .} 
        
      } else if (length(plot1vars$variable()) == 2) {
        
        p <- dygraphs::dygraph(df2) %>% 
          dygraphs::dySeries(plot1vars$variable()[1], 
                             label = ylabel[1]) %>%
          dygraphs::dyAxis("y",label = ylabel[1]) %>%
          dygraphs::dySeries(plot1vars$variable()[2], axis = 'y2') %>% 
          dygraphs::dyAxis("y2",label = ylabel[2]) %>% 
          dygraphs::dyOptions(connectSeparatedPoints = F,
                              useDataTimezone = TRUE)
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

  output$plot1 <- dygraphs::renderDygraph({
    # plot1vars$ref_check()
    plot1_obj()[[1]]
  })
  
  return(
    list(
      p = reactive({  plot1_obj()[[1]] }),
      df = reactive({ plot1_obj()[[2]] })
    )
  )
  
}

## To be copied in the UI
# mod_02_ts_vis_ui("02_ts_vis_ui_1")

## To be copied in the server
# callModule(mod_02_ts_vis_server, "02_ts_vis_ui_1")