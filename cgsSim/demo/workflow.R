library(sf)
library(gstat)
library(terra)
library(rgrass)
library(cgsSim)

# Set GRASS region
rgrass::execGRASS(
    "g.region",
    n = "4780470",
    s = "4774720",
    e = "783130",
    w = "777410",
    flags = c("p", "a")
)

# Read vector elevation points from GRASS
elevrand <- rgrass::read_VECT("elevrand")

# Calcuate cutoff and width
coords <- terra::geom(elevrand)[, c("x", "y")]
dists <- as.matrix(dist(coords))
max_dist <- max(dists)

# Best practice
# Default cutoff is 0.5 but this is too small for our data
cutoff <- 0.7 * max_dist
width <- cutoff / 15
print(paste("Using cutoff:", cutoff, "and width:", width))

# Create exploratory variogram
elev_df <- terra::as.data.frame(elevrand, geom = "XY")
g <- gstat::gstat(formula = value ~ 1, locations = ~ x + y, data = elev_df)
vg <- gstat::variogram(g, cutoff = cutoff, width = width)

fit_kappa <- optimize_kappa(vg)

# Fit variogram model
# fit_result <- auto_variogram_fit(elev_df, cutoff = cutoff, width = width)
vgm_model <- gstat::vgm(
    model = "Mat",
    psill = 25.64052,
    range = 5984.59,
    kappa = fit_kappa,
    nugget = 25.64052
)
print(vgm_model)

vfit <- gstat::fit.variogram(vg, model = fit_result$vgm_model, fit.kappa = FALSE)

# Create 10m resolution grid for prediction
grid_ext <- terra::ext(elevrand)
grid_res <- 10

xy <- expand.grid(
    x = seq(grid_ext[1], grid_ext[2], by = grid_res),
    y = seq(grid_ext[3], grid_ext[4], by = grid_res)
)

# Convert to sf POINT geometry
xy_sf <- sf::st_as_sf(xy, coords = c("x", "y"), crs = 32633)

# Run simulation
# Simulate 10 realizations of the random field
run_sim(
    elev_df,
    fitmodel = vfit,
    nsim = 10,
    newdata = xy_sf,
    nmin = 10,
    nmax = 30,
    distmax = cutoff,
)
