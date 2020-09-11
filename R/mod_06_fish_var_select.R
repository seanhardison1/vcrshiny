#' fish_var_select UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_06_fish_var_select_ui <- function(id){
  ns <- NS(id)
  tagList(
    shiny::selectizeInput(
      ns("meadow"),
      "Select meadow",
      choices = c("Aggregate meadows","Hog Island Bay", "South Bay"),
      selected = "Aggregate meadows"
    ),
    
    shiny::selectizeInput(
      ns("temp_res"),
      "Temporal resolution",
      choices = c("Year", "Year-quarter", "Year-month","Sampling date"),
      selected = "Year-season"
    ),
    
    shiny::selectizeInput(
      ns("species"),
      "Select taxa",
      choices = stringr::str_sort(unique(vcrshiny::fish$sciName)),
      selected = "Anchoa spp."
    ),
    
    shiny::sliderInput(
      ns("period_fish"),
      "Select time period",
      min = 2012,
      max = 2018,
      value = c(2012, 2018),
      step = 1
    )
  )
}
    
#' fish_var_select Server Function
#'
#' @noRd 
mod_06_fish_var_select_server <- function(input, output, session){
  ns <- session$ns
  
  observe({
    value <- input$period_fish
    updateSliderInput(
      session,
      "period_fish",
      min = 2012,
      max = 2018,
      value = val
    )
  })
  
  return(
    list(
      meadow_locs = reactive({ input$meadow }),
      temp_res = reactive({ input$temp_res }),
      fish_spec_choices = reactive({input$species}),
      fish_period_choice = reactive({ input$period_fish })
    )
  )
}
    
## To be copied in the UI
# mod_06_fish_var_select_ui("fish_var_select_ui_1")
    
## To be copied in the server
# callModule(mod_06_fish_var_select_server, "fish_var_select_ui_1")
 
