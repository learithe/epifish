library("lubridate")


#' Identify epidemic week number for a given date
#'
#' Given a case date and epidemic start date, returns the epidemic week it represents
#'
#' @details
#' This function takes a case date, and date to start counting on (eg the first case of an
#' epidemic or the first day of a year), and returns the week that case ocurred on.
#'
#' By default this function uses a CDC-format "epi week" which starts on Sunday and ends on
#' Saturday. If you want your week to start on a different day, use the `week_start` variable.
#' #'
#' @param cdate character date of interest in chosen format
#' @param start_date character date of epidemic start
#' @param date_format character date format: "ymd" "dmy" or "mdy" (default is "ymd")
#' @param week_start integer day that weeks start on (1=Monday, 6=Saturday, 7=Sunday)
#'
#' @return integer number of epi weeks since the epidemic start
#'
#' @examples
#' get_epiweek(cdate="2020/4/1", start_date="2020/1/25", week_start=7)
#' get_epiweek("25/1/2020", "25/1/2020", date_format="dmy", week_start=7)
#' get_epiweek("01-01-2020", "01-01-2019", date_format="mdy", week_start=1)
#'
#' @export
#'
#'
get_epiweek<- function(cdate, start_date, date_format="ymd", week_start=7) {

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

  d2 <- lubridate::floor_date(d2, unit="week", week_start=week_start) -1
  e <- ceiling( lubridate::time_length( difftime(d1, d2), unit="week") )
  return(e)

}


#' Produce a human-readable start and end date for the epi week
#'
#' Given a case date, returns a text description of the epi week it belongs in
#' (eg "29 Mar - 4 Apr"). If `return_end` is `TRUE` just returns the end date
#' (eg "4 Apr"). If `add_year` is `TRUE` appends the year (eg "4 Apr 2020"). If
#' `first_month` is FALSE will skip the first month entry (eg "29-4 Apr"). If
#' `newline` is TRUE will use a newline instead of a space (eg `29-4\\nApr``).
#'
#'
#' @details
#' This function takes a case date, and returns a human-friendly description of that week
#' (useful for labelling plots). By default this function uses the CDC's description of an epi week
#' which starts on Sunday and ends on Monday; If your weeks start on a different day, use the `week_start` variable.
#'
#' @param cdate character string in specified date format (eg 2020/01/25, 2020.1.25, 20-01-05 or the like)
#' @param return_end  TRUE/FALSE whether to just return the end day
#' @param add_year TRUE/FALSE whether to include the year
#' @param first_month TRUE/FALSE whether to include the first month in the text
#' @param date_format character date format: "ymd" "dmy" or "mdy" (default is "ymd")
#' @param week_start integer day that weeks start on (1=Monday, 6=Saturday, 7=Sunday)
#' @param newline TRUE/FALSE whether to use newlines instead of spaces
#'
#' @return character string
#'
#' @examples
#' get_epiweek_span( "2020/01/25")
#' get_epiweek_span( "25.1.20", return_end=TRUE, add_year=TRUE, date_format="dmy")
#' get_epiweek_span( "1-25-2020", first_month=FALSE, add_year=TRUE, date_format="mdy")
#'
#' @export
#'
get_epiweek_span <- function(cdate, return_end=FALSE, add_year=FALSE, first_month=TRUE,
                             date_format="ymd", week_start=7, newline=FALSE){

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

  end <- lubridate::ceiling_date(t, unit="week", week_start=week_start) -1
  start <- lubridate::floor_date(t, unit="week", week_start=week_start)

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

  if(newline==TRUE){ ret <- gsub(" ", "\n", ret) }

  return(ret)

}


#' Identify epidemic month number for a given date
#'
#' Given a case date and epidemic start date, returns the epidemic month it represents
#'
#' @details
#' This function takes a case date, and date to start counting on (eg the first case of an
#' epidemic or the first day of a year), and returns the month that case ocurred on.
#'
#' @param cdate character date of interest in chosen format
#' @param start_date character date of epidemic start
#' @param date_format character date format: "ymd" "dmy" or "mdy" (default is "ymd")
#'
#' @return integer number of months since the epidemic start
#'
#' @examples
#' get_epimonth(cdate="2020/4/1", start_date="2020/1/25")
#' get_epimonth("25/1/2020", "25/1/2020", date_format="dmy")
#' get_epimonth("01-02-2020", "01-01-2019", date_format="mdy")
#'
#' @export
#'
#'
get_epimonth<- function(cdate, start_date, date_format="ymd") {

  cdate <- paste0(cdate, " 00:00:00")
  start_date <- paste0(start_date, " 00:00:01")

  if ( date_format == "ymd") {
    d1 <- lubridate::ymd_hms(cdate)
    d2 <- lubridate::ymd_hms(start_date)

  } else if ( date_format == "mdy") {
    d1 <- lubridate::mdy_hms(cdate)
    d2 <- lubridate::mdy_hms(start_date)

  } else if ( date_format == "dmy") {
    d1 <- lubridate::dmy_hms(cdate)
    d2 <- lubridate::dmy_hms(start_date)

  } else {
    warning("ERROR: date_format must one of ('ymd', 'dmy', 'mdy')")
    return(NA)
  }

  d1 <- lubridate::floor_date(d1, unit="month")
  d2 <- lubridate::ceiling_date(d2, unit="month")
  e <- ceiling( lubridate::time_length( difftime(d1, d2), unit="month") ) + 2
  
  if (lubridate::leap_year(d2)) {
    if ( ! lubridate::leap_year(d1)) {
      if (lubridate::month(d1) == 2) {
        e <- e - 1
      }
    }
  }
  return(e)
}


#' Extract the month in text form from a date
#'
#' Given a case date, returns the month it belongs to (eg "Apr" or "Apr 2020" or `Apr\\n2020`)
#'
#' @details
#' This function takes a case date, and returns a human-friendly description
#' of the month it belongs to (useful for labelling plots).
#'
#' @param cdate character string date (2020/1/19, 20-1-19, 20.01.19, or similar)
#' @param add_year TRUE/FALSE whether to include the year
#' @param date_format character date format: "ymd" "dmy" or "mdy" (default is "ymd")
#' @param newline TRUE/FALSE whether to use a newline instead of a space before the year
#'
#' @return character string
#'
#' @examples
#' get_month_text( "2020.01.25")
#' get_month_text( "2020.01.25", add_year=TRUE)
#' get_month_text( "25/1/20", add_year=TRUE, date_format="dmy", newline=TRUE)
#'
#' @export
#'
get_month_text <- function(cdate, add_year=FALSE, date_format="ymd", newline=FALSE){

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
  if(newline==TRUE){ ret <- gsub(" ", "\n", ret) }
  return(ret)

}



