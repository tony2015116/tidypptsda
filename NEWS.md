# tidypptsda 0.4.0

## New features

* `add_breed()` merges a breed (line) table from your own records into the
  visit table. `prep_visits()` keeps a `breed` column of the raw data and
  otherwise reminds you to add one. With breed, `calc_adfi()` adds it as a
  fixed effect to the correction model and `calc_fcr()` summarises traits by
  breed. `run_pipeline()` gains `breeds`.
* QC parameter `fiv_max_by_weight`: the FIV-hi limit can depend on body
  weight (and breed) instead of the fixed 2000 g. The limit used for each
  visit is kept in column `fiv_max`. Example table: `fiv_max_example()`.
* QC parameter `max_daily_jump_kg` (off by default): flags pigs whose daily
  median weight changes too fast; `clean_weight()` always reports
  `max_daily_jump`.
* `calc_fcr()` returns `$by_bin`: feed, gain and FCR per body weight class
  (`bin_width`, default 10 kg). Inner classes covered by less than
  `min_bin_coverage_kg` (default 6 kg) of recorded weights, and segment FCR
  outside the optional `bin_fcr_limits` (example: `bin_fcr_example()`), flag
  the pig as low confidence.
* `write_results()` writes all result tables to CSV files named
  `<farm>_<table>_<date>.csv` (UTF-8 with BOM for Excel).
* `clean_weight()`, `calc_adg()`, `calc_adfi()` and `run_pipeline()` gain
  `cores` for parallel per-pig computation (base package parallel).

## Bug fixes

* `calc_fcr()`: the numbers in `fcr_note` (coverage, extrapolated days) could
  belong to another pig when several pigs were flagged. The flags themselves
  were right.

# tidypptsda 0.3.0

## Breaking changes

* The deprecated wrappers of the 0.1.0 function names were removed:
  `import_nedap()`, `preprocess_data()`, `clean_weight_get()`, `adg_get()`,
  `adfi_get()`, `fcr_get()`, `adg_plot()` and `adfi_plot()`. Use
  `read_station()`, `prep_visits()`, `clean_weight()`, `calc_adg()`,
  `calc_adfi()`, `calc_fcr()`, `plot_adg()` and `plot_adfi()`. Version 0.1.0
  stays installable with `pak::pak("tony2015116/tidypptsda@v0.1.0")`.

## Documentation

* New Chinese articles: a guide to every `qc_config()` parameter and a guide
  to the three QC presets.
* The reference index has a short description for every group.

# tidypptsda 0.2.0

## New workflow

* Complete rewrite of the analysis functions, in `dev/flat_tidypptsda.Rmd`.
* `read_station()` -> `prep_visits()` -> `clean_weight()` -> `calc_adg()` ->
  `flag_feed_errors()` / `calc_adfi()` -> `calc_fcr()` -> `plot_adg()`,
  `plot_adfi()`, `save_plots()`; or all at once with `run_pipeline()`.
* All quality-control thresholds are set with `qc_config()` (presets
  `"casey"`, `"national"`, `"legacy"`).
* The old function names still work for one version, with a deprecation
  warning (see `?tidypptsda-deprecated`).

## Changes in results

* Feeder errors follow Casey et al. (2005) Table 3: differences between
  subsequent visits are computed per feeder and include unidentified
  visits; FRV-hi-strict / FRV-hi were wrong before (FRV-hi-strict was
  flagged about 12 times too often in the FIRE example).
* Feed intake correction follows Jiao et al. (2014): the mixed model is
  fitted on all pig-days and the corrected intake is the error-free intake
  minus the effects of the error covariates (before: model fitted on error
  days only, fitted values used as intake).
* ADG is the stage weight difference divided by the days between the
  times the growth curve reaches the stage limits; every pig gets an
  `adg_type` (observed / extrapolated / partial / none).
* ADFI is computed over the same stage days as ADG; FCR = ADFI / ADG
  (`corrected_adg` was removed).
* A body weight of 0 is treated as missing. FIRE visits crossing midnight
  get the right exit time.
* Pigs seen at several stations are kept: transfer, split or misread.
* Entry / exit body weight limits now flag pigs as `low_confidence`
  instead of removing them.
* Robust regression uses bisquare weights (as in Jiao et al. 2014) instead
  of Huber weights.
* FCR confidence: a pig is `low_confidence` when the growth curve or the
  feed intake is extrapolated over more than `max_edge_extrap_days`
  (default 15) at either end of the stage, instead of whenever any
  extrapolation happens.
* Feed intake gaps longer than `long_gap_days` (default 7) are imputed with
  robust LOESS; `impute_method = "cumulative_loess"` and `impute_r2_min`
  were removed (the R2 of a cumulative curve is about 0.9 even for a
  constant intake, so it does not check anything). Use
  `impute_method = "loess"` instead.
* Nothing is removed silently: every result has a `removed` table with the
  step and the reason.

## Dependencies

* Removed: purrr, tidyr, lubridate, zoo, recipes, cAIC4, lme4, ggsci, vroom,
  mintyr.
* Imports are now cli, data.table, ggplot2, MASS, nlme, stats, utils and
  grDevices (MASS and nlme ship with R).
* Example data `nedap` and `fire` ship with the package.
