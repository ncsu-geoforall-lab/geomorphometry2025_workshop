#' @title Automatically fit a variogram model by cross-validation
#' @description Finds optimal psill, range, and nugget parameters by minimizing LOOCV mean squared error.
#' @param pts A SpatialPointsDataFrame or sf object with x, y, value columns.
#' @param model The variogram model type (default "Mat").
#' @param kappa Matérn smoothness parameter (default 1.2).
#' @param cutoff Maximum distance for empirical variogram.
#' @param width Bin width for empirical variogram.
#' @param return_vgm Logical, if TRUE return a gstat vgm model ready for use.
#' @return List with optimized psill, range, nugget, mse, and optionally the fitted vgm model.
#' @export
auto_variogram_fit <- function(pts, model = "Mat", kappa = 1.2, cutoff = 3000, width = 100, return_vgm = TRUE) {
    
    pts <- prepare_pts(pts)
    vg <- gstat::variogram(value ~ 1, data = pts, locations = ~x + y, cutoff = cutoff, width = width)

    f <- function(params) {
        psill <- params[1]
        range <- params[2]
        nugget <- params[3]

        vgm_model <- gstat::vgm(psill = psill, model = model, range = range, nugget = nugget, kappa = kappa)
        vfit <- tryCatch(
        gstat::fit.variogram(vg, vgm_model, fit.kappa = FALSE),
        error = function(e) return(NULL)
        )

        if (is.null(vfit)) return(Inf)

        gfit <- gstat::gstat(formula = value ~ 1, data = pts, model = vfit)
        cv <- gstat::krige.cv(gfit, nfold = nrow(pts), verbose = FALSE)

        mean((cv$residual)^2, na.rm = TRUE)
    }

    result <- optim(
        par = c(100, 1000, 10),
        fn = f,
        method = "L-BFGS-B",
        lower = c(1e-3, 10, 0),
        upper = c(5000, 10000, 500)
    )

    fitted_vgm <- gstat::vgm(
        psill = result$par[1],
        model = model,
        range = result$par[2],
        nugget = result$par[3],
        kappa = kappa
    )

    out <- list(
        psill = result$par[1],
        range = result$par[2],
        nugget = result$par[3],
        mse = result$value
    )

    if (return_vgm) {
        out$vgm_model <- fitted_vgm
    }

    return(out)
    }
