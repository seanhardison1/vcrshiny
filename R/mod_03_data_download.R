#' data_download UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_03_data_download_ui <- function(id){
  ns <- NS(id)
  tagList(
    downloadButton(ns("data_download"), 
                   label = "Download data")
  )
}
    
#' mod_03_data_download_server Server Functions
#'
#' @noRd 
mod_03_data_download_server <- function(input, 
                                        output, 
                                        session,
                                       df_in){
  ns <- session$ns
  output$data_download <- downloadHandler(
    filename = function() {
      paste("data-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write.csv(df_in(), file) 
    }
  )
}
    
## To be copied in the UI
# mod_03_data_download_ui("03_data_download_ui_1")
    
## To be copied in the server
# mod_03_data_download_server("03_data_download_ui_1")
