#' Generate default labels for HMM states
#'
#' Provides standardized names for hidden states based on the number of states
#' specified. These labels are used for plot legends and summary tables to
#' provide epidemiological interpretation to the states.
#'
#' @param n_states An integer. The number of hidden states (2 to 4).
#'
#' @details
#' The labels are assigned as follows:
#' \itemize{
#'   \item \strong{2 states}: "Low activity (L1)", "High activity (L2)"
#'   \item \strong{3 states}: "Low activity (L1)", "Medium activity (L2)", "High activity (L3)"
#'   \item \strong{4 states}: "Very low activity (L1)", "Low activity (L2)", "Medium activity (L3)", "High activity (L4)"
#' }
#'
#' @return A character vector of length \code{n_states} containing the labels.
#'
#' @seealso \code{\link{generate_palette_hmm}}
#' @keywords internal
#' @importFrom rlang .data
#' @export
generate_state_labels_hmm <- function(
  n_states = 3
) {
  if (n_states == 2) {
    state_labels <- c("Low activity (L1)", "High activity (L2)")
  } else if (n_states == 3) {
    state_labels <- c("Low activity (L1)", "Medium activity (L2)", "High activity (L3)")
  } else if (n_states == 4) {
    state_labels <- c("Very low activity (L1)", "Low activity (L2)", "Medium activity (L3)", "High activity (L4)")
  } else {
    stop("Input n_states must be integer between 2 and 4.")
  }

  return(state_labels)
}
