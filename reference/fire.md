# FIRE feeding station visits

Raw visit records exported from two FIRE (Osborne) feeding stations.

## Usage

``` r
fire
```

## Format

A data frame with 9,794 rows and 10 columns:

- Location:

  Station (feeder) number, 101 or 102.

- Tag:

  Transponder number. `0` for unidentified visits (51 rows).

- Date:

  Visit date, `"YYYY-MM-DD"`.

- Entry, Exit:

  Entrance and exit clock time, `"HH:MM:SS"`. A visit that crosses
  midnight has `Exit < Entry` (68 rows).

- Ent Wt, Ext Wt:

  Feed trough weight at entrance and exit, kg.

- Consumed:

  Feed intake of the visit, kg.

- Weight:

  Body weight, kg. `0` means no valid weight.

- Topup Amount:

  Feed dispensed into the trough during the visit, kg.

## Source

Pig performance testing station, 2023-12-19 to 2024-02-22, 26 pigs.
