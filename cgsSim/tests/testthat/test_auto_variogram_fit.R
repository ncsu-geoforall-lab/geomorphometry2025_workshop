test_that("auto_variogram_fit returns correct structure", {
    # Convert to sf-style data frame for gstat
    pts_df <- data.frame(x = runif(10, 0, 100), y = runif(10, 0, 100), value = rnorm(10))
    vfit <- auto_variogram_fit(pts_df)

    expect_true("psill" %in% names(vfit))
    expect_true("range" %in% names(vfit))
    expect_true("nugget" %in% names(vfit))
    expect_true("mse" %in% names(vfit))
    expect_true("vgm_model" %in% names(vfit))
})
