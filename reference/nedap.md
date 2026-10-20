# NEDAP feeding station visits

Raw visit records exported from two NEDAP feeding stations.

## Usage

``` r
nedap
```

## Format

A data frame with 31,863 rows and 9 columns:

- animal_number:

  Full animal number.

- lifenumber:

  Life number (empty in this export).

- responder:

  Transponder number. `NA` for visits where no transponder was read
  (unidentified visits, 211 rows).

- location:

  Station (feeder) number, 101 or 102.

- visit_time:

  Entrance time, POSIXct in UTC.

- duration:

  Occupation time of the visit in seconds.

- state:

  Station state code.

- weight:

  Body weight in grams. `0` means no valid weight.

- feed_intake:

  Feed intake of the visit in grams.

## Source

Pig performance testing station, 2024-02-19 to 2024-05-25, 30 pigs.
