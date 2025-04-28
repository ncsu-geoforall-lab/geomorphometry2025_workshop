#' @title Run Conditional Gaussian Simulations (SGS)
#' @description Perform parallel conditional Gaussian simulations using gstat and save results into GRASS.
#' 
#' @param gdata sf or Spatial object: observed points
#' @param nsim integer: number of simulations
#' @param newdata sf or Spatial object: prediction grid
#' @param vmodel variogram model from gstat::fit.variogram()
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
run_sim <- function(gdata, nsim, newdata, vmodel, nmin = 0, nmax = 0, distmax = Inf,
                    ncores = NULL, debug.level = -1, write_to_grass = TRUE, grass_prefix = "sgs_sim") {

  if (is.null(ncores) || ncores <= 0) {
    ncores <- parallel::detectCores() - 1
  }

  future::plan(future::multisession, workers = ncores)

  sim_list <- future.apply::future_lapply(1:nsim, function(i) {

    is_spatial <- inherits(gdata, c("Spatial", "sf"))

    krige_args <- list(
      formula = value ~ 1,
      newdata = newdata,
      model = vmodel,
      nmin = nmin,
      nmax = nmax,
      maxdist = distmax,
      nsim = 1,
      debug.level = debug.level
    )

    if (is_spatial) {
      krige_args$locations <- gdata
    } else {
      krige_args$locations <- ~x + y
      krige_args$data <- gdata
    }

    sim <- do.call(gstat::krige, krige_args)

    # sim <- gstat::krige(
    #   formula = value ~ 1,
    #   data = if (!inherits(g, c("Spatial", "sf"))) gdata else NULL,
    #   locations = locations_arg,
    #   newdata = newdata,
    #   model = vmodel,
    #   nmin = nmin,
    #   nmax = nmax,
    #   maxdist = distmax,
    #   nsim = 1,
    #   debug.level = debug.level
    # )

    if (write_to_grass) {
      sim_rast <- terra::rast(sim)
      outname <- paste0(grass_prefix, "_", i)
      rgrass::write_RAST(sim_rast, outname, flags = c("overwrite"))
    }

    return(sim)
  })

  return(sim_list)
}
