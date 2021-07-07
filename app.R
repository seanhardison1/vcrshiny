# Launch the ShinyApp (Do not remove this comment)
# To deploy, run: rsconnect::deployApp()
# Or use the blue button on top of this file
pkgload::load_all(export_all = T,helpers = FALSE,attach_testthat = FALSE)
options( "golem.app.prod" = F)

# profvis::profvis({print(vcrshiny::run_app())}) # add parameters here (if any)
vcrshiny::run_app()