#' 05_veg_plotting UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_05_veg_plotting_ui <- function(id){
  ns <- NS(id)
  tagList(
    shiny::plotOutput(ns("veg_plot"))
  )
}
    
#' 05_veg_plotting Server Function
#'
#' @noRd 
mod_05_veg_plotting_server <- function(input, 
                                       output, 
                                       session, 
                                       leafvars){
  ns <- session$ns
  
  df <- reactive({
  
    vcrshiny::marsh_veg[vcrshiny::marsh_veg$marshName %in% leafvars$marsh_locs() &
                        vcrshiny::marsh_veg$year >= leafvars$period_choice()[1]  &
                        vcrshiny::marsh_veg$year <= leafvars$period_choice()[2]  &
                        vcrshiny::marsh_veg$speciesName %in% leafvars$spec_choices(),]
    
  }) 

  

  output$veg_plot <- shiny::renderPlot({
    
    if (is.null(leafvars$spec_choices())) return()
    # browser()
    ggplot2::ggplot(df()) +
      ggplot2::geom_point(ggplot2::aes(x = year, 
                                       y = liveMass,
                                       color = marshName,
                                       group = year)) +
      ggplot2::facet_wrap(.~speciesName) +
      ggsci::scale_color_d3() +
      ggplot2::theme(
        strip.background = ggplot2::element_blank(),
        panel.grid.major = ggplot2::element_blank(),
        panel.grid.minor = ggplot2::element_blank(),
        panel.background = ggplot2::element_blank(),
        panel.border = ggplot2::element_rect(colour = "black", fill=NA,
                                    size=0.2),
        legend.key = ggplot2::element_blank(),
        axis.title = ggplot2::element_text(size = 10)
      )
    
  })
  

  
}
    
## To be copied in the UI
# mod_05_veg_plotting_ui("05_veg_plotting_ui_1")
    
## To be copied in the server
# callModule(mod_05_veg_plotting_server, "05_veg_plotting_ui_1")
 
