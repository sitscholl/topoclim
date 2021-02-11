#' Table with daily measurements from the official stations.
#'
#' A data.frame with measurements from the official stations
#'
#' @format A data frame with 16425 rows and 4 variables:
#' \describe{
#' \item{st_id}{id of the official stations}
#' \item{date}{measurement date}
#' \item{tmean}{daily mean temperature in deg C}
#' \item{irradiation}{daily solar irradiation in kWh/m2}
#' }
"timeseries"

#' Table with daily measurements of solar irradiation from the official stations
#'
#' A data.frame containing measured solar irradiation from the official stations with a long timeseries of measurements
#'
#' @format A data frame with 35430 rows and 4 variables:
#' \describe{
#' \item{st_id}{id of the official stations}
#' \item{date}{measurement date}
#' \item{month}{measurement month}
#' \item{irradiation}{daily solar irradiation in kWh/m2}
#' }
"rad_longterm"

#' Table with validation data from the phenological surveys.
#'
#' A data.frame containing a column for station id, year, phenological stage, phenological timing from the vineyard surveys, modeled phenological timing from measured temperature as well as from the lapse-rate and topoclimate model predictions
#'
#' @format A data frame with 210 rows and 7 variables:
#' \describe{
#' \item{st_id}{id of the validation stations}
#' \item{year}{year}
#' \item{stage}{phenological stage}
#' \item{survey}{starting day of year for the phenological stage from the vineyard survey}
#' \item{measured}{modeled starting day of year for the phenological stage from the measured temperature from the validation station}
#' \item{lapse_rate}{modeled starting day of year for the phenological stage from the predictions of the lapse-rate model}
#' \item{topoclimate}{modeled starting day of year for the phenological stage from the predictions of the topoclimate model}
#' }
"validation_phenology"

#' Table with validation data from the validation stations.
#'
#' A data.frame containing a column for station id, date and measured air temperature from the validation stations as well as predictions from the lapse-rate and topoclimate models
#'
#' @format A data frame with 28470 rows and 5 variables:
#' \describe{
#' \item{st_id}{id of the validation stations}
#' \item{date}{measurement date}
#' \item{measured}{measured air temperature from the validation stations}
#' \item{lapse_rate}{modeled air temperature from the lapse-rate model}
#' \item{topoclimate}{modeled air temperature from the topoclimate model}
#' }
"validation_tair"

#' Location of the official stations
#'
#' A SpatialPointsDataFrame with the location of the official stations from the national meteorological service
#'
#' @format A SpatialPointsDataFrame with 15 features and 4 variables:
#' \describe{
#' \item{st_id}{id of the station}
#' \item{elev}{elevation of the station in meters above sea level}
#' \item{slope}{slope of the station in degrees}
#' \item{aspect}{aspect of the station in degrees}
#' }

"official_stations"

#' Location of the validation stations
#'
#' A SpatialPointsDataFrame with the location of the validation stations that are placed within vineyards throughout the study area
#'
#' @format A SpatialPointsDataFrame with 15 features and 4 variables:
#' \describe{
#' \item{st_id}{id of the validation stations}
#' \item{elev}{elevation of the station in meters above sea level}
#' \item{slope}{slope of the station in degrees}
#' \item{aspect}{aspect of the station in degrees}
#' \item{aspect_c}{aspect classification among east, west, south or north}
#' \item{elev_c}{elevation class of the station}
#' }

"validation_stations"
