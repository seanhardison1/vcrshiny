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

non_species <- 
  c("Pine needles", "Plant debris - leaves", "Unidentified",
    "Woody debris", "Algae: unidentified", 
    "Unidentified vine", "Combined Dead", "Wrack", 
    "Pine leaves","No vegetation", "Pine debris",
    "Unidentified sedge", "Snail")

special <- c("Algae: Ulva",
             "Algae: Gracilaria") 

# Adds asterisks for italicizing species names
out <- NULL
for (i in 1:length(marsh_veg_species)){
  
  if (marsh_veg_species[i] %in% special) {
    new <- paste0(str_split(marsh_veg_species[i], " ")[[1]][1]," *",
                  str_split(marsh_veg_species[i], " ")[[1]][2],"*")
  } else if (marsh_veg_species[i] %in% non_species){
    new <- marsh_veg_species[i]
  } else if (str_detect(marsh_veg_species[i], "sp\\.")){
    new <- paste0("*",str_split(marsh_veg_species[i], " ")[[1]][1],"* ",
                  str_split(marsh_veg_species[i], " ")[[1]][2])
  } else {
    new <- paste0("*", marsh_veg_species[i], "*")
  }
  assign("out", rbind(out, tibble(speciesName = marsh_veg_species[i],
                                  speciesName_ital = new)))
}

marsh_veg %<>% left_join(.,out, by = c("speciesName"))

usethis::use_data(marsh_veg, 
                  marsh_veg_locs, 
                  marsh_veg_species,
                  overwrite = TRUE)