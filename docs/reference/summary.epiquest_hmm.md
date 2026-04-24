# Summary of hidden Markov model fit

Provides a readable summary of an `epiquest_hmm` object, including model
type, state definitions, and transition probabilities.

## Usage

``` r
# S3 method for class 'epiquest_hmm'
summary(object, ...)
```

## Arguments

- object:

  An object of class `epiquest_hmm` produced by
  [`run_hmm()`](run_hmm.md).

- ...:

  Additional arguments passed to methods (not currently used).

## Value

The function prints a summary to the console and invisibly returns the
`object`.

## Details

The last section on state distribution (observations) does not count the
number of observations in each state since the model does not make hard
state assignments. Rather, it provides for each observations a
(posterior smoothing) probability that it is in each of the states. In
other words, each observation is assigned a weight of 1 that is
distributed over the different states. The summary provides the total
weight in each state.
