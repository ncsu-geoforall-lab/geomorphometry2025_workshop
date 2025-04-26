library(testthat)
library(sf)
library(gstat)
library(terra)

test_that("prepare_pts handles sf and data.frame correctly", {
  pts_sf <- sf::st_as_sf(data.frame(x = 1:5, y = 2:6, value = 10:14), coords = c("x", "y"), crs = 4326)
  expect_s3_class(prepare_pts(pts_sf), "data.frame")

  pts_df <- data.frame(x = 1:5, y = 2:6, value = 10:14)
  expect_s3_class(prepare_pts(pts_df), "data.frame")

  bad_df <- data.frame(a = 1:5, b = 2:6)
  expect_error(prepare_pts(bad_df))
})