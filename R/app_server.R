app_server <- function(input, output, session, df, on = T) {

  # fill in data collected since last build
  if (on){
    df <- vcrshiny:::rtq()
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
}
