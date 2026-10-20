# Flag feeder errors

Flag each visit with the 16 error types of Casey et al. (2005).

## Usage

``` r
flag_feed_errors(visits, qc = qc_config(), verbose = 1)
```

## Arguments

- visits:

  Visit table from
  [`prep_visits()`](https://tony2015116.github.io/tidypptsda/reference/prep_visits.md).
  Keep the unidentified visits: they are part of the feeder sequence.

- qc:

  QC settings from
  [`qc_config()`](https://tony2015116.github.io/tidypptsda/reference/qc_config.md).
  Used here: `fiv_range`, `fiv0_abs_max`, `duration_max`,
  `speed_fiv_lo_max`, `speed_strict_max`, `speed_range`,
  `idle_duration_max`, `trough_diff_range`, `max_unidentified_feed_kg`.

- verbose:

  0 (silent), 1 (summary, default) or 2 (rate of each error type).

## Value

The visit table (all visits) with added columns:

- `fiv`, `otv`, `frv`, `lwd`, `fwd`, `ltd`, `ftd`: the seven variables;

- one logical column per error type (`fiv_lo`, `fiv_hi`, `fiv_0`,
  `otv_lo`, `otv_hi`, `frv_hi_fiv_lo`, `frv_hi_strict`, `frv_hi`,
  `frv_0`, `frv_lo`, `lwd_lo`, `lwd_hi`, `fwd_lo`, `fwd_hi`, `ltd_lo`,
  `ftd_lo`);

- `n_errors`: number of error types of the visit (0 = error-free).

Attributes `"feeders"` (per feeder: visits, unidentified visits, feed
disappearance in unidentified visits, error rate) and `"error_rates"`
(share of identified visits with each error type) summarise the result.
The attributes of `visits` are kept.

## References

Casey, D. S., Stern, H. S., & Dekkers, J. C. M. (2005). Identification
of errors and factors associated with errors in data from electronic
swine feeders. *Journal of Animal Science*, 83, 969-982.

## See also

[`prep_visits()`](https://tony2015116.github.io/tidypptsda/reference/prep_visits.md)
for the previous step,
[`calc_adfi()`](https://tony2015116.github.io/tidypptsda/reference/calc_adfi.md)
which uses the flags.

## Examples

``` r
visits <- prep_visits(fire, verbose = 0)
flagged <- flag_feed_errors(visits, verbose = 2)
#> 
#> ── Flagging feeder errors (Casey et al. 2005) ──────────────────────────────────
#> ℹ Visits with at least one error: 2.62% of 9743 identified visits
#> • FRV-lo: 64 (0.66%)
#> • LWD-hi: 60 (0.62%)
#> • FWD-hi: 60 (0.62%)
#> • FIV-lo: 33 (0.34%)
#> • FRV-hi: 28 (0.29%)
#> • FIV-hi: 21 (0.22%)
#> • LWD-lo: 5 (0.05%)
#> • FRV-hi-strict: 4 (0.04%)
#> • FWD-lo: 4 (0.04%)
#> • FRV-0: 1 (0.01%)
attr(flagged, "feeders")
#>    location n_visits n_unidentified unidentified_feed_kg error_rate
#>      <char>    <int>          <int>                <num>      <num>
#> 1:      101     6014             30                2.148 0.01788102
#> 2:      102     3780             21                0.621 0.03937217
```
