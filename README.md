
<!-- README.md is generated from README.Rmd. Please edit that file -->

# topoclim

<!-- badges: start -->

<!-- badges: end -->

## Overview

The goal of the package **topoclim** is to provide supplementary code
and explanations for the article **XXX**. The present document describes
the calculation of topoclimatic air temperature for every day during
April 2019 within the mountaineous study area South Tyrol. In the
present document, we included the code that was used to calculate the
datasets presented in the article. The package also includes some
datasets that allow everyone to run the present code.

## Installation

You can install the package using:

``` r
devtools::install_github('sitscholl/topoclim')
```

``` r
library(topoclim)
library(raster)
#> Loading required package: sp
```

## Included Datasets

The topoclim package includes the following datasets:

  - **station\_location:** A shapefile with the location of the official
    stations
  - **timeseries:** A table with daily measurements of mean temperature
    and solar irradiation from the official stations for the period 2017
    until 2019
  - **rad\_longterm:** A table with daily measurements of solar
    irradiation for seven stations for several years (up to 32 years)
  - ![](http://latex.codecogs.com/gif.latex?%5Cmathbf%7BH_%7Btopo%7D%7D):
    Incoming solar irradiation for the study area for April with a
    resolution of 100m
  - ![](http://latex.codecogs.com/gif.latex?%5Cmathbf%7BH_%7Bflat%7D%7D):
    Incoming solar irradiation for the study area using constant values
    of 0 for slope and aspect (e.g. on a flat surface) for April with a
    resolution of 100m
  - **dem:** A digital elevation model of the study area with a
    resolution of 100m

![](http://latex.codecogs.com/gif.latex?H_%7Btopo%7D) and
![](http://latex.codecogs.com/gif.latex?H_%7Bflat%7D) were both
calculated using the [Solar Analyst in
ArcGIS](https://desktop.arcgis.com/en/arcmap/10.3/tools/spatial-analyst-toolbox/area-solar-radiation.htm#),
version 10.6.1. Two separate files were calculated for a single
reference day for each month, for
![](http://latex.codecogs.com/gif.latex?H_%7Btopo%7D) we set the option
`slope_aspect_input_type` to `FROM_DEM` and for
![](http://latex.codecogs.com/gif.latex?H_%7Bflat%7D) to `FLAT_SURFACE`.
For model parameters and reference days, please check the associated
article.

*Incoming solar irradiation can also be calculated using open source
software, for example `r.sun` in GRASS GIS.*

The following code imports these datasets, and we can use them to
calculate the topoclimatic air temperature.

``` r
data("station_location")
data("timeseries")
data("rad_longterm")
h_topo <- raster( system.file('extdata', 'h_topo.tif', package = 'topoclim', mustWork = T) )
h_flat <- raster( system.file('extdata', 'h_flat.tif', package = 'topoclim', mustWork = T) )
dem <- raster( system.file('extdata', 'dem.tif', package = 'topoclim', mustWork = T) )
```

<div class="figure">

<img src="man/figures/readme-h-topo-flat-1.png" alt="Incoming solar irradiation during April with and without consideration of aspect and slope." width="100%" />

<p class="caption">

Incoming solar irradiation during April with and without consideration
of aspect and slope.

</p>

</div>

## Calculating topoclimatic air temperature

The following sections will illustrate the topoclimate model
step-by-step. First, the calculation of the *relative radiation* is
described, followed by the *cloud index*, the *radiation correction
factor*, the *lapse-rate model* and, finally, the *topoclimatic air
temperature*.

<img src="man/figures/flowchart.png" width="100%" />

### Relative Radiation

The relative radiation is defined as the ratio between incoming solar
irradiation on an inclined and flat surface:

![](http://latex.codecogs.com/gif.latex?%5CDelta_%7Brad%7D%20%3D%20%5Cfrac%7BH_%7Btopo%7D%7D%7BH_%7Bflat%7D%7D)

We can therefore calculate
![](http://latex.codecogs.com/gif.latex?%5CDelta_%7Brad%7D) by dividing
the raster objects `h_topo` and `h_flat`. Because `h_flat` contains some
unrealistic jumps in pixel values on ridges and mountain tops, it is
first smoothed using a 5x5 pixel filter.

``` r
h_flat2 <- focal(h_flat, w = matrix(1, 5, 5), fun = mean)
d_rad <- h_topo / h_flat2
```

<div class="figure">

<img src="man/figures/readme-d-rad-1.png" alt="Relative radiation during April." width="100%" />

<p class="caption">

Relative radiation during April.

</p>

</div>

### Cloud Index

The cloud index \(c\) can be calculated using the following formula:

![](http://latex.codecogs.com/gif.latex?c%20%3D%20%5Cfrac%7BH_%7Bobs%7D%20-%20H_%7Bcloud%7D%7D%7BH_%7Bclear%7D%20-%20H_%7Bcloud%7D%7D)

The first step is to calculate monthly reference values for maximum and
minimum solar irradiation
(![](http://latex.codecogs.com/gif.latex?H_%7Bclear%7D) and
![](http://latex.codecogs.com/gif.latex?H_%7Bcloud%7D)).
![](http://latex.codecogs.com/gif.latex?H_%7Bclear%7D) is defined as the
mean of all irradiation measurements above the 95% quantile and
![](http://latex.codecogs.com/gif.latex?H_%7Bcloud%7D) as the mean of
all irradiation measurements below the 95% quantile. Outliers were
already removed from this dataset, using a 3-sigma test.

``` r
h_clear_monthly <- aggregate(list(h_clear = rad_longterm$irradiation),
                             by = rad_longterm[c('st_id', 'month')],
                             FUN = function(x){
                               mean(x[x >= quantile(x, .95, na.rm = T)], na.rm = T)
                             })

h_cloud_monthly <- aggregate(list(h_cloud = rad_longterm$irradiation),
                             by = rad_longterm[c('st_id', 'month')],
                             FUN = function(x){
                               mean(x[x <= quantile(x, .05, na.rm = T)], na.rm = T)
                             })
h_ref_month <- merge(h_clear_monthly, h_cloud_monthly, by = c('st_id', 'month'))
```

From the monthly reference values, the daily reference values are
estimated via linear interpolation for every station. This can be
accomplished using the function `complete_ts()`, which is included in
this package. Internally, the function uses the function
`na_interpolation()` from the package `imputeTS`.

``` r
h_ref_split <- split(h_ref_month, h_ref_month$st_id)

h_ref <- lapply(h_ref_split, complete_ts)
#> Registered S3 method overwritten by 'quantmod':
#>   method            from
#>   as.zoo.data.frame zoo
h_ref <- do.call(rbind, h_ref)
```

Because there are only small differences for
![](http://latex.codecogs.com/gif.latex?H_%7Bclear%7D) and
![](http://latex.codecogs.com/gif.latex?H_%7Bcloud%7D) between the
single stations, the average values across all stations is used to
calculate the cloud index:

``` r
h_ref <- aggregate(h_ref[c('h_clear', 'h_cloud')],
                   by = h_ref[c('day', 'month')],
                   FUN = mean)
```

![](http://latex.codecogs.com/gif.latex?H_%7Bobs%7D) is calculated by
using ordinary kriging together with the observed irradiation from all
the official stations. The function `kriging()`, which is included in
this package, performs the ordinary kriging and returns a raster dataset
with interpolated values.

``` r
timeseries_sub <- subset(timeseries, date %in% seq.Date(as.Date('2019-04-01'), as.Date('2019-04-30'), by = 'day'))
timeseries_split <- split(timeseries_sub, timeseries_sub$date)

krige_split <- lapply(timeseries_split, merge, x = station_location, by = 'st_id', all.y = T)

# h_obs <- lapply(krige_split, kriging, new_data = dem, formula = irradiation ~ 1)
# h_obs <- stack(h_obs)
# 
# #kriging can produce negative radiation values
# h_obs[h_obs < 0] <- 0

# writeRaster(h_obs, 'cache/h_obs.tif')

h_obs <- stack('cache/h_obs.tif')
names(h_obs) <- names(krige_split)
```

In the last step, the cloud index is computed. In the present example,
we only consider the month of April. There can be some pixels, where the
interpolated value `h_obs` is higher or lower than our reference values
`h_clear` and `h_cloud`, respectively. This would lead to cloud index
values above one or below zero. To avoid this, values above one are
assigned a value of one, and values below zero a value of zero.

``` r
h_ref_sub <- subset(h_ref, month == 4)

c <- (h_obs - h_ref_sub$h_cloud) / (h_ref_sub$h_clear - h_ref_sub$h_cloud)

##Standardize to range 0-1
c[c < 0] <- 0
c[c > 1] <- 1

names(c) <- names(krige_split)
```

<div class="figure">

<img src="man/figures/readme-cloud-index-1.png" alt="The cloud index for four example days during April 2019." width="100%" />

<p class="caption">

The cloud index for four example days during April 2019.

</p>

</div>

### Radiation correction factor

The relative radiation and the cloud index are both combined to the
radiation correction factor:

![](http://latex.codecogs.com/gif.latex?%5Cdelta_%7Brad%7D%20%3D%20%5Cbegin%7Bcases%7D%201%20+%20\(\(%5CDelta_%7Brad%7D%20-%201\)c\),%20&%20%5CDelta_%7Brad%7D%20%5Cgeq%201%20%5C%5C%201%20-%20\(\(1%20-%20%5CDelta_%7Brad%7D\)c\),%20&%20%5CDelta_%7Brad%7D%20%3C%201%20%5C%5C%20%5Cend%7Bcases%7D)

``` r
rcf <- 
  (d_rad >= 1) * (1 + ((d_rad - 1) * c)) +
  (d_rad <  1) * (1 - ((1 - d_rad) * c))

names(rcf) <- names(krige_split)
```

<div class="figure">

<img src="man/figures/readme-rcf-1.png" alt="The radiation correction factor for four example days during April 2019." width="100%" />

<p class="caption">

The radiation correction factor for four example days during April 2019.

</p>

</div>

### Lapse-rate model

The lapse-rate model is a simple linear regression with elevation as
explanatory and air temperature as dependent variable. Because it does
not consider slope or aspect of a surface, the predictions from the
lapse-rate model describe the air temperature of a flat surface across
different elevation levels.

``` r
#join elevation column
lr_split <- lapply(timeseries_split, merge, station_location@data, by = 'st_id')
#train linear models
lr_fit <- lapply(lr_split, lm, formula = tmean ~ elev)

names(dem) <- 'elev'

#predict
t_flat <- lapply(lr_fit, predict, object = dem)
t_flat <- stack(t_flat)
```

<div class="figure">

<img src="man/figures/readme-t_flat-1.png" alt="Predictions from the lapse-rate model for four example days during April 2019." width="100%" />

<p class="caption">

Predictions from the lapse-rate model for four example days during April
2019.

</p>

</div>

### Topoclima

Topoclimatic air temperature is calculated by combining the predictions
from the lapse-rate model with the radiation correction factor, using
the following formula:

![](http://latex.codecogs.com/gif.latex?T_%7Btopo%7D%20%3D%20T_%7Bflat%7D%20+%20\(\(%5Cdelta_%7Brad%7D%20-%201\)%20*%20m_%7Brad%7D%20*%20%7CT_%7Bflat%7D%7C\))

``` r
topoclim <- t_flat + ((rcf - 1) * 0.93 * abs(t_flat))
```

<div class="figure">

<img src="man/figures/readme-topoclim-1.png" alt="Topoclimatic air temperature for four example days during April 2019." width="100%" />

<p class="caption">

Topoclimatic air temperature for four example days during April 2019.

</p>

</div>
