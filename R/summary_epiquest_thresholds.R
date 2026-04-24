#' Summary of QUEST thresholds
#'
#' Provides a readable summary of the calculated thresholds and the
#' HMM configuration used to derive them.
#'
#' @param object An object of class \code{epiquest_thresholds}.
#' @param ... Additional arguments passed to methods.
#'
#' @return The function prints a summary to the console and invisibly
#'   returns the \code{object}.
#'
#' @export
#' @importFrom rlang .data
summary.epiquest_thresholds <- function(object, ...) {
  cat("\n==============================================================\n")
  cat("        EpiQUEST threshold summary                            \n")
  cat("==============================================================\n\n")

  cat("--- Model configuration --------------------------------------\n")
  cat("Type:                         ", ifelse(object$type == "rate", "Continuous (Gaussian)", "Percentage (binomial)"), "\n")
  cat("Number of states:             ", object$n_states, "\n")
  cat("Seasonal:                     ", object$seasonal, "\n")
  cat("Number of observations:       ", nrow(object$data), "\n")
  cat("State(s) defined as epidemic: ", paste(paste0("L", object$epidemic_state_indices), collapse = ", "), "\n\n")

  # Threshold specific info
  cat("--- Calculated QUEST thresholds ------------------------------\n")

  # Match labels to the values
  labels <- generate_threshold_labels(length(object$quantiles))

  if (object$type == "rate") {
    df_thresh <- data.frame(
      Level = labels,
      Quantile = paste0(object$quantiles * 100, "%"),
      Value = round(object$thresholds, 3)
    )
  } else if (object$type == "perc") {
    df_thresh <- data.frame(
      Level = labels,
      Quantile = paste0(object$quantiles * 100, "%"),
      Value = sprintf("%.2f%%", object$thresholds * 100)
    )
  }

  print(df_thresh, row.names = FALSE)

  cat("\nNote: Thresholds calculated using weighted ECDF\n")
  cat("based on posterior probabilities of epidemic state(s).\n")
  cat("==============================================================\n")

  invisible(object)
}
