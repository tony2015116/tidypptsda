# Quality-control settings

Build the set of quality-control (QC) thresholds used by the whole
pipeline. Start from a preset with `profile` and override any parameter
through `...`.

## Usage

``` r
qc_config(profile = c("casey", "national", "legacy"), ...)
```

## Arguments

- profile:

  Preset to start from:

  - `"casey"` (default): feeder error criteria of Casey et al. (2005),
    robust regression
    ([`MASS::rlm`](https://rdrr.io/pkg/MASS/man/rlm.html)) for body
    weight outliers and a quadratic growth curve.

  - `"national"`: LOESS-based weight cleaning and growth curve, a
    minimum curve R², longer test period and lower missing rate.

  - `"legacy"`: STL + robust regression + robust SD outlier detection
    and a Gompertz growth curve.

- ...:

  Parameters to override, as `name = value`. See **Parameters**.

## Value

An object of class `ppt_qc`: a named list of parameters with the preset
name in attribute `"profile"`.

## Parameters

**Station transfer** (pigs seen at several stations)

- `max_gap_days`: maximum gap between two stations to treat the pig as
  transferred. A larger gap splits it into two animals. Default 3.

- `max_overlap_days`: maximum time overlap between two stations. A
  larger overlap is treated as transponder misreads. Default 1.

- `max_jump_kg`: body weight jump at the transfer that triggers a
  warning. Default 10.

**Body weight records**

- `weight_range`: valid body weight of a single record, kg.

- `weight_outlier`: one or more of `"rlm"`, `"loess"`, `"stl"`, `"sd"`.

- `outlier_combine`: `"any"` (outlier for any method) or `"majority"`.

- `rlm_cutoff`: records with a robust regression weight below this are
  outliers. Default 0.5.

- `sd_max`: residuals beyond this many robust SDs (MAD) are outliers.

- `loess_span`: smoothing span for LOESS. Default 0.75.

- `rel_dev_max`: optional, relative deviation from the curve above which
  a record is an outlier (e.g. 0.25). `NULL` = off.

- `daily_drop_min`: optional, a day whose weight is below this ratio of
  the previous day is an outlier (e.g. 0.90). `NULL` = off.

**Pig-level checks**

- `min_test_days`, `min_records`: minimum test length (days) and number
  of valid weight records.

- `max_missing_rate`: maximum share of days without a valid weight.

- `entry_weight_max`, `exit_weight_min`: maximum entry and minimum exit
  body weight, kg.

- `curve_r2_min`: optional, pigs whose growth curve R² is below this are
  flagged as low confidence (not removed). `NULL` = off.

**Growth and ADG**

- `stage_range`: body weight interval for ADG and FCR, kg.

- `curve_model`: `"poly1"`, `"poly2"`, `"poly3"`, `"loess"` or
  `"gompertz"` (falls back to `"poly2"` when it does not converge).

- `max_extrap_days`: maximum extrapolation of the curve, days.

**Feeder errors** (Casey et al. 2005, Table 3)

- `fiv_range`: FIV-lo / FIV-hi, feed intake per visit, g.

- `fiv0_abs_max`: FIV-0, maximum \|FIV\| for a 0 s visit, g.

- `duration_max`: OTV-hi, maximum occupation time per visit, s.

- `speed_fiv_lo_max`: FRV-hi-FIV-lo, maximum feeding rate for visits
  with 0 \< FIV \< 50 g, g/min.

- `speed_strict_max`: FRV-hi-strict, maximum feeding rate when the
  preceding or following visit has FIV \< -20 g, g/min.

- `speed_range`: FRV-lo and FRV-hi, g/min.

- `idle_duration_max`: FRV-0, maximum occupation time with no intake, s.

- `trough_diff_range`: LWD / FWD, trough weight difference between
  subsequent visits, g.

- `max_unidentified_feed_kg`: feed disappearance in unidentified visits
  per feeder above which a warning is given.

**Daily feed intake**

- `dfi_range`: valid daily feed intake, kg.

- `dfi_quantile`: optional, lower and upper quantile cut-offs (e.g.
  `c(0.025, 0.99)`). `NULL` = off.

- `dfi_correct`: `"lmm"` (Jiao et al. 2014) or `"none"`.

- `impute_method`: `"linear"` (linear interpolation, LOESS for long
  gaps, intake ~ body weight regression at the stage ends) or `"loess"`
  (robust LOESS over days everywhere).

- `long_gap_days`: inside gaps longer than this many days are imputed
  with LOESS instead of a straight line (`impute_method = "linear"`).
  Default 7.

**Confidence flags** (used by
[`calc_fcr()`](https://tony2015116.github.io/tidypptsda/reference/calc_fcr.md))

- `max_edge_extrap_days`: a pig is `"low_confidence"` when the growth
  curve or the feed intake is extrapolated over more than this many days
  at the start or the end of the stage. Default 15.

- `min_coverage`: minimum share of stage days with recorded feed intake.
  Default 0.7.

## References

Casey, D. S., Stern, H. S., & Dekkers, J. C. M. (2005). Identification
of errors and factors associated with errors in data from electronic
swine feeders. *Journal of Animal Science*, 83, 969-982.

Jiao, S., Maltecca, C., Gray, K. A., & Cassady, J. P. (2014). Feed
intake, average daily gain, feed efficiency, and real-time ultrasound
traits in Duroc pigs: I. *Journal of Animal Science*, 92, 2377-2386.

## Examples

``` r
# Default preset
qc <- qc_config()
qc$duration_max
#> [1] 3600

# Another preset with one parameter overridden
qc_national <- qc_config("national", min_test_days = 50)
qc_national
#> 
#> ── QC settings: profile "national" ──
#> 
#> Station transfer
#>   max_gap_days: 3
#>   max_overlap_days: 1
#>   max_jump_kg: 10
#> Body weight records
#>   weight_range: 25, 140
#>   weight_outlier: loess
#>   outlier_combine: any
#>   rlm_cutoff: 0.5
#>   sd_max: 3
#>   loess_span: 0.75
#>   rel_dev_max: NULL (off)
#>   daily_drop_min: NULL (off)
#> Pig-level checks
#>   min_test_days: 50
#>   min_records: 20
#>   max_missing_rate: 0.15
#>   entry_weight_max: 65
#>   exit_weight_min: 85
#>   curve_r2_min: 0.99
#> Growth and ADG
#>   stage_range: 30, 120
#>   curve_model: loess
#>   max_extrap_days: 30
#> Feeder errors
#>   fiv_range: -20, 2000
#>   fiv0_abs_max: 20
#>   duration_max: 3600
#>   speed_fiv_lo_max: 500
#>   speed_strict_max: 110
#>   speed_range: 2, 170
#>   idle_duration_max: 500
#>   trough_diff_range: -20, 1800
#>   max_unidentified_feed_kg: 90
#> Daily feed intake
#>   dfi_range: 0, 6
#>   dfi_quantile: NULL (off)
#>   dfi_correct: lmm
#>   impute_method: loess
#>   long_gap_days: 7
#> Confidence flags
#>   max_edge_extrap_days: 15
#>   min_coverage: 0.7

# Optional rules are off (NULL) unless switched on
qc_config("casey", daily_drop_min = 0.90)$daily_drop_min
#> [1] 0.9
```
