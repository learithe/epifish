library("lubridate")


#' Identify epi week number for a given date
#'
#' Given a case date and epidemic start date (in day-month-year order),
#' return the epi week it represents.
#'
#' @details
#' A CDC-format "epi week" starts on Sunday and ends on Saturday. This function takes a case
#' date, and date to start counting on (eg the first case of an epidemic or the first day
#' of a year), and returns the epi week that case ocurred on.
#'
#' @param cdate character date of interest in dmy format (19/01/2020, 19-1-20, 19.1.20, or similar)
#' @param start_date character date of epidemic start in dmy format.
#'
#' @return integer number of epi weeks since the epidemic start
#'
#' @example
#' get_epi_week(cdate="1/4/2020", start_date="25/1/2020")
#' get_epi_week("25/1/2020", "25/1/2020")
#' get_epi_week("1/4/2020", "1/1/2019")
#'
#' @export
#'
#'
get_epi_week<- function(cdate, start_date) {
  d1 <- lubridate::dmy(cdate)
  d2 <- lubridate::dmy(start_date)
  d2 <- floor_date(d2, unit="week", week_start=7) -1
  e <- ceiling( time_length(difftime(d1, d2), unit="week") )
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
#' @param cdate character string in dmy format (20/1/2020, 20-1-20, 20.01.20, or similar)
#' @param return_end  TRUE/FALSE whether to just return the end day
#' @param add_year TRUE/FALSE whether to include the year
#' @param first_month TRUE/FALSE whether to include the first month in the text
#'
#' @return character string
#'
#' @example
#' get_epi_week_span_date( "25.01.2020")
#' get_epi_week_span_date( "25.01.2020", return_end=TRUE, add_year=TRUE)
#' get_epi_week_span_date( "25.01.2020", first_month=FALSE, add_year=TRUE)
#'
#' @export
#'
#'
get_epi_week_span_date <- function(cdate, return_end=FALSE, add_year=FALSE, first_month=TRUE){

  t <- dmy(cdate)
  end <- ceiling_date(t, unit="week", week_start=7) -1
  start <- floor_date(t, unit="week", week_start=7)

  ret <- paste0( day(end), " ", as.character( month(end, label=TRUE)) )

  if(add_year==TRUE){
    ret <- paste0( ret, " ", year(end))
  }

  if ( return_end==FALSE & first_month==FALSE ) {
    ret <- paste0( day(start), "-", ret)
  }

  if( return_end==FALSE & first_month==TRUE ){
    ret <- paste0( day(start), " ",
                   as.character( month(start, label=TRUE)),
                   "-", ret)
  }

  return(ret)

}



#' Extract the month in text form from a date
#'
#' Given a case date, returns the month it belongs to (eg "Apr" or "Apr 2020)
#'
#' @details
#' This function takes a case date, and returns a human-friendly description
#' of the month it belongs to (useful for labelling plots).
#'
#' @param cdate character string in dmy format (20/1/2020, 20-1-20, 20.01.20, or similar)
#' @param add_year TRUE/FALSE whether to include the year
#'
#' @return character string
#'
#' @example
#' get_month( "25.01.2020")
#' get_month( "25.01.2020", add_year=TRUE)
#'
#' @export
#'
get_month <- function(cdate, add_year=FALSE){
  t <- dmy(cdate)
  ret <- paste0( as.character( month(t, label=TRUE)) )

  if(add_year==TRUE){ ret <- paste0( ret, " ", year(t)) }
  return(ret)

}
get_month("25.1.2020")
get_month("25.1.2020", add_year=TRUE)

