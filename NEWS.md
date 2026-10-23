# tidypptsda 0.9.1

* `plot_cfi()` plots the cumulative feed intake of the national method
  against body weight, one plot per station: kept stage days, removed
  weight classes shaded, and the line whose slope is the FCR (dashed where
  extended by the regression). The national `calc_fcr()` result gains `$cfi`
  (every stage day with its class, whether it is kept and the cumulative
  intake).
* Fixed: with `impute_method = "national"`, imputed days could get the wrong
  `state` (`iii` / `elrp`); the imputed values were right.

# tidypptsda 0.9.0

## National method

* `qc_config("national")` now implements the national FCR procedure
  (chapter 6 "FCR raw data processing") as a whole pipeline
  (`method = "national"`), replacing the earlier, unverified LOESS-based
  preset. Body weights: range 20-140 kg; rlm (bisquare) weights <= 0.25
  removed (`rlm_cutoff`); a day whose records all have rlm weights < 0.90 is
  removed (`day_weight_min`, `qc_flag = "day_weight"`); daily weight = mean
  weighted by the rlm weights (`daily_weight = "weighted_mean"`); pigs with
  a daily-weight R² (quadratic) < 0.995 (`daily_r2_min`), a test shorter
  than 40 days or more than 10% of days without feed (`max_feed_missing`)
  are removed. Feed errors and their correction are those of the package;
  missing days are imputed by LOESS for gaps of up to 3 days and by a
  regression of intake on body weight for longer gaps
  (`impute_method = "national"`). `calc_fcr()` then removes 10 kg classes
  with a gain below `bin_min_gain_kg` (6 kg) or an FCR outside table 5
  (`bin_fcr_limits`), removes pigs with a removed class between kept ones,
  regresses cumulative feed intake on body weight (pigs with R² <=
  `cfi_r2_min`, 0.95, removed), extends it to the stage limits and computes
  FCR = (CFI at the upper limit - CFI at the lower limit) / stage width.
  New `per_pig` columns `cfi_start`, `cfi_end`, `cfi_r2`, `cfi_slope`,
  `weight_first`, `weight_last`, `extrap_kg_start`, `extrap_kg_end`,
  `n_classes`, `n_classes_removed`; `by_bin$removed`.

## ADG

* New QC parameter `adg_method`: `"lm"` (new default) uses the slope of a
  linear regression of all valid weights between the stage start and end
  times (with its R² in `r_squared`); `"curve"` uses the stage weight
  difference / days of the growth curve (the earlier default). Both are
  reported (`lm_slope`, `adg_curve`); `adg_source` tells which one `adg`
  is; `lm_weight_from` / `lm_weight_to` give the weight range covered by
  the regression.

## Body weight

* New QC parameter `adapt_days` (default 7): weights of the first 7 days
  after a pig's first visit are not used (`qc_flag = "adaptation"`). Their
  feed intake still counts when these days lie inside `stage_range`, and
  not when the pig is below it.
* New per-pig columns `r2_daily` and `feed_missing`; records keep their rlm
  weight in `rlm_w`.

## Documentation

* New Chinese article "输出结果说明" describing every output table and
  column. The parameter and preset articles describe the national method,
  `adapt_days`, `adg_method` and how `stage_range` drives every step.

# tidypptsda 0.8.0

## Body weight: tracking from the end of the test

* `clean_weight()` now tracks the weight of each pig back from the end of the
  test (`weight_track = TRUE`, default in all three presets). The scale only
  counts a pig standing on it with all four feet, so readings are rarely too
  light; early in the test, when pigs are small, several of them fit into the
  station and readings are too heavy. At the end only one pig fits, so the
  last days are the most reliable. Starting from the median of the last 3
  recorded days and the gain of the last 14 days, the weight is tracked back
  day by day; records more than `track_tol` (default 8%, at least 2 kg) from
  the expected weight are removed (`qc_flag = "track"`). The gain is
  updated from the kept weights of the next 10 days, so slow growth after
  entry is followed. Kept records are not overruled by the outlier methods,
  which are still used for pigs that are not tracked (less than 7 recorded
  days or a test shorter than 14 days) and with `weight_track = FALSE`.
