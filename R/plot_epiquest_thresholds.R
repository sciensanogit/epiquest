#' Plot method for threshold results
#'
#' A wrapper for \code{\link{create_threshold_plots}} that provides
#' the full time series visualization with overlaid QUEST thresholds.
#'
#' @param x An object of class \code{epiquest_thresholds} produced by
#'   \code{run_threshold_computation()}.
#' @param ... Additional arguments passed to methods (not currently used).
#'
#' @return A \code{ggplot2} object showing the time series, state assignments,
#'   and QUEST thresholds.
#'
#' @keywords internal
#' @importFrom rlang .data
#' @export
plot.epiquest_thresholds <- function(x, ...) {
  create_threshold_plots(x)$time_series_full
}
