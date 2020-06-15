# Porter, J., D. Krovetz, W. Nuttle, and J. Spitler. 2020. 
# Hourly Meteorological Data for the Virginia Coast Reserve LTER 1989-present ver 41. 
# Environmental Data Initiative. https://doi.org/10.6073/pasta/06db7a25a4f157f514def6addcdfdd53 (Accessed 2020-06-12).

library(RCurl)
library(tidyverse)
library(lubridate)
library(tsibble)

infile1  <- "http://www.vcrlter.virginia.edu/data/metdata/metgraphs/csv/hourly/whour_all_years.csv" 
infile1 <- sub("^https","http",infile1)
dt1 <-readr::read_csv(infile1, skip = 24, quote = '"', col_names = c(
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

meteorology <- dt1 %>% 
  mutate_all(function(x)ifelse(x == ".", NA, x)) %>% 
  mutate_at(vars(PPT:SOIL.T), as.numeric) %>% 
  mutate(STATION = as.factor(STATION)) %>% 
  # filter(YEAR != ".", TIME != ".") %>%
  tidyr::unite("datetime",c("YEAR", "MONTH", "DAY"), sep = "-", remove = T) %>%
  mutate(TIME2 = format(strptime(substr(as.POSIXct(sprintf("%04.0f", as.numeric(TIME)),
                                                  format="%H%M"), 12, 16), 
                                '%H:%M'), '%I:%M %p')) %>% 
  mutate(datetime = as.POSIXct(paste(.$datetime, TIME2), 
                               format="%Y-%m-%d %I:%M %p")) %>% 
  dplyr::select(-TIME, -TIME2) %>% 
  dplyr::filter(!is.na(datetime)) %>% 
  dplyr::rename(station = STATION) %>% 
  group_by(station) %>% 
  filter(!duplicated(datetime), year(datetime) > 2017) %>% 
  tsibble::as_tsibble(., key = station)# %>%
 # fill_gaps(.,.full = TRUE)

names(meteorology) <- str_to_lower(names(meteorology))
  
usethis::use_data(meteorology, overwrite = TRUE)
