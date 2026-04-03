# Retrieve Fama-French three-factor data via tidyfinance

Downloads the Fama-French three-factor dataset from Tidy Finance.

## Usage

``` r
get_ff3_factors(start_date, end_date = Sys.Date())
```

## Arguments

- start_date:

  A `Date` or date string. Start of range.

- end_date:

  A `Date` or date string. End of range. Defaults to today.

## Value

A tibble with columns: `date`, `mkt_excess`, `smb`, `hml`, `risk_free`.

## Examples

``` r
if (FALSE) { # \dontrun{
get_ff3_factors("2020-01-01", "2023-12-31")
} # }
```
