#' Stability analysis of QUEST thresholds via iterative refitting
#'
#' Evaluates the robustness of the HMM states and the QUEST thresholds by
#' repeatedly refitting the model over an expanding window of the time series.
#'
#' @param obs_data A \code{data.frame} formatted for \code{run_hmm()}.
#' @param n_states An integer. Number of hidden states (2 to 4).
#' @param type A character string. Either \code{"rate"} (Gaussian) or \code{"perc"} (binomial).
#' @param seasonal A logical. If \code{TRUE}, treats seasons as independent.
#' @param quantiles A numeric vector. Quantile levels for threshold calculation.
#' @param epidemic_state_indices An integer vector. HMM states considered as
#'   "epidemic" (see the section 'Defining the "epidemic" state(s)' in
#'   \code{\link{run_threshold_computation}}).
#' @param step An integer. The number of units to advance the
#'   cutoff date in each iteration. Defaults to 7 (one week).
#' @param window_summary An integer. The number of most recent iterations to
#'   include when calculating the final summary statistics.
#'
#' @details
#' \strong{Stability analysis:}
#' To ensure the HMM has enough data to converge to a stable estimate,
#' the function starts with a minimum training set of 50 \code{step} units.
#' It then adds data in increments of \code{step} (default 1 week of 7 days),
#' refitting the model and recalculating thresholds at every stage.
#'
#' This process mimics how the model would perform in a real-time surveillance
#' setting as new data arrives each week. If the thresholds or state means
#' show high volatility, it may indicate that the model is overfit or that
#' the surveillance signal is too noisy for the chosen number of states.
#'
#' @return An object of class \code{epiquest_loop}. This is a list containing:
#' \itemize{
#'   \item \code{thresholds}: A data frame of all thresholds calculated at
#'      each cutoff date.
#'   \item \code{states}: A data frame showing how state means and standard
#'      deviations evolved.
#'   \item \code{summary}: A summary table (median, mean, min, max) of
#'      thresholds within the final \code{window_summary} iterations.
#'   \item \code{data}: The original input data.
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
#' @seealso \code{\link{create_loop_plots}}, \code{\link{run_threshold_computation}}
#' @export
#' @importFrom rlang .data
run_loop_thresholds <- function(
  obs_data,
  n_states = 2,
  type = "rate",
  seasonal = FALSE,
  quantiles = c(.05, .70, .90, .99),
  epidemic_state_indices = NULL,
  step = 7,
  window_summary = 12
) {
  # Create list of cutoffs -------------------------------------------------
  min_index <- obs_data |> dplyr::pull("index") |> min()
  max_index <- obs_data |> dplyr::pull("index") |> max()

  min_cutoff <- min_index + 50 * step
  max_cutoff <- max_index

  if (min_cutoff > max_cutoff) {
    stop("There need to be at least 50 data points to proceed.")
  }

  list_cutoffs <- seq(min_cutoff, max_cutoff, step)

  # Set up progress bar -----------------------------------------------------
  pb <- progress::progress_bar$new(total = length(list_cutoffs), format = "[:bar] :percent", force = TRUE)

  # Compute thresholds for growing period ----------------------------------
  df_results <- lapply(list_cutoffs, function(cutoff) {
    pb$tick() # Update progress bar

    obs_data_partial <- obs_data |>
      dplyr::filter(.data$index <= cutoff)

    list_results <- run_hmm(
      obs_data = obs_data_partial,
      n_states = n_states,
      seasonal = seasonal,
      type = type
    )

    list_results <- run_threshold_computation(
      list_results,
      quantiles = quantiles,
      epidemic_state_indices = epidemic_state_indices
    )

    df_thresholds <- tibble::tibble(
      cutoff = cutoff,
      value = list_results$thresholds,
      type = factor(
        generate_threshold_labels(length(quantiles)),
        levels = generate_threshold_labels(length(quantiles))
      )
    )

    df_states <- list_results$states |>
      dplyr::mutate(cutoff = cutoff)

    list_results <- list(
      thresholds = df_thresholds,
      states = df_states
    )
  })

  # Aggregate results ------------------------------------------------------
  df_thresholds <- dplyr::bind_rows(df_results |> purrr::map(1))
  df_states <- dplyr::bind_rows(df_results |> purrr::map(2))

  # Create summary ---------------------------------------------------------
  df_summary_thresholds <- df_thresholds |>
    # Take last threshold values (determined by window_summary)
    dplyr::arrange(.data$cutoff) |>
    dplyr::slice_tail(n = window_summary * length(quantiles)) |>
    # Compute summary for each threshold
    dplyr::group_by(.data$type) |>
    dplyr::summarize(
      Median = stats::median(.data$value, na.rm = TRUE),
      Mean = mean(.data$value, na.rm = TRUE),
      Min = min(.data$value, na.rm = TRUE),
      Max = max(.data$value, na.rm = TRUE)
    )

  df_summary_states <- df_states |>
    # Take the last window of iterations for each state
    dplyr::arrange(.data$cutoff) |>
    dplyr::slice_tail(n = window_summary * n_states) |>
    # Compute summary for every available parameter
    dplyr::group_by(.data$state) |>
    dplyr::summarize(
      dplyr::across(
        dplyr::any_of(c("mean_state", "sd_state")),
        list(
          Median = ~ stats::median(.x, na.rm = TRUE),
          Mean = ~ mean(.x, na.rm = TRUE),
          Min = ~ min(.x, na.rm = TRUE),
          Max = ~ max(.x, na.rm = TRUE)
        ),
        .names = "{.col}_{.fn}"
      )
    )

  # Bundle output and return -----------------------------------------------
  list_results <- list(
    thresholds = df_thresholds,
    states = df_states,
    summary_thresholds = df_summary_thresholds,
    summary_states = df_summary_states,
    data = obs_data,
    n_states = n_states,
    quantiles = quantiles,
    seasonal = seasonal,
    epidemic_state_indices = epidemic_state_indices,
    step = step,
    window_summary = window_summary
  )

  return(structure(list_results, class = c("epiquest_loop", "list")))
}
