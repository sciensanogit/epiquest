# Fit HMM for binomial percentage data

Internal function to fit a binomial HMM. This is preferred for data
representing proportions (e.g., cases out of a total population).

## Usage

``` r
run_hmm_perc(obs_data, n_states = 2, seasonal = FALSE)
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

The response variable is modeled as `cbind(num, denom - num)`, which
represents the number of successes/cases and failures/non-cases. This
accounts for the increased variance in observations with smaller
denominators.
