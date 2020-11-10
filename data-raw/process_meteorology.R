# Porter, J., D. Krovetz, W. Nuttle, and J. Spitler. 2020. 
# Hourly Meteorological Data for the Virginia Coast Reserve LTER 1989-present ver 41. 
# Environmental Data Initiative. https://doi.org/10.6073/pasta/06db7a25a4f157f514def6addcdfdd53 (Accessed 2020-06-12).
library(dplyr)
library(lubridate)
library(tsibble)
library(stringr)
library(magrittr)
library(tidyr)
library(xts)

# load old data
load("data/meteorology.rda")

# infile1  <- "http://www.vcrlter.virginia.edu/data/metdata/metgraphs/csv/hourly/whour_all_years.csv"
infile1 <- "http://www.vcrlter.virginia.edu/data/metdata/metgraphs/csv/hourly/todayWeather.csv"
dt1 <-readr::read_csv(infile1, quote = '"', col_names = c(
  "STATION",
  "YEAR",
  "MONTH",
  "DAY",
  "TIME",
  "PPT",
  "AVG.T",
  "MIN.T",
  "MAX.T",
  "AVG.RH",
  "MIN.RH",
  "MAX.RH",
  "AVG.WS",
  "AVG.WANG",
  "STD.WANG",
  "RAD.SOL",
  "PAR",
  "SOIL.T" ))

meteo_new_df <- dt1 %>% 
  filter(STATION == "OYSM") %>% 
  dplyr::select(-STATION) %>% 
  mutate_all(function(x)ifelse(x == ".", NA, x)) %>% 
  mutate_at(vars(PPT:SOIL.T), as.numeric) %>% 
  tidyr::unite("datetime",c("YEAR", "MONTH", "DAY"), sep = "-", remove = T) %>%
  mutate(TIME2 = format(strptime(substr(as.POSIXct(sprintf("%04.0f", as.numeric(TIME)),
                                                   format="%H%M"), 12, 16), 
                                 '%H:%M'), '%I:%M %p')) %>% 
  mutate(datetime = as.POSIXct(paste(.$datetime, TIME2), 
                               format="%Y-%m-%d %I:%M %p")) %>% 
  dplyr::select(-TIME, -TIME2) %>% 
  dplyr::filter(!is.na(datetime)) %>% 
  filter(!duplicated(datetime))

names(meteo_new_df) <- str_to_lower(names(meteo_new_df))

meteo_new <- xts(x = meteo_new_df %>% dplyr::select(-datetime), order.by = meteo_new_df$datetime)

# bind new to old
meteorology <- rbind(meteorology, meteo_new)
meteorology <- make.index.unique(meteorology,drop=TRUE)

# export for packaging
usethis::use_data(meteorology, overwrite = TRUE)
