#' The application User-Interface
#' 
#' @param request Internal parameter for `{shiny}`. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request){
  
# Navigation bar---------------------------------------------------------------
  
  bootstrapPage(
    shinyFeedback::useShinyFeedback(),
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
             
      div(class = "outer",
        tags$head(includeCSS("styles.css")),
        shiny::titlePanel("Marsh vegetation surveys"),
        
        mod_03_veg_surv_ui("03_veg_surv_ui_1"),
        
        shiny::absolutePanel(
          id = "controls",
          mod_04_veg_var_select_ui("04_veg_var_select_ui_1"),
          class = "panel panel-default",
          top = 70, left = 55, width = 330, fixed=F,
          draggable = TRUE, height = "auto"
            ),
          shiny::absolutePanel(
            id = "controls",
            mod_05_veg_plotting_ui("05_veg_plotting_ui_1"),
            class = "panel panel-default",
            top = 400, left = 55, width = 500, fixed=F,
            draggable = TRUE, height = "auto"
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