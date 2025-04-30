#' @title Automatically fit a variogram model by cross-validation
#' @description Finds optimal psill, range, and nugget parameters by minimizing LOOCV mean squared error.
#' @param pts A sf object or data.frame.
#' @param model The variogram model type (default "Mat").
#' @param kappa Matérn smoothness parameter (default 1.2).
#' @param cutoff Maximum distance for empirical variogram.
#' @param width Bin width for empirical variogram.
#' @param return_vgm Logical, if TRUE return a gstat vgm model ready for use.
#' @return List with optimized psill, range, nugget, mse, and optionally the fitted vgm model.
#' @importFrom gstat variogram fit.variogram vgm gstat gstat.cv
#' @importFrom stats optim
#' @export
auto_variogram_fit <- function(pts, model = "Mat", kappa = 1.2, cutoff = NULL, width = NULL, return_vgm = TRUE) {
    if (!is.null(cutoff) && !is.numeric(cutoff)) {
        stop("cutoff must be a numeric value.")
    }
    if (!is.null(width) && !is.numeric(width)) {
        stop("width must be a numeric value.")
    }
    if (!is.null(cutoff) && !is.null(width) && cutoff <= width) {
        stop("cutoff must be greater than width.")
    }
    if (!is.null(cutoff) && is.null(width)) {
        width <- cutoff / 15
    }
    if (is.null(cutoff) && is.null(width)) {
        cutoff <- 0.5 * max(pts$x, na.rm = TRUE)
        width <- cutoff / 15
    }
    # Check if pts is a data frame or sf object
    pts <- prepare_pts(pts)
    g <- gstat::gstat(formula = value ~ 1, locations = ~ x + y, data = pts)
    vg <- gstat::variogram(g, cutoff = cutoff, width = width)

    f <- function(params) {
        psill <- params[1]
        range <- params[2]
        nugget <- params[3]

        vgm_model <- gstat::vgm(psill = psill, model = model, range = range, nugget = nugget, kappa = kappa)
        vfit <- tryCatch(
            gstat::fit.variogram(vg, model = vgm_model, fit.kappa = FALSE),
            error = function(e) {
                return(NULL)
            }
        )

        if (is.null(vfit)) {
            return(Inf)
        }
        gfit <- gstat::gstat(
            formula = value ~ 1,
            data = pts,
            model = vfit,
            locations = ~ x + y
        )
        # Get beta (mean) - Needed to perform simple kriging
        beta <- mean(pts$value, na.rm = TRUE)
        print(beta)
        cv <- gstat::gstat.cv(gfit, nfold = nrow(pts), nmax = 40, beta = beta, verbose = FALSE)

        mse <- mean((cv$residual)^2, na.rm = TRUE)
        return(as.numeric(mse))
    }

    # Initial guess for parameters
    coords <- pts[, c("x", "y")]
    dists <- as.matrix(dist(coords))
    min_spacing <- min(dists[dists > 0])
    mean_spacing <- mean(dists[dists > 0])

    # Get the variance of the values
    value_var <- var(pts$value, na.rm = TRUE)

    par_start <- c(
        psill_start = 0.5 * value_var,
        range_start = mean_spacing * 2,
        nugget_start = 0.01 * value_var
    )

    lower_bounds <- c(1e-3, min_spacing, 0)
    upper_bounds <- c(5 * value_var, 10 * mean_spacing, 0.1 * value_var)

    # TODO add optimParallel
    result <- optim(
        par = par_start,
        fn = f,
        method = "L-BFGS-B",
        lower = lower_bounds,
        upper = upper_bounds
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
        kappa = kappa,
        mse = result$value
    )

    if (return_vgm) {
        out$vgm_model <- fitted_vgm
    }

    return(out)
}
