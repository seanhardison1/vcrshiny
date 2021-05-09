library(dplyr)
library(lubridate)
library(tsibble)
library(stringr)
library(magrittr)
library(tidyr)
library(xts)

# load tidal and meteorological data
df <- vcrshiny::vcr_phys_vars

# find 2 * SD for visualizing extreme tides, precipitation, and wind speeds
extremes <- 
  data.frame(tides_mean = mean(df$relative_tide_level, na.rm = T),
      tides_2_sd = sd(df$relative_tide_level, na.rm = T) * 2,
     precip_2_sd = sd(df$ppt, na.rm = T) * 2,
     precip_mean = mean(df$ppt, na.rm = T),
     wind_speed_2_sd = sd(df$avg.ws, na.rm = T) * 2,
     wind_speed_mean = mean(df$avg.ws, na.rm = T))

usethis::use_data(extremes, overwrite = TRUE)