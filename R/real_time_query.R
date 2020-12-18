#' Get data recorded since last package build
#' 
#' 
#' 
#' 
# tides-----------------------------------
real_time_query <- function(){
  last_tide <- zoo::index(xts::last(vcrshiny::tides))
  
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
    dplyr::filter(station == "OYST") %>% 
    dplyr::select(-station) %>% 
    dplyr::mutate_all(function(x)ifelse(x == ".", NA, x)) %>% 
    dplyr::mutate(date = as.Date(date, format = "%d%b%Y"),
           time = format(strptime(substr(as.POSIXct(sprintf("%04.0f", as.numeric(time)),
                                                    format="%H%M"), 12, 16), 
                                  '%H:%M'), '%I:%M %p'),
           datetime = as.POSIXct(paste(date, time), 
                                 format="%Y-%m-%d %I:%M %p"),
           water_temperature = as.numeric(water_temperature)) %>% 
    dplyr::select(-date, -time) %>%
    dplyr::filter(!is.na(datetime)) %>%
    dplyr::filter(!duplicated(datetime)) %>% 
    dplyr::filter(datetime >= last_tide)
  
  tides_new_xts_rt <- xts::xts(x = tides_new_df %>% 
                            dplyr::select(-datetime), 
                          order.by = tides_new_df$datetime)
  
  # meteorology-----------------------------
  last_meteo <- zoo::index(xts::last(vcrshiny::meteorology))
  
  fname <- "http://www.vcrlter.virginia.edu/data/metdata/metgraphs/csv/hourly/todayWeather.csv"
  infile2 <-readr::read_csv(fname, quote = '"', col_names = c(
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
  
  meteo_new_df <- infile2 %>% 
    dplyr::filter(STATION == "OYSM") %>% 
    dplyr::select(-STATION) %>% 
    dplyr::mutate_all(function(x)ifelse(x == ".", NA, x)) %>% 
    dplyr::mutate_at(dplyr::vars(PPT:SOIL.T), as.numeric) %>% 
    tidyr::unite("datetime",c("YEAR", "MONTH", "DAY"), sep = "-", remove = T) %>%
    dplyr::mutate(TIME2 = format(strptime(substr(as.POSIXct(sprintf("%04.0f", as.numeric(TIME)),
                                                     format="%H%M"), 12, 16), 
                                   '%H:%M'), '%I:%M %p')) %>% 
    dplyr::mutate(datetime = as.POSIXct(paste(.$datetime, TIME2), 
                                 format="%Y-%m-%d %I:%M %p")) %>% 
    dplyr::select(-TIME, -TIME2) %>% 
    dplyr::filter(!is.na(datetime)) %>% 
    dplyr::filter(!duplicated(datetime)) %>% 
    dplyr::filter(datetime >= last_tide)
  
  names(meteo_new_df) <- stringr::str_to_lower(names(meteo_new_df))
  
  meteo_new_xts_rt <- xts::xts(x = meteo_new_df %>% 
                            dplyr::select(-datetime), 
                          order.by = meteo_new_df$datetime)
  
  return(list(tides_new = tides_new_xts_rt,
              meteo_new = meteo_new_xts_rt))
}

