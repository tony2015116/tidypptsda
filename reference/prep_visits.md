# Prepare a standard visit table

Convert raw NEDAP or FIRE station data into a standard visit table with
the same columns and units for both station types.

## Usage

``` r
prep_visits(data, station = NULL, qc = qc_config(), verbose = 1)
```

## Arguments

- data:

  Raw station data, e.g. from
  [`read_station()`](https://tony2015116.github.io/tidypptsda/reference/read_station.md)
  or the example datasets
  [nedap](https://tony2015116.github.io/tidypptsda/reference/nedap.md)
  and
  [fire](https://tony2015116.github.io/tidypptsda/reference/fire.md).

- station:

  `"nedap"`, `"fire"` or `NULL` (default): taken from the `"station"`
  attribute set by
  [`read_station()`](https://tony2015116.github.io/tidypptsda/reference/read_station.md),
  or detected from the column names.

- qc:

  QC settings from
  [`qc_config()`](https://tony2015116.github.io/tidypptsda/reference/qc_config.md).
  Used here: `duration_max` (to tell a FIRE midnight crossing from a
  recording error) and the station transfer parameters `max_gap_days`,
  `max_overlap_days`, `max_jump_kg`.

- verbose:

  0 (silent), 1 (summary, default) or 2 (details).

## Value

A `data.table`, one row per visit, ordered by `location` and
`entry_time`:

- `responder`: pig ID (character, `NA` for unidentified visits);
  `responder_raw`: transponder number as recorded;

- `identified`: `FALSE` for visits without a transponder read;

- `location`: station (feeder) ID, character;

- `date`, `seq_days` (day number from the first day in the data, 1 =
  first day), `seq_in_day` (visit number of the pig that day),
  `seq_in_location` (visit number on the feeder that day);

- `entry_time`, `exit_time`: POSIXct, UTC; `duration`: seconds;

- `feed_intake`: g; `weight`: body weight, kg (`NA` if not recorded);

- `trough_in`, `trough_out`: trough weight at entrance and exit, g (FIRE
  only, `NA` for NEDAP); `topup`: feed dispensed, g (FIRE only);

- `source_file`, if present in the input.

Attributes:

- `"station"`: station type;

- `"stations"`: one row per pig with its station history (see below);

- `"removed"`: log of visits removed as transponder misreads;

- `"prep_summary"`: number of rows dropped at each step.

## Station transfer

For each pig seen at several stations, the time span at each station is
compared:

- **misread**: the span at a minor station overlaps the span at the main
  station (most visits) by more than `max_overlap_days`. Visits at the
  minor station inside the main span are removed as transponder
  misreads.

- **transfer**: consecutive spans are separated by at most
  `max_gap_days`. All visits are kept, each with its real `location`. A
  body weight jump above `max_jump_kg` at the transfer gives a warning.

- **split**: a gap longer than `max_gap_days`. The spans are treated as
  different animals and `responder` becomes `"<id>_<location>"`.

A pig that returns to a station it already used is not supported: the
return looks like an overlap and is treated as misreads.

## See also

[`read_station()`](https://tony2015116.github.io/tidypptsda/reference/read_station.md)
for the previous step.

## Examples

``` r
visits <- prep_visits(fire)
#> 
#> ── Preparing FIRE visits ───────────────────────────────────────────────────────
#> • Visits read: 9,794
#> • Unidentified visits (kept, identified = FALSE): 51
#> • FIRE visits crossing midnight (exit time corrected): 68
#> • Body weights of 0 set to NA: 478
#> • Rows without entry time (dropped): 0
#> • Duplicated rows (dropped): 0
#> ℹ No pig was seen at more than one station
#> ✔ 26 pigs at 2 stations, 9794 visits over 66 days
head(visits)
#>    responder responder_raw identified location       date seq_days seq_in_day
#>       <char>        <char>     <lgcl>   <char>     <Date>    <int>      <int>
#> 1:     35877         35877       TRUE      101 2023-12-19        1          1
#> 2:     35873         35873       TRUE      101 2023-12-19        1          1
#> 3:     35878         35878       TRUE      101 2023-12-19        1          1
#> 4:     35855         35855       TRUE      101 2023-12-19        1          1
#> 5:     35877         35877       TRUE      101 2023-12-19        1          2
#> 6:     35853         35853       TRUE      101 2023-12-19        1          1
#>    seq_in_location          entry_time           exit_time duration feed_intake
#>              <int>              <POSc>              <POSc>    <num>       <num>
#> 1:               1 2023-12-19 14:15:39 2023-12-19 14:18:02      143          46
#> 2:               2 2023-12-19 14:18:03 2023-12-19 14:23:05      302         248
#> 3:               3 2023-12-19 14:23:15 2023-12-19 14:28:45      330         201
#> 4:               4 2023-12-19 14:29:05 2023-12-19 14:34:29      324         121
#> 5:               5 2023-12-19 14:34:30 2023-12-19 14:34:37        7           0
#> 6:               6 2023-12-19 14:34:38 2023-12-19 14:36:26      108           0
#>    weight trough_in trough_out topup
#>     <num>     <num>      <num> <num>
#> 1:   67.6       678        632   286
#> 2:   60.8       632        384     0
#> 3:   70.8       670        469   286
#> 4:   51.2       755        634   286
#> 5:     NA       634        634     0
#> 6:   88.6       634        634     0

# Unidentified visits are kept for the feeder error checks
table(visits$identified)
#> 
#> FALSE  TRUE 
#>    51  9743 

# Station history of each pig
head(attr(visits, "stations"))
#>    responder responder_raw location_path main_location n_locations transfer
#>       <char>        <char>        <char>        <char>       <int>   <lgcl>
#> 1:     25822         25822           101           101           1    FALSE
#> 2:     35853         35853           101           101           1    FALSE
#> 3:     35855         35855           101           101           1    FALSE
#> 4:     35862         35862           101           101           1    FALSE
#> 5:     35865         35865           101           101           1    FALSE
#> 6:     35869         35869           101           101           1    FALSE
#>     split misreads_removed weight_jump_kg
#>    <lgcl>            <int>          <num>
#> 1:  FALSE                0             NA
#> 2:  FALSE                0             NA
#> 3:  FALSE                0             NA
#> 4:  FALSE                0             NA
#> 5:  FALSE                0             NA
#> 6:  FALSE                0             NA

# NEDAP data gets the same columns and units
nedap_visits <- prep_visits(nedap, verbose = 0)
summary(nedap_visits$weight)
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.     NAs 
#>   20.50   43.00   80.00   77.17  106.50  147.75     391 
```
