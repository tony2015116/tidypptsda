# Average daily gain

Fit a growth curve to the cleaned body weights of each pig and compute
average daily gain (ADG) over a body weight stage.

## Usage

``` r
calc_adg(weight, qc = weight$settings, verbose = 1)
```

## Arguments

- weight:

  Result of
  [`clean_weight()`](https://tony2015116.github.io/tidypptsda/reference/clean_weight.md).

- qc:

  QC settings; by default the ones used by
  [`clean_weight()`](https://tony2015116.github.io/tidypptsda/reference/clean_weight.md).
  Used here: `stage_range`, `curve_model`, `loess_span`,
  `max_extrap_days`.

- verbose:

  0 (silent), 1 (summary, default) or 2 (details).

## Value

An object of class `ppt_adg` (a list):

- `per_pig`: one row per pig (pigs removed by
  [`clean_weight()`](https://tony2015116.github.io/tidypptsda/reference/clean_weight.md)
  are not included) with `stage`, `curve_used`, `curve_r2`, `adg_type`,
  `start_date` / `end_date` and `start_weight` / `end_weight` (when the
  curve reaches the stage limits, kg), `stage_days`, `extrap_days_start`
  / `extrap_days_end` (days the curve is extrapolated before the first /
  after the last weight), `adg` (g/d), `lm_slope` (g/d, linear
  regression on the records inside the stage, for comparison),
  `r_squared` (of that regression), `weight_status` and `weight_reason`
  (from
  [`clean_weight()`](https://tony2015116.github.io/tidypptsda/reference/clean_weight.md));

- `daily`: one row per pig and day from `start_date` to `end_date` and
  over the recorded days: observed `weight` (daily median, kg, `NA` on
  predicted days), `predicted` weight with `lower` / `upper` limits (±
  1.96 residual SD), `in_stage` and `source` (`"observed"` or
  `"predicted"`);

- `removed`: pigs removed so far, plus pigs without ADG;

- `settings`: QC settings.

## See also

[`clean_weight()`](https://tony2015116.github.io/tidypptsda/reference/clean_weight.md)
for the previous step.

## Examples

``` r
visits <- prep_visits(nedap, verbose = 0)
w <- clean_weight(visits, verbose = 0)
adg <- calc_adg(w)
#> 
#> ── ADG over 30-120 kg (poly2 curve) ────────────────────────────────────────────
#> • Observed (stage inside the records): 24
#> • Extrapolated: 4
#> • Partial (stage not fully reached): 1
#> • No ADG: 0
#> Warning: 1 pig do not reach the whole stage: ADG is based on part of it (adg_type =
#> "partial").
#> ✔ Mean ADG: 1160 g/d (SD 124)
head(adg$per_pig[, .(responder, adg_type, start_date, end_date, stage_days, adg)])
#>    responder     adg_type start_date   end_date stage_days       adg
#>       <char>       <char>     <Date>     <Date>      <num>     <num>
#> 1:     13913     observed 2024-02-29 2024-05-16   76.79974 1171.8790
#> 2:     13918     observed 2024-03-06 2024-05-24   78.90401 1140.6265
#> 3:     13954 extrapolated 2024-02-18 2024-05-26   97.85791  919.7008
#> 4:     13996     observed 2024-02-26 2024-05-08   71.09056 1265.9909
#> 5:     14962     observed 2024-02-25 2024-05-07   72.05496 1249.0465
#> 6:     15006     observed 2024-02-26 2024-05-07   70.83402 1270.5759

# Gompertz curve, with quadratic fallback
adg_g <- calc_adg(w, qc = qc_config("casey", curve_model = "gompertz"), verbose = 0)
table(adg_g$per_pig$curve_used)
#> 
#>                gompertz poly2 (gompertz failed) 
#>                      28                       1 
```
