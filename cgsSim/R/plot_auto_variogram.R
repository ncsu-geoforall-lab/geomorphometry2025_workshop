#' @title Plot empirical and fitted variogram
#' @description Plots the empirical variogram together with the fitted model.
#' @param pts A sf object or data.frame.
#' @param vgm_model A gstat variogram model object.
#' @param cutoff Maximum distance for the empirical variogram.
#' @param width Bin width for the empirical variogram.
#' @importFrom gstat variogram gstat
#' @export
plot_auto_variogram <- function(pts, vgm_model, cutoff = NULL, width = NULL) {
    pts <- prepare_pts(pts)
    g <- gstat::gstat(formula = value ~ 1, locations = ~x + y, data = pts)
    vg <- gstat::variogram(g, cutoff = cutoff, width = width)
    vfit <- gstat::fit.variogram(vg, model = vgm_model, fit.kappa = FALSE)

    plot(vg, model = vfit, main = "Empirical Variogram with Fitted Model")
}
