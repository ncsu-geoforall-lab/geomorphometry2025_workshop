test_that("plot_auto_variogram runs without error", {
  pts_df <- data.frame(x = runif(10, 0, 100), y = runif(10, 0, 100), value = rnorm(10))
  vfit <- auto_variogram_fit(pts_df)

  expect_silent(plot_auto_variogram(pts_df, vfit$vgm_model))
})