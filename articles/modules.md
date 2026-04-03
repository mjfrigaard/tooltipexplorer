# Module structure

tooltipexplorer is organised as a collection of Shiny modules wired
together by a thin
[`app_server()`](https://mjfrigaard.github.io/tooltipexplorer/reference/app_server.md).
This vignette explains the naming convention, the UI/server split, how
data flows between modules, and the role each module plays.

------------------------------------------------------------------------

## Naming convention

Every module follows the same file-and-function layout:

| File               | UI function           | Server function                             |
|--------------------|-----------------------|---------------------------------------------|
| `R/mod_inputs.R`   | `mod_inputs_ui(id)`   | `mod_inputs_server(id)`                     |
| `R/mod_outputs.R`  | `mod_outputs_ui(id)`  | `mod_outputs_server(id, inputs_r)`          |
| `R/mod_download.R` | `mod_download_ui(id)` | `mod_download_server(id, inputs_r, perf_r)` |

The two tooltip helpers
([`mod_tooltip()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_tooltip.md)
and
[`mod_hoverinfo()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_hoverinfo.md))
are *not* modules in the Shiny sense — they have no server counterpart
and no `moduleServer()` call. They are UI / rendering helpers that
happen to share the `mod_` prefix for discoverability.

------------------------------------------------------------------------

## How modules are wired

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
reactive (`perf_r`) that the download server consumes — this is the only
inter-module dependency.

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

## mod_inputs

**Files:** `R/mod_inputs.R`  
**Exports:**
[`mod_inputs_ui()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_inputs_ui.md),
[`mod_inputs_server()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_inputs_server.md)

### UI

`mod_inputs_ui(id)` returns a
[`bslib::sidebar()`](https://rstudio.github.io/bslib/reference/sidebar.html)
containing:

- `selectizeInput` — multi-select ticker picker (user-creatable entries)
- `dateRangeInput` — date range (defaults to the past year)
- `sliderInput` — rolling-volatility window, 5–120 trading days
- `actionButton` — “Fetch data” trigger
- `mod_download_ui("download")` — embedded at the bottom

[`mod_tooltip()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_tooltip.md)
with `type = "bslib"` is used on the ticker and vol-window labels to
attach bslib popovers without any server-side code:

``` r
shiny::selectizeInput(
  inputId = ns("tickers"),
  label   = shiny::tags$span(
    "Tickers",
    mod_tooltip(
      trigger  = bsicons::bs_icon("info-circle"),
      type     = "bslib",
      contents = "Enter one or more stock ticker symbols (e.g. AAPL, MSFT).",
      size     = "0.85rem",
      style    = "color:#6c757d"
    )
  ),
  # ...
)
```

### Server

`mod_inputs_server(id)` logs the fetch event and validates that at least
one ticker is selected, then returns a **reactive list**:

``` r
list(
  tickers    = character(),  # selected ticker symbols
  from       = Date,         # start of date range
  to         = Date,         # end of date range
  vol_window = integer(),    # rolling-vol window in trading days
  fetch      = integer()     # action-button counter (used as event trigger)
)
```

The `fetch` element is an integer counter incremented each time the
button is pressed. Downstream modules use
`eventReactive(inputs_r()$fetch, ...)` to re-run only when the user
explicitly requests new data.

------------------------------------------------------------------------

## mod_outputs

**Files:** `R/mod_outputs.R`  
**Exports:**
[`mod_outputs_ui()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_outputs_ui.md),
[`mod_outputs_server()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_outputs_server.md)

### UI

`mod_outputs_ui(id)` returns a
[`shiny::tagList()`](https://rstudio.github.io/htmltools/reference/tagList.html)
with two pieces:

1.  `shiny::uiOutput(ns("value_boxes"))` — KPI value boxes rendered
    server-side so the number of boxes matches the number of selected
    tickers.
2.  [`bslib::navset_card_tab()`](https://rstudio.github.io/bslib/reference/navset.html)
    — five demo tabs, one per tooltip back-end.

| Tab         | Back-end                                                                                                                                                                  | Interaction       |
|-------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------|
| bslib       | [`bslib::popover()`](https://rstudio.github.io/bslib/reference/popover.html) via [`mod_tooltip()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_tooltip.md) | Click info icon   |
| shinyhelper | [`shinyhelper::helper()`](https://rdrr.io/pkg/shinyhelper/man/helper.html) via [`mod_tooltip()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_tooltip.md)   | Click circled-?   |
| prompter    | [`prompter::add_prompt()`](https://rdrr.io/pkg/prompter/man/add_prompt.html) via [`mod_tooltip()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_tooltip.md) | Hover over label  |
| shinyalert  | `data-sa-*` attrs + delegated JS via [`mod_tooltip()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_tooltip.md)                                             | Click ticker card |
| reactable   | `htmltools` `<span title>` via [`mod_hoverinfo()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_hoverinfo.md)                                               | Hover over cell   |

### Server

`mod_outputs_server(id, inputs_r)` is the computational core of the app.
It registers
[`shinyhelper::observe_helpers()`](https://rdrr.io/pkg/shinyhelper/man/observe_helpers.html)
once per session (required by shinyhelper; do not call it separately in
[`app_server()`](https://mjfrigaard.github.io/tooltipexplorer/reference/app_server.md)),
then chains four reactives triggered by `inputs_r()$fetch`:

``` r
# 1 — fetch adjusted prices
prices_r <- shiny::eventReactive(inputs_r()$fetch, {
  get_stock_prices(
    tickers = inp$tickers,
    from    = inp$from,
    to      = inp$to
  )
})

# 2 — daily log returns
returns_r <- shiny::reactive({
  get_stock_returns(prices_r())
})

# 3 — annualised performance summary
perf_r <- shiny::reactive({
  summarise_performance(returns_r())
})

# 4 — five renderUI / renderReactable outputs that consume perf_r()
```

`perf_r` is returned to
[`app_server()`](https://mjfrigaard.github.io/tooltipexplorer/reference/app_server.md)
so
[`mod_download_server()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_download_server.md)
can embed it in the rendered report without re-computing it.

### KPI value boxes

The value boxes are coloured by Sharpe ratio threshold:

``` r
theme <- if (sharpe >= 1) "success" else if (sharpe >= 0) "warning" else "danger"
```

### reactable tab and `mod_hoverinfo()`

The reactable tab is the only output that uses
[`mod_hoverinfo()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_hoverinfo.md).
Each numeric column in the performance table gets a `colDef` cell
renderer that wraps the formatted value in an `htmltools`
`<span title="...">`:

``` r
reactable::colDef(
  name = "Ann. Return (%)",
  html = TRUE,
  cell = function(value, index) {
    mod_hoverinfo(
      type     = "reactable",
      contents = glue::glue(
        "Annualised log return for {df$symbol[index]}: {value}%"
      ),
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

## mod_download

**Files:** `R/mod_download.R`  
**Exports:**
[`mod_download_ui()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_download_ui.md),
[`mod_download_server()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_download_server.md)

### UI

`mod_download_ui(id)` returns a
[`bslib::card()`](https://rstudio.github.io/bslib/reference/card.html)
with:

- `selectInput` — report format (`"html"` or `"pdf"`)
- `downloadButton` — triggers the handler

The card is embedded at the bottom of the inputs sidebar by
[`mod_inputs_ui()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_inputs_ui.md):

``` r
# inside mod_inputs_ui()
bslib::sidebar(
  # ... other inputs ...
  mod_download_ui("download")
)
```

This keeps all user controls in the sidebar while the download server is
wired at the top level in
[`app_server()`](https://mjfrigaard.github.io/tooltipexplorer/reference/app_server.md).

### Server

`mod_download_server(id, inputs_r, perf_r)` renders
`inst/report_template.Rmd` into a temporary directory via
[`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html)
and serves the output through
[`shiny::downloadHandler()`](https://rdrr.io/pkg/shiny/man/downloadHandler.html).
Parameters passed to the template:

``` r
params = list(
  tickers    = inp$tickers,
  from       = as.character(inp$from),
  to         = as.character(inp$to),
  vol_window = inp$vol_window,
  perf_data  = perf_r()
)
```

Rendering into an isolated
[`tempfile()`](https://rdrr.io/r/base/tempfile.html) directory ensures
the Shiny session working directory is not affected and simultaneous
downloads do not collide.

------------------------------------------------------------------------

## Tooltip helpers

These two functions share the `mod_` prefix but are not Shiny modules.

### `mod_tooltip()`

A **UI helper** — returns a `shiny.tag` with no server counterpart.
Place it anywhere inside a UI tree, including inside `renderUI()`.

``` r
mod_tooltip(
  trigger     = bsicons::bs_icon("info-circle"),  # clickable/hoverable element
  type        = "bslib",      # "bslib" | "shinyhelper" | "prompter" | "shinyalert"
  contents    = "Help text.",
  size        = NULL,         # CSS font-size for the wrapper span
  style       = NULL,         # inline CSS for the wrapper span
  helper_type = "inline",     # shinyhelper only
  helper_size = "m",          # shinyhelper only
  alert_type  = "info",       # shinyalert only
  ...                         # forwarded to the back-end
)
```

### `mod_hoverinfo()`

A **rendering helper** — returns an `htmltools` `<span title="...">` for
use inside `reactable::colDef(cell = ..., html = TRUE)`.

``` r
mod_hoverinfo(
  type     = "reactable",    # only supported back-end
  contents = character(0),   # tooltip text; named vector → "Name: value" pairs
  display  = NULL,           # visible cell value
  size     = NULL,           # CSS font-size
  style    = NULL,           # inline CSS
  ...                        # extra HTML attributes on the <span>
)
```

------------------------------------------------------------------------

## Adding a new module

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
