# Feed conversion ratio

Compute feed conversion ratio (FCR) from ADG and ADFI over the same body
weight stage, flag pigs whose values rely on extrapolation, and
summarise the traits.

## Usage

``` r
calc_fcr(adg, adfi, min_coverage = adg$settings$min_coverage, verbose = 1)
```

## Arguments

- adg:

  Result of
  [`calc_adg()`](https://tony2015116.github.io/tidypptsda/reference/calc_adg.md).

- adfi:

  Result of
  [`calc_adfi()`](https://tony2015116.github.io/tidypptsda/reference/calc_adfi.md)
  computed from the same `adg`.

- min_coverage:

  Minimum share of stage days with recorded feed intake for
  `fcr_flag = "ok"`. Default: `min_coverage` of the QC settings (0.7).

- verbose:

  0 (silent), 1 (summary, default) or 2 (details).

## Value

An object of class `ppt_fcr` (a list):

- `per_pig`: `adg` (g/d), `adfi` (g/d), `fcr`, `gf`, `adg_type`,
  `coverage`, `stage_days`, `start_weight`, `end_weight`, `fcr_flag`,
  `fcr_note`;

- `daily`: the daily table of
  [`calc_adfi()`](https://tony2015116.github.io/tidypptsda/reference/calc_adfi.md);

- `summary`: numeric summary (`n`, `min`, `max`, `median`, `mean`, `sd`,
  `cv`) of the main traits, for all pigs and for pigs with
  `fcr_flag = "ok"`;

- `removed`, `settings`.

## See also

[`calc_adg()`](https://tony2015116.github.io/tidypptsda/reference/calc_adg.md),
[`calc_adfi()`](https://tony2015116.github.io/tidypptsda/reference/calc_adfi.md).

## Examples

``` r
visits <- prep_visits(nedap, verbose = 0)
adg <- calc_adg(clean_weight(visits, verbose = 0), verbose = 0)
adfi <- calc_adfi(visits, adg, verbose = 0)
fcr <- calc_fcr(adg, adfi)
#> 
#> ── FCR over 30-120 kg ──────────────────────────────────────────────────────────
#> ℹ FCR for 29 pigs: 28 ok, 1 low confidence
#> ✔ Mean FCR 2.41 (SD 0.15), ADG 1160 g/d, ADFI 2801 g/d
head(fcr$per_pig[, .(responder, adg, adfi, fcr, fcr_flag, fcr_note)])
#>    responder       adg     adfi      fcr fcr_flag fcr_note
#>       <char>     <num>    <num>    <num>   <char>   <char>
#> 1:     13913 1171.8790 2616.719 2.232926       ok         
#> 2:     13918 1140.6265 2570.041 2.253183       ok         
#> 3:     13954  919.7008 2343.422 2.548026       ok         
#> 4:     13996 1265.9909 2857.824 2.257381       ok         
#> 5:     14962 1249.0465 2818.537 2.256551       ok         
#> 6:     15006 1270.5759 3084.452 2.427602       ok         
fcr$summary[group == "all"]
#>     group        trait     n          min          max       median
#>    <char>       <char> <int>        <num>        <num>        <num>
#> 1:    all          adg    29  788.2016246 1329.9939338 1195.4404810
#> 2:    all         adfi    29 1918.5410620 3517.5385488 2808.5847425
#> 3:    all          fcr    29    2.2266875    2.8288859    2.4117169
#> 4:    all           gf    29    0.3534961    0.4490976    0.4146424
#> 5:    all   stage_days    29   67.6694817   97.8579101   74.8865629
#> 6:    all start_weight    29   29.9999831   30.0000041   29.9999981
#> 7:    all   end_weight    29   84.5754696  120.0000029  119.9999988
#>            mean           sd           cv
#>           <num>        <num>        <num>
#> 1: 1159.9380965 1.240203e+02 1.069198e-01
#> 2: 2800.9155080 3.523560e+02 1.258003e-01
#> 3:    2.4144006 1.469139e-01 6.084903e-02
#> 4:    0.4156041 2.428400e-02 5.843061e-02
#> 5:   77.0849839 7.744381e+00 1.004655e-01
#> 6:   29.9999977 3.864205e-06 1.288068e-07
#> 7:  118.7784622 6.578170e+00 5.538184e-02
```
