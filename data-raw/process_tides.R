library(tidyverse)
library(lubridate)
library(tsibble)

# Porter, J., D. Krovetz, J. Spitler, J. Spitler, T. Williams and K. Overman. 2019. Tide Data for Hog Island (1991-), 
# Redbank (1992-), Oyster (2007-) . Virginia Coast Reserve Long-Term Ecological Research Project Data Publication
# knb-lter-vcr.61.33 (http://www.vcrlter.virginia.educgi-bin/showDataset.cgi?docid=knb-lter-vcr.61.33).

# Read in data from VCR database
fname <- "http://www.vcrlter.virginia.edu/data/metdata/metgraphs/tidedata/VCRTide.csv"
infile1 <- readr::read_csv(fname, 
                           skip = 23,
                           col_names = c("station",
                                         "date",
                                         "time",
                                         "relative_tide_level",
                                         "water_temperature",
                                         "barometric_pressure"))

# Process for use in package format
tides <- 
  infile1 %>% 
  mutate_all(function(x)ifelse(x == ".", NA, x)) %>% 
  mutate(date = as.Date(date, format = "%d%b%Y"),
         time = format(strptime(substr(as.POSIXct(sprintf("%04.0f", as.numeric(time)),
                                                  format="%H%M"), 12, 16), 
                                '%H:%M'), '%I:%M %p'),
         datetime = as.POSIXct(paste(date, time), 
                               format="%Y-%m-%d %I:%M %p"),
         water_temperature = as.numeric(water_temperature),
         station = as.factor(station)) %>% 
  filter(year(datetime) > 2018) %>% 
  dplyr::select(-date, -time) %>%
  dplyr::filter(!is.na(datetime)) %>%
  group_by(station) %>%
  filter(!duplicated(datetime)) %>% 
  tsibble::as_tsibble(., key = station) #%>% 
  #fill_gaps()

# export to package
usethis::use_data(tides, overwrite = TRUE)
