#' @title Smart Optimizer Dispatcher
#' @description Automatically uses optimParallel if available, otherwise falls back to stats::optim.
#' @param ... Arguments passed to optim or optimParallel
#' @return Optim result list
#' @importFrom stats optim
#' @importFrom optimParallel optimParallel
#' @export
smart_optim <- function(...) {
  if (requireNamespace("optimParallel", quietly = TRUE)) {
    message("Using optimParallel for parallel optimization.")
    return(optimParallel::optimParallel(...))
  } else {
    message("optimParallel not available, falling back to optim.")
    return(stats::optim(...))
  }
}
