# server logic
app_server <- function(input, output, session) {

  # execute plot variable selection modules
  plot1vars <- callModule(mod_01_var_select_server, "01_var_select_ui_1")
  
  # execute scatterplot module
  callModule(mod_02_ts_vis_server, 
                    "02_ts_vis_ui_1",
                    plot1vars = plot1vars)

  # execute leaflet module
  callModule(mod_03_veg_surv_server, "03_veg_surv_ui_1")
}
