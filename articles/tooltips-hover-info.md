# Tooltip and Hover-Info Explorer

**tooltipexplorer** is a Shiny application-package for demoing and
comparing tooltip and hover-info approaches in R using real financial
data from [Tidy Finance](https://www.tidy-finance.org/r/)
(`tidyfinance`) and
[tidyquant](https://business-science.github.io/tidyquant/).

------------------------------------------------------------------------

## Package structure

Each module lives in a single file containing both its `_ui()` and
`_server()` functions. All other exported objects have one file each.

    R/
    ├── app_server.R              # app_server()
    ├── app_set_log_threshold.R   # app_set_log_threshold()
    ├── app_ui.R                  # app_ui()
    ├── compute_rolling_vol.R     # compute_rolling_vol()
    ├── default_tickers.R         # default_tickers  (character vector)
    ├── get_ff3_factors.R         # get_ff3_factors()
    ├── get_stock_prices.R        # get_stock_prices()
    ├── get_stock_returns.R       # get_stock_returns()
    ├── launch.R                  # launch()
    ├── mod_download.R            # mod_download_ui()  +  mod_download_server()
    ├── mod_hoverinfo.R           # mod_hoverinfo()
    ├── mod_inputs.R              # mod_inputs_ui()    +  mod_inputs_server()
    ├── mod_outputs.R             # mod_outputs_ui()   +  mod_outputs_server()
    ├── mod_tooltip.R             # mod_tooltip()
    ├── summarise_performance.R   # summarise_performance()
    ├── utils_operators.R         # %||%
    └── with_logging.R            # with_logging()

------------------------------------------------------------------------

## Launching the app

``` r
tooltipexplorer::launch()
```

[`launch()`](https://mjfrigaard.github.io/tooltipexplorer/reference/launch.md)
calls `shiny::shinyApp(app_ui(), app_server)` and accepts `...`
forwarded to
[`shiny::shinyApp()`](https://rdrr.io/pkg/shiny/man/shinyApp.html)
(e.g. `options = list(port = 4000)`).

------------------------------------------------------------------------

## App architecture

### Entry points

| File           | Function                                                                               | Role                                                                                                    |
|----------------|----------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------|
| `launch.R`     | [`launch()`](https://mjfrigaard.github.io/tooltipexplorer/reference/launch.md)         | Creates and runs the Shiny app                                                                          |
| `app_ui.R`     | [`app_ui()`](https://mjfrigaard.github.io/tooltipexplorer/reference/app_ui.md)         | Top-level [`bslib::page_sidebar()`](https://rstudio.github.io/bslib/reference/page_sidebar.html) layout |
| `app_server.R` | [`app_server()`](https://mjfrigaard.github.io/tooltipexplorer/reference/app_server.md) | Wires all module servers together                                                                       |

### Reactive flow

    launch()
      └─ shinyApp(app_ui(), app_server)

    app_ui()
      ├─ mod_inputs_ui("inputs")       # sidebar: tickers, dates, vol window, fetch
      └─ mod_outputs_ui("outputs")     # main: KPI boxes + 5 demo tabs

    app_server()
      ├─ mod_inputs_server("inputs")   → inputs_r  (reactive list)
      ├─ mod_outputs_server("outputs", inputs_r)
      │    ├─ shinyhelper::observe_helpers()   # registered here, per session
      │    └─ returns perf_r  (reactive tibble)
      └─ mod_download_server("download", inputs_r, perf_r)

The download module UI (`mod_download_ui("download")`) is embedded at
the bottom of the inputs sidebar inside
[`mod_inputs_ui()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_inputs_ui.md);
its server is wired at the top level in
[`app_server()`](https://mjfrigaard.github.io/tooltipexplorer/reference/app_server.md).

------------------------------------------------------------------------

## Modules

All modules follow the `mod_<name>_ui()` / `mod_<name>_server()`
convention and are co-located in a single `mod_<name>.R` file.

### Inputs — `mod_inputs.R`

**`mod_inputs_ui(id)`** — returns a
[`bslib::sidebar()`](https://rstudio.github.io/bslib/reference/sidebar.html)
with:

- `selectizeInput` — ticker picker (multi-select, user-creatable)
- `dateRangeInput` — date range
- `sliderInput` — rolling-volatility window (5–120 trading days)
- `actionButton` — “Fetch data”
- [`mod_download_ui()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_download_ui.md)
  embedded at the bottom

**`mod_inputs_server(id)`** — returns a **reactive list**:

``` r
list(
  tickers    = character(),   # selected ticker symbols
  from       = Sys.Date(),    # start date
  to         = Sys.Date(),    # end date
  vol_window = 30L,           # rolling-vol window in days
  fetch      = integer()      # action button counter
)
```

### Outputs — `mod_outputs.R`

**`mod_outputs_ui(id)`** — returns a
[`shiny::tagList()`](https://rstudio.github.io/htmltools/reference/tagList.html)
containing:

- [`shiny::uiOutput`](https://rdrr.io/pkg/shiny/man/htmlOutput.html) —
  KPI value boxes (one per ticker)
- [`bslib::navset_card_tab()`](https://rstudio.github.io/bslib/reference/navset.html)
  — five demo tabs (see below)

**`mod_outputs_server(id, inputs_r)`** — triggered by
`inputs_r()$fetch`:

1.  Calls
    [`shinyhelper::observe_helpers()`](https://rdrr.io/pkg/shinyhelper/man/observe_helpers.html)
    once per session (registered here)
2.  Calls
    [`get_stock_prices()`](https://mjfrigaard.github.io/tooltipexplorer/reference/get_stock_prices.md)
    → `prices_r`
3.  Calls `get_stock_returns(prices_r())` → `returns_r`
4.  Calls `summarise_performance(returns_r())` → `perf_r`
5.  Renders all outputs (value boxes + five tabs)
6.  **Returns** `perf_r` for the download module

### Download — `mod_download.R`

**`mod_download_ui(id)`** — a
[`bslib::card()`](https://rstudio.github.io/bslib/reference/card.html)
with a format selector and `downloadButton`.

**`mod_download_server(id, inputs_r, perf_r)`** — renders a
parameterised `inst/report_template.Rmd` into HTML or PDF and serves it
via
[`shiny::downloadHandler()`](https://rdrr.io/pkg/shiny/man/downloadHandler.html).

------------------------------------------------------------------------

## Data utilities

Financial data is fetched and processed through four functions:

| File                      | Function                                | Description                                                                                                           |
|---------------------------|-----------------------------------------|-----------------------------------------------------------------------------------------------------------------------|
| `get_stock_prices.R`      | `get_stock_prices(tickers, from, to)`   | Daily adjusted prices via [`tidyquant::tq_get()`](https://business-science.github.io/tidyquant/reference/tq_get.html) |
| `get_stock_returns.R`     | `get_stock_returns(prices)`             | Daily log returns: `log(adjusted / lag(adjusted))`                                                                    |
| `compute_rolling_vol.R`   | `compute_rolling_vol(returns, window)`  | Rolling annualised volatility via [`slider::slide_dbl()`](https://slider.r-lib.org/reference/slide.html)              |
| `summarise_performance.R` | `summarise_performance(returns)`        | Per-ticker ann. return, ann. vol, Sharpe ratio                                                                        |
| `get_ff3_factors.R`       | `get_ff3_factors(start_date, end_date)` | Fama-French 3-factor data via `tidyfinance`                                                                           |
| `default_tickers.R`       | `default_tickers`                       | Character vector of default mega-cap tickers                                                                          |

### Example usage outside Shiny

``` r
library(tooltipexplorer)

prices  <- get_stock_prices(c("AAPL", "MSFT"), from = "2024-01-01")
returns <- get_stock_returns(prices)
perf    <- summarise_performance(returns)
vol     <- compute_rolling_vol(returns, window = 30L)
```

------------------------------------------------------------------------

## Tooltip helpers

Two helper functions provide a uniform interface for attaching tooltip
and hover content across all five back-ends.

### `mod_tooltip()`

A **UI helper** (in `mod_tooltip.R`) — returns a `shiny.tag` with no
server-side counterpart. Place it anywhere inside a UI tree, including
inside `renderUI()`.

``` r
mod_tooltip(
  trigger     = bsicons::bs_icon("info-circle"),  # default
  type        = c("bslib", "shinyhelper", "prompter", "shinyalert"),
  contents    = "",
  size        = NULL,       # CSS font-size for the wrapper span
  style       = NULL,       # extra inline CSS for the wrapper span
  helper_type = "inline",   # "inline" | "markdown"  (shinyhelper only)
  helper_size = "m",        # "s" | "m" | "l"        (shinyhelper only)
  alert_type  = "info",     # "info"|"success"|"warning"|"error" (shinyalert only)
  ...                       # forwarded to the back-end function
)
```

| `type`          | Back-end                                                                     | Interaction | Extra `...` args                                              |
|-----------------|------------------------------------------------------------------------------|-------------|---------------------------------------------------------------|
| `"bslib"`       | [`bslib::popover()`](https://rstudio.github.io/bslib/reference/popover.html) | Click       | `title`, `placement`                                          |
| `"shinyhelper"` | [`shinyhelper::helper()`](https://rdrr.io/pkg/shinyhelper/man/helper.html)   | Click       | `title`, `colour`, `icon`, `buttonLabel`, `easyClose`, `fade` |
| `"prompter"`    | [`prompter::add_prompt()`](https://rdrr.io/pkg/prompter/man/add_prompt.html) | Hover       | `position`, `rounded`, `bounce`, `arrow`, `animate`           |
| `"shinyalert"`  | `data-sa-*` attrs + delegated JS                                             | Click       | `title`, `confirmButtonText`                                  |

#### bslib example

``` r
mod_tooltip(
  type     = "bslib",
  contents = "Annualised log return = mean daily log return \u00d7 252.",
  title    = "Ann. Return"
)
```

#### shinyhelper example

``` r
mod_tooltip(
  trigger     = shiny::tags$span("Sharpe Ratio"),
  type        = "shinyhelper",
  contents    = c("Sharpe Ratio", "Assumes a zero risk-free rate."),
  helper_type = "inline",
  helper_size = "m",
  title       = "Sharpe Ratio"
)
```

#### prompter example

``` r
mod_tooltip(
  trigger  = shiny::tags$span("Ann. Vol"),
  type     = "prompter",
  contents = "Annualised volatility = SD of daily log returns \u00d7 \u221a252.",
  position = "right"
)
```

#### shinyalert example

The `shinyalert` back-end stores content in `data-sa-*` attributes and
fires on click via a delegated `jQuery` handler injected once in
[`app_ui()`](https://mjfrigaard.github.io/tooltipexplorer/reference/app_ui.md).

***EXAMPLE: i.e., in `app_ui.R`:***

``` r
shiny::tags$script(shiny::HTML("
   $(document).on('click', '[data-sa-title]', function() { ... });
"))
```

No `observeEvent()` or server handler is needed:

``` r
mod_tooltip(
  trigger           = shiny::tags$span(class = "fs-4 fw-bold", "AAPL"),
  type              = "shinyalert",
  contents          = "Ann. Return: 14.2%<br>Ann. Vol: 22.1%<br>Sharpe: 0.64",
  title             = "AAPL \u2013 Performance Summary",
  alert_type        = "info",
  confirmButtonText = "Close"
)
```

------------------------------------------------------------------------

### `mod_hoverinfo()`

A **rendering helper** (in `mod_hoverinfo.R`) — formats hover content
for back-ends that build tooltips programmatically inside table-cell
renderers.

``` r
mod_hoverinfo(
  type     = "reactable",   # currently the only supported back-end
  contents = character(0),  # tooltip text; named vector → "Name: value" pairs
  display  = NULL,          # visible cell value (child node of the <span>)
  size     = NULL,          # CSS font-size
  style    = NULL,          # inline CSS (e.g. "color:#198754; cursor:help")
  ...                       # extra HTML attributes on the <span>
)
```

Returns an `htmltools` `<span>` with a `title` attribute — browsers
render this as a native tooltip on hover. Use inside
`reactable::colDef(cell = ..., html = TRUE)`.

``` r
reactable::colDef(
  name = "Ann. Return (%)",
  html = TRUE,
  cell = function(value, index) {
    mod_hoverinfo(
      type     = "reactable",
      contents = glue::glue("Annualised log return for {df$symbol[index]}: {value}%"),
      display  = glue::glue("{value}%"),
      style    = paste0(
        "color:", if (value >= 0) "#198754" else "#dc3545",
        "; cursor:help"
      )
    )
  }
)
```

------------------------------------------------------------------------

## Logging utilities

| File                      | Function                          | Description                                           |
|---------------------------|-----------------------------------|-------------------------------------------------------|
| `app_set_log_threshold.R` | `app_set_log_threshold(level)`    | Sets `logger` threshold across all package namespaces |
| `with_logging.R`          | `with_logging(expr, context, ns)` | `tryCatch` wrapper that logs warnings and errors      |
| `utils_operators.R`       | `%||%`                            | Null-coalescing operator                              |

[`app_set_log_threshold()`](https://mjfrigaard.github.io/tooltipexplorer/reference/app_set_log_threshold.md)
is called once in
[`app_server()`](https://mjfrigaard.github.io/tooltipexplorer/reference/app_server.md)
at session start. Pass
[`logger::DEBUG`](https://daroczig.github.io/logger/reference/log_levels.html)
during development for verbose output:

``` r
# In app_server(), or interactively:
app_set_log_threshold(logger::DEBUG)
```

------------------------------------------------------------------------

## Decision guide

| Where does the tooltip appear?  | Use                                                                                          | `type`          |
|---------------------------------|----------------------------------------------------------------------------------------------|-----------------|
| Input label / icon in sidebar   | [`mod_tooltip()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_tooltip.md)     | `"bslib"`       |
| Metric card with help modal     | [`mod_tooltip()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_tooltip.md)     | `"shinyhelper"` |
| Metric label — CSS hover        | [`mod_tooltip()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_tooltip.md)     | `"prompter"`    |
| Clickable element → modal alert | [`mod_tooltip()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_tooltip.md)     | `"shinyalert"`  |
| reactable table cell            | [`mod_hoverinfo()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_hoverinfo.md) | `"reactable"`   |
