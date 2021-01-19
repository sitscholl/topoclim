#' Table with daily observations from the official stations.
#'
#' A data.frame containing a column for station id, date, daily mean temperature and daily solar irradiation
#'
#' @format A data frame with 16425 rows and 4 variables:
#' \describe{
#' \item{st_id}{id of the station}
#' \item{date}{measurement date}
#' \item{tmean}{daily mean temperature in deg C}
#' \item{irradiation}{daily solar irradiation in kWh/m2}
#' }
"timeseries"

#' Table with daily observations of solar irradiation for a long time period.
#'
#' A data.frame containing a column for station id, date and daily solar irradiation
#'
#' @format A data frame with 16425 rows and 4 variables:
#' \describe{
#' \item{st_id}{id of the station}
#' \item{date}{measurement date}
#' \item{month}{measurement month}
#' \item{irradiation}{daily solar irradiation in kWh/m2}
#' }
"rad_longterm"

#' Location of the official stations
#'
#' A SpatialPointsDataFrame with the location of the official meteorological stations from the national meteorological service
#'
#' @format A SpatialPointsDataFrame with 15 features and 4 variables:
#' \describe{
#' \item{st_id}{id of the station}
#' \item{elev}{elevation of the station in meters above sea level}
#' \item{slope}{slope of the station in degrees}
#' \item{aspect}{aspect of the station in degrees}
#' }

"station_location"
