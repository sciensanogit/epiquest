#' Generate standardized color scales for thresholds
#'
#' Generates a manual color scale for \code{ggplot2} to visualize different
#' QUEST threshold levels.
#'
#' @param n_thresholds An integer. The number of thresholds (1, 2, 3, or 4).
#'
#' @return A \code{ggplot2} manual color scale object.
#'
#' @seealso \code{\link{generate_threshold_labels}}
#' @keywords internal
#' @importFrom rlang .data
#' @export
generate_palette_thresholds <- function(
  n_thresholds = 4
) {
  if (n_thresholds == 1) {
    colors <- c("#c91717ee")
  } else if (n_thresholds == 2) {
    colors <- c("#39B54A", "#c91717ee")
  } else if (n_thresholds == 3) {
    colors <- c("#39b54a", "#FAD500", "#c91717ee")
  } else if (n_thresholds == 4) {
    colors <- c("#39B54A", "#FAD500", "#FA8E00", "#c91717ee")
  } else {
    stop("Input n_thresholds must be integer between 1 and 4.")
  }

  threshold_labels <- generate_threshold_labels(n_thresholds)

  scale_color_hmm <- ggplot2::scale_color_manual(
    name = "Threshold",
    values = colors,
    breaks = threshold_labels
  )

  return(scale_color_hmm)
}
