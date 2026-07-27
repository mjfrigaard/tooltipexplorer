# Structure

``` r

library(tooltipexplorer)
#> 
#> Attaching package: 'tooltipexplorer'
#> The following object is masked from 'package:base':
#> 
#>     %||%
```

## Module Wiring

`tooltipexplorer` is organized as a collection of Shiny modules, wired
together in
[`app_server()`](https://mjfrigaard.github.io/tooltipexplorer/reference/app_server.md).
Every module follows the same file-and-function layout:

| File | UI function | Server function |
|----|----|----|
| `R/mod_inputs.R` | `mod_inputs_ui(id)` | `mod_inputs_server(id)` |
| `R/mod_outputs.R` | `mod_outputs_ui(id)` | `mod_outputs_server(id, inputs_r)` |
| `R/mod_download.R` | `mod_download_ui(id)` | `mod_download_server(id, inputs_r, perf_r)` |

The two tooltip helpers
([`mod_tooltip()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_tooltip.md)
and
[`mod_hoverinfo()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_hoverinfo.md))
are *not* modules in the Shiny sense; they have no server counterpart
and no `moduleServer()` call. They are UI / rendering helpers that
happen to share the `mod_` prefix for discoverability.

[`app_ui()`](https://mjfrigaard.github.io/tooltipexplorer/reference/app_ui.md)
composes the three UI functions into a
[`bslib::page_sidebar()`](https://rstudio.github.io/bslib/reference/page_sidebar.html)
layout. The download module UI is embedded *inside* the inputs sidebar
rather than at the top level, so the sidebar contains all user controls
in one place.

``` r

app_ui <- function() {
  bslib::page_sidebar(
    sidebar = mod_inputs_ui("inputs"),   # sidebar: includes mod_download_ui()
    mod_outputs_ui("outputs")            # main panel
  )
}
```

[`app_server()`](https://mjfrigaard.github.io/tooltipexplorer/reference/app_server.md)
wires the three server functions together. The outputs server returns a
reactive (`perf_r`) that the download server consumes — the only
inter-module dependency:

``` r

app_server <- function(input, output, session) {
  app_set_log_threshold(logger::INFO)

  inputs_r <- mod_inputs_server("inputs")
  perf_r   <- mod_outputs_server("outputs", inputs_r)
             mod_download_server("download", inputs_r, perf_r)
}
```

The reactive data flow is strictly top-down:

    mod_inputs_server()  ──► inputs_r  ──► mod_outputs_server()  ──► perf_r  ──► mod_download_server()

No module reaches up into its parent or sideways into a sibling.

------------------------------------------------------------------------

## File Structure

### R/ Directory (Core Implementation)

#### Module Functions

1.  **`mod_inputs.R`**
    - **Lines**: 162
    - **Exports**: `mod_inputs_ui(id)`, `mod_inputs_server(id)`
    - **Key Features**: ticker picker, date range, rolling-vol slider,
      fetch button, embedded
      [`mod_download_ui()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_download_ui.md);
      fetch-button observer and reactive inputs list on the server side
2.  **`mod_outputs.R`**
    - **Lines**: 542
    - **Exports**: `mod_outputs_ui(id)`,
      `mod_outputs_server(id, inputs_r)`
    - **Key Features**:
      - Five tooltip/hover demo tabs (bslib, shinyhelper, prompter,
        shinyalert, reactable)
      - Reactive data pipeline (prices → returns → performance)
      - KPI value boxes with color-coded Sharpe ratios
3.  **`mod_download.R`**
    - **Lines**: 161
    - **Exports**: `mod_download_ui(id)`,
      `mod_download_server(id, inputs_r, perf_r)`
    - **Key Features**: HTML/PDF report generation via a parameterised R
      Markdown template, rendered into an isolated temp directory

#### App-Level Functions

4.  **`app_ui.R`**
    ([`app_ui()`](https://mjfrigaard.github.io/tooltipexplorer/reference/app_ui.md))
    - **Lines**: 108
    - **Purpose**: Top-level UI composition
    - **Pattern**: Calls each module’s UI function and composes them
      into
      [`bslib::page_sidebar()`](https://rstudio.github.io/bslib/reference/page_sidebar.html)
    - **Features**: Custom theme
      ([`tooltipexplorer_theme()`](https://mjfrigaard.github.io/tooltipexplorer/reference/tooltipexplorer_theme.md)),
      `tooltipexplorer_head()` CSS injection, delegated event handlers
      for shinyalert/shinyhelper
5.  **`app_server.R`**
    ([`app_server()`](https://mjfrigaard.github.io/tooltipexplorer/reference/app_server.md))
    - **Lines**: 57
    - **Purpose**: Top-level server orchestration
    - **Pattern**: Calls each module’s server function and wires the
      reactive dependencies between them
    - **Features**: Logging threshold setup, shinyhelper initialization,
      session lifecycle logging
6.  **`launch.R`**
    ([`launch()`](https://mjfrigaard.github.io/tooltipexplorer/reference/launch.md))
    - **Lines**: 28
    - **Purpose**: Convenience wrapper for launching the Shiny app
    - **Features**: Installs the reactable theme globally, supports
      passing custom options to
      [`shiny::shinyApp()`](https://rdrr.io/pkg/shiny/man/shinyApp.html)

#### Helper/Utility Functions

7.  **`mod_tooltip.R`**
    ([`mod_tooltip()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_tooltip.md))
    - **Lines**: 205
    - **Type**: Pure UI helper function (no paired server)
    - **Purpose**: Unified interface for four tooltip backends — bslib,
      shinyhelper, prompter, shinyalert
8.  **`mod_hoverinfo.R`**
    ([`mod_hoverinfo()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_hoverinfo.md))
    - **Lines**: 95
    - **Type**: Server-side helper for reactable cells
    - **Purpose**: Wraps content with a `title` attribute for native
      tooltips
9.  **`with_logging.R`** / **`app_set_log_threshold.R`**
    - **Lines**: 47 / 42
    - **Purpose**: Structured logging with namespace-based filtering —
      see
      [`vignette("implementation")`](https://mjfrigaard.github.io/tooltipexplorer/articles/implementation.md)
10. **`utils_operators.R`**
    - **Lines**: 15
    - **Operators**: `%||%` (null-coalescing operator)
11. **Financial data/logic functions**
    - `get_stock_prices.R`, `get_stock_returns.R`,
      `summarise_performance.R`, `compute_rolling_vol.R`,
      `get_ff3_factors.R`, `default_tickers.R`
    - **Purpose**: Reusable data utilities for fetching prices and
      computing returns, volatility, and performance summaries
12. **Theme functions**
    - `setup_theme.R`, `custom_head.R`, `utils_reactable_theme.R`
    - **Purpose**: Dark Bloomberg-terminal styling — see
      [`vignette("theme")`](https://mjfrigaard.github.io/tooltipexplorer/articles/theme.md)

### Supporting Files

- **`DESCRIPTION`** — Package metadata, dependencies
- **`LICENSE`** / **`LICENSE.md`** — MIT license
- **`README.md`** — Package overview
- **`inst/report_template.Rmd`** — Parameterised R Markdown template
  used by
  [`mod_download_server()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_download_server.md)
- **`.Rbuildignore`** / **`.gitignore`** — Build and version-control
  exclusions

------------------------------------------------------------------------

## Adding a New Module

Follow these steps to add a fourth module to the app.

**1.** Create `R/mod_<name>.R` with `mod_<name>_ui()` and
`mod_<name>_server()`, both exported with `@export`.

**2.** Add the UI call to
[`app_ui()`](https://mjfrigaard.github.io/tooltipexplorer/reference/app_ui.md):

``` r
# app_ui.R
bslib::page_sidebar(
  sidebar = mod_inputs_ui("inputs"),
  mod_outputs_ui("outputs"),
  mod_<name>_ui("<name>")     # add here
)
```

**3.** Wire the server in
[`app_server()`](https://mjfrigaard.github.io/tooltipexplorer/reference/app_server.md):

``` r
# app_server.R
mod_<name>_server("<name>", inputs_r, perf_r)
```

**4.** Run
[`devtools::document()`](https://devtools.r-lib.org/reference/document.html)
to update `NAMESPACE` and regenerate the help page, then
[`pkgdown::build_site()`](https://pkgdown.r-lib.org/reference/build_site.html)
to update the reference index.
