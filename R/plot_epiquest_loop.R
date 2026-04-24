#' Plot method for loop stability results
#'
#' A wrapper for \code{\link{create_loop_plots}} that returns
#' the threshold stability visualization by default.
#'
#' @param x An object of class \code{epiquest_loop} produced by
#'   \code{run_loop_thresholds()}.
#' @param ... Additional arguments passed to methods (not currently used).
#'
#' @return A \code{ggplot2} object showing the evolution of thresholds
#'   across various cutoff dates.
#'
#' @keywords internal
#' @importFrom rlang .data
#' @export
plot.epiquest_loop <- function(x, ...) {
  create_loop_plots(x)$thresholds
}
