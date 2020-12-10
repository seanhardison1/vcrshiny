# vcrshiny
A data package and shiny app for visualizing research data collected as part of the Virginia Coast Reserve Long-Term Ecological Research (VCR LTER) program. This application is in early beta and should not be expected to work properly :ghost:. 

Read more about the program [here](https://www.vcrlter.virginia.edu/home2/).

Installation:
```
devtools::install_github("seanhardison1/vcrshiny")
```

To access up-to-date tidal/meteorological data from the VCR:
```
vcrshiny::tides
vcrshiny::meteorology
```

To run the dev version of this app locally:
```
vcrshiny::run_app()
```
Note: The app may not load on the first go - run the script again or click "Open in Browser" in the viewer pane to get around this.
