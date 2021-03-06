library(dplyr)
library(lubridate)
library(tsibble)
library(stringr)
library(magrittr)
library(xts)
library(tidyr)

# Porter, J., D. Krovetz, J. Spitler, J. Spitler, T. Williams and K. Overman. 2019. Tide Data for Hog Island (1991-), 
# Redbank (1992-), Oyster (2007-) . Virginia Coast Reserve Long-Term Ecological Research Project Data Publication
# knb-lter-vcr.61.33 (http://www.vcrlter.virginia.educgi-bin/showDataset.cgi?docid=knb-lter-vcr.61.33).

print(paste("Time of data pull is", Sys.time()))

# Read in data from VCR database
fname <- "http://www.vcrlter.virginia.edu/data/metdata/metgraphs/tidedata/VCRTide.csv"
# fname <- "http://www.vcrlter.virginia.edu/data/metdata/metgraphs/csv/hourly/todayTide.csv"
infile1 <- data.table::fread(fname, col.names = c("station",
                                                  "date",
                                                  "time",
                                                  "relative_tide_level",
                                                  "water_temperature"),
                             quote = '"',
                             select = c(1:5)) %>% 
  tibble::tibble() %>% 
  mutate(time = as.numeric(time),
         relative_tide_level = as.numeric(relative_tide_level))

# infile2 <- readr::read_csv(fname, col_names = c("station",
#                                      "date",
#                                      "time",
#                                      "relative_tide_level",
#                                      "water_temperature",
#                                      "barometric_pressure"),
#                 quote = '"')

# Process for use in package format
tides_new_df <-
  infile1 %>% 
    
    # select data from the Oyster station only
    dplyr::filter(stringr::str_detect(station, "OYST")) %>% 
    dplyr::select(-station) %>% 
  
    # convert missing values to NA
    mutate_all(function(x)ifelse(x == ".", NA, x)) %>% 
  
    # process the datetimes
    dplyr::mutate(date = as.Date(date, format = "%d%b%Y"),
           time = format(strptime(substr(as.POSIXct(sprintf("%04.0f", as.numeric(time)),
                                                    format="%H%M", tz = "America/New_York"), 12, 16), 
                                  '%H:%M'), '%I:%M %p'),
           datetime = as.POSIXct(paste(date, time), 
                                 format="%Y-%m-%d %I:%M %p", tz = "America/New_York"),
           water_temperature = as.numeric(water_temperature)) %>% 
    dplyr::filter(date <= Sys.Date()) %>% 
    dplyr::select(-date, -time) %>%
    dplyr::filter(!is.na(datetime)) %>%
  
    # Convert to tsibble to fill missing datetimes
    dplyr::filter(!duplicated(datetime)) %>% 
    tsibble(index = datetime) %>% 
    fill_gaps(.full  = TRUE) %>% 
    as_tibble() %>%
  
    # get the hourly mean
    group_by(y = year(datetime),
             m = month(datetime),
             d = day(datetime),
             h = hour(datetime)) %>% 
    dplyr::summarise(relative_tide_level = mean(relative_tide_level, na.rm = T) * 3.28084,
                     water_temperature = (mean(water_temperature, na.rm = T) * 9/5) + 32) %>% 
  
    # convert back to datetime
    dplyr::mutate(datetime = lubridate::ymd_h(paste(y, m, d, h, sep = "-"), tz = "America/New_York")) %>%
    
    # select variables of interest
    dplyr::ungroup() %>% 
    dplyr::select(datetime, relative_tide_level, water_temperature)
 
# convert to xts for dygraphs
tides_new_xts <- xts(x = tides_new_df %>% dplyr::select(-datetime), order.by = tides_new_df$datetime)
# xts::tzone(tides_new_xts) <- "America/New_York"
# Meteorology-----------------------------


fname  <- "http://www.vcrlter.virginia.edu/data/metdata/metgraphs/csv/hourly/whour_all_years.csv"
# infile1 <- "http://www.vcrlter.virginia.edu/data/metdata/metgraphs/csv/hourly/todayWeather.csv"
dt1 <-data.table::fread(fname, col.names = c(
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
  "SOIL.T" )) %>% 
  tibble::as_tibble() 

meteo_new_df <- dt1 %>% 
  dplyr::filter(stringr::str_detect(STATION,"OYSM")) %>% 
  dplyr::select(-STATION) %>% 
  mutate_all(function(x)ifelse(x == ".", NA, x)) %>% 
  mutate_at(vars(PPT:SOIL.T), as.numeric) %>% 
  tidyr::unite("datetime",c("YEAR", "MONTH", "DAY"), sep = "-", remove = T) %>%
  mutate(TIME2 = format(strptime(substr(as.POSIXct(sprintf("%04.0f", as.numeric(TIME)),
                                                   format="%H%M", tz = "America/New_York"), 12, 16), 
                                 '%H:%M'), '%I:%M %p')) %>% 
  mutate(datetime = as.POSIXct(paste(.$datetime, TIME2), 
                               format="%Y-%m-%d %I:%M %p", tz = "America/New_York")) %>% 
  dplyr::select(-TIME, -TIME2) %>% 
  dplyr::filter(!is.na(datetime)) %>% 
  filter(!duplicated(datetime)) %>% 
  tsibble(index = datetime) %>% 
  fill_gaps(.full  = TRUE) %>% 
  as_tibble() %>% 
  dplyr::select(datetime, PPT, AVG.T, AVG.WS) %>% 
  dplyr::mutate(AVG.T = (AVG.T * 9/5) + 32,
                AVG.WS = AVG.WS * 3.28084,
                PPT = PPT/16.387)

names(meteo_new_df) <- str_to_lower(names(meteo_new_df))

meteo_new <- xts(x = meteo_new_df %>% dplyr::select(-datetime), order.by = meteo_new_df$datetime)

# xts::tzone(meteo_new) <- "America/New_York"
rm(meteo_new_df, tides_new_df)

# bind new to old
vcr_phys_vars <- merge(meteo_new, tides_new_xts)

# find 2 * SD for visualizing extreme tides, precipitation, and wind speeds
extremes <- 
  data.frame(tides_mean = mean(vcr_phys_vars$relative_tide_level, na.rm = T),
             tides_2_sd = sd(vcr_phys_vars$relative_tide_level, na.rm = T) * 2,
             precip_2_sd = sd(vcr_phys_vars$ppt, na.rm = T) * 2,
             precip_mean = mean(vcr_phys_vars$ppt, na.rm = T),
             wind_speed_2_sd = sd(vcr_phys_vars$avg.ws, na.rm = T) * 2,
             wind_speed_mean = mean(vcr_phys_vars$avg.ws, na.rm = T),
             air_temp_mean = mean(vcr_phys_vars$avg.t, na.rm = T),
             air_temp_2_sd = sd(vcr_phys_vars$avg.t, na.rm = T) * 2,
             wat_temp_mean = mean(vcr_phys_vars$water_temperature, na.rm = T),
             wat_temp_2_sd = sd(vcr_phys_vars$water_temperature, na.rm = T) * 2)

vcr_phys_vars <- vcr_phys_vars[paste0(lubridate::year(Sys.Date()) - 1, "/", lubridate::year(Sys.Date()))]

usethis::use_data(vcr_phys_vars, overwrite = T)
usethis::use_data(extremes, overwrite = TRUE)
