# Visualize the stability of HMM states and thresholds

Generates plots to visualize how HMM state parameters and resulting
QUEST thresholds evolve as the model is refitted over different periods
(cutoff dates).

## Usage

``` r
create_loop_plots(list_results, print = FALSE)
```

## Arguments

- list_results:

  An object of class `epiquest_loop` produced by
  [`run_loop_thresholds()`](https://sciensanogit.github.io/epiquest/reference/run_loop_thresholds.md).

- print:

  A logical. If `TRUE`, all generated plots are printed to the active
  graphics device.

## Details

It is important to assess HMM and threshold stability, i.e., that adding
or removing a few weeks of data does not meaningfully change the
results. The 'cutoff date' on the horizontal axis represents the end of
the data window used for that specific model fit.

\#' @return An object of class `epiquest_plot_list`, a named `list` of
`ggplot2` objects containing:

- `thresholds`: Threshold values plotted against cutoff dates, with the
  raw surveillance signal shown in the background for context.

- `states_facet`: A faceted plot showing the evolution of the estimated
  mean (and standard deviation) for each hidden state.

- `states`: A plot of the mean values for each state over time,
  including shaded ribbons representing ±1 and ±2 standard deviations to
  visualize state overlap and uncertainty.

## See also

[`generate_palette_thresholds`](https://sciensanogit.github.io/epiquest/reference/generate_palette_thresholds.md),
[`generate_palette_hmm`](https://sciensanogit.github.io/epiquest/reference/generate_palette_hmm.md)

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
