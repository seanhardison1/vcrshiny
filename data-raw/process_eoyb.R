library(tidyverse)
library(magrittr)

url <- 'http://www.vcrlter.virginia.edu/cgi-bin/fetchdataVCR.cgi/1/VCR09159/EOYB_data.csv'

marsh_veg <- readr::read_csv(url, skip = 21) %>% 
  dplyr::select(-marshRegion, -monitoringPurpose, -isExperiment) %>% 
  mutate(collectDate = as.Date(collectDate, format = "%m/%e/%y"),
         sortDate = as.Date(sortDate, format = "%m/%e/%y")) %>% 
  dplyr::rename(year = EOYBYear)

marsh_veg_locs <- 
  marsh_veg %>% 
  dplyr::select(marshName, latitude, longitude) %>% 
  filter(marshName != "Broad Creek") %>% 
  distinct()

marsh_veg_species <- 
  marsh_veg %>% 
  pull(speciesName) %>% 
  unique()

usethis::use_data(marsh_veg, 
                  marsh_veg_locs, 
                  marsh_veg_species,
                  overwrite = TRUE)
