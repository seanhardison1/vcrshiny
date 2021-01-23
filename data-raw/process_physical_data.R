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

# trigger processing of long-term mean calculation
get_hourly_ltm <- F

# Read in data from VCR database
fname <- "http://www.vcrlter.virginia.edu/data/metdata/metgraphs/tidedata/VCRTide.csv"
# fname <- "http://www.vcrlter.virginia.edu/data/metdata/metgraphs/csv/hourly/todayTide.csv"
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
    
    # select data from the Oyster station only
    filter(station == "OYST") %>% 
    dplyr::select(-station) %>% 
  
    # convert missing values to NA
    mutate_all(function(x)ifelse(x == ".", NA, x)) %>% 
  
    # process the datetimes
    mutate(date = as.Date(date, format = "%d%b%Y"),
           time = format(strptime(substr(as.POSIXct(sprintf("%04.0f", as.numeric(time)),
                                                    format="%H%M"), 12, 16), 
                                  '%H:%M'), '%I:%M %p'),
           datetime = as.POSIXct(paste(date, time), 
                                 format="%Y-%m-%d %I:%M %p"),
           water_temperature = as.numeric(water_temperature)) %>% 
    dplyr::select(-date, -time) %>%
    dplyr::filter(!is.na(datetime)) %>%
  
    # Convert to tsibble to fill missing datetimes
    filter(!duplicated(datetime)) %>% 
    tsibble(index = datetime) %>% 
    fill_gaps(.full  = TRUE) %>% 
    as_tibble() %>%
  
    # get the hourly mean
    group_by(y = year(datetime),
             m = month(datetime),
             d = day(datetime),
             h = hour(datetime)) %>% 
    dplyr::summarise(relative_tide_level = mean(relative_tide_level, na.rm = T),
                     water_temperature = mean(water_temperature, na.rm = T)) %>% 
  
    # convert back to datetime
    mutate(date = as.Date(paste(y,m,d, sep = "-")),
           time = strptime(h, "%H"),
           datetime = ymd_hms(as.POSIXct(paste(date, hour(time)), 
                                format="%Y-%m-%d %H"))) %>% 
    
    # select variables of interest
    ungroup() %>% 
    dplyr::select(datetime, relative_tide_level, water_temperature)
    
if (get_hourly_ltm){
  # Get hourly long-term means for water temperature data. 
  # The reference period is 2006-2021
  hourly_ltm <- 
    tides_new_df  %>%
    mutate(month = month(datetime),
           day = day(datetime),
           hour = hour(datetime)) %>% 
    group_by(month, day, hour) %>% 
    dplyr::summarise(ltm_water_temperature = mean(water_temperature, na.rm = T)) %>% 
    mutate(date = as.Date(paste("2000",month, day, sep = "-"), "%Y-%m-%d"),
           time = strptime(hour, "%H"),
           datetime = ymd_hms(as.POSIXct(paste(date, hour(time)), 
                                         format="%Y-%m-%d %H"))) %>%
    ungroup() %>% 
    dplyr::select(-month,-day, -hour,-date,-time)
  
  n_years <- length(unique(year(tides_new_df$datetime)))
  
  # In order to bind the LTMs into the real time data, keep the month-day-hour values, but 
  # add unique years
  tides_hourly_ltm <- do.call("rbind", replicate(n_years, hourly_ltm, simplify = FALSE)) %>% 
    mutate(year_group = rep(1:n_years, each = 366 * 24),
           year_group = plyr::mapvalues(year_group, from = unique(year_group),
                                        to = 2006:max(unique(year(tides_new_df$datetime)))))
  
  year(tides_hourly_ltm$datetime) <- tides_hourly_ltm$year_group
  save(tides_hourly_ltm, file = "data/hourly_ltm.rdata")
} else {
  load("data/hourly_ltm.rdata")
}

# join tidal data with ltm data
tides_new_df <- 
  tides_hourly_ltm %>% 
  ungroup() %>% 
  dplyr::select(-year_group) %>% 
  inner_join(.,tides_new_df, "datetime")

# convert to xts for dygraphs
tides_new_xts <- xts(x = tides_new_df %>% dplyr::select(-datetime), order.by = tides_new_df$datetime)

# Meteorology-----------------------------


infile1  <- "http://www.vcrlter.virginia.edu/data/metdata/metgraphs/csv/hourly/whour_all_years.csv"
# infile1 <- "http://www.vcrlter.virginia.edu/data/metdata/metgraphs/csv/hourly/todayWeather.csv"
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
  filter(!duplicated(datetime)) %>% 
  tsibble(index = datetime) %>% 
  fill_gaps(.full  = TRUE) %>% 
  as_tibble() %>% 
  dplyr::select(datetime, PPT, AVG.T, AVG.WS)

names(meteo_new_df) <- str_to_lower(names(meteo_new_df))

if (get_hourly_ltm){
  # Get hourly long-term means for tides and water temperature data. 
  # The reference period is 1991-2021
  
  ltm_avg_t <- 
    meteo_new_df  %>%
    mutate(month = month(datetime),
           day = day(datetime),
           hour = hour(datetime)) %>% 
    group_by(month, day, hour) %>% 
    dplyr::summarise(ltm_avg_t = mean(avg.t, na.rm = T)) %>% 
    mutate(date = as.Date(paste("2000",month, day, sep = "-"), "%Y-%m-%d"),
           time = strptime(hour, "%H"),
           datetime = ymd_hms(as.POSIXct(paste(date, hour(time)), 
                                         format="%Y-%m-%d %H"))) %>%
    ungroup() %>% 
    dplyr::select(-month,-day, -hour,-date,-time)
  
  n_years <- length(unique(year(meteo_new_df$datetime)))
  
  # In order to bind the LTMs into the real time data, keep the month-day-hour values, but 
  # add unique years
  meteo_hourly_ltm <- do.call("rbind", replicate(n_years, ltm_avg_t, simplify = FALSE)) %>% 
    mutate(year_group = rep(1:n_years, each = 366 * 24),
           year_group = plyr::mapvalues(year_group, from = unique(year_group),
                                        to = 1991:max(unique(year(meteo_new_df$datetime)))))
  
  year(meteo_hourly_ltm$datetime) <- meteo_hourly_ltm$year_group
  save(meteo_hourly_ltm, file = "data/meteo_hourly_ltm.rdata")
} else {
  load("data/meteo_hourly_ltm.rdata")
}

# join meteo data with ltm data
meteo_new_df <- 
  meteo_hourly_ltm %>% 
  ungroup() %>% 
  dplyr::select(-year_group) %>% 
  inner_join(.,meteo_new_df, "datetime")

meteo_new <- xts(x = meteo_new_df %>% dplyr::select(-datetime), order.by = meteo_new_df$datetime)
rm(meteo_new_df, tides_new_df)

# bind new to old
vcr_phys_vars <- merge(meteo_new, tides_new_xts)
usethis::use_data(vcr_phys_vars, overwrite = T)
