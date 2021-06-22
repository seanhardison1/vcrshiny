#' Get data recorded since last package build
#' 
#' @description Used to update data for app.
#'
#'
#' 
#' 
# tides-----------------------------------
real_time_query <- function(){
  # last_tide <- zoo::index(xts::last(vcrshiny::vcr_phys_vars))
  
  fname <- "http://www.vcrlter.virginia.edu/data/metdata/metgraphs/csv/hourly/todayTide.csv"
  infile1 <- readr::read_csv(fname, 
                             col_names = c("station",
                                           "date",
                                           "time",
                                           "relative_tide_level",
                                           "water_temperature",
                                           "barometric_pressure")) %>% 
    dplyr::select(-barometric_pressure)
  
  if (nrow(infile1) != 0){
    # Process for use in package format
    tides_new_df <-
      infile1 %>% 
      
      # select data from the Oyster station only
      dplyr::filter(station == "OYST") %>% 
      dplyr::select(-station) %>% 
      
      # convert missing values to NA
      dplyr::mutate_all(function(x)ifelse(x == ".", NA, x)) %>% 
      
      # process the datetimes
      dplyr::mutate(date = as.Date(date, format = "%d%b%Y"),
             time = format(strptime(substr(as.POSIXct(sprintf("%04.0f", as.numeric(time)),
                                                      format="%H%M", tz = "America/New_York"), 12, 16), 
                                    '%H:%M'), '%I:%M %p'),
             datetime = as.POSIXct(paste(date, time), 
                                   format="%Y-%m-%d %I:%M %p", tz = "America/New_York"),
             water_temperature = as.numeric(water_temperature)) %>%
      dplyr::filter(date <= Sys.Date()) %>% 
      dplyr::select(-date, -time) %>%
      dplyr::filter(!is.na(datetime)) %>% 
      
      # Convert to tsibble to fill missing datetimes
      dplyr::filter(!duplicated(datetime)) %>% 
      tsibble::tsibble(index = datetime) %>% 
      tsibble::fill_gaps(.full  = TRUE) %>% 
      tibble::as_tibble() %>%
      
      # get the hourly mean
      dplyr::group_by(y = lubridate::year(datetime),
               m = lubridate::month(datetime),
               d = lubridate::day(datetime),
               h = lubridate::hour(datetime)) %>% 
      dplyr::summarise(relative_tide_level = mean(relative_tide_level, na.rm = T) * 3.28084,
                       water_temperature = (mean(water_temperature, na.rm = T) * 9/5) + 32) %>% 
      
      dplyr::mutate(datetime = lubridate::ymd_h(paste(y, m, d, h, sep = "-"), tz = "America/New_York")) %>% 
      
      # select variables of interest
      dplyr::ungroup() %>% 
      dplyr::select(datetime, relative_tide_level, water_temperature) %>% 
      dplyr::filter(datetime <= Sys.time(),
                    datetime > zoo::index(xts::last(vcrshiny::vcr_phys_vars)))
      
    tides_new_xts <- xts::xts(x = tides_new_df %>% dplyr::select(-datetime), 
                              order.by = tides_new_df$datetime,
                              tzone = "America/New_York")
    # xts::tzone(tides_new_xts) <- "America/New_York"
    
  } else {
    message("No tidal data available")
    tides_new_xts <- NA
  }
  # meteorology-----------------------------
  # last_meteo <- zoo::index(xts::last(vcrshiny::meteorology))
  
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
  
  if (nrow(infile2) != 0){
    meteo_new_df <- infile2 %>% 
      dplyr::filter(STATION == "OYSM") %>% 
      dplyr::select(-STATION) %>% 
      dplyr::mutate_all(function(x)ifelse(x == ".", NA, x)) %>% 
      dplyr::mutate_at(dplyr::vars(PPT:SOIL.T), as.numeric) %>% 
      tidyr::unite("datetime",c("YEAR", "MONTH", "DAY"), sep = "-", remove = T) %>%
      dplyr::mutate(TIME2 = format(strptime(substr(as.POSIXct(sprintf("%04.0f", as.numeric(TIME)),
                                                       format="%H%M", tz = "America/New_York"), 12, 16), 
                                     '%H:%M'), '%I:%M %p'),
                    date = as.Date(datetime)) %>% 
      dplyr::filter(date <= Sys.Date()) %>% 
      dplyr::mutate(datetime = as.POSIXct(paste(.$datetime, TIME2), 
                                   format="%Y-%m-%d %I:%M %p", tz = "America/New_York")) %>% 
      dplyr::select(-TIME, -TIME2, -date) %>% 
      dplyr::filter(!is.na(datetime)) %>% 
      dplyr::filter(!duplicated(datetime)) %>% 
      tsibble::tsibble(index = datetime) %>% 
      tsibble::fill_gaps(.full  = TRUE) %>% 
      tsibble::as_tibble() %>% 
      dplyr::select(datetime, PPT, AVG.T, AVG.WS) %>% 
      dplyr::mutate(AVG.T = (AVG.T * 9/5) + 32,
                    AVG.WS = AVG.WS * 3.28084,
                    PPT = PPT/16.387) %>% 
      dplyr::filter(datetime <= Sys.time(),
                    datetime > zoo::index(xts::last(vcrshiny::vcr_phys_vars)))
    
    names(meteo_new_df) <- stringr::str_to_lower(names(meteo_new_df))
    
    meteo_new_xts <- xts::xts(x = meteo_new_df %>% 
                                   dplyr::select(-datetime), 
                                 order.by = meteo_new_df$datetime)
    # xts::tzone(meteo_new_xts) <- "America/New_York"
  } else {
    message("No meteo data available")
    meteo_new_xts <- NA
  }
  
  # bind new to old
  vcr_phys_rt <- xts::merge.xts(meteo_new_xts, tides_new_xts)
  
  return(vcr_phys_rt)
}
