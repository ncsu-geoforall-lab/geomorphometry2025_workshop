#' @title Plot empirical and fitted variogram
#' @description Plots the empirical variogram together with the fitted model.
#' @param pts_sp A SpatialPointsDataFrame or sf object.
#' @param vgm_model A gstat variogram model object.
#' @param cutoff Maximum distance for the empirical variogram.
#' @param width Bin width for the empirical variogram.
#' @export
plot_auto_variogram <- function(pts_sp, vgm_model, cutoff = 3000, width = 100) {
  if (inherits(pts_sp, "sf")) {
    pts_sp <- as(pts_sp, "Spatial")
  }

  vg <- gstat::variogram(value ~ 1, data = pts_sp, cutoff = cutoff, width = width)

  plot(vg, model = vgm_model, main = "Empirical Variogram with Fitted Model")
}
