# Retrieve historical adjusted prices via tidyquant

Downloads daily adjusted closing prices from Yahoo Finance for one or
more ticker symbols over a given date range.

## Usage

``` r
get_stock_prices(tickers, from, to = Sys.Date())
```

## Arguments

- tickers:

  A character vector of ticker symbols.

- from:

  A `Date` or date string (`"YYYY-MM-DD"`). Start of range.

- to:

  A `Date` or date string. End of range. Defaults to today.

## Value

A tibble with columns: `symbol`, `date`, `open`, `high`, `low`, `close`,
`volume`, `adjusted`.

## Examples

``` r
if (FALSE) { # \dontrun{
get_stock_prices(c("AAPL", "MSFT"), from = "2023-01-01")
} # }
```
