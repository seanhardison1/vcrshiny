#' 07_fish_plotting UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_07_fish_plotting_ui <- function(id){
  ns <- NS(id)
  tagList(
    shiny::plotOutput(ns("fish_plot")),
    shinyFeedback::loadingButton(ns("fish_plot_button"), 
                                 "Generate figure")
  )
}
    
#' 07_fish_plotting Server Function
#'
#' @noRd 
mod_07_fish_plotting_server <- function(input, output, session){
  ns <- session$ns
  
  # Filter data based on selections
  df <- eventReactive(input$fish_plot_button, {
    
    if(is.null(fishvars$fish_spec_choices())){
      return()
    }
    
    if (fishvars$meadow_locs() == "Aggregate meadows"){
      int <- vcrshiny::fish %>% 
        dplyr::filter(sciName %in% fishvars$fish_spec_choices(),
                      lubridate::year(sampleDate) >= fishvars$fish_period_choice()[1],
                      lubridate::year(sampleDate) <= fishvars$fish_period_choice()[2]) %>% 
        dplyr::group_by(time = get(fishvars$temp_res())) %>% 
        dplyr::summarise(Fish = sum(nFish)) %>% 
        tsibble::tsibble(time) %>% 
        tsibble::fill_gaps() 
    } else {
      int <- vcrshiny::fish %>% 
        dplyr::filter(sciName %in% fishvars$fish_spec_choices(),
                      lubridate::year(sampleDate) >= fishvars$fish_period_choice()[1],
                      lubridate::year(sampleDate) <= fishvars$fish_period_choice()[2],
                      meadow == fishvars$meadow_locs()) %>% 
        dplyr::group_by(time = get(fishvars$temp_res())) %>% 
        dplyr::summarise(Fish = sum(nFish)) %>% 
        tsibble::tsibble(time) %>% 
        tsibble::fill_gaps()
    }
    
    return(int)
  })
  
  # Reset loading button after 1 second
  observeEvent(input$fish_plot_button, {
    Sys.sleep(1)
    shinyFeedback::resetLoadingButton("fish_plot_button")
  })
  
  # Show figure
  output$fish_plot <- shiny::renderPlot({
    
    if (is.null(fishvars$fish_spec_choices())) return()
    
    ggplot(data = int) +
      geom_bar(aes(x = time,
                   y = Fish), stat = "identity") +
      labs(x = "Time",
           y = "Abundance") +
      ggsci::scale_color_d3() +
      if (t == "yearmon"){ 
        tsibble::scale_x_yearmonth(expand = c(0.01, 0.01))
      } else if (t == "yearquarter"){
        tsibble::scale_x_yearquarter(expand = c(0.01, 0.01))
      } else if (t == "year"){
        scale_x_continuous(expand = c(0.01, 0.01))
      }
    
  })
  
  
}
    
## To be copied in the UI
# mod_07_fish_plotting_ui("07_fish_plotting_ui_1")
    
## To be copied in the server
# callModule(mod_07_fish_plotting_server, "07_fish_plotting_ui_1")
 
