# Plot method for HMM results

A wrapper for [`create_hmm_plots`](create_hmm_plots.md) that provides
the "full time series" visualization by default.

## Usage

``` r
# S3 method for class 'epiquest_hmm'
plot(x, ...)
```

## Arguments

- x:

  An object of class `epiquest_hmm` produced by
  [`run_hmm()`](run_hmm.md).

- ...:

  Additional arguments passed to methods (not currently used).

## Value

A `ggplot2` object showing the time series colored by the most probable
hidden state.
