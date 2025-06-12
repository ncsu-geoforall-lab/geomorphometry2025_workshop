#' @title Run Conditional Gaussian Simulations (SGS)
#' @description Perform parallel conditional Gaussian simulations using gstat and save results into GRASS.
#'
#' @param pts sf or Spatial object: observed points
#' @param fitmodel variogram model from gstat::fit.variogram()
#' @param nsim integer: number of simulations
#' @param newdata sf or Spatial object: prediction grid
#' @param nmin optional kriging parameter Minimum number of neighbors
#' @param nmax optional kriging parameter Maximum number of neighbors
#' @param distmax optional kriging parameter Maximum search distance
#' @param ncores number of parallel workers
#' @param debug.level integer controlling kriging verbosity
#' @param write_to_grass logical: whether to save results to GRASS
#' @param grass_prefix character: GRASS raster name prefix
#'
#' @return A list of simulated realizations
#' @importFrom gstat krige
#' @importFrom future plan
#' @importFrom future.apply future_lapply
#' @importFrom rgrass write_RAST
#' @importFrom terra rast
#' @export
run_sim <- function(pts, fitmodel, nsim, newdata, nmin = 0, nmax = 0, distmax = Inf,
                    ncores = NULL, debug.level = -1, write_to_grass = TRUE, grass_prefix = "sgs_sim") {
  if (is.null(ncores) || ncores <= 0) {
    ncores <- parallel::detectCores() - 1
  }

  #
  sf::st_crs(pts) == sf::st_crs(newdata)

  future::plan(future::multisession, workers = ncores)

  sim_list <- future.apply::future_lapply(1:nsim, function(i) {
    krige_args <- list(
      formula = value ~ x + y,
      newdata = newdata,
      locations = ~ x + y,
      data = pts,
      model = fitmodel,
      nmin = nmin,
      nmax = nmax,
      maxdist = distmax,
      nsim = 1,
      debug.level = debug.level
    )

    sim <- do.call(gstat::krige, krige_args)

    if (write_to_grass) {
      sim_rast <- terra::rast(sim)
      outname <- paste0(grass_prefix, "_", i)
      rgrass::write_RAST(sim_rast, outname, overwrite = TRUE, flags = c("o"))
    }

    return(sim)
  })

  return(sim_list)
}
