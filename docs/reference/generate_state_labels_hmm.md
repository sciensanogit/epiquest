# Generate default labels for HMM states

Provides standardized names for hidden states based on the number of
states specified. These labels are used for plot legends and summary
tables to provide epidemiological interpretation to the states.

## Usage

``` r
generate_state_labels_hmm(n_states = 3)
```

## Arguments

- n_states:

  An integer. The number of hidden states (2 to 4).

## Value

A character vector of length `n_states` containing the labels.

## Details

The labels are assigned as follows:

- **2 states**: "Low activity (L1)", "High activity (L2)"

- **3 states**: "Low activity (L1)", "Medium activity (L2)", "High
  activity (L3)"

- **4 states**: "Very low activity (L1)", "Low activity (L2)", "Medium
  activity (L3)", "High activity (L4)"

## See also

[`generate_palette_hmm`](generate_palette_hmm.md)