* Pigs whose tracking removes more than `track_flag_share` (default 40%) of
  the records are flagged as low confidence: a possible weighing fault such
  as a faulty load cell. New `per_pig` column `track_removed`.
* The tracking replaces the double-layer check and the tracking after
  entry of 0.7.0, which chose the wrong layer when the early readings of
  several pigs formed the majority. Removed QC parameters:
  `double_layer_gap`, `double_layer_min_share`, `double_layer_flag_weeks`,
  `entry_noise_days`, `entry_noise_iqr_kg`, `entry_noise_tol`,
  `entry_noise_flag_days`; removed `per_pig` columns `n_weeks`,
  `double_layer_weeks`, `entry_noise_days`, `entry_noise_kept`.
* `validate_outliers()` compares `"track"` with the other methods (which run
  without tracking).

## ADG

* New QC parameter `curve_margin_kg` (default `NULL` = all records): fit the
  growth curve only to the records from the last day below
  `stage_range[1] - curve_margin_kg` to the first day above
  `stage_range[2] + curve_margin_kg` (cut by time). Slow growth for weeks
  after entry then no longer bends the curve and pulls the stage start
  earlier. With 5 kg, the mean difference between ADG and `lm_slope` drops
  from 29 to 19 g/d on the NEDAP example. New `per_pig` columns
  `curve_start` and `curve_end`.

## Website

* "Get started" and "News" are now in the navigation bar.

# tidypptsda 0.7.0

## Body weight

* `clean_weight()` detects **double-layer weights** before the outlier
  methods: within each week, records are split into two groups; when both are
  tight bands that differ by at least `double_layer_gap` (default 8%) of the
  upper weight and the smaller one holds at least `double_layer_min_share`
  (default 15%) of the records, the layer that does not continue the pig's
  growth in the other weeks is removed (`qc_flag = "double_layer"`). Pigs
  with two layers in at least `double_layer_flag_weeks` (default 3) weeks are
  flagged as low confidence (possibly two pigs on one transponder). Before,
  when both layers were about equally large, the curve ran between them and
  the daily median jumped from one layer to the other. New `per_pig`
  columns `n_weeks` and `double_layer_weeks`. Set `double_layer_gap = NULL`
  to switch it off.

* `clean_weight()` also handles **unstable weights after entry**: new pigs
  often show a wide smear of readings for days (pen mates' weights mixed in
  while the pig itself hardly eats and may lose weight). Within
  `entry_noise_days` (default 21) after the first record, days whose
  interquartile range exceeds `entry_noise_iqr_kg` (default 3 kg) and 4 times
  the pig's usual range are unstable; the period runs from entry to the last
  such day as long as at least half of the days are unstable. From the
  stable days after it, the weight is tracked back day by day and only
  records within `entry_noise_tol` (default 8%, at least 2 kg) of the next
  day's weight are kept (`qc_flag = "entry_noise"`); the curve methods do
  not overrule the kept records. Pigs with a period longer than
  `entry_noise_flag_days` (default 14) or less than 30% of its records kept
  are flagged as low confidence. New `per_pig` columns `entry_noise_days`
  and `entry_noise_kept`.

## ADG

* The stage now starts at the **last** time the growth curve rises through
  the lower stage weight before it first reaches the upper one. Before, a
  curve that passed 30 kg, dipped below and rose again started the stage at
  the first pass (only possible with flexible curves: poly3, loess).
* `lm_slope` is now the regression on all valid records between the stage
  start and end times, instead of on the records whose weight lies inside
  `stage_range`. A dip below 30 kg after the start no longer leaves a few
  isolated early records in the regression.

