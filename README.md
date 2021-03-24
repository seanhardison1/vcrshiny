# vcrshiny
A data package and shiny app for visualizing research data collected as part of the Virginia Coast Reserve Long-Term Ecological Research (VCR LTER) program. The repository uses Github Actions to collect the most recent data from the VCR servers every four hours, and these data are immediately available in the app/package if installed or downloaded. However, the demo application linked at the top of this page is not tied to this update process (yet) 👻. 

Read more about the program [here](https://www.vcrlter.virginia.edu/home2/).

Installation:
```
devtools::install_github("seanhardison1/vcrshiny")
```

To access up-to-date time series of air and water temperatures, precipitation, wind speeds, and tides from the VCR:
```
vcrshiny::vcr_phys_vars
```

To run the dev version of this app locally:
```
vcrshiny::run_app()
```
