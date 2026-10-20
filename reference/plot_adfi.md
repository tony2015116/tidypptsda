# Plot daily feed intake

Plot recorded and corrected daily feed intake of each pig over the
stage, one plot per station. Point colours show how each day was
obtained.

## Usage

``` r
plot_adfi(adfi, responders = NULL, locations = NULL, ncol = 3, verbose = 1)
```

## Arguments

- adfi:

  Result of
  [`calc_adfi()`](https://tony2015116.github.io/tidypptsda/reference/calc_adfi.md).

- responders, locations:

  Optional pig IDs and stations to plot.

- ncol:

  Number of panel columns. Default 3.

- verbose:

  0 (silent), 1 (summary, default).

## Value

A `data.table` with `location`, `n_pigs` and `plot`.
