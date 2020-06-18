library(tidyverse)
library(magrittr)

url <- 'http://www.vcrlter.virginia.edu/cgi-bin/fetchdataVCR.cgi/1/VCR09159/EOYB_data.csv'

marsh_veg <- readr::read_csv(url, skip = 21) %>% 
  dplyr::select(-marshRegion, -monitoringPurpose, -isExperiment) %>% 
  mutate(collectDate = as.Date(collectDate, format = "%m/%e/%y"),
         sortDate = as.Date(sortDate, format = "%m/%e/%y"))

usethis::use_data(marsh_veg, overwrite = TRUE)