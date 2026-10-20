# Deprecated functions

These functions were renamed. They still work but give a warning; use
the new names instead:

|  |  |
|----|----|
| Old | New |
| `import_nedap()` | [`read_station()`](https://tony2015116.github.io/tidypptsda/reference/read_station.md) |
| `preprocess_data()` | [`prep_visits()`](https://tony2015116.github.io/tidypptsda/reference/prep_visits.md) |
| `clean_weight_get()` | [`clean_weight()`](https://tony2015116.github.io/tidypptsda/reference/clean_weight.md) |
| `adg_get()` | [`clean_weight()`](https://tony2015116.github.io/tidypptsda/reference/clean_weight.md) + [`calc_adg()`](https://tony2015116.github.io/tidypptsda/reference/calc_adg.md) |
| `adfi_get()` | [`calc_adfi()`](https://tony2015116.github.io/tidypptsda/reference/calc_adfi.md) |
| `fcr_get()` | [`calc_fcr()`](https://tony2015116.github.io/tidypptsda/reference/calc_fcr.md) |
| `adg_plot()` | [`plot_adg()`](https://tony2015116.github.io/tidypptsda/reference/plot_adg.md) + [`save_plots()`](https://tony2015116.github.io/tidypptsda/reference/save_plots.md) |
| `adfi_plot()` | [`plot_adfi()`](https://tony2015116.github.io/tidypptsda/reference/plot_adfi.md) + [`save_plots()`](https://tony2015116.github.io/tidypptsda/reference/save_plots.md) |

`my_break` maps to the QC parameter `stage_range`, `quiet = TRUE` to
`verbose = 0`, `print_details = TRUE` to `verbose = 2`. Other old
arguments are ignored with a warning; set them through
[`qc_config()`](https://tony2015116.github.io/tidypptsda/reference/qc_config.md).

## Usage

``` r
import_nedap(filepaths, ...)

preprocess_data(
  data,
  station_type = "nedap",
  print_details = FALSE,
  quiet = FALSE
)

clean_weight_get(data, my_break, print_details = FALSE, quiet = FALSE, ...)

adg_get(data, my_break, print_details = FALSE, quiet = FALSE, ...)

adfi_get(data, adg_res, station_type = NULL, quiet = FALSE)

fcr_get(adg_res, adfi_res, quiet = FALSE)

adg_plot(
  data,
  responders = NULL,
  locations = NULL,
  save_path = NULL,
  file_prefix = "loc",
  file_suffix = "grow",
  dpi = 300,
  device = "png",
  quiet = FALSE,
  ...
)

adfi_plot(
  data,
  responders = NULL,
  locations = NULL,
  save_path = NULL,
  file_prefix = "loc",
  file_suffix = "adfi",
  dpi = 300,
  device = "png",
  quiet = FALSE,
  ...
)
```

## Arguments

- filepaths, data, adg_res, adfi_res, station_type, my_break,
  responders, locations, save_path, file_prefix, file_suffix, dpi,
  device, print_details, quiet, ...:

  Arguments of the old functions.

## Value

The result of the new function.