On the example data ADG changes by 2 g/d on average; pig 15961 (wide smear
of readings for two weeks after entry) changes most, from 1211 to 1320 g/d.

# tidypptsda 0.6.1

## Bug fixes

* Visit times given as POSIXct in a time zone other than UTC (for example
  read from a database as Asia/Shanghai) were split into days at 00:00 UTC,
  i.e. 08:00 Beijing time: on the example data 27% of visits got the
  previous day's date and ADFI changed by up to 50 g/d. Clock times are now
  kept, so a day always runs from 00:00 to 24:00 local time.
* `calc_adg()` failed with a cryptic data.table error when `clean_weight()`
  had removed every pig (e.g. a test period that is too short); it now says
  so and lists the most common reasons.
* `calc_fcr()` printed R warnings (`no non-missing arguments to min`) when no
  body weight record fell inside `stage_range`.
* With `cores > 1` on Linux/macOS, stopping a run (Esc / Ctrl+C, or an error)
  left the worker processes running in the background; they are now stopped.

# tidypptsda 0.6.0

## Validation

* `validate_outliers()` adds artificial errors to clean body weight records
  and reports, for each outlier method, the share of errors found
  (`sensitivity`), the share of good records removed, precision and the
  effect on ADG. `direction = "down"` checks weights that are too low only.
* `validate_adg()` compares growth curve models by k-fold cross-validation
  on recorded days, and by how much ADG changes when the first or last days
  are hidden (late entry, early exit).
* `validate_adfi()` hides recorded feed intake days (random days, blocks,
  start or end of the stage), imputes them again and compares ADFI with the
  recorded value.
* All three take `seed`, `max_pigs` (random sample of pigs for large data)
  and `cores`, show a progress bar, and return `$summary` plus per-pig
  details. New Chinese article "方法验证".

## Progress

* The progress bar of `clean_weight()`, `calc_adg()`, `calc_adfi()` and
  `save_plots()` is now also shown with `cores > 1`. On Linux/macOS one
  process per core is started and the bar moves while it works; on Windows
  the bar moves after each of 10 chunks.
* With `cores > 1`, the function sent to the workers no longer carries the
  data of all pigs (faster start-up, less memory).

# tidypptsda 0.5.0

## Faster on large data

* The feed-intake correction model is fitted by a built-in REML routine for
  the random-intercept model (profiled likelihood over the variance ratio,
  computed from cross-products). Estimates, standard errors and p values are
  the same as `nlme::lme()` (difference < 0.001 g), but on 1.75 million visits
  `calc_adfi()` takes 9 s instead of 66 s. `nlme` is no longer a dependency.
* `daily_error_covariates()` (used by `calc_adfi()`) is vectorised: 39 s to
  1.6 s on the same data. Polynomial growth curves are evaluated directly
  instead of through `predict()`, and outlier reasons are built column-wise:
  `clean_weight()` 27 s to 18 s, `calc_adg()` 18 s to 12 s.
  Results are unchanged.

* Plots are built from their own station's data only. Before, every plot
  kept a reference to all pigs' records (about 177 MB per plot when serialised
  on 1.75 million visits, now about 6 MB), which made parallel export and
  `saveRDS()` of plots slow.
* `save_plots()` gains `cores` to save stations in parallel (fork on
  Linux/macOS, a PSOCK cluster on Windows) and shows a progress bar.
  Drawing takes about 1–1.5 s per station of 15 pigs.

## Messages

* Situations that need attention (pigs not reaching the stage end, weight
  jumps at a transfer, pigs missing from the breed table, too much
  unidentified feed, a failed correction model, unknown pigs in plots) are now
  shown at once as cli alerts instead of R warnings printed only after the call
  has finished. Use `verbose = 0` to hide them, or `suppressMessages()`.
* data.table's own "Processed ... groups" progress output is switched off
  inside the package; long per-pig steps show a cli progress bar instead.

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
