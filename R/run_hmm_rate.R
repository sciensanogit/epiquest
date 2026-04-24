#' Fit HMM for continuous rate data
#'
#' Internal function to fit a Gaussian HMM to rate time series.
#' It uses the Baum-Welch algorithm for parameter estimation and provides
#' smoothed state probabilities.
#'
#' @inheritParams run_hmm
#'
#' @details
#' The model assumes a Gaussian (normal) distribution for the response variable
#' \code{rate}. If \code{seasonal} is \code{TRUE}, the \code{ntimes} parameter
#' in \code{depmixS4} is populated with the lengths of each individual season
#' to prevent transitions between the end of one season and the start of the next.
#'
#' @return An object of class \code{epiquest_hmm}.
#'
#' @keywords internal
#' @importFrom rlang .data
run_hmm_rate <- function(
  obs_data,
  n_states = 2,
  seasonal = FALSE
) {
  # Perform input checks -------------------------------------------------------
  if (!"rate" %in% colnames(obs_data)) {
    stop("Input obs_data must have column named rate.")
  }

  if (!is.numeric(obs_data$rate)) {
    stop("Column obs_data$rate column must be numeric.")
  }

  # Extract season lengths -----------------------------------------------------

  # Make sure data are sorted chronologically
  obs_data <- obs_data |> dplyr::arrange(.data$index)

  # Get first week of new season
  if (seasonal) {
    list_index_end <- obs_data |>
      dplyr::mutate(row_number = dplyr::row_number()) |>
      dplyr::group_by(.data$season) |>
      dplyr::slice_tail(n = 1) |>
      dplyr::pull("row_number")

    list_season_length <- diff(c(0, list_index_end))
  } else {
    list_season_length <- NULL
  }

  # Define and fit HMM ---------------------------------------------------------

  # Define HMM model
  hmm <- depmixS4::depmix(
    response = rate ~ 1,
    data = obs_data,
    nstates = n_states,
    ntimes = list_season_length,
    family = stats::gaussian()
  )

  # Fit the HMM using the Baum-Welch algorithm
  utils::capture.output({
    fit_hmm <- depmixS4::fit(hmm, emcontrol = depmixS4::em.control(tol = 1e-12, maxit = 2000), nstart = 100)
    summary_fit_hmm <- depmixS4::summary(fit_hmm)
  })

  # Extract the transition matrix ----------------------------------------------
  matrix_transition <- matrix(
    as.vector(depmixS4::getpars(fit_hmm)[
      (n_states + 1):(n_states + n_states^2)
    ]),
    nrow = n_states,
    byrow = TRUE,
    dimnames = list(paste0("FromS", 1:n_states), paste0("ToS", 1:n_states))
  )

  # Extract states and label them:
  #   - Get states names and mean response per state.
  #   - Order state names according to increasing mean response.
  #   - Use mean response to create new state labels.
  info_states <- tibble::tibble(
    mean_state = sapply(1:n_states, function(x) summary_fit_hmm[x, 1]),
    sd_state = sapply(1:n_states, function(x) summary_fit_hmm[x, 2]),
    state = paste0("S", 1:n_states)
  ) |>
    dplyr::arrange(.data$mean_state) |>
    # Add new state labels by increasing mean response
    dplyr::mutate(state_new = paste0("L", 1:n_states)) |>
    # Reorder according to original states
    dplyr::arrange(.data$state)

  # Get smoothing probability of hidden states ---------------------------------
  hmm_states <- depmixS4::posterior(fit_hmm, type = "smoothing")
  colnames(hmm_states) <- paste0("S", 1:n_states)
  hmm_states <- hmm_states |>
    tibble::as_tibble() |>
    dplyr::rowwise() |>
    dplyr::mutate(
      state = paste0("S", which.max(dplyr::c_across(dplyr::starts_with("S", ignore.case = FALSE)))),
      prob_max = max(dplyr::c_across(dplyr::starts_with("S", ignore.case = FALSE)))
    ) |>
    dplyr::ungroup() |>
    dplyr::select("state", dplyr::starts_with("S", ignore.case = FALSE), "prob_max")

  # Add state labels
  hmm_states <- hmm_states |>
    dplyr::left_join(info_states, by = "state") |>
    dplyr::select(-dplyr::all_of(c("mean_state", "sd_state")))

  # Rename states --------------------------------------------------------------

  # Rename hmm_states
  vector_rename_states <- stats::setNames(
    info_states$state,
    paste0("prob_", info_states$state_new)
  )
  hmm_states <- hmm_states |>
    dplyr::rename(dplyr::all_of(vector_rename_states)) |>
    dplyr::select(
      dplyr::all_of(paste0("prob_L", 1:n_states)),
      "prob_max",
      "state_new"
    ) |>
    dplyr::rename(stats::setNames("state_new", "state"))

  # Reorder and rename transition matrix
  vector_reorder_states <- match(
    info_states |> dplyr::arrange(.data$state_new) |> dplyr::pull(.data$state),
    paste0("S", 1:n_states)
  )

  # Reorder the matrix rows and columns
  matrix_transition <- matrix_transition[
    vector_reorder_states,
    vector_reorder_states
  ]

  # Dynamically label the dimensions
  dimnames(matrix_transition) <- list(
    paste0("From", paste0("L", 1:n_states)),
    paste0("To", paste0("L", 1:n_states))
  )

  info_states <- info_states |>
    dplyr::select(-dplyr::all_of("state")) |>
    dplyr::rename(stats::setNames("state_new", "state")) |>
    dplyr::arrange(.data$state) |>
    dplyr::relocate("state")

  # Add state information to input ---------------------------------------------
  obs_data <- obs_data |>
    cbind(hmm_states)

  list_results <- list(
    data = obs_data,
    states = info_states,
    transition = matrix_transition,
    n_states = n_states,
    seasonal = seasonal,
    type = "rate",
    model = fit_hmm,
    state_reorder = vector_reorder_states
  )

  return(structure(list_results, class = c("epiquest_hmm", "list")))
}
