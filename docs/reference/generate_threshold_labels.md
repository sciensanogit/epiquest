# Generate QUEST threshold labels

Generates standardized descriptive names for thresholds based on the
number of threshold levels calculated. These are typically used for plot
axes and legend labels.

## Usage

``` r
generate_threshold_labels(n_thresholds = 4)
```

## Arguments

- n_thresholds:

  An integer. The number of thresholds (1, 2, 3, or 4).

## Value

A character vector of length `n_thresholds`.

## Details

The labels are assigned based on the complexity of the thresholding
tiers:

- **1 threshold**: "High"

- **2 thresholds**: "Low", "High"

- **3 thresholds**: "Low", "Medium", "High"

- **4 thresholds**: "Low", "Medium", "High", "Very high"

## See also

[`generate_palette_thresholds`](https://sciensanogit.github.io/epiquest/reference/generate_palette_thresholds.md)
