#!/usr/bin/env Rscript

# --- LIBRARIES ---
library(optparse)
library(sf)
library(gstat)
library(terra)
library(rgrass)
library(future)
library(future.apply)

# --- LOAD FUNCTION ---
source("R/run_sim.R")  # load your reusable run_sim()

# --- MAIN FUNCTION ---
main <- function() {
  option_list <- list(
    make_option(c("--gdata"), type = "character", help = "Path to RDS file with input point data (sf or sp)"),
    make_option(c("--nsim"), type = "integer", help = "Number of simulations to run"),
    make_option(c("--newdata"), type = "character", help = "Path to RDS file with grid/newdata object"),
    make_option(c("--vmodel"), type = "character", help = "Path to RDS file with fitted variogram model"),
    make_option(c("--nmin"), type = "integer", default = NULL, help = "Minimum number of neighbors"),
    make_option(c("--nmax"), type = "integer", default = NULL, help = "Maximum number of neighbors"),
    make_option(c("--distmax"), type = "double", default = NULL, help = "Maximum search distance"),
    make_option(c("--ncores"), type = "integer", default = NULL, help = "Number of parallel workers"),
    make_option(c("--debug"), type = "integer", default = -1, help = "Debug level"),
    make_option(c("--prefix"), type = "character", default = "sgs_sim", help = "Prefix for GRASS raster output")
  )

  parser <- OptionParser(option_list = option_list)
  args <- parse_args(parser)

  # Load data
  gdata <- readRDS(args$gdata)
  newdata <- readRDS(args$newdata)
  model <- readRDS(args$model)

  # Run simulation
  sim_results <- run_sim(
    gdata = gdata,
    nsim = args$nsim,
    newdata = newdata,
    model = model,
    nmin = args$nmin,
    nmax = args$nmax,
    distmax = args$distmax,
    ncores = args$ncores,
    debug.level = args$debug,
    grass_prefix = args$prefix
  )

  # Save all simulations to RDS
  saveRDS(sim_results, file = paste0(args$prefix, "_results.rds"))
}

# --- ONLY RUN IF SCRIPT CALLED DIRECTLY ---
if (interactive() == FALSE) {
  main()
}
