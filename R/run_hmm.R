#' Fit a hidden Markov model (HMM) to epidemiological time series data
#'
#' This function fits a hidden Markov model (HMM) to time series data using either
#' Gaussian (for rates) or binomial (for percentages) distributions.
#'
#' @param obs_data A \code{data.frame} containing an \code{index} column (Date
#'   or integer). Additional required columns depend on \code{type} and \code{seasonal}:
#'   \itemize{
#'     \item If \code{type = "rate"}: Must contain a numeric \code{rate} column.
#'           This represents the intensity, incidence or activity level of the
#'           surveillance signal (e.g., cases per 100,000 population).
#'     \item If \code{type = "perc"}: Must contain integer \code{num} and
#'           \code{denom} columns. \code{num} is the numerator (e.g., the number
#'           of positive lab tests or symptomatic patients), and \code{denom}
#'           is the denominator or total sample size (e.g., total tests
#'           performed or total clinical consultations).
#'     \item If \code{seasonal = TRUE}: Must contain a \code{season} column.
#'           The subseries in each season is treated as an independent time series.
#'   }
#' @param n_states An integer. The number of hidden states (2 to 4).
#' @param type A character string. Either \code{"rate"} (Gaussian) or \code{"perc"} (binomial).
#' @param seasonal A logical. If \code{TRUE}, the model prevents transitions
#'   between different seasons, treating them as independent sequences.
#'
#' @details
#' The function uses the \code{depmixS4} package to estimate parameters
#' using the Baum-Welch algorithm. For \code{type = "perc"}, the model accounts for the
#' varying precision of proportions by using the raw counts (\code{num} and \code{denom}). After
#' fitting, hidden states are sorted and renamed from \strong{L1} (lowest
#' intensity) to \strong{Ln} (highest intensity) based on the estimated mean.
#'
#' The posterior probabilities are 'local' probabilities. See \code{\link{run_out_of_sample_decoding}}
#' for more information.
#'
#' @section Missing Data:
#' Missing values (\code{NA}) are permitted in the response columns (\code{rate}
#' or \code{num}/\code{denom}). \code{depmixS4} handles these by allowing
#' state transitions to occur as usual while ignoring the missing observation
#' in the likelihood calculation.
#'
#' However, if the surveillance signal is interrupted for extended periods
#' (e.g., for systems that do not operate during low intensity months), it is
#' **strongly recommended** to use \code{seasonal = TRUE}.
#'
#' @return An object of class \code{epiquest_hmm}. This is a list containing:
#' \itemize{
#'   \item \code{data}: The input \code{obs_data} with added columns for
#'     the predicted state and posterior probabilities.
#'   \item \code{states}: Summary statistics (mean and SD, or probability)
#'     for each hidden state.
#'   \item \code{transition}: The estimated transition matrix between states.
#'   \item \code{n_states}: Number of states in the model.
#'   \item \code{type}: The data type used for the fit.
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
run_hmm <- function(
  obs_data,
  n_states = 2,
  type = "rate",
  seasonal = FALSE
) {
  # Perform input checks -------------------------------------------------------
  if (!is.data.frame(obs_data)) {
    stop("Input obs_data must be a data.frame.")
  }

  if (!"index" %in% colnames(obs_data)) {
    stop("Input obs_data must have column named index.")
  }

  index_is_date <- inherits(obs_data$index, "Date") || inherits(obs_data$index, "POSIXt")
  index_is_int <- is.numeric(obs_data$index) && all(obs_data$index == as.integer(obs_data$index), na.rm = TRUE)
  if (!index_is_date && !index_is_int) {
    stop("Column obs_data$index must contain date or integer values.")
  }

  if (anyDuplicated(obs_data$index) > 0) {
    stop("Column obs_data$index must contain unique values.")
  }

  n_states_is_int <- is.numeric(n_states) && (n_states == as.integer(n_states))
  if (!n_states_is_int) {
    stop("Input n_states must be integer between 2 and 4.")
  }

  if (n_states <= 1 || n_states >= 5) {
    stop("Input n_states must be integer between 2 and 4.")
  }

  if (!is.logical(seasonal)) {
    stop("Input seasonal must be a logical (TRUE/FALSE).")
  }

  if (seasonal & (!"season" %in% colnames(obs_data))) {
    stop("Input obs_data must contain column 'season' if seasonal = TRUE.")
  }

  # Split into data type 'rate' or 'perc' --------------------------------------
  if (type == "rate") {
    return(run_hmm_rate(obs_data, n_states = n_states, seasonal = seasonal))
  } else if (type == "perc") {
    return(run_hmm_perc(obs_data, n_states = n_states, seasonal = seasonal))
  } else {
    stop("Input type must be either 'rate' or 'perc'.")
  }
}
