# Package index

## App

Entry points for creating and running the Shiny application.

- [`launch()`](https://mjfrigaard.github.io/tooltipexplorer/reference/launch.md)
  : Launch the Tooltip Explorer Shiny app
- [`app_ui()`](https://mjfrigaard.github.io/tooltipexplorer/reference/app_ui.md)
  : Application UI
- [`app_server()`](https://mjfrigaard.github.io/tooltipexplorer/reference/app_server.md)
  : Application server

## Modules

Shiny modules following the `mod_<name>_ui()` / `mod_<name>_server()`
convention. Each pair is co-located in a single `mod_<name>.R` file.

- [`mod_inputs_ui()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_inputs_ui.md)
  : Inputs module UI
- [`mod_inputs_server()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_inputs_server.md)
  : Inputs module server
- [`mod_outputs_ui()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_outputs_ui.md)
  : Outputs module UI
- [`mod_outputs_server()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_outputs_server.md)
  : Outputs module server
- [`mod_download_ui()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_download_ui.md)
  : Download module UI
- [`mod_download_server()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_download_server.md)
  : Download module server

## Tooltip helpers

UI and rendering helpers for attaching tooltip and hover content.
[`mod_tooltip()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_tooltip.md)
targets UI elements;
[`mod_hoverinfo()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_hoverinfo.md)
targets `reactable` table cells.

- [`mod_tooltip()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_tooltip.md)
  : Tooltip module
- [`mod_hoverinfo()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_hoverinfo.md)
  : Hover-info module

## Logic

Financial data retrieval and transformation functions.

- [`get_stock_prices()`](https://mjfrigaard.github.io/tooltipexplorer/reference/get_stock_prices.md)
  : Retrieve historical adjusted prices via tidyquant
- [`get_stock_returns()`](https://mjfrigaard.github.io/tooltipexplorer/reference/get_stock_returns.md)
  : Compute daily log returns from price data
- [`get_ff3_factors()`](https://mjfrigaard.github.io/tooltipexplorer/reference/get_ff3_factors.md)
  : Retrieve Fama-French three-factor data via tidyfinance
- [`compute_rolling_vol()`](https://mjfrigaard.github.io/tooltipexplorer/reference/compute_rolling_vol.md)
  : Compute rolling annualised volatility
- [`summarise_performance()`](https://mjfrigaard.github.io/tooltipexplorer/reference/summarise_performance.md)
  : Summarise performance metrics by ticker
- [`default_tickers`](https://mjfrigaard.github.io/tooltipexplorer/reference/default_tickers.md)
  : Default stock tickers available in the app

## Utilities

Logging helpers and operators.

- [`app_set_log_threshold()`](https://mjfrigaard.github.io/tooltipexplorer/reference/app_set_log_threshold.md)
  : Set the application-wide log threshold
- [`with_logging()`](https://mjfrigaard.github.io/tooltipexplorer/reference/with_logging.md)
  : Execute an expression with structured error and warning logging
- [`` `%||%` ``](https://mjfrigaard.github.io/tooltipexplorer/reference/grapes-or-or-grapes.md)
  : Null-coalescing operator
