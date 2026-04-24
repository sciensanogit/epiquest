#' Print method for EpiQUEST plot lists
#'
#' Ensures that when a list of plots is returned to the console,
#' the plots are drawn automatically without printing the list structure.
#'
#' @param x An object of class \code{epiquest_plot_list}.
#' @param ... Additional arguments passed to methods.
#'
#' @keywords internal
#' @importFrom rlang .data
#' @export
print.epiquest_plot_list <- function(x, ...) {
  # Trigger the drawing of each ggplot object
  lapply(x, print)

  # Prevent names of list elements from appearing in the console
  invisible(x)
}
