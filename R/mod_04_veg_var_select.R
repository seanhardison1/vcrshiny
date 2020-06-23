#' 04_veg_var_select UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_04_veg_var_select_ui <- function(id){
  ns <- NS(id)
  tagList(
    shiny::selectizeInput(
      ns("marsh_loc"),
      "Select location(s)",
      choices = vcrshiny::marsh_veg_locs$marshName,
      selected = "Oyster",
      multiple = TRUE
    ),
    
    shiny::selectizeInput(
      ns("species"),
      "Select species",
      choices = "",
      selected = NULL,
      multiple = TRUE
    ),
    
    shiny::sliderInput(
      ns("period_veg"),
      "Select time period",
      min = 1999,
      max = 2018,
      value = c(1999, 2018),
      sep = ""
    )
  )
}
    
#' 04_veg_var_select Server Function
#'
#' @noRd 
mod_04_veg_var_select_server <- function(input, output, session){
  ns <- session$ns

  
  # Species choices are based on marsh location(s)------------------
  spec_choices <- reactive({
      vcrshiny::marsh_veg %>% 
        dplyr::filter(marshName %in% input$marsh_loc) %>% 
        dplyr::pull(speciesName) %>% 
        unique()
    })
  
  # Update species choices
  observe({
    updateSelectInput(
      session, 
      "species",
      choices = spec_choices()
    )
  })

  # Period choice is based on marsh location(s)--------------------
  period_choice <- reactive({
    
    if (is.null(input$species)){
      dplyr::tibble(end = 2018,
            start = 1999,
            value = start)
    } else {
      dplyr::tibble(end = max(vcrshiny::marsh_veg[vcrshiny::marsh_veg$speciesName %in% input$species,]$year)) %>%
        dplyr::mutate(start = min(vcrshiny::marsh_veg[vcrshiny::marsh_veg$speciesName %in% input$species,]$year),
                      value = start) 
    }
  })
  
  observe({
    updateSliderInput(
      session,
      "period_veg",
      min = period_choice()$start,
      max = period_choice()$end,
      value = c(period_choice()$value,
                period_choice()$end)
      )
  })
  
  return(
    list(
      marsh_locs = reactive({ input$marsh_loc })
    )
  )
  
}
    
## To be copied in the UI
# mod_04_veg_var_select_ui("04_veg_var_select_ui_1")
    
## To be copied in the server
# callModule(mod_04_veg_var_select_server, "04_veg_var_select_ui_1")
 
