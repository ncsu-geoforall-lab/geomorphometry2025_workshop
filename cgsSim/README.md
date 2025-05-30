
# cgsSim

<!-- badges: start -->
<!-- badges: end -->

The goal of cgsSim is to provides tools for stochastic Gaussian simulation of geospatial fields, supporting automatic variogram fitting, simple and ordinary kriging modes, and parallelized simulation.

## Features

- Automatic Matérn variogram fitting by cross-validation
- Parallel sequential Gaussian simulation
- Integration with GRASS GIS for input/output
- Support for simple kriging or ordinary kriging
- R-CMD check and pkgdown ready

## Installation

You can install the development version of cgsSim from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ncsu-geoforall-lab/geomorphometry2025_workshop")
```

## Example

This is a basic example which shows you how to solve a common problem:

```r
library(cgsSim)
## basic example code
# Set GRASS region
rgrass::execGRASS("g.region", n="4780470", s="4774720", e="783130", w="777410", flags = c("p","a"))

# Read vector elevation points from GRASS
elevrand <- rgrass::read_VECT("elevrand")
elev_df <- terra::as.data.frame(elevrand, geom = "XY")

# Fit variogram automatically
fit_result <- auto_variogram_fit(elev_df)

# Plot the fitted variogram
plot_auto_variogram(elev_df, fit_result$vgm_model)

# Create 10m resolution grid for prediction
grid_ext <- terra::ext(elevrand)
grid_res <- 10

xy <- expand.grid(
  x = seq(grid_ext[1], grid_ext[2], by = grid_res),
  y = seq(grid_ext[3], grid_ext[4], by = grid_res)
)

# Convert to sf POINT geometry
xy_sf <- sf::st_as_sf(xy, coords = c("x", "y"))

# Run conditional Gaussian simulation
sim_result <- cgsSim::cgsSim(
  gdata = elev_df,
  vmodel = fit_result$vgm_model,
  n_sim = 10,
  newdata = xy_sf
)

```
