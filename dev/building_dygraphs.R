library(dygraphs)
library(tidyverse)
library(lubridate)
library(tydygraphs)
library(tsibble)

t <- vcrshiny::meteorology %>% 
  filter(station == "BRNV", !is.na(datetime)) %>% 
  dplyr::select(datetime, avg.t) %>% 
  distinct() 

dygraph(t, avg.t)