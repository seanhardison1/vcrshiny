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
  
  # Travis CI is updated once a day at around 3 pm EST. 
  # This step sources the latest data when the app is initialized to side-step the need to the package
  new_data <- vcrshiny:::real_time_query()
  
  plot1_obj <- shiny::reactive({
    
    if(!is.null(plot1vars$variable())){
      # print(plot1vars$agg_step())
      
      ylabel <- NULL 
      for (i in 1:length(plot1vars$variable())){
        ylabel[i] <- switch(plot1vars$variable()[i],
                            "ppt" = "Precipitation (ml)",
                            "avg.t" = "Avg. Temperature (°C)",
                            "min.t" = "Min. Temperature (°C)",
                            "avg.rh" = "Avg. Relative Humidity (%)",
                            "min.rh" = "Min. Relative Humidity (%)",
                            "max.rh" = "Max Relative Humidity (%)",
                            "avg.ws" = "Avg. Wind Speed (m/s)",
                            "avg.wang" = "Avg. Wind Angle (°)",
                            "std.wang" = "St. Dev. of Wind Direction (°)",
                            "rad.sol" = "Solar Radiation (kJ/m<sup>2</sup>)",
                            "par" = "PAR (mmol/m<sup>2</sup>/hr)",
                            "soil.t" = "Soil Temperature (°C)",
                            "relative_tide_level" ="Relative tide level (m)",
                            "water_temperature"  = "Water temperature (°C)",
                            "barometric_pressure" = "Barometric pressure (mm)"
        )
      }
      
      # select data set and period of interest
      df <- eval(parse(text = paste0("vcrshiny::", plot1vars$dataset())))
      
      # bind in data queried after Travis build
      if (plot1vars$dataset() == "tides"){
        df <- rbind(df, new_data$tides_new)
        print(tail(df))
        # print(tail(tides_new_xts_rt))
      } else if (plot1vars$dataset() == "meteorology"){
        df <- rbind(df, new_data$meteo_new)
        print(tail(df))
        # print(tail(meteo_new_xts_rt))
      }
      
      # remove duplicates if they exist
      df <- xts::make.index.unique(df,drop=TRUE)
      
      # trim to selected time range
      df2 <- df[paste0(plot1vars$period()[1],"/",plot1vars$period()[2])]
      print(tail(df2))
      # aggregate data if selected
      if (plot1vars$agg_step() != "Six minutes"){
        agg_step <-
          switch(plot1vars$agg_step(),
                 "One hour" = "60",
                 "One day" = "1440",
                 "One week" = "10080")
        df <- xts::period.apply(df[, plot1vars$variable()],
                                INDEX = xts::endpoints(df, "mins", k=as.numeric(agg_step)),
                                FUN = mean)
      }
      
      # create a plot from one or two variables  
      if (length(plot1vars$variable()) == 1){
        print(tail(df2))
        p <- dygraphs::dygraph(df2[, plot1vars$variable()]) %>% 
          dygraphs::dySeries(plot1vars$variable(), 
                             label = ylabel) %>%
          dygraphs::dyAxis("y",label = ylabel) %>% 
          dygraphs::dyOptions(connectSeparatedPoints = TRUE) 
        
      } else if (length(plot1vars$variable()) == 2) {
        p <- dygraphs::dygraph(df2[, plot1vars$variable()]) %>% 
          dygraphs::dySeries(plot1vars$variable()[1], 
                             label = ylabel[1]) %>%
          dygraphs::dyAxis("y",label = ylabel[1]) %>%
          
          dygraphs::dySeries(plot1vars$variable()[2], axis = 'y2') %>% 
          dygraphs::dyAxis("y2",label = ylabel[2]) %>% 
          dygraphs::dyOptions(connectSeparatedPoints = TRUE) 
      } 
      
      
      # if no choices, return an empty plot
    } else {
      return()
    }
    
    
  })
  
  output$plot1 <- dygraphs::renderDygraph({
    plot1_obj()
  })
  
}

## To be copied in the UI
# mod_02_ts_vis_ui("02_ts_vis_ui_1")

## To be copied in the server
# callModule(mod_02_ts_vis_server, "02_ts_vis_ui_1")

