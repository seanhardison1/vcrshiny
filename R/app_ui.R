#' The application User-Interface
#' 
#' @param request Internal parameter for `{shiny}`. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request){
  
# Navigation bar---------------------------------------------------------------
  
  bootstrapPage(
    navbarPage(theme = shinythemes::shinytheme("simplex"), collapsible = TRUE,
               "VCR Data Explorer", id="nav",
               
# Tides and meteorological data------------------------------------------------
    tabPanel("Tides and Meteorology",
    # shiny::fluidPage(theme = shinythemes::shinytheme("simplex"),

      shiny::titlePanel("Tides and meteorology"),
      
      shiny::fluidRow(
        shiny::column(
          width = 3,
          shiny::wellPanel(
            mod_01_var_select_ui("01_var_select_ui_1")
          )
        ),
        mod_02_ts_vis_ui("02_ts_vis_ui_1")
       )
      ),
    
# Marsh vegetation surveys----------------------------------------------------
    tabPanel("Marsh Vegetation",
             tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
      shiny::titlePanel("Marsh vegetation surveys"),
      fluidPage(
        shiny::column(
          width = 3,
          shiny::wellPanel(
            mod_04_veg_var_select_ui("04_veg_var_select_ui_1")
          )
        ),
        shiny::mainPanel(
          mod_03_veg_surv_ui("03_veg_surv_ui_1")
        )
       )
      )
    )
  )
}

  
#' Add external Resources to the Application
#' 
#' This function is internally used to add external 
#' resources inside the Shiny application. 
#' 
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function(){
  
  add_resource_path(
    'www', app_sys('app/www')
  )
  
  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys('app/www'),
      app_title = 'vcrshiny'
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert() 
  )
}