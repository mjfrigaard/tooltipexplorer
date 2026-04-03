# Outputs module server

Reacts to the fetch signal from
[`mod_inputs_server()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_inputs_server.md),
downloads adjusted price data via
[`get_stock_prices()`](https://mjfrigaard.github.io/tooltipexplorer/reference/get_stock_prices.md),
computes daily log returns with
[`get_stock_returns()`](https://mjfrigaard.github.io/tooltipexplorer/reference/get_stock_returns.md),
and summarises performance metrics with
[`summarise_performance()`](https://mjfrigaard.github.io/tooltipexplorer/reference/summarise_performance.md).
Renders all five tooltip-demo outputs (KPI boxes, bslib, shinyhelper,
prompter, shinyalert, reactable) and returns the reactive
performance-summary tibble for use by
[`mod_download_server()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_download_server.md).

## Usage

``` r
mod_outputs_server(id, inputs_r)
```

## Arguments

- id:

  Module namespace id.

- inputs_r:

  Reactive list returned by
  [`mod_inputs_server()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_inputs_server.md).

## Value

A reactive tibble with columns `symbol`, `ann_return`, `ann_vol`, and
`sharpe` — the output of
[`summarise_performance()`](https://mjfrigaard.github.io/tooltipexplorer/reference/summarise_performance.md).

## Details

Calls
[`shinyhelper::observe_helpers()`](https://rdrr.io/pkg/shinyhelper/man/observe_helpers.html)
internally — do **not** call it separately in
[`app_server()`](https://mjfrigaard.github.io/tooltipexplorer/reference/app_server.md).

## See also

[`mod_outputs_ui()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_outputs_ui.md)
