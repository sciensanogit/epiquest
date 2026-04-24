#' Fit HMM for binomial percentage data
#'
#' Internal function to fit a binomial HMM. This is preferred for data
#' representing proportions (e.g., cases out of a total population).
#'
#' @inheritParams run_hmm
#'
#' @details
#' The response variable is modeled as \code{cbind(num, denom - num)},
#' which represents the number of successes/cases and failures/non-cases.
#' This accounts for the increased variance in observations
#' with smaller denominators.
#'
#' @return An object of class \code{epiquest_hmm}.
#'
#' @keywords internal
#' @importFrom rlang .data
run_hmm_perc <- function(
  obs_data,
  n_states = 2,
  seasonal = FALSE
) {
  # Perform input checks -------------------------------------------------------

  if (!all(c("num", "denom") %in% colnames(obs_data))) {
    stop("Input obs_data must have columns named num and denom if input type is 'perc'.")
  }

  if (
    !all(
      is.numeric(obs_data$num) && all(obs_data$num == as.integer(obs_data$num)),
      is.numeric(obs_data$denom) && all(obs_data$denom == as.integer(obs_data$denom))
    )
  ) {
    stop("Columns num and denom in input obs_data must be integers.")
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
    response = cbind(num, denom - num) ~ 1,
    data = obs_data,
    nstates = n_states,
    ntimes = list_season_length,
    family = stats::binomial()
  )

  # Fit the HMM using the Baum-Welch algorithm
  utils::capture.output({
    fit_hmm <- depmixS4::fit(hmm)
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
    state = paste0("S", 1:n_states)
  ) |>
    dplyr::arrange(.data$mean_state) |>
    # Add new state labels by increasing mean response
    dplyr::mutate(state_new = paste0("L", 1:n_states)) |>
    # Reorder according to original states
    dplyr::arrange(.data$state) |>
    # Mean response is on logit scale, so need to expit
    dplyr::mutate(mean_state = exp(.data$mean_state) / (1 + exp(.data$mean_state)))

  # Get the most likely hidden states ------------------------------------------
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
    dplyr::select(-"mean_state")

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

  # Bundle output and return ---------------------------------------------------
  obs_data <- obs_data |>
    cbind(hmm_states)

  list_results <- list(
    data = obs_data,
    states = info_states,
    transition = matrix_transition,
    n_states = n_states,
    seasonal = seasonal,
    type = "perc",
    model = fit_hmm,
    state_reorder = vector_reorder_states
  )

  return(structure(list_results, class = c("epiquest_hmm", "list")))
}
