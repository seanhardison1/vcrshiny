library(dplyr)
library(tidyr)
library(lubridate)
library(tsibble)
library(stringr)
library(magrittr)
library(xts)
library(zoo)

# tides-----------------------------------
last_tide <- zoo::index(xts::last(vcrshiny::tides))

fname <- "http://www.vcrlter.virginia.edu/data/metdata/metgraphs/csv/hourly/todayTide.csv"
infile1 <- readr::read_csv(fname, 
                           col_names = c("station",
                                         "date",
                                         "time",
                                         "relative_tide_level",
                                         "water_temperature",
                                         "barometric_pressure")) %>% 
  dplyr::select(-barometric_pressure)


# Process for use in package format
tides_new_df <-
  infile1 %>% 
  filter(station == "OYST") %>% 
  dplyr::select(-station) %>% 
  mutate_all(function(x)ifelse(x == ".", NA, x)) %>% 
  mutate(date = as.Date(date, format = "%d%b%Y"),
         time = format(strptime(substr(as.POSIXct(sprintf("%04.0f", as.numeric(time)),
                                                  format="%H%M"), 12, 16), 
                                '%H:%M'), '%I:%M %p'),
         datetime = as.POSIXct(paste(date, time), 
                               format="%Y-%m-%d %I:%M %p"),
         water_temperature = as.numeric(water_temperature)) %>% 
  dplyr::select(-date, -time) %>%
  dplyr::filter(!is.na(datetime)) %>%
  filter(!duplicated(datetime)) %>% 
  dplyr::filter(datetime >= last_tide)

tides_new_xts_rt <- xts(x = tides_new_df %>% 
                        dplyr::select(-datetime), 
                        order.by = tides_new_df$datetime)

# meteorology-----------------------------
last_meteo <- zoo::index(xts::last(vcrshiny::meteorology))

fname <- "http://www.vcrlter.virginia.edu/data/metdata/metgraphs/csv/hourly/todayWeather.csv"
infile2 <-readr::read_csv(fname, quote = '"', col_names = c(
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

meteo_new_df <- infile2 %>% 
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
  filter(!duplicated(datetime)) %>% 
  dplyr::filter(datetime >= last_tide)

names(meteo_new_df) <- str_to_lower(names(meteo_new_df))

meteo_new_xts_rt <- xts(x = meteo_new_df %>% 
                      dplyr::select(-datetime), 
                    order.by = meteo_new_df$datetime)

rm(meteo_new_df, tides_new_df, infile1, infile2)


