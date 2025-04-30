#' @title Optimize kappa for a Matérn variogram
#' @description Uses WLS to fit variograms for different kappa and finds the best one.
#' @param vg A gstat variogram object (from gstat::variogram)
#' @param kappa_range Numeric vector of length 2, bounds for optimization (e.g., c(0.1, 5))
#' @return A list with best fitted model and selected kappa
#' @importFrom gstat vgm fit.variogram
#' @export
optimize_kappa <- function(vg, kappa_range = c(0.1, 5)) {
    f <- function(x) {
        tryCatch(
            {
                vfit <- gstat::fit.variogram(vg, model = gstat::vgm(model = "Mat", nugget = NA, kappa = x))
                attr(vfit, "SSErr")
            },
            error = function(e) Inf
        )
    }
    result <- optimize(f, kappa_range)
    best_kappa <- result$minimum
    vfit_best <- gstat::fit.variogram(vg, model = gstat::vgm(model = "Mat", nugget = NA, kappa = best_kappa))
    list(model = vfit_best, kappa = best_kappa, SSErr = result$objective)
}
