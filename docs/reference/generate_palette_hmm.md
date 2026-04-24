# Generate standardized ggplot2 color scales for HMM states

Generates a manual color or fill scale for `ggplot2` using a pre-defined
color palette designed for epidemiological surveillance signals.

## Usage

``` r
generate_palette_hmm(n_states = 3, fill = FALSE)
```

## Arguments

- n_states:

  An integer. The number of hidden states (2 to 4).

- fill:

  A logical. If `TRUE`, returns `scale_fill_manual`. If `FALSE`
  (default), returns `scale_color_manual`.

## Value

A `ggplot2` manual color/fill scale object.

## Details

The palette uses specific hex codes to represent severity. In general:

- **Green** : (very) low activity.

- **Yellow**: medium activity.

- **Red**: high activity.

## See also

[`generate_state_labels_hmm`](https://sciensanogit.github.io/epiquest/reference/generate_state_labels_hmm.md)
