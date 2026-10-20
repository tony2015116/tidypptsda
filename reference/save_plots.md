# Save plots to files

Save plots to files

## Usage

``` r
save_plots(
  plots,
  path,
  prefix = "station",
  suffix = "plot",
  device = c("png", "pdf", "jpeg", "tiff"),
  dpi = 300,
  width = NULL,
  height = NULL,
  verbose = 1
)
```

## Arguments

- plots:

  Result of
  [`plot_adg()`](https://tony2015116.github.io/tidypptsda/reference/plot_adg.md)
  or
  [`plot_adfi()`](https://tony2015116.github.io/tidypptsda/reference/plot_adfi.md).

- path:

  Folder to write to (created if needed).

- prefix, suffix:

  File name parts: `<prefix>_<location>_<suffix>.<device>`.

- device:

  `"png"`, `"pdf"`, `"jpeg"` or `"tiff"`.

- dpi:

  Resolution for bitmap devices. Default 300.

- width, height:

  Size in cm. By default computed from the number of panels.

- verbose:

  0 (silent), 1 (summary, default).

## Value

Invisibly, a `data.table` with `location`, `file` and `saved`.
