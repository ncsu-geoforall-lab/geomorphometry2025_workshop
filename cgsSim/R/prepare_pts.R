#' @title Prepare points for variogram modeling
#' @description Ensure the input has x, y, and value columns. Converts sf to data.frame if needed.
#' @param pts A sf object or data.frame.
#' @return A sf object with x, y, value columns.
#' @export
prepare_pts <- function(pts) {
  if (inherits(pts, "sf")) {
    coords <- sf::st_coordinates(pts)
    crs_info <- sf::st_crs(pts)  # Save CRS (optional)
    pts <- cbind(data.frame(coords), value = pts$value)
    names(pts)[1:2] <- c("x", "y")
  }
  if (is.data.frame(pts)) {
    if (!all(c("x", "y", "value") %in% names(pts))) {
      stop("Input must have columns named 'x', 'y', and 'value'.")
    }
  } else {
    stop("Input must be sf or data.frame.")
  }
  return(pts)  # Always a data.frame
}
