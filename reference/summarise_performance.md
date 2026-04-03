# Summarise performance metrics by ticker

Computes annualised return, annualised volatility, and Sharpe ratio
(assuming zero risk-free rate) for each ticker.

## Usage

``` r
summarise_performance(returns)
```

## Arguments

- returns:

  A tibble returned by
  [`get_stock_returns()`](https://mjfrigaard.github.io/tooltipexplorer/reference/get_stock_returns.md).

## Value

A tibble with columns: `symbol`, `ann_return`, `ann_vol`, `sharpe`.
