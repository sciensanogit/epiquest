#' Generate QUEST threshold labels
#'
#' Generates standardized descriptive names for thresholds based on the number
#' of threshold levels calculated. These are typically used for plot axes
#' and legend labels.
#'
#' @param n_thresholds An integer. The number of thresholds (1, 2, 3, or 4).
#'
#' @details
#' The labels are assigned based on the complexity of the thresholding tiers:
#' \itemize{
#'   \item \strong{1 threshold}: "High"
#'   \item \strong{2 thresholds}: "Low", "High"
#'   \item \strong{3 thresholds}: "Low", "Medium", "High"
#'   \item \strong{4 thresholds}: "Low", "Medium", "High", "Very high"
#' }
#'
#' @return A character vector of length \code{n_thresholds}.
#'
#' @seealso \code{\link{generate_palette_thresholds}}
#' @keywords internal
#' @importFrom rlang .data
#' @export
generate_threshold_labels <- function(
  n_thresholds = 4
) {
  if (n_thresholds == 1) {
    return("High")
  } else if (n_thresholds == 2) {
    return(c("Low", "High"))
  } else if (n_thresholds == 3) {
    return(c("Low", "Medium", "High"))
  } else if (n_thresholds == 4) {
    return(c("Low", "Medium", "High", "Very high"))
  } else {
    stop("Input n_thresholds must be integer between 1 and 4.")
  }
}
