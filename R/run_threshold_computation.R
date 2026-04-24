#' Compute QUEST thresholds
#'
#' Calculates QUEST thresholds (default: low, medium, high, very high)
#' by determining specific quantiles of the observed surveillance signal, weighted by the
#' posterior probability that the system is in a user-defined epidemic state.
#'
#' @param list_results An object of class \code{epiquest_hmm} produced by \code{run_hmm()}.
#' @param quantiles A numeric vector. The cumulative probabilities (between 0 and 1)
#'   at which to calculate thresholds. Defaults to \code{c(0.05, 0.70, 0.90, 0.99)}.
#' @param epidemic_state_indices An integer vector. The indices of the HMM states
#'   to be jointly considered as the "epidemic" signal. If \code{NULL},
#'   defaults to the state with the highest mean (see section
#'   'Defining the "epidemic" state(s)' below).
#'
#' @details
#' This function implements a "soft" thresholding approach. Instead of calculating
#' quantiles from the raw data alone, it uses the HMM posterior probabilities
#' to weight the observations.
#'
#' For each observation, the function:
#' \enumerate{
#'   \item Determines how likely a specific week is to be in the "epidemic" state(s).
#'   \item Constructs a weighted empirical cumulative distribution function (ECDF)
#'      of the observed \code{rate}.
#'   \item Uses linear interpolation to find the exact rates that correspond to your
#'         chosen \code{quantiles}.
#' }
#'
#' @section Defining the "epidemic" state(s):
#' The \code{epidemic_state_indices} argument allows you to define what states
#' in the HMM output represent "epidemic activity". This flexibility is useful in
#' several scenarios:
#' \itemize{
#'   \item \strong{Combining states}: In a 3-state model, you might consider
#'      both state 2 ("Elevated") and state 3 ("Epidemic") to represent
#'      high activity activity. You would set \code{epidemic_state_indices = c(2, 3)}.
#'   \item \strong{Excluding extreme outliers}: If the data includes a
#'      "super-epidemic" year, the highest HMM state might capture
#'      only those rare extremes. To set thresholds that are more sensitive
#'      to normal annual epidemics, you might choose to define the epidemic
#'      signal based only on the state with the second highest mean.
#' }
#'
#' If no indices are provided, the function defaults to the state with the
#' highest mean incidence.
#'
#' @return An object of class \code{epiquest_thresholds}, which inherits from
#'   \code{epiquest_hmm}. This is the input \code{list_results} with 3
#'   additional elements:
#' \itemize{
#'   \item \code{thresholds}: A numeric vector of calculated rate values.
#'   \item \code{quantiles}: The input quantile levels used for calculation.
#'   \item \code{epidemic_state_indices}: The indices of states used to define
#'     the epidemic state.
#' }
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
#' # Compute QUEST thresholds using the highest state (L3) as the epidemic
#' # state. By default, epidemic_state_indices is the highest state.
#' thresh <- run_threshold_computation(fit)
#'
#' # Check QUEST threshold information
#' summary(thresh)
#'
#' # Visualize threshold information
#' create_threshold_plots(thresh)
#' @export
#' @importFrom rlang .data
run_threshold_computation <- function(
  list_results,
  quantiles = c(.05, .70, .90, .99),
  epidemic_state_indices = NULL
) {
  # Perform input checks -------------------------------------------------------
  if (!inherits(list_results, "epiquest_hmm")) {
    stop("Input list_results must be an object of class 'epiquest_hmm' outputted by run_hmm().")
  }

  if (!is.numeric(quantiles)) {
    stop("Input quantiles must only contains numbers between 0 and 1.")
  }

  if (!all(quantiles >= 0 & quantiles <= 1)) {
    stop("Input quantiles must only contains numbers between 0 and 1.")
  }

  # Get epidemic state ---------------------------------------------------------
  if (is.null(epidemic_state_indices)) {
    epidemic_state_indices <- list_results$n_states
    # print("No epidemic state(s) declared, so state with highest mean incidence chosen by default.")
  } else {
    if (!all(epidemic_state_indices %in% 1:list_results$n_states)) {
      stop("Input epidemic_state_indices must be integers describing HMM states.")
    }
  }
  epidemic_state <- paste0("L", epidemic_state_indices)

  # Compute percentage for percentage data ------------------------------------
  if (list_results$type == "perc") {
    list_results$data <- list_results$data |>
      dplyr::mutate(rate = .data$num / .data$denom)
  }

  # Define soft quantiles ------------------------------------------------------

  df_weighted <- list_results$data |>
    dplyr::filter(!is.na(.data$rate)) |>
    # Select only the incidences and the posterior smoothing probabilities
    # that the point is in the epidemic state.
    dplyr::select(dplyr::any_of(paste0("prob_", epidemic_state)), "rate") |>
    dplyr::rowwise() |>
    dplyr::mutate(total_prob = sum(dplyr::c_across(dplyr::starts_with("prob_L")))) |>
    dplyr::ungroup() |>
    dplyr::arrange(.data$rate) |>

    # If several data points have the same incidence, we sum their
    # posterior smoothing probabilities.
    dplyr::group_by(.data$rate) |>
    dplyr::summarize(total_prob = sum(.data$total_prob)) |>

    # For every observed incidence, compute total weight of lower incidences,
    # where posterior smoothing probabilities are weights. In the end, we normalize
    # by the total sum of the weights so they vary from 0 to 1.
    dplyr::mutate(total_prob_cum = cumsum(.data$total_prob) / sum(.data$total_prob)) |>

    # Filter out rows with very low cumulative weights: we do not need them and they
    # cause numerical instability below.
    dplyr::filter(.data$total_prob_cum > .001)

  # To compute quantiles that do not appear as values of total_prob_cum_cum, we linearly
  # interpolate between the closest smaller and larger values. Below we compute half percentiles.
  list_tresholds <- stats::approx(
    x = df_weighted$total_prob_cum,
    y = df_weighted$rate,
    xout = quantiles,
    method = "linear",
    ties = mean
  )

  # Bundle output and return ---------------------------------------------------
  list_results <- append(
    list_results,
    list(
      thresholds = list_tresholds$y,
      quantiles = quantiles,
      epidemic_state_indices = epidemic_state_indices
    )
  )

  return(structure(list_results, class = c("epiquest_thresholds", "epiquest_hmm", "list")))
}
