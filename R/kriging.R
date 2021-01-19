#' kriging
#'
#' Interpolation of point values via ordinary kriging
#'
#' @param x SpatialPointsDataFrame with observed values
#' @param new_data a raster file that defines the points for which predictions are needed
#' @param formula a formula, for ordinary kriging use var ~ 1, where var equals the column name in x, where the observations are stored
#'
#' @return raster
#' @export

kriging <- function(x, new_data, formula) {

  var <- automap::autofitVariogram(formula, x)

  krige_fit <- gstat::gstat(NULL, "insol",
                            formula = formula,
                            data = x,
                            model = var$var_model)

  pred <- raster::interpolate(new_data, krige_fit)

  return(pred)

}
