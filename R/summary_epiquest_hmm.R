#' Summary of hidden Markov model fit
#'
#' Provides a readable summary of an \code{epiquest_hmm} object,
#' including model type, state definitions, and transition probabilities.
#'
#' @param object An object of class \code{epiquest_hmm} produced by \code{run_hmm()}.
#' @param ... Additional arguments passed to methods (not currently used).
#'
#' @details
#' The last section on state distribution (observations) does not count the number
#' of observations in each state since the model does not make hard state assignments.
#' Rather, it provides for each observations a (posterior smoothing) probability that
#' it is in each of the states. In other words, each observation is assigned a weight
#' of 1 that is distributed over the different states. The summary provides the total
#' weight in each state.
#'
#' @return The function prints a summary to the console and invisibly
#'   returns the \code{object}.
#'
#' @export
#' @importFrom rlang .data
summary.epiquest_hmm <- function(object, ...) {
  cat("\n========================================================\n")
  cat("         EpiQUEST hidden Markov model summary           \n")
  cat("========================================================\n\n")

  # Model configuration ----------------------------------------------
  cat("--- Model configuration --------------------------------\n")
  cat("Type:                   ", ifelse(object$type == "rate", "Continuous (Gaussian)", "Percentage (binomial)"), "\n")
  cat("Number of states:       ", object$n_states, "\n")
  cat("Seasonal:               ", object$seasonal, "\n")
  cat("Number of observations: ", nrow(object$data), "\n\n")

  # State estimates --------------------------------------------------
  cat("--- Estimated state parameters -------------------------\n")

  if (object$type == "rate") {
    print(
      as.data.frame(
        object$states |>
          dplyr::rename(State = "state", Mean = "mean_state", `Standard deviation` = "sd_state")
      ),
      row.names = FALSE
    )
    cat("\n")
  } else if (object$type == "perc") {
    print(
      as.data.frame(
        object$states |>
          dplyr::mutate(mean_state = sprintf("%.2f%%", .data$mean_state * 100)) |>
          dplyr::rename(State = "state", Proportion = "mean_state")
      ),
      row.names = FALSE
    )
    cat("\n")
  }

  # Transition matrix  -----------------------------------------------
  info_transition <- tibble::as_tibble(object$transition) |>
    dplyr::mutate(dplyr::across(dplyr::where(is.numeric), ~ sprintf("%.2f%%", .x * 100))) |>
    dplyr::mutate(State = rownames(object$transition)) |>
    dplyr::relocate("State")

  cat("--- Transition matrix ----------------------------------\n")
  print(as.data.frame(info_transition), row.names = FALSE)

  # State distribution -----------------------------------------------
  cat("\n--- State distribution (observations) ------------------\n")

  # Calculate soft proportions
  soft_weights <- object$data |>
    dplyr::select(dplyr::starts_with("prob_L")) |>
    colSums()

  soft_proportions <- soft_weights / nrow(object$data)

  summary_dist <- tibble::tibble(
    State = names(soft_proportions) |> gsub("prob_", "", x = _),
    `Total weight` = as.numeric(round(soft_weights, 1)),
    Proportion = paste0(round(soft_proportions * 100, 1), "%")
  )

  print(as.data.frame(summary_dist), row.names = FALSE)

  cat("\nNote: Weights are posterior probabilities.\n")
  cat("========================================================\n")

  invisible(object)
}
