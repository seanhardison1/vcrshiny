#' veg_surv UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_03_veg_surv_ui <- function(id){
  ns <- NS(id)
  leaflet::leafletOutput(ns("vcrmap"), width = "100%", height = "800px")
}
    
#' veg_surv Server Function
#'
#' @noRd 
mod_03_veg_surv_server <- function(input, output, session){
  ns <- session$ns
  
  output$vcrmap <- leaflet::renderLeaflet({
    leaflet::leaflet(data = vcrshiny::marsh_veg_locs, height=500) %>% 
      leaflet::addTiles() %>% 
      leaflet::setView(lng = -75.8, lat = 37.5, zoom = 10) %>% 
      leaflet::addCircleMarkers(lng = ~longitude, lat = ~latitude, label = ~marshName,
                                stroke = FALSE, fillOpacity = 0.5)
  })
 
}
    
## To be copied in the UI
# mod_03_veg_surv_ui("03_veg_surv_ui_1")
    
## To be copied in the server
# callModule(mod_03_veg_surv_server, "03_veg_surv_ui_1")
 
