#' complete_ts
#'
#' Fill the missing values between the monthly reference values for radiation via linear interpolation
#'
#' @param x data.frame with the columns st_id, month, h_clear and h_cloud
#'
#' @return data.frame
#' @export

complete_ts <- function(x) {

  #Generate a sequence of dates for an entire, arbitrary year
  dseq <- seq.Date(as.Date('2019-01-01'),
                   as.Date('2019-12-31'),
                   by = 'day')

  #use the 15 of each month for observed reference irradiation
  x$day <- 15

  #generate a data.frame with the datesequence
  x_daily <- data.frame(date = dseq,
                        month = as.numeric(format(dseq, '%m')),
                        day = as.numeric(format(dseq, '%d')))

  #join the observed reference values
  x_daily <- merge(x_daily, x, by = c('month', 'day'), all.x = T)
  x_daily$st_id <- unique(x$st_id)

  #fill the missing values via linear interpolation
  x_daily$h_clear <- imputeTS::na_interpolation(x_daily$h_clear)
  x_daily$h_cloud <- imputeTS::na_interpolation(x_daily$h_cloud)

  x_daily$date <- NULL

  return(x_daily)
}
