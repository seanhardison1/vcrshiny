#' The application User-Interface
#' 
#' @param request Internal parameter for `{shiny}`. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request){
  tagList(
    shiny::fluidPage(theme = shinythemes::shinytheme("simplex"),

      shiny::titlePanel("VCR Data Explorer"),
      
      shiny::fluidRow(
        shiny::column(
          width = 3,
          shiny::wellPanel(
            mod_01_var_select_ui("01_var_select_ui_1")
          )
        ),
        mod_02_ts_vis_ui("02_ts_vis_ui_1")
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