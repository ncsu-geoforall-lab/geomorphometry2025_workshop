#' @title Plot empirical and fitted variogram
#' @description Plots the empirical variogram together with the fitted model.
#' @param vg A gstat::variogram object.
#' @param vgm_model A gstat variogram model object.
#' @return A plot of the empirical variogram with the fitted model.
#' @importFrom gstat variogram gstat fit.variogram
#' @export
plot_auto_variogram <- function(vg, vgm_model) {
    # Plot the empirical variogram
    vfit <- gstat::fit.variogram(vg, model = vgm_model, fit.kappa = FALSE)
    plot(vg, model = vfit, main = "Empirical Variogram with Fitted Model")
}
