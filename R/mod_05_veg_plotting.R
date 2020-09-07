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
    shiny::plotOutput(ns("veg_plot")),
    shinyFeedback::loadingButton(ns("plot_button"), 
                                 "Generate figure")
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
  
  # Filter data based on selections
  df <- eventReactive(input$plot_button, {
    
    if(is.null(leafvars$spec_choices())){
      return()
    }
    
    int <- vcrshiny::marsh_veg[vcrshiny::marsh_veg$marshName %in% leafvars$marsh_locs() &
                                 vcrshiny::marsh_veg$year >= leafvars$period_choice()[1]  &
                                 vcrshiny::marsh_veg$year <= leafvars$period_choice()[2]  &
                                 vcrshiny::marsh_veg$speciesName %in% leafvars$spec_choices(),]
    return(int)
  })
  
  # Reset loading button after 1 second
  observeEvent(input$plot_button, {
    Sys.sleep(1)
    shinyFeedback::resetLoadingButton("plot_button")
  })
  
  # Show figure
  output$veg_plot <- shiny::renderPlot({
    
    if (is.null(leafvars$spec_choices())) return()
    
    df() %>% 
      dplyr::mutate(year = factor(year),
                    marshName = factor(marshName)) %>% 
      ggplot2::ggplot() +
      ggplot2::geom_boxplot(ggplot2::aes(x = year, 
                                         y = liveMass,
                                         fill = marshName,
                                         color = marshName),
                            alpha = 0.2) +
      ggsci::scale_fill_d3() +
      ggplot2::facet_wrap(.~speciesName_ital, scales = "free_y") +
      ggplot2::labs(color = "Sampling\n location",
                    fill = "Sampling\n location",
                    x = "Year",
                    y = "Live mass (g 0.625 m<sup>-2</sup>)") +
      ggsci::scale_color_d3() +
      ggplot2::theme(
        strip.text = ggtext::element_markdown(size = 14),
        axis.title.y = ggtext::element_markdown(size = 13),
        axis.title.x = ggplot2::element_text(size = 13),
        axis.text.x = ggplot2::element_text(angle = 45, vjust = 0.8, size = 12),
        strip.background = ggplot2::element_blank(),
        panel.grid.major = ggplot2::element_blank(),
        panel.grid.minor = ggplot2::element_blank(),
        panel.background = ggplot2::element_blank(),
        panel.border = ggplot2::element_rect(colour = "black", fill=NA,
                                             size=0.2),
        legend.key = ggplot2::element_blank(),
        legend.title = ggplot2::element_text(size = 14),
        axis.title = ggplot2::element_text(size = 10))
  })
  
  
}

## To be copied in the UI
# mod_05_veg_plotting_ui("05_veg_plotting_ui_1")

## To be copied in the server
# callModule(mod_05_veg_plotting_server, "05_veg_plotting_ui_1")