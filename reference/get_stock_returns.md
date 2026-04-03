# Compute daily log returns from price data

Calculates daily log returns from the adjusted closing price column
produced by
[`get_stock_prices()`](https://mjfrigaard.github.io/tooltipexplorer/reference/get_stock_prices.md).

## Usage

``` r
get_stock_returns(prices)
```

## Arguments

- prices:

  A tibble returned by
  [`get_stock_prices()`](https://mjfrigaard.github.io/tooltipexplorer/reference/get_stock_prices.md).

## Value

A tibble with columns `symbol`, `date`, `daily_return`.
