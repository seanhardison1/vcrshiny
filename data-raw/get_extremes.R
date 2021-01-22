library(dplyr)
library(lubridate)
library(tsibble)
library(stringr)
library(magrittr)
library(tidyr)
library(xts)

# load tidal and meteorological data
load("data/meteorology.rda")
load("data/tides.rda")

# find 2 * SD for visualizing extreme tides, precipitation, and wind speeds
extremes <- 
  list(tides_2_sd = sd(tides$relative_tide_level, na.rm = T) * 2,
     precip_2_sd = sd(meteorology$ppt, na.rm = T) * 2,
     wind_speed_2_sd = sd(meteorology$avg.ws, na.rm = T) * 2)
save(extremes,file = 'data/extremes.rdata')
