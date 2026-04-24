#' Summary of HMM stability analysis
#'
#' Provides a readable summary of the stability of thresholds and HMM
#' state means over multiple iterative refits (the loop).
#'
#' @param object An object of class \code{epiquest_loop}.
#' @param ... Additional arguments passed to methods.
#'
#' @return The function prints a summary to the console and invisibly
#'   returns the \code{object}.
#'
#' @export
#' @importFrom rlang .data
summary.epiquest_loop <- function(object, ...) {
  cat("\n========================================================\n")
  cat("        EpiQUEST stability analysis summary             \n")
  cat("========================================================\n\n")

  # Loop configuration
  n_iterations <- length(unique(object$thresholds$cutoff))
  cat("--- Loop configuration ---------------------------------\n")
  cat("Number of iterations (refits): ", n_iterations, "\n")
  cat("Step size (increments):        ", object$step, "units\n")
  cat("Summary window:                ", object$window_summary, "last iterations\n\n")

  # Threshold stability
  cat("--- Threshold stability (in summary window) ------------\n")
  print(as.data.frame(object$summary_thresholds), row.names = FALSE)

  # State parameter stability
  cat("\n--- State mean stability (in summary window) -----------\n")

  df_mean_stability <- object$summary_states |>
    dplyr::select("state", dplyr::contains("mean_state")) |>
    dplyr::rename_with(~ gsub("mean_state_", "", .x), dplyr::contains("mean_state"))

  print(as.data.frame(df_mean_stability), row.names = FALSE)

  cat("\nFor information on standard deviation stability and\n")
  cat("overlap, please look at output of create_loop_plots().")
  cat("\n========================================================\n")

  invisible(object)
}
