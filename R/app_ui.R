#' The application User-Interface
#' 
#' @param request Internal parameter for `{shiny}`. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request){
  
  # Navigation bar---------------------------------------------------------------
  
  bootstrapPage(theme = shinythemes::shinytheme("simplex"),#theme = "styles.css",
    
                # shinyFeedback::useShinyFeedback(),
                # navbarPage(theme = shinythemes::shinytheme("simplex"), collapsible = TRUE,
                #            "VCR Data Explorer", id="nav",
                           # Marsh vegetation surveys----------------------------------------------------
                         #   tabPanel("Marsh Vegetation",
                         #            
                         #            div(class = "outer",
                         #                shiny::titlePanel("Marsh vegetation surveys"),
                         #                
                         #                mod_03_veg_surv_ui("03_veg_surv_ui_1"),
                         #                
                         #                shiny::absolutePanel(
                         #                  id = "controls",
                         #                  mod_04_veg_var_select_ui("04_veg_var_select_ui_1"),
                         #                  class = "panel panel-default",
                         #                  top = 140, left = 55, width = 330, fixed=F,
                         #                  draggable = TRUE, height = "auto"
                         #                ),
                         #                shiny::absolutePanel(
                         #                  id = "controls",
                         #                  mod_05_veg_plotting_ui("05_veg_plotting_ui_1"),
                         #                  class = "panel panel-default",
                         #                  top = 400, left = 55, width = 725, fixed=F,
                         #                  draggable = TRUE, height = "auto"
                         #                ),
                         #                shiny::absolutePanel(
                         #                  id = "controls",
                         #                  tags$div(
                         #                    shiny::h4("End of Year Biomass in Marshes of the Virginia Coast Reserve, 1999-2017"),
                         #                    shiny::HTML("<p>Brinson et al. (1995) developed a model representing the change that occurs in ecosystem state 
                         # (or habitat type) along the shorezone, from the forest -> high marsh -> low marsh -> mud flat, 
                         # in response to the increased inundation caused by rising sea-level. They suggested that a seaward shift 
                         # in ecosystem state is largely dependent on local slope and sediment supply.</p>"),
                         #                    
                         #                    shiny::HTML("<p>The states are associated with the dominant vegetation found within each. The most seaward (lowest in 
                         # elevation) state is the mud flat. It is frequently inundated by tide and typically supports algal species. The 
                         # next landward state is the mineral low marsh; it is dominated by <em>Spartina alterniflora</em> and is typically flooded 
                         # at high tide. Sediments here may be largely mineral in origin. The next landward state is the high 
                         # marsh; it may be dominated by <em>S. patens</em>, <em>Distichlis spicata</em>, and <em>Juncus roemerianus</em>. It is occasionally 
                         # inundated by high tides and the soil is usually organic. The transition zone between the high marsh and 
                         # the forest is typically dominated by <em>Iva frutescens</em>, <em>Baccharis hamifolia</em>, and <em>Juniperus virginiana</em>. It 
                         # is only inundated during severe storm surges. The forest may be dominated by either pines or hardwoods 
                         # and is again flooded with sea water only by storm surges.</p>"),
                         #              
                         #                    
                         #                    shiny::h4("References"),
                         #                    
                         #                    shiny::HTML("<p> Christian, R. and L. Blum. 2017. End of Year Biomass in Marshes of the Virginia Coast Reserve 1999-2017. 
                         # Virginia Coast Reserve Long-Term Ecological Research Project
                         # Data Publication knb-lter-vcr.167.25 (<a href='http://doi.org/10.6073/pasta/eec055c0416a916b37c5d8079f32acc7'>doi:10.6073/pasta/eec055c0416a916b37c5d8079f32acc7</a>).</p>")
                         #                  ),
                         #                  class = "panel panel-default",
                         #                  top = 140, right = 55, width = 550, fixed=F,
                         #                  draggable = TRUE, height = "auto"
                         #                )
                         #            )
                         #   ),               
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
                           )
                           
                # )
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