## R CMD check results

0 errors | 0 warnings | 0 notes

* This is an update of a package already on CRAN (1.6.4). It fixes the
  website links and removes an internal vignette; no change to the methods.

## Test environments

* local: Windows 11, R 4.6.1
* Linux (Ubuntu), R 4.3.3, with `--as-cran`
* win-builder: R-devel, R-release

## Notes

* Possibly misspelled words in DESCRIPTION (Jiao, et al.): "Jiao" is an
  author name and "et al." is part of the references
  (Casey et al. 2005, Jiao et al. 2014).
* Examples of `validate_outliers()`, `validate_truncation()` and
  `write_report()` run longer and are wrapped in `\donttest{}`; with
  `--run-donttest` each takes less than 5 s.
