#' Standardized ggplot2 theme for EpiQUEST
#'
#' Provides a consistent visual style for all package visualizations,
#' ensuring uniform font sizes and legend placement.
#'
#' @return A \code{ggplot2} theme object.
#'
#' @keywords internal
#' @importFrom rlang .data
#' @export
generate_ggplot_theme <- function() {
  ggplot2::theme_bw() +
    ggplot2::theme(
      text = ggplot2::element_text(size = 12),
      axis.text = ggplot2::element_text(size = 12),
      axis.title = ggplot2::element_text(size = 12),
      legend.text = ggplot2::element_text(size = 12),
      legend.title = ggplot2::element_text(size = 12, face = "bold"),
      strip.text = ggplot2::element_text(size = 10),
      legend.position = "bottom"
    )
}
