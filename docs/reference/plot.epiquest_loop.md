# Plot method for loop stability results

A wrapper for [`create_loop_plots`](create_loop_plots.md) that returns
the threshold stability visualization by default.

## Usage

``` r
# S3 method for class 'epiquest_loop'
plot(x, ...)
```

## Arguments

- x:

  An object of class `epiquest_loop` produced by
  [`run_loop_thresholds()`](run_loop_thresholds.md).

- ...:

  Additional arguments passed to methods (not currently used).

## Value

A `ggplot2` object showing the evolution of thresholds across various
cutoff dates.
