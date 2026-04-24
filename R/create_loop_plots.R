#' Visualize the stability of HMM states and thresholds
#'
#' Generates plots to visualize how HMM state parameters and
#' resulting QUEST thresholds evolve as the model is refitted over
#' different periods (cutoff dates).
#'
#' @param list_results An object of class \code{epiquest_loop} produced by
#'   \code{run_loop_thresholds()}.
#' @param print A logical. If \code{TRUE}, all generated plots are printed to the
#'   active graphics device.
#'
#' @details
#' It is important to assess HMM and threshold stability, i.e., that adding or removing
#' a few weeks of data does not meaningfully change the results. The 'cutoff date' on the
#' horizontal axis represents the end of the data window used for that specific model fit.
#'
#' #' @return An object of class \code{epiquest_plot_list}, a named \code{list} of \code{ggplot2} objects containing:
#' \itemize{
#'   \item \code{thresholds}: Threshold values plotted against cutoff dates,
#'      with the raw surveillance signal shown in the background for context.
#'   \item \code{states_facet}: A faceted plot showing the evolution of the
#'      estimated mean (and standard deviation) for each hidden state.
#'   \item \code{states}: A plot of the mean values for each state over time,
#'      including shaded ribbons representing ±1 and ±2 standard deviations
#'      to visualize state overlap and uncertainty.
#' }
#'
#' @examples
#' \dontrun{
#' # Stability analysis takes time as it refits the model repeatedly
#' fit_loop <- loop_thresholds(df_sari_be, n_states = 2)
#'
#' # Look at results
#' summary(fit_loop)
#'
#' # Visualize results
#' create_loop_plots(fit_loop)
#' }
#' @seealso \code{\link{generate_palette_thresholds}}, \code{\link{generate_palette_hmm}}
#' @export
#' @importFrom rlang .data
create_loop_plots <- function(
  list_results,
  print = FALSE
) {
  # Perform input checks -------------------------------------------------------
  if (!inherits(list_results, "epiquest_loop")) {
    stop("Input list_results must be an object of class 'epiquest_loop' outputted by run_loop_thresholds().")
  }

  # Set plotting theme ---------------------------------------------------------

  # Create color and fill scale
  scale_color_thresholds <- generate_palette_thresholds(
    n_thresholds = length(list_results$quantiles)
  )

  scale_color_states <- generate_palette_hmm(n_states = list_results$n_states)
  scale_fill_states <- generate_palette_hmm(n_states = list_results$n_states, fill = TRUE)

  # Set ggplot theme
  ggplot2::theme_set(ggplot2::theme_bw() + ggplot2::theme(legend.position = "bottom"))

  # Create threshold plot ------------------------------------------------------
  plot_thresholds <- list_results$thresholds |>
    ggplot2::ggplot(ggplot2::aes(x = .data$cutoff, y = .data$value, color = .data$type)) +

    ggplot2::geom_point(
      data = list_results$data,
      ggplot2::aes(x = .data$index, y = .data$rate),
      color = "grey70",
      alpha = .2
    ) +
    ggplot2::geom_line(
      data = list_results$data,
      ggplot2::aes(x = .data$index, y = .data$rate),
      color = "grey70",
      alpha = .2
    ) +

    ggplot2::geom_point() +
    ggplot2::geom_line() +

    ggplot2::scale_y_continuous(limits = c(0, NA)) +
    scale_color_thresholds +
    ggplot2::labs(x = "Cutoff date", y = "Rate", color = "Threshold")

  # Create state plot ----------------------------------------------------------
  plot_states_facet <- list_results$states |>
    dplyr::left_join(
      tibble::tibble(
        state = paste0("L", 1:list_results$n_states),
        state_new = generate_state_labels_hmm(list_results$n_states)
      ),
      by = "state"
    ) |>
    tidyr::pivot_longer(cols = c(.data$mean_state, .data$sd_state), names_to = "target", values_to = "value") |>
    dplyr::mutate(target = ifelse(.data$target == "mean_state", "Mean state", "SD state")) |>
    ggplot2::ggplot(ggplot2::aes(x = .data$cutoff, y = .data$value, color = .data$state_new)) +
    ggplot2::geom_point() +
    ggplot2::geom_line() +
    ggplot2::facet_grid(.data$target ~ ., scales = "free_y") +
    ggplot2::scale_y_continuous(limits = c(0, NA)) +
    scale_color_states +
    ggplot2::labs(x = "Cutoff date", y = "Rate", color = "State")

  plot_states <- list_results$states |>
    dplyr::left_join(
      tibble::tibble(
        state = paste0("L", 1:list_results$n_states),
        state_new = generate_state_labels_hmm(list_results$n_states)
      ),
      by = "state"
    ) |>
    ggplot2::ggplot(ggplot2::aes(x = .data$cutoff)) +

    ggplot2::geom_point(
      data = list_results$data,
      ggplot2::aes(x = .data$index, y = .data$rate),
      color = "grey70",
      alpha = .3
    ) +
    ggplot2::geom_line(
      data = list_results$data,
      ggplot2::aes(x = .data$index, y = .data$rate),
      color = "grey70",
      alpha = .3
    ) +

    ggplot2::geom_ribbon(
      ggplot2::aes(
        ymin = .data$mean_state - 2 * .data$sd_state,
        ymax = .data$mean_state + 2 * .data$sd_state,
        fill = .data$state_new
      ),
      alpha = 0.1
    ) +
    ggplot2::geom_ribbon(
      ggplot2::aes(
        ymin = .data$mean_state - 1 * .data$sd_state,
        ymax = .data$mean_state + 1 * .data$sd_state,
        fill = .data$state_new
      ),
      alpha = 0.3
    ) +

    ggplot2::geom_point(ggplot2::aes(y = .data$mean_state, color = .data$state_new)) +
    ggplot2::geom_line(ggplot2::aes(y = .data$mean_state, color = .data$state_new)) +

    ggplot2::scale_y_continuous(limits = c(0, NA)) +
    scale_color_states +
    scale_fill_states +
    ggplot2::labs(x = "Cutoff date", y = "Rate", color = "State")

  # Bundle output and return ---------------------------------------------------
  list_plots <- list(
    thresholds = plot_thresholds,
    states_facet = plot_states_facet,
    states = plot_states
  )

  class(list_plots) <- c("epiquest_plot_list", "list")

  if (print) {
    print(list_plots)
    return(invisible(list_plots))
  }

  return(list_plots)
}
