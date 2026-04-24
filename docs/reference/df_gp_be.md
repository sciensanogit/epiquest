# Belgian GP workload data

Sciensano, the Belgian Institute for Health, coordinates a surveillance
network of about 100 general practices all over Belgium. They report
data every week about different health problems, including their
workload due to acute respiratory infections on a 5-point scale (very
low/low/normal/high/very high). The percentage of responding GPs with a
high or very high workload is an important epidemiological surveillance
signal.

## Usage

``` r
df_gp_be
```

## Format

### `df_gp_be`

A data frame with 259 rows and 3 columns:

- index:

  Week encoded as Monday of that week (Date variable)

- num:

  Number of GPs indicating a high or very high workload due to acute
  respiratory infection (integer variable)

- denom:

  Number of responding GPS (integer variable)

## Source

<https://www.sciensano.be/en/projects/network-general-practitioners>

## Details

This data set contains synthetic data that mimics the behavior of the
real workload data for the period 2021-02-22 to 2026-02-02.
