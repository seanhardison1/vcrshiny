# Package ID: knb-lter-vcr.25.40 Cataloging System:https://pasta.edirepository.org.
# Data set title: Hourly Meteorological Data for the Virginia Coast Reserve LTER 1989-present.
# Data set creator:  John Porter -  
# Data set creator:  David Krovetz -  
# Data set creator:  William Nuttle -  
# Data set creator:  James Spitler -  
# Metadata Provider:    - Virginia Coast Reserve Long-Term Ecological Research Project 
# Contact:  John Porter -    - jhp7e@virginia.edu
# Contact:    - Information manager - Virginia Coast Reserve Long-Term Ecological Research Project   - jhp7e@virginia.edu
# Stylesheet for metadata conversion into program: John H. Porter, Univ. Virginia, jporter@lternet.edu 
library(RCurl)
library(tidyverse)
library(lubridate)

infile1  <- "https://pasta.lternet.edu/package/data/eml/knb-lter-vcr/25/40/32a020479d23312012444a5b4ff81658" 
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
  dplyr::select(-TIME, -TIME2)

names(meteorology) <- str_to_lower(names(meteorology))
  
usethis::use_data(meteorology, overwrite = TRUE)
