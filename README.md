# vcrshiny

A data package and shiny app for communicating research data collected through the Virginia Coast Reserve Long-Term Ecological Research (VCR LTER) program. Data are queried from the VCR servers and displayed on the app within two hours of data collection at tidal and meteorological stations in Oyster, VA. The app was built using the [golem](https://github.com/ThinkR-open/golem) framework.

Read more about the VCR LTER program [here](https://www.vcrlter.virginia.edu/home2/).

Installation:
```
devtools::install_github("seanhardison1/vcrshiny")
```

To access time series of air and water temperatures, precipitation, wind speeds, and tides from the VCR:
```
vcrshiny::vcr_phys_vars
```

To run the dev version of this app locally:
```
vcrshiny::run_app()
```
