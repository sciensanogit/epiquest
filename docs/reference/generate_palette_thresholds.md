# Generate standardized color scales for thresholds

Generates a manual color scale for `ggplot2` to visualize different
QUEST threshold levels.

## Usage

``` r
generate_palette_thresholds(n_thresholds = 4)
```

## Arguments

- n_thresholds:

  An integer. The number of thresholds (1, 2, 3, or 4).

## Value

A `ggplot2` manual color scale object.

## See also

[`generate_threshold_labels`](generate_threshold_labels.md)
