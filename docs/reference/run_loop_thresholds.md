# Stability analysis of QUEST thresholds via iterative refitting

Evaluates the robustness of the HMM states and the QUEST thresholds by
repeatedly refitting the model over an expanding window of the time
series.

## Usage

``` r
run_loop_thresholds(
  obs_data,
  n_states = 2,
  type = "rate",
  seasonal = FALSE,
  quantiles = c(0.05, 0.7, 0.9, 0.99),
  epidemic_state_indices = NULL,
  step = 7,
  window_summary = 12
)
```

## Arguments

- obs_data:

  A `data.frame` formatted for
  [`run_hmm()`](https://sciensanogit.github.io/epiquest/reference/run_hmm.md).

- n_states:

  An integer. Number of hidden states (2 to 4).

- type:

  A character string. Either `"rate"` (Gaussian) or `"perc"` (binomial).

- seasonal:

  A logical. If `TRUE`, treats seasons as independent.

- quantiles:

  A numeric vector. Quantile levels for threshold calculation.

- epidemic_state_indices:

  An integer vector. HMM states considered as "epidemic" (see the
  section 'Defining the "epidemic" state(s)' in
  [`run_threshold_computation`](https://sciensanogit.github.io/epiquest/reference/run_threshold_computation.md)).

- step:

  An integer. The number of units to advance the cutoff date in each
  iteration. Defaults to 7 (one week).

- window_summary:

  An integer. The number of most recent iterations to include when
  calculating the final summary statistics.

## Value

An object of class `epiquest_loop`. This is a list containing:

- `thresholds`: A data frame of all thresholds calculated at each cutoff
  date.

- `states`: A data frame showing how state means and standard deviations
  evolved.

- `summary`: A summary table (median, mean, min, max) of thresholds
  within the final `window_summary` iterations.

- `data`: The original input data.

## Details

**Stability analysis:** To ensure the HMM has enough data to converge to
a stable estimate, the function starts with a minimum training set of 50
`step` units. It then adds data in increments of `step` (default 1 week
of 7 days), refitting the model and recalculating thresholds at every
stage.

This process mimics how the model would perform in a real-time
surveillance setting as new data arrives each week. If the thresholds or
state means show high volatility, it may indicate that the model is
overfit or that the surveillance signal is too noisy for the chosen
number of states.

## See also

[`create_loop_plots`](https://sciensanogit.github.io/epiquest/reference/create_loop_plots.md),
[`run_threshold_computation`](https://sciensanogit.github.io/epiquest/reference/run_threshold_computation.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Stability analysis takes time as it refits the model repeatedly
fit_loop <- loop_thresholds(df_sari_be, n_states = 2)

# Look at results
summary(fit_loop)

# Visualize results
create_loop_plots(fit_loop)
} # }
```
