library(testthat)
library(sf)
library(gstat)
library(terra)

test_that("run_sim returns expected number of simulations with Matérn model", {
  # Create 100 random sample points with spatial coordinates and values
  set.seed(42)
  coords <- data.frame(
    x = runif(100, 0, 1000),
    y = runif(100, 0, 1000),
    value = rnorm(100, mean = 50, sd = 10)
  )

  pts_sf <- sf::st_as_sf(
    coords,
    coords = c("x", "y"),
    crs = 32633
  ) # UTM zone 33N, example
  pts_sp <- as(pts_sf, "Spatial")

  # Create a 50m grid over the same area
  grid <- sf::st_as_sf(expand.grid(
    x = seq(0, 1000, 50),
    y = seq(0, 1000, 50)
  ), coords = c("x", "y"), crs = 32633)
  grid_sp <- as(grid, "Spatial")

  # Compute experimental variogram
  v <- gstat::variogram(value ~ 1, data = pts_sp, cutoff = 300)

  # Fit Matérn variogram model
  vfit <- gstat::fit.variogram(
    v,
    gstat::vgm(
      model = "Mat",
      psill = 100,
      range = 300,
      nugget = 10,
      kappa = 1.2
    ),
    fit.kappa = FALSE
  )

  expect_s3_class(vfit, "variogramModel")

  # Run simulation
  sim <- run_sim(
    pts = pts_sp,
    nsim = 3,
    newdata = grid_sp,
    fitmodel = vfit,
    write_to_grass = FALSE,
    ncores = 2
  )

  # Validate output
  expect_length(sim, 3)
  expect_true(all(sapply(sim, inherits, what = "SpatialPointsDataFrame")))
})
