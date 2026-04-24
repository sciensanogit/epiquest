# Fit HMM for continuous rate data

Internal function to fit a Gaussian HMM to rate time series. It uses the
Baum-Welch algorithm for parameter estimation and provides smoothed
state probabilities.

## Usage

``` r
run_hmm_rate(obs_data, n_states = 2, seasonal = FALSE)
```

## Arguments

- obs_data:

  A `data.frame` containing an `index` column (Date or integer).
  Additional required columns depend on `type` and `seasonal`:

  - If `type = "rate"`: Must contain a numeric `rate` column. This
    represents the intensity, incidence or activity level of the
    surveillance signal (e.g., cases per 100,000 population).

  - If `type = "perc"`: Must contain integer `num` and `denom` columns.
    `num` is the numerator (e.g., the number of positive lab tests or
    symptomatic patients), and `denom` is the denominator or total
    sample size (e.g., total tests performed or total clinical
    consultations).

  - If `seasonal = TRUE`: Must contain a `season` column. The subseries
    in each season is treated as an independent time series.

- n_states:

  An integer. The number of hidden states (2 to 4).

- seasonal:

  A logical. If `TRUE`, the model prevents transitions between different
  seasons, treating them as independent sequences.

## Value

An object of class `epiquest_hmm`.

## Details

The model assumes a Gaussian (normal) distribution for the response
variable `rate`. If `seasonal` is `TRUE`, the `ntimes` parameter in
`depmixS4` is populated with the lengths of each individual season to
prevent transitions between the end of one season and the start of the
next.
