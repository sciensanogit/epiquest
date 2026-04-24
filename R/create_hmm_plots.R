#' Visualize hidden Markov model results
#'
#' Generates a series of plots to visualize state assignments and the distribution of
#' the surveillance signal across different hidden states.
#'
#' @param list_results An object of class \code{epiquest_hmm} produced by \code{run_hmm()}.
#' @param print A logical. If \code{TRUE}, all generated plots are printed to the
#'   active graphics device.
#'
#' @details
#' The function produces several types of visualizations:
#' \itemize{
#'   \item \strong{Time series}: The raw signal colored by the most probable state.
#'   \item \strong{Jitter plots and histograms}: Visualize the overlap and separation
#'     between states.
#'   \item \strong{State probabilities}: A stacked bar chart showing the
#'     certainty of state assignments over time.
#' }
#'
#' For many plots, both **"hard"** and **"soft"** versions are provided.
#' \strong{Hard} assignments classify a time point strictly into the single state
#' with the highest posterior probability. \strong{Soft} assignments weight
#' each observation by its probability of belonging to each state, providing
#' a more nuanced view of uncertainty.
#'
#' @note
#' If \code{list_results$type == "rate"}, the \code{histogram_soft} plot
#' overlays the estimated Gaussian density curves for each state.
#'
#' @return An object of class \code{epiquest_plot_list}, a named \code{list} of \code{ggplot2} objects containing:
#' \itemize{
#'   \item \code{jitter_hard/soft} Jitter plot showing signal distribution per state.
#'   \item \code{histogram_hard/soft} Histogram showing signal density per state.
#'   \item \code{prob_states} Stacked bar chart of posterior state probabilities.
#'   \item \code{time_series_per_state} Faceted time series by state.
#'   \item \code{time_series_full} Single time series colored by most probable state.
#' }
#'
#' @examples
#' # Fit a 3-state HMM to (continuous) rate data
#' fit <- run_hmm(df_sari_be, n_states = 3, type = "rate")
#'
#' # Check state information
#' summary(fit)
#'
#' # Visualize state information
#' create_hmm_plots(fit)
#'
#' # Compute thresholds using the highest state (L3) as the epidemic state
#' # By default, epidemic_state_indices is the highest state
#' thresh <- run_threshold_computation(fit)
#'
#' # Visualize theshold information
#' summary(thresh)
#'
#' # Visualize theshold information
#' create_threshold_plots(thresh)
#' @export
#' @importFrom rlang .data
create_hmm_plots <- function(
  list_results,
  print = FALSE
) {
  # Perform input checks -------------------------------------------------------
  if (!inherits(list_results, "epiquest_hmm")) {
    stop("Input list_results must be an object of class 'epiquest_hmm' outputted by run_hmm().")
  }

  # Get state names ------------------------------------------------------------
  state_labels <- generate_state_labels_hmm(list_results$n_states)

  list_results$states <- list_results$states |>
    dplyr::arrange(.data$state) |>
    dplyr::mutate(state_label = factor(state_labels, levels = state_labels)) |>
    dplyr::mutate(state_label_rev = forcats::fct_rev(.data$state_label))

  # Compute percentage for percentage data ------------------------------------
  if (list_results$type == "perc") {
    list_results$data <- list_results$data |>
      dplyr::mutate(rate = .data$num / .data$denom)
  }

  # Set plotting theme ---------------------------------------------------------
  scale_color_hmm <- generate_palette_hmm(n_states = list_results$n_states)
  scale_fill_hmm <- generate_palette_hmm(n_states = list_results$n_states, fill = TRUE)

  # Create time series plots ---------------------------------------------------
  plot_time_series_per_state <- list_results$data |>
    dplyr::select("index", "rate", dplyr::starts_with("prob_L")) |>
    tidyr::pivot_longer(
      cols = dplyr::starts_with("prob_L"),
      names_to = "state",
      values_to = "prob",
      names_prefix = "prob_"
    ) |>
    dplyr::left_join(list_results$states, by = "state") |>
    dplyr::filter(.data$prob > .01) |>
    ggplot2::ggplot() +
    ggplot2::geom_line(
      data = list_results$data,
      ggplot2::aes(
        x = .data$index,
        y = .data$rate,
      ),
      color = "grey70",
      alpha = .5
    ) +
    ggplot2::geom_point(
      ggplot2::aes(
        x = .data$index,
        y = .data$rate,
        color = .data$state_label,
        alpha = .data$prob
      ),
      size = 2
    ) +
    scale_color_hmm +
    ggplot2::facet_grid(.data$state_label_rev ~ .) +
    ggplot2::guides(alpha = "none", color = "none") +
    generate_ggplot_theme()

  if (list_results$type == "rate") {
    plot_time_series_per_state <- plot_time_series_per_state +
      ggplot2::scale_y_continuous(limits = \(x) range(c(x, 0))) +
      ggplot2::labs(
        x = "Week",
        y = "Rate",
        title = "Time series in each of the HMM states"
      )
  } else if (list_results$type == "perc") {
    plot_time_series_per_state <- plot_time_series_per_state +
      ggplot2::scale_y_continuous(labels = scales::percent) +
      ggplot2::labs(
        x = "Week",
        y = "Percentage",
        title = "Time series in each of the HMM states"
      )
  }

  plot_time_series_full <- list_results$data |>
    dplyr::left_join(list_results$states, by = "state") |>
    ggplot2::ggplot() +
    ggplot2::geom_line(ggplot2::aes(x = .data$index, y = .data$rate)) +
    ggplot2::geom_point(ggplot2::aes(
      x = .data$index,
      y = .data$rate,
      color = .data$state_label
    )) +
    scale_color_hmm +
    ggplot2::labs(
      x = "Week",
      y = "Rate",
      title = "Time series colored by most probable state"
    ) +
    generate_ggplot_theme()

  if (list_results$type == "rate") {
    plot_time_series_full <- plot_time_series_full +
      ggplot2::scale_y_continuous(limits = \(x) range(c(x, 0))) +
      ggplot2::labs(
        x = "Week",
        y = "Rate",
        title = "Time series colored by most probable state"
      )
  } else if (list_results$type == "perc") {
    plot_time_series_full <- plot_time_series_full +
      ggplot2::scale_y_continuous(labels = scales::percent) +
      ggplot2::labs(
        x = "Week",
        y = "Percentage",
        title = "Time series colored by most probable state"
      )
  }

  # Create histogram plots -----------------------------------------------------
  plot_histogram_hard <- list_results$data |>
    dplyr::left_join(list_results$states, by = "state") |>
    ggplot2::ggplot(ggplot2::aes(x = .data$rate)) +
    ggplot2::geom_histogram(ggplot2::aes(fill = .data$state_label_rev), bins = 30, color = "white") +
    scale_color_hmm +
    scale_fill_hmm +
    ggplot2::facet_grid(.data$state_label_rev ~ .) +
    ggplot2::guides(color = "none", fill = "none") +
    generate_ggplot_theme()

  if (list_results$type == "rate") {
    plot_histogram_hard <- plot_histogram_hard +
      ggplot2::labs(
        x = "Rate",
        y = "Count",
        title = "Histogram of rates in each state",
        subtitle = "where weeks are labeled by their most probable state"
      )
  } else if (list_results$type == "perc") {
    plot_histogram_hard <- plot_histogram_hard +
      ggplot2::scale_x_continuous(labels = scales::percent) +
      ggplot2::labs(
        x = "Percentage",
        y = "Count",
        title = "Histogram of percentages in each state",
        subtitle = "where weeks are labeled by their most probable state"
      )
  }

  plot_histogram_soft <- list_results$data |>
    dplyr::select("index", "rate", dplyr::starts_with("prob_L", ignore.case = FALSE)) |>
    tidyr::pivot_longer(
      cols = dplyr::starts_with("prob_L", ignore.case = FALSE),
      names_to = "state",
      values_to = "prob",
      names_prefix = "prob_"
    ) |>
    dplyr::left_join(list_results$states, by = "state", relationship = "many-to-many") |>
    ggplot2::ggplot() +
    ggplot2::geom_histogram(
      ggplot2::aes(
        x = .data$rate,
        fill = .data$state_label_rev,
        y = ggplot2::after_stat(density),
        weight = .data$prob
      ),
      bins = 30,
      position = "dodge",
      color = "white"
    ) +
    scale_fill_hmm +
    scale_color_hmm +
    ggplot2::facet_grid(.data$state_label_rev ~ .) +
    ggplot2::guides(fill = "none", color = "none") +
    generate_ggplot_theme()

  if (list_results$type == "rate") {
    for (i in 1:nrow(list_results$states)) {
      row <- list_results$states[i, ]

      plot_histogram_soft <- plot_histogram_soft +
        ggplot2::geom_function(
          data = row,
          ggplot2::aes(color = .data$state_label_rev),
          fun = stats::dnorm,
          args = list(mean = row$mean_state, sd = row$sd_state),
          linewidth = .8
        )
    }

    plot_histogram_soft <- plot_histogram_soft +
      ggplot2::labs(
        x = "Rate",
        y = "Density",
        title = "(Weighted) histogram of rates in each state",
        subtitle = "where weeks are weighted by their probability to be in a specific state"
      )
  } else if (list_results$type == "perc") {
    plot_histogram_soft <- plot_histogram_soft +
      ggplot2::scale_x_continuous(labels = scales::percent) +
      ggplot2::labs(
        x = "Percentage",
        y = "Density",
        title = "(Weighted) histogram of percentages in each state",
        subtitle = "where weeks are weighted by their probability to be in a specific state"
      )
  }

  # Create jitter plots --------------------------------------------------------
  plot_jitter_hard <- list_results$data |>
    dplyr::left_join(list_results$states, by = "state") |>
    ggplot2::ggplot(ggplot2::aes(
      y = .data$rate,
      x = .data$state_label,
      color = .data$state_label
    )) +
    ggplot2::geom_point(position = ggplot2::position_jitter(height = 0, width = 0.4)) +
    scale_color_hmm +
    ggplot2::guides(color = "none") +
    generate_ggplot_theme()

  if (list_results$type == "rate") {
    plot_jitter_hard <- plot_jitter_hard +
      ggplot2::scale_y_continuous(limits = \(x) range(c(x, 0))) +
      ggplot2::labs(
        x = NULL,
        y = "Rate",
        title = "Jitter plot of rate in each state (fixed/hard)"
      )
  } else if (list_results$type == "perc") {
    plot_jitter_hard <- plot_jitter_hard +
      ggplot2::scale_y_continuous(labels = scales::percent) +
      ggplot2::labs(
        x = NULL,
        y = "Percentage",
        title = "Jitter plot of percentage in each state (fixed/hard)"
      )
  }

  plot_jitter_soft <- list_results$data |>
    dplyr::select("index", "rate", dplyr::starts_with("prob_L", ignore.case = FALSE)) |>
    tidyr::pivot_longer(
      cols = dplyr::starts_with("prob_L", ignore.case = FALSE),
      names_to = "state",
      values_to = "prob",
      names_prefix = "prob_"
    ) |>
    dplyr::left_join(list_results$states, by = "state", relationship = "many-to-many") |>
    dplyr::filter(.data$prob > 0.005) |>
    ggplot2::ggplot(ggplot2::aes(
      y = .data$rate,
      x = .data$state_label,
      color = .data$state_label,
      size = .data$prob
    )) +
    ggplot2::geom_point(position = ggplot2::position_jitter(height = 0, width = 0.4)) +
    scale_color_hmm +
    ggplot2::scale_size_continuous(range = c(0.005, 1.5)) +
    ggplot2::guides(color = "none", size = "none") +
    generate_ggplot_theme()

  if (list_results$type == "rate") {
    plot_jitter_soft <- plot_jitter_soft +
      ggplot2::scale_y_continuous(limits = \(x) range(c(x, 0))) +
      ggplot2::labs(
        x = NULL,
        y = "Rate",
        title = "Jitter plot of rate in each state (flexible/soft)"
      )
  } else if (list_results$type == "perc") {
    plot_jitter_soft <- plot_jitter_soft +
      ggplot2::scale_y_continuous(labels = scales::percent) +
      ggplot2::labs(
        x = NULL,
        y = "Percentage",
        title = "Jitter plot of percentage in each state (flexible/soft)"
      )
  }

  # Create state probability plot ----------------------------------------------
  plot_prob_states <- list_results$data |>
    dplyr::select("index", "rate", dplyr::starts_with("prob_L", ignore.case = FALSE)) |>
    tidyr::pivot_longer(
      cols = dplyr::starts_with("prob_L", ignore.case = FALSE),
      names_to = "state",
      values_to = "prob",
      names_prefix = "prob_"
    ) |>
    dplyr::left_join(list_results$states, by = "state", relationship = "many-to-many") |>
    ggplot2::ggplot() +
    ggplot2::geom_col(ggplot2::aes(x = .data$index, y = .data$prob, fill = .data$state_label)) +
    scale_fill_hmm +
    ggplot2::scale_y_continuous(labels = scales::percent) +
    ggplot2::labs(
      x = NULL,
      y = "Probability",
      title = "Probability of being in each state"
    ) +
    generate_ggplot_theme()

  # Bundle output and return ---------------------------------------------------
  list_plots <- list(
    jitter_hard = plot_jitter_hard,
    jitter_soft = plot_jitter_soft,
    histogram_hard = plot_histogram_hard,
    histogram_soft = plot_histogram_soft,
    prob_states = plot_prob_states,
    time_series_per_state = plot_time_series_per_state,
    time_series_full = plot_time_series_full
  )

  class(list_plots) <- c("epiquest_plot_list", "list")

  if (print) {
    print(list_plots)
    return(invisible(list_plots))
  }

  return(list_plots)
}
