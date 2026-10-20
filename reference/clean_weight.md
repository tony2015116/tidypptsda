# Clean body weight records

Flag implausible and outlying body weight records, then decide for each
pig whether its weight data are good enough for growth analysis.

## Usage

``` r
clean_weight(visits, qc = qc_config(), verbose = 1)
```

## Arguments

- visits:

  Visit table from
  [`prep_visits()`](https://tony2015116.github.io/tidypptsda/reference/prep_visits.md).

- qc:

  QC settings from
  [`qc_config()`](https://tony2015116.github.io/tidypptsda/reference/qc_config.md).
  Used here: `weight_range`, `weight_outlier`, `outlier_combine`,
  `rlm_cutoff`, `sd_max`, `loess_span`, `rel_dev_max`, `daily_drop_min`,
  `min_records`, `min_test_days`, `max_missing_rate`,
  `entry_weight_max`, `exit_weight_min`, `curve_r2_min`.

- verbose:

  0 (silent), 1 (summary, default) or 2 (details).

## Value

An object of class `ppt_weight` (a list):

- `per_pig`: one row per pig with `n_records`, `n_valid`, `n_outliers`,
  `first_date`, `last_date`, `test_days`, `missing_rate`,
  `entry_weight`, `exit_weight` (kg, from the fitted curve), `r2`,
  `status` (`"keep"`, `"low_confidence"` or `"removed"`) and `reason`;

- `daily`: one row per pig and day for pigs not removed: median of the
  valid weights (`weight`, kg), `n_records`, `n_outliers`;

- `records`: every weight record with `fitted`, `outlier` and `qc_flag`
  (why it was flagged);

- `removed`: pigs removed here, plus misreads logged by
  [`prep_visits()`](https://tony2015116.github.io/tidypptsda/reference/prep_visits.md);

- `settings`: the QC settings used.

## Details

Pig checks use the valid (non-outlier) records only:

- `n_valid < min_records`, `test_days < min_test_days` or
  `missing_rate > max_missing_rate` (share of test days without a valid
  weight) remove the pig;

- `entry_weight > entry_weight_max`, `exit_weight < exit_weight_min` or
  `r2 < curve_r2_min` mark the pig `"low_confidence"` but keep it: its
  growth can still be estimated by extrapolation in
  [`calc_adg()`](https://tony2015116.github.io/tidypptsda/reference/calc_adg.md),
  with a flag.

## See also

[`prep_visits()`](https://tony2015116.github.io/tidypptsda/reference/prep_visits.md)
for the previous step,
[`qc_config()`](https://tony2015116.github.io/tidypptsda/reference/qc_config.md)
for the settings.

## Examples

``` r
visits <- prep_visits(nedap, verbose = 0)
w <- clean_weight(visits)
#> 
#> ── Cleaning body weight (rlm) ──────────────────────────────────────────────────
#> • Weight records: 31,472
#> • Outside weight range: 0
#> • Outliers: 2,975
#> ! Pigs kept: 28, low confidence: 1, removed: 1
w
#> 
#> ── <ppt_weight> ──
#> 
#> Pigs: 30 (keep 28, low confidence 1, removed 1)
#> $per_pig: 30 rows x 14 columns
#> $daily: 2789 rows x 7 columns
#> $removed: 1 row x 4 columns
#> $records: 31472 rows x 9 columns
#> QC profile: "casey"

# Why pigs were removed
w$removed
#>    responder location         step                 reason
#>       <char>   <char>       <char>                 <char>
#> 1:     15964      101 clean_weight test period 2 d < 35 d

# Records flagged as outliers
head(w$records[outlier == TRUE])
#>    responder location       date seq_days          entry_time weight   fitted
#>       <char>   <char>     <Date>    <int>              <POSc>  <num>    <num>
#> 1:     13913      101 2024-02-20        2 2024-02-20 01:05:04   31.0 21.48760
#> 2:     13913      101 2024-02-20        2 2024-02-20 06:52:21   28.5 21.69242
#> 3:     13913      101 2024-02-20        2 2024-02-20 06:53:50   29.5 21.69330
#> 4:     13913      101 2024-02-20        2 2024-02-20 08:46:55   30.0 21.76008
#> 5:     13913      101 2024-02-20        2 2024-02-20 11:28:05   29.5 21.85532
#> 6:     13913      101 2024-02-20        2 2024-02-20 11:32:56   27.5 21.85819
#>    outlier qc_flag
#>     <lgcl>  <char>
#> 1:    TRUE     rlm
#> 2:    TRUE     rlm
#> 3:    TRUE     rlm
#> 4:    TRUE     rlm
#> 5:    TRUE     rlm
#> 6:    TRUE     rlm

# Another QC preset
w_national <- clean_weight(visits, qc = qc_config("national"), verbose = 0)
table(w_national$per_pig$status)
#> 
#>           keep low_confidence        removed 
#>             26              3              1 
```
