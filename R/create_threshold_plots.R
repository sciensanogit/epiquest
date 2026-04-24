#' Visualize hidden Markov model and threshold results
#'
#' Extends the visualizations from \code{create_hmm_plots()} by adding
#' horizontal or vertical dashed lines representing the calculated QUEST
#' thresholds.
#'
#' @param list_results An object of class \code{epiquest_thresholds} produced
#'   by \code{run_threshold_computation()}.
#' @param print A logical. If \code{TRUE}, all generated plots are printed to the
#'   active graphics device.
#'
#' @details
#' This function first calls \code{create_hmm_plots()} to generate the base
#' visualizations. It then overlays dashed lines corresponding to the
#' \code{thresholds} stored in the \code{list_results} object.
#'
#' @return An object of class \code{epiquest_plot_list}, a named \code{list} of \code{ggplot2} objects,
#'   identical in structure to the output of \code{create_hmm_plots()}, but with threshold lines added to:
#' \itemize{
#'   \item \code{jitter_hard/soft}
#'   \item \code{histogram_hard/soft}
#'   \item \code{time_series_per_state}
#'   \item \code{time_series_full}
#' }
#'
#' @seealso \code{\link{run_threshold_computation}}, \code{\link{create_hmm_plots}}
#'
#' @examples
#' # Fit a 3-state HMM to (continuous) rate data
#' fit <- run_hmm(df_sari_be, n_states = 3, type = "rate")
#'
#' # Check state information
#' summary(fit)
#'
#' # Visualize state information
#' create_hmm_plots(fit)
#'
#' # Compute thresholds using the highest state (L3) as the epidemic state
#' # By default, epidemic_state_indices is the highest state
#' thresh <- run_threshold_computation(fit)
#'
#' # Visualize theshold information
#' summary(thresh)
#'
#' # Visualize theshold information
#' create_threshold_plots(thresh)
#' @export
#' @importFrom rlang .data
create_threshold_plots <- function(
  list_results,
  print = FALSE
) {
  list_plots <- create_hmm_plots(list_results, print = FALSE)

  list_plots$time_series_per_state <- list_plots$time_series_per_state +
    ggplot2::geom_hline(yintercept = list_results$thresholds, linetype = "dashed")

  list_plots$time_series_full <- list_plots$time_series_full +
    ggplot2::geom_hline(yintercept = list_results$thresholds, linetype = "dashed")

  list_plots$jitter_hard <- list_plots$jitter_hard +
    ggplot2::geom_hline(yintercept = list_results$thresholds, linetype = "dashed")

  list_plots$jitter_soft <- list_plots$jitter_soft +
    ggplot2::geom_hline(yintercept = list_results$thresholds, linetype = "dashed")

  list_plots$histogram_hard <- list_plots$histogram_hard +
    ggplot2::geom_vline(xintercept = list_results$thresholds, linetype = "dashed")

  list_plots$histogram_soft <- list_plots$histogram_soft +
    ggplot2::geom_vline(xintercept = list_results$thresholds, linetype = "dashed")

  if (print) {
    lapply(list_plots, print)
  }

  return(list_plots)
}
