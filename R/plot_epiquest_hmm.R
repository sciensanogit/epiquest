#' Plot method for HMM results
#'
#' A wrapper for \code{\link{create_hmm_plots}} that provides the
#' "full time series" visualization by default.
#'
#' @param x An object of class \code{epiquest_hmm} produced by \code{run_hmm()}.
#' @param ... Additional arguments passed to methods (not currently used).
#'
#' @return A \code{ggplot2} object showing the time series colored by the
#'   most probable hidden state.
#'
#' @keywords internal
#' @importFrom rlang .data
#' @export
plot.epiquest_hmm <- function(x, ...) {
  create_hmm_plots(x)$time_series_full
}
