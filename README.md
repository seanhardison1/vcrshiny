# vcrshiny
A shiny app for visualizing tidal and meteorological data from the Virginia Coast Reserve.

To run the dev version of this app locally:

```
# install and load libraries
install.packages('golem')
devtools::install_github("seanhardison1/vcrshiny")

library(golem)
library(vcrshiny)

options(golem.app.prod = FALSE) 

# Detach all loaded packages and clean your environment
golem::detach_all_attached()
rm(list=ls(all.names = TRUE))

# Document and reload 
golem::document_and_reload()

# Run the application
run_app()
```
