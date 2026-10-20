# Read feeding station export files

Read one or more CSV exports from NEDAP or FIRE feeding stations and
combine them into one table.

## Usage

``` r
read_station(
  files,
  station = NULL,
  pattern = "\\.csv$",
  fill = FALSE,
  verbose = 1,
  ...
)
```

## Arguments

- files:

  Character vector of file paths, or a single folder. For a folder, all
  files matching `pattern` are read.

- station:

  `"nedap"`, `"fire"` or `NULL` (default) to detect the station type
  from the column names.

- pattern:

  Regular expression for file names when `files` is a folder. Default
  `"\\.csv$"` (case-insensitive).

- fill:

  If `FALSE` (default), all files must have the same columns. If `TRUE`,
  missing columns are filled with `NA`.

- verbose:

  0 (silent), 1 (summary, default) or 2 (details per file).

- ...:

  Further arguments passed to
  [`data.table::fread()`](https://rdrr.io/pkg/data.table/man/fread.html).

## Value

A `data.table` with the original columns plus `source_file` (file name
without folder). Its attribute `"station"` holds the station type.

## Details

Required columns:

- NEDAP: `responder`, `location`, `visit_time`, `duration`, `weight`,
  `feed_intake`.

- FIRE: `Location`, `Tag`, `Date`, `Entry`, `Exit`, `Ent Wt`, `Ext Wt`,
  `Consumed`, `Weight`.

Transponder and animal ID columns (`responder`, `animal_number`,
`lifenumber`, `Tag`) are read as character.

## Examples

``` r
# Write the example data to two CSV files, then read them back
folder <- file.path(tempdir(), "fire_export")
dir.create(folder, showWarnings = FALSE)
data.table::fwrite(fire[fire$Location == 101, ], file.path(folder, "fire_101.csv"))
data.table::fwrite(fire[fire$Location == 102, ], file.path(folder, "fire_102.csv"))

raw <- read_station(folder)
#> 
#> ── Reading 2 files ─────────────────────────────────────────────────────────────
#> ℹ Detected station type "fire"
#> ✔ Read 9794 rows from 2 files (FIRE)
table(raw$source_file)
#> 
#> fire_101.csv fire_102.csv 
#>         6014         3780 
attr(raw, "station")
#> [1] "fire"

unlink(folder, recursive = TRUE)
```
