# Plot method for threshold results

A wrapper for
[`create_threshold_plots`](https://sciensanogit.github.io/epiquest/reference/create_threshold_plots.md)
that provides the full time series visualization with overlaid QUEST
thresholds.

## Usage

``` r
# S3 method for class 'epiquest_thresholds'
plot(x, ...)
```

## Arguments

- x:

  An object of class `epiquest_thresholds` produced by
  [`run_threshold_computation()`](https://sciensanogit.github.io/epiquest/reference/run_threshold_computation.md).

- ...:

  Additional arguments passed to methods (not currently used).

## Value

A `ggplot2` object showing the time series, state assignments, and QUEST
thresholds.
