# server logic
app_server <- function(input, output, session) {
  
  # execute plot variable selection modules
  plot1vars <- callModule(mod_01_var_select_server, 
                          "01_var_select_ui_1")
  
  # execute time series module
  df_in <- 
    callModule(mod_02_ts_vis_server, 
             "02_ts_vis_ui_1",
             plot1vars = plot1vars)
  
  callModule(mod_03_data_download_server,
               id = "03_data_download_ui_1",
               df_in = df_in)
  
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
