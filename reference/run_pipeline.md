# Run the whole analysis

Run
[`prep_visits()`](https://tony2015116.github.io/tidypptsda/reference/prep_visits.md),
[`clean_weight()`](https://tony2015116.github.io/tidypptsda/reference/clean_weight.md),
[`calc_adg()`](https://tony2015116.github.io/tidypptsda/reference/calc_adg.md),
[`calc_adfi()`](https://tony2015116.github.io/tidypptsda/reference/calc_adfi.md)
and
[`calc_fcr()`](https://tony2015116.github.io/tidypptsda/reference/calc_fcr.md)
in a row with the same QC settings.

## Usage

``` r
run_pipeline(data, station = NULL, qc = qc_config(), verbose = 1)
```

## Arguments

- data:

  Raw station data (see
  [`prep_visits()`](https://tony2015116.github.io/tidypptsda/reference/prep_visits.md)).

- station:

  `"nedap"`, `"fire"` or `NULL` to detect it.

- qc:

  QC settings from
  [`qc_config()`](https://tony2015116.github.io/tidypptsda/reference/qc_config.md).

- verbose:

  0 (silent), 1 (summary, default) or 2 (details).

## Value

An object of class `ppt_pipeline`: a list with `visits`, `weight`,
`adg`, `adfi` and `fcr`, plus `removed` (every pig removed, with the
step and the reason).

## Examples

``` r
res <- run_pipeline(fire, qc = qc_config(stage_range = c(60, 120)), verbose = 0)
res
#> 
#> ── tidypptsda pipeline (FIRE, profile "casey") ──
#> 
#> • Pigs in the data: 26
#> • Pigs with weight data kept: 25
#> • Pigs with ADG: 25
#> • Pigs with FCR: 25 (25 ok, 0 low confidence)
#> • Removed pigs: 1 (see $removed)
#> Mean ADG 1226 g/d, ADFI 3266 g/d, FCR 2.67
res$fcr$summary[group == "all"]
#>     group        trait     n         min          max       median        mean
#>    <char>       <char> <int>       <num>        <num>        <num>       <num>
#> 1:    all          adg    25  937.148002 1554.7635738 1238.2756911 1226.292755
#> 2:    all         adfi    25 2572.527511 3874.4621650 3243.1673513 3266.068769
#> 3:    all          fcr    25    2.261206    3.0879735    2.6424840    2.674295
#> 4:    all           gf    25    0.323837    0.4422418    0.3784318    0.375591
#> 5:    all   stage_days    25   38.591072   64.0240415   48.4544758   49.422974
#> 6:    all start_weight    25   59.999985   60.0000093   59.9999980   59.999997
#> 7:    all   end_weight    25  119.999985  120.0000104  119.9999970  119.999997
#>              sd           cv
#>           <num>        <num>
#> 1: 1.245986e+02 1.016059e-01
#> 2: 2.595311e+02 7.946285e-02
#> 3: 1.816529e-01 6.792553e-02
#> 4: 2.559708e-02 6.815148e-02
#> 5: 5.149714e+00 1.041968e-01
#> 6: 4.429726e-06 7.382877e-08
#> 7: 4.537231e-06 3.781026e-08
```
