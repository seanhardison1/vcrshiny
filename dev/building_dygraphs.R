library(tidyverse)
library(lubridate)
library(tydygraphs)
library(tsibble)

t <- "meteorology"
df <- eval(parse(text = paste0("vcrshiny::",t))) 

df %<>%
  filter(station == "HOG2") %>% 
  dplyr::select(datetime, avg.t)

dygraph(t, "avg.t") 
