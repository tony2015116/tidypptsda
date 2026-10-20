# Average daily feed intake

Correct daily feed intake for feeder errors with a linear mixed model,
impute missing days and compute average daily feed intake (ADFI) over
the ADG stage.

## Usage

``` r
calc_adfi(visits, adg, qc = adg$settings, verbose = 1)
```

## Arguments

- visits:

  Visit table from
  [`prep_visits()`](https://tony2015116.github.io/tidypptsda/reference/prep_visits.md),
  or already flagged by
  [`flag_feed_errors()`](https://tony2015116.github.io/tidypptsda/reference/flag_feed_errors.md).

- adg:

  Result of
  [`calc_adg()`](https://tony2015116.github.io/tidypptsda/reference/calc_adg.md).

- qc:

  QC settings; by default the ones used for `adg`. Used here: the feeder
  error thresholds, `dfi_correct`, `dfi_range`, `dfi_quantile`,
  `impute_method`, `long_gap_days`, `loess_span`.

- verbose:

  0 (silent), 1 (summary, default) or 2 (details).

## Value

An object of class `ppt_adfi` (a list):

- `per_pig`: `adfi` (g/d over the stage), `adfi_raw` (mean recorded
  intake of the recorded stage days), `adfi_error_free`, `n_stage_days`,
  `n_observed`, `n_corrected`, `n_interpolated`, `n_extrapolated`,
  `n_missing`, `n_extrap_start` / `n_extrap_end` (consecutive
  extrapolated days at the start / end of the stage), `coverage` (share
  of stage days with a recorded or corrected value), `adg_type`;

- `daily`: one row per pig and day: `bw` (kg), `in_stage`, `n_visits`,
  `n_error_visits`, `dfi_raw`, `dfi_error_free`, `dfi_corrected`, `dfi`
  (final value, g) and `state`;

- `model`: fixed-effect estimates of the correction model;

- `removed`, `settings`.

## References

Jiao, S., Maltecca, C., Gray, K. A., & Cassady, J. P. (2014). Feed
intake, average daily gain, feed efficiency, and real-time ultrasound
traits in Duroc pigs: I. *Journal of Animal Science*, 92, 2377-2386.

## See also

[`flag_feed_errors()`](https://tony2015116.github.io/tidypptsda/reference/flag_feed_errors.md),
[`calc_adg()`](https://tony2015116.github.io/tidypptsda/reference/calc_adg.md).

## Examples

``` r
visits <- prep_visits(nedap, verbose = 0)
w <- clean_weight(visits, verbose = 0)
adg <- calc_adg(w, verbose = 0)
adfi <- calc_adfi(visits, adg)
#> 
#> ── Flagging feeder errors (Casey et al. 2005) ──────────────────────────────────
#> ℹ Visits with at least one error: 1.58% of 31652 identified visits
#> 
#> ── ADFI over 30-120 kg ─────────────────────────────────────────────────────────
#> ℹ Correction model: 2772 pig-days, 11 error covariates
#> • Stage days recorded without error (org): 1,959
#> • Corrected (corr): 280
#> • Interpolated (iii): 1
#> • Extrapolated (elrp): 27
#> • Missing: 0
#> • Pig-days outside dfi_range: 0
#> ✔ Mean ADFI over the stage: 2801 g/d
head(adfi$per_pig)
#>    responder location  stage     adfi     adg_type adfi_raw adfi_error_free
#>       <char>   <char> <char>    <num>       <char>    <num>           <num>
#> 1:     13913      101 30-120 2616.719     observed 2596.513        2595.679
#> 2:     13918      101 30-120 2570.041     observed 2540.500        2539.662
#> 3:     13954      101 30-120 2343.422 extrapolated 2317.260        2312.906
#> 4:     13996      101 30-120 2857.824     observed 2835.890        2832.712
#> 5:     14962      101 30-120 2818.537     observed 2800.425        2800.137
#> 6:     15006      101 30-120 3084.452     observed 3071.028        3070.833
#>    n_stage_days n_observed n_corrected n_interpolated n_extrapolated n_missing
#>           <int>      <int>       <int>          <int>          <int>     <int>
#> 1:           78         78          12              0              0         0
#> 2:           80         80          15              0              0         0
#> 3:           99         96          15              0              3         0
#> 4:           73         73           8              0              0         0
#> 5:           73         73           9              0              0         0
#> 6:           72         72           7              0              0         0
#>    n_extrap_start n_extrap_end coverage
#>             <int>        <int>    <num>
#> 1:              0            0 1.000000
#> 2:              0            0 1.000000
#> 3:              2            1 0.969697
#> 4:              0            0 1.000000
#> 5:              0            0 1.000000
#> 6:              0            0 1.000000
table(adfi$daily[in_stage == TRUE, state])
#> 
#> corr elrp  iii  org 
#>  280   27    1 1959 
head(adfi$model)
#>           term      estimate    std_error      p_value
#>         <char>         <num>        <num>        <num>
#> 1: (Intercept)   -883.565535  294.8491609 2.754031e-03
#> 2: location102    -75.207468   60.1144632 2.220494e-01
#> 3:          bw     24.930643    0.3435384 0.000000e+00
#> 4:         adg      1.557668    0.2481584 1.209946e-06
#> 5:  pte_fiv_hi -12786.859956 6072.7882287 3.533023e-02
#> 6:  pte_otv_hi  -2668.620256 3480.0227004 4.432430e-01
```
