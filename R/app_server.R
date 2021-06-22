rtq <- function(){
  rtq <- vcrshiny:::real_time_query()
  rtq$ltm_water_temperature <- NA
  rtq$ltm_avg_t <- NA
  rtq <- rtq[, names(vcrshiny::vcr_phys_vars)]
  # print(head(rtq))
  df <- rbind(rtq, vcrshiny::vcr_phys_vars)
  # tail(df,10)
  return(df)
}

app_server <- function(input, output, session, df, on = T) {

  # fill in data collected since last build
  if (on){
    df <- rtq()
  } else {
    df <- vcrshiny::vcr_phys_vars
  }
  
  # execute plot variable selection modules
  plot1vars <- callModule(mod_01_var_select_server, 
                          "01_var_select_ui_1")
  
  # execute time series module
  df_in <- 
    callModule(mod_02_ts_vis_server, 
             "02_ts_vis_ui_1",
             plot1vars = plot1vars,
             df = df)
  
  # execute module for downloading data
  callModule(mod_03_data_download_server,
               id = "03_data_download_ui_1",
               df_in = df_in)
  
  # execute module for reference lines
  # callModule(mod_04_reference_lines_server,
  #            id = "04_reference_lines_ui_1",
  #            plot1vars = plot1vars,
  #            df_in = df_in)
  # 
  # execute marsh vegetation variable selection module
  # leafvars <- callModule(mod_04_veg_var_select_server, 
  #                        "04_veg_var_select_ui_1")
  
  # execute leaflet module
  # callModule(mod_03_veg_surv_server, 
  #            "03_veg_surv_ui_1",
  #            leafvars = leafvars)
  
  # plotting module for marsh vegetation
  # callModule(mod_05_veg_plotting_server, 
  #            "05_veg_plotting_ui_1",
  #            leafvars = leafvars)
  
  
}
