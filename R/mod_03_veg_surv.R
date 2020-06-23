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
mod_03_veg_surv_server <- function(input, output, 
                                   session,
                                   leafvars){
  ns <- session$ns

  # set default color and opacity parameters
  mvl_base <- 
    isolate(vcrshiny::marsh_veg_locs %>% 
        dplyr::mutate(col = ifelse(marshName == "Oyster",
                            "orange",
                            "purple"),
                      alpha = ifelse(marshName == "Oyster",
                                     1,
                                     0.5)))
  
  # leaflet basemap of VCR
  output$vcrmap <- leaflet::renderLeaflet({
    leaflet::leaflet(data = mvl_base) %>% 
      leaflet::addTiles() %>%
      leaflet::setView(lng = -75.8, lat = 37.5, zoom = 10) %>% 
      leaflet::addCircleMarkers(lng = ~longitude,
                                lat = ~latitude, 
                                label = ~marshName,
                                color = ~col,
                                stroke = FALSE, 
                                fillOpacity = ~alpha)
  })
  
  observe({
    
    #leaflet proxy map for manipulating dynamics elements
    proxy_map <- leaflet::leafletProxy("vcrmap") 
    
    # filter locations based on marsh inputs
    df <- vcrshiny::marsh_veg_locs %>% 
            dplyr::filter(marshName %in% leafvars$marsh_locs())
    
    # if no location inputs, show all markers as purple dots
    if (nrow(df) == 0){
      proxy_map %>% 
        leaflet::clearMarkers() %>% 
        leaflet::addCircleMarkers(data = mvl_base,
                                  lng = ~longitude,
                                  lat = ~latitude, 
                                  label = ~marshName,
                                  color = "purple",
                                  stroke = FALSE, 
                                  fillOpacity = 0.5)
    } else {
    # otherwise, highlight markers one by one in orange
      proxy_map %>% 
        leaflet::clearMarkers() %>% 
        leaflet::addCircleMarkers(data = mvl_base,
                                  lng = ~longitude,
                                  lat = ~latitude, 
                                  label = ~marshName,
                                  color = "purple",
                                  stroke = FALSE, 
                                  fillOpacity = 0.5) %>% 
        leaflet::addCircleMarkers(data = df,
                                  lng = ~longitude,
                                  lat = ~latitude, 
                                  label = ~marshName,
                                  stroke = FALSE, 
                                  fillOpacity = 1,
                                  color = "orange")
    }
  })
}
    
## To be copied in the UI
# mod_03_veg_surv_ui("03_veg_surv_ui_1")
    
## To be copied in the server
# callModule(mod_03_veg_surv_server, "03_veg_surv_ui_1")
 
