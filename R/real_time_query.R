#' Get data recorded since last package build
#' 
#' @description Used to update data for app.
#'
#'
#' 
#' 
# tides-----------------------------------
real_time_query <- function(){
  # last_tide <- zoo::index(xts::last(vcrshiny::tides))
  
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
    filter(station == "OYST") %>% 
    dplyr::select(-station) %>% 
    
    # convert missing values to NA
    mutate_all(function(x)ifelse(x == ".", NA, x)) %>% 
    
    # process the datetimes
    mutate(date = as.Date(date, format = "%d%b%Y"),
           time = format(strptime(substr(as.POSIXct(sprintf("%04.0f", as.numeric(time)),
                                                    format="%H%M"), 12, 16), 
                                  '%H:%M'), '%I:%M %p'),
           datetime = as.POSIXct(paste(date, time), 
                                 format="%Y-%m-%d %I:%M %p"),
           water_temperature = as.numeric(water_temperature)) %>% 
    dplyr::select(-date, -time) %>%
    dplyr::filter(!is.na(datetime)) %>%
    
    # Convert to tsibble to fill missing datetimes
    filter(!duplicated(datetime)) %>% 
    tsibble(index = datetime) %>% 
    fill_gaps(.full  = TRUE) %>% 
    as_tibble() %>%
    
    # get the hourly mean
    group_by(y = year(datetime),
             m = month(datetime),
             d = day(datetime),
             h = hour(datetime)) %>% 
    dplyr::summarise(relative_tide_level = mean(relative_tide_level, na.rm = T) * 3.28084,
                     water_temperature = (mean(water_temperature, na.rm = T) * 9/5) + 32) %>% 
    
    # convert back to datetime
    mutate(date = as.Date(paste(y,m,d, sep = "-")),
           time = strptime(h, "%H"),
           datetime = ymd_hms(as.POSIXct(paste(date, hour(time)), 
                                         format="%Y-%m-%d %H"))) %>% 
    
    # select variables of interest
    ungroup() %>% 
    dplyr::select(datetime, relative_tide_level, water_temperature)
  
  tides_new_xts_rt <- xts::xts(x = tides_new_df %>% 
                                 dplyr::select(-datetime), 
                               order.by = tides_new_df$datetime)
  tides_new_xts_rt <- xts::period.apply(tides_new_xts_rt,
                                      INDEX = xts::endpoints(tides_new_xts_rt, "mins", k=30),
                                      FUN = mean)
  } else {
    message("No tidal data available")
    tides_new_xts_rt <- NA
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
      filter(STATION == "OYSM") %>% 
      dplyr::select(-STATION) %>% 
      mutate_all(function(x)ifelse(x == ".", NA, x)) %>% 
      mutate_at(vars(PPT:SOIL.T), as.numeric) %>% 
      tidyr::unite("datetime",c("YEAR", "MONTH", "DAY"), sep = "-", remove = T) %>%
      mutate(TIME2 = format(strptime(substr(as.POSIXct(sprintf("%04.0f", as.numeric(TIME)),
                                                       format="%H%M"), 12, 16), 
                                     '%H:%M'), '%I:%M %p')) %>% 
      mutate(datetime = as.POSIXct(paste(.$datetime, TIME2), 
                                   format="%Y-%m-%d %I:%M %p")) %>% 
      dplyr::select(-TIME, -TIME2) %>% 
      dplyr::filter(!is.na(datetime)) %>% 
      filter(!duplicated(datetime)) %>% 
      tsibble(index = datetime) %>% 
      fill_gaps(.full  = TRUE) %>% 
      as_tibble() %>% 
      dplyr::select(datetime, PPT, AVG.T, AVG.WS) %>% 
      dplyr::mutate(AVG.T = (AVG.T * 9/5) + 32,
                    AVG.WS = AVG.WS * 3.28084,
                    PPT = PPT/16.387)
    
    names(meteo_new_df) <- stringr::str_to_lower(names(meteo_new_df))
    
    meteo_new_xts_rt <- xts::xts(x = meteo_new_df %>% 
                                   dplyr::select(-datetime), 
                                 order.by = meteo_new_df$datetime)
  } else {
    message("No meteo data available")
    meteo_new_xts_rt <- NA
  }
  

  
  return(list(tides_new = tides_new_xts_rt,
              meteo_new = meteo_new_xts_rt))
}
