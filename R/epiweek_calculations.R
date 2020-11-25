library("lubridate")


#' Identify epi week number for a given date
#'
#' Given a case date and epidemic start date, returns the epi week it represents.
#'
#' @details
#' A CDC-format "epi week" starts on Sunday and ends on Saturday. This function takes a case
#' date, and date to start counting on (eg the first case of an epidemic or the first day
#' of a year), and returns the epi week that case ocurred on.
#'
#' @param cdate character date of interest in chosen format
#' @param start_date character date of epidemic start
#' @param date_format date format: "ymd" "dmy" or "mdy" (default is "ymd")
#'
#' @return integer number of epi weeks since the epidemic start
#'
#' @examples
#' get_epiweek(cdate="2020/4/1", start_date="2020/1/25")
#' get_epiweek("25/1/2020", "25/1/2020", date_format="dmy")
#' get_epiweek("01-01-2020", "01-01-2019", date_format="mdy")
#'
#' @export
#'
#'
get_epiweek<- function(cdate, start_date, date_format="ymd") {

  if ( date_format == "ymd") {
    d1 <- lubridate::ymd(cdate)
    d2 <- lubridate::ymd(start_date)

  } else if ( date_format == "mdy") {
    d1 <- lubridate::mdy(cdate)
    d2 <- lubridate::mdy(start_date)

  } else if ( date_format == "dmy") {
    d1 <- lubridate::dmy(cdate)
    d2 <- lubridate::dmy(start_date)

  } else {
    warning("ERROR: date_format must one of ('ymd', 'dmy', 'mdy')")
    return(NA)
  }

  d2 <- lubridate::floor_date(d2, unit="week", week_start=7) -1
  e <- ceiling( lubridate::time_length( difftime(d1, d2), unit="week") )
  return(e)

}



#' Produce a human-readable start and end date for the epi week
#'
#' Given a case date, returns a text description of the epi week it represents
#' (eg "29 Mar - 4 Apr"). If `return_end` is `TRUE` just returns the end date
#' (eg "4 Apr"). If `add_year` is `TRUE` appends the year (eg "4 Apr 2020"). If
#' `first_month` is FALSE will skip the first month entry (eg "29-4 Apr")
#'
#'
#' @details
#' A CDC-format "epi week" starts on Sunday and ends on Saturday. This function takes a case
#' date, and returns a human-friendly description of that week (useful for labelling plots).
#'
#' @param cdate character string in specified date format (eg 2020/01/25, 2020.1.25, 20-01-05 or the like)
#' @param return_end  TRUE/FALSE whether to just return the end day
#' @param add_year TRUE/FALSE whether to include the year
#' @param first_month TRUE/FALSE whether to include the first month in the text
#' @param date_format character date format: "ymd" "dmy" or "mdy" (default is "ymd")
#'
#' @return character string
#'
#' @examples
#' get_epiweek_span_date( "2020/01/25")
#' get_epiweek_span_date( "25.1.20", return_end=TRUE, add_year=TRUE, date_format="dmy")
#' get_epiweek_span_date( "1-25-2020", first_month=FALSE, add_year=TRUE, date_format="mdy")
#'
#' @export
#'
#'
get_epiweek_span_date <- function(cdate, return_end=FALSE, add_year=FALSE, first_month=TRUE, date_format="ymd"){

  if ( date_format == "ymd") {
    t <-  lubridate::ymd(cdate)
  } else if ( date_format == "mdy") {
    t <- lubridate::mdy(cdate)
  } else if ( date_format == "dmy") {
    t <- lubridate::dmy(cdate)
  } else {
    warning("ERROR: date_format must one of ('ymd', 'dmy', 'mdy')")
    return(NA)
  }

  end <- lubridate::ceiling_date(t, unit="week", week_start=7) -1
  start <- lubridate::floor_date(t, unit="week", week_start=7)

  ret <- paste0( lubridate::day(end), " ", as.character( lubridate::month(end, label=TRUE)) )

  if(add_year==TRUE){
    ret <- paste0( ret, " ", lubridate::year(end))
  }

  if ( return_end==FALSE & first_month==FALSE ) {
    ret <- paste0( lubridate::day(start), "-", ret)
  }

  if( return_end==FALSE & first_month==TRUE ){
    ret <- paste0( lubridate::day(start), " ",
                   as.character( lubridate::month(start, label=TRUE)),
                   "-", ret)
  }

  return(ret)

}



#' Extract the month in text form from a date
#'
#' Given a case date, returns the month it belongs to (eg "Apr" or "Apr 2020")
#'
#' @details
#' This function takes a case date, and returns a human-friendly description
#' of the month it belongs to (useful for labelling plots).
#'
#' @param cdate character string date (2020/1/19, 20-1-19, 20.01.19, or similar)
#' @param add_year TRUE/FALSE whether to include the year
#' @param date_format character date format: "ymd" "dmy" or "mdy" (default is "ymd")
#'
#' @return character string
#'
#' @examples
#' get_month( "2020.01.25")
#' get_month( "2020.01.25", add_year=TRUE)
#' get_month( "25/1/20", add_year=TRUE, date_format="dmy")
#'
#' @export
#'
get_month <- function(cdate, add_year=FALSE, date_format="ymd"){

  if ( date_format == "ymd") {
    t <-  lubridate::ymd(cdate)
  } else if ( date_format == "mdy") {
    t <- lubridate::mdy(cdate)
  } else if ( date_format == "dmy") {
    t <- lubridate::dmy(cdate)
  } else {
    warning("ERROR: date_format must one of ('ymd', 'dmy', 'mdy')")
    return(NA)
  }

  ret <- paste0( as.character( lubridate::month(t, label=TRUE)) )

  if(add_year==TRUE){ ret <- paste0( ret, " ", lubridate::year(t)) }
  return(ret)

}

