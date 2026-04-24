#' Generate standardized ggplot2 color scales for HMM states
#'
#' Generates a manual color or fill scale for \code{ggplot2} using a
#' pre-defined color palette designed for epidemiological surveillance signals.
#'
#' @param n_states An integer. The number of hidden states (2 to 4).
#' @param fill A logical. If \code{TRUE}, returns \code{scale_fill_manual}.
#'   If \code{FALSE} (default), returns \code{scale_color_manual}.
#'
#' @details
#' The palette uses specific hex codes to represent severity. In general:
#' \itemize{
#'   \item \strong{Green} : (very) low activity.
#'   \item \strong{Yellow}: medium activity.
#'   \item \strong{Red}: high activity.
#' }
#'
#' @return A \code{ggplot2} manual color/fill scale object.
#'
#' @seealso \code{\link{generate_state_labels_hmm}}
#' @keywords internal
#' @importFrom rlang .data
#' @export
generate_palette_hmm <- function(
  n_states = 3,
  fill = FALSE
) {
  if (n_states == 2) {
    colors <- c("#39B54A", "#C95117")
  } else if (n_states == 3) {
    colors <- c("#39B54A", "#FAD500", "#C95117")
  } else if (n_states == 4) {
    colors <- c("#39B54A", "#8AB53980", "#FAD500", "#C95117")
  } else {
    stop("Input n_states must be integer between 2 and 4.")
  }

  state_labels <- generate_state_labels_hmm(n_states)

  scale_color_hmm <- ggplot2::scale_color_manual(
    name = "HMM states",
    values = colors,
    breaks = state_labels
  )

  scale_fill_hmm <- ggplot2::scale_fill_manual(
    name = "HMM states",
    values = colors,
    breaks = state_labels
  )

  if (fill) {
    return(scale_fill_hmm)
  } else {
    return(scale_color_hmm)
  }
}
