library(dplyr)
library(lubridate)
library(tsibble)
library(stringr)
library(magrittr)
library(xts)

# Porter, J., D. Krovetz, J. Spitler, J. Spitler, T. Williams and K. Overman. 2019. Tide Data for Hog Island (1991-), 
# Redbank (1992-), Oyster (2007-) . Virginia Coast Reserve Long-Term Ecological Research Project Data Publication
# knb-lter-vcr.61.33 (http://www.vcrlter.virginia.educgi-bin/showDataset.cgi?docid=knb-lter-vcr.61.33).

print(paste("Time of data pull is", Sys.time()))

#load old data
load("data/tides.rda")

# Read in data from VCR database
# fname <- "http://www.vcrlter.virginia.edu/data/metdata/metgraphs/tidedata/VCRTide.csv"
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
    filter(!duplicated(datetime))
  
tides_new_xts <- xts(x = tides_new_df %>% dplyr::select(-datetime), order.by = tides_new_df$datetime)

# Bind new to old
tides <- rbind(tides, tides_new_xts)
tides <- make.index.unique(tides,drop=TRUE)

# export for packaging
usethis::use_data(tides, overwrite = TRUE)
