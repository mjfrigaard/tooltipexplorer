#' Inputs module (UI)
#'
#' Sidebar controls for ticker selection, date range, rolling-vol window,
#' and tooltip-type picker.
#'
#' @section UI:
#' `mod_inputs_ui()` returns a `bslib::sidebar()` ready to embed in a
#' `bslib::page_sidebar()` layout.
#'
#' @section Server:
#' `mod_inputs_server()` returns a reactive list with elements: `tickers`,
#' `from`, `to`, `vol_window`, `tooltip_type`, and `fetch` (the
#' action-button integer).
#'
#' @param id Module namespace id.
#'
mod_inputs_ui <- function(id) {
  ns <- shiny::NS(id)

  bslib::sidebar(
    width = 280,
    bg    = "#f8f9fa",

    # ── Ticker picker ──────────────────────────────────────────────────────
    shiny::selectizeInput(
      inputId  = ns("tickers"),
      label    = shiny::tags$span(
        "Tickers",
        mod_tooltip(
          trigger  = bsicons::bs_icon("info-circle"),
          type     = "tippy",
          contents = "Enter one or more stock ticker symbols (e.g. AAPL, MSFT).",
          size     = "0.85rem",
          style    = "color:#6c757d"
        )
      ),
      choices  = tooltipexplorer::default_tickers,
      selected = c("AAPL", "MSFT", "GOOGL"),
      multiple = TRUE,
      options  = list(
        plugins     = list("remove_button"),
        placeholder = "Add a ticker\u2026",
        create      = TRUE
      )
    ),

    # ── Date range ────────────────────────────────────────────────────────
    shiny::dateRangeInput(
      inputId = ns("dates"),
      label   = "Date range",
      start   = Sys.Date() - 365,
      end     = Sys.Date(),
      min     = "2000-01-01",
      max     = Sys.Date()
    ),

    # ── Rolling-vol window ────────────────────────────────────────────────
    shiny::sliderInput(
      inputId = ns("vol_window"),
      label   = shiny::tags$span(
        "Rolling vol window (days)",
        mod_tooltip(
          trigger  = bsicons::bs_icon("info-circle"),
          type     = "tippy",
          contents = "Number of trading days used for the rolling volatility calculation.",
          size     = "0.85rem",
          style    = "color:#6c757d"
        )
      ),
      min   = 5L,
      max   = 120L,
      value = 30L,
      step  = 5L
    ),

    shiny::hr(),

    # ── Tooltip-demo selector ─────────────────────────────────────────────
    shiny::radioButtons(
      inputId  = ns("tooltip_type"),
      label    = shiny::tags$span(
        "Tooltip / hover method",
        mod_tooltip(
          trigger  = bsicons::bs_icon("info-circle"),
          type     = "tippy",
          contents = paste(
            "Choose which tooltip technology to demo in the Output tab.",
            "Each option highlights a different R package or approach."
          ),
          size     = "0.85rem",
          style    = "color:#6c757d"
        )
      ),
      choices  = c(
        "plotly (interactive)"     = "plotly",
        "tippy (HTML tooltip)"     = "tippy",
        "bslib value boxes"        = "bslib",
        "reactable (cell tooltip)" = "reactable",
        "gt (column tooltip)"      = "gt",
        "DT (Bootstrap tooltip)"   = "dt"
      ),
      selected = "plotly"
    ),

    shiny::hr(),

    shiny::actionButton(
      inputId = ns("fetch"),
      label   = "Fetch data",
      icon    = shiny::icon("download"),
      class   = "btn-primary w-100"
    )
  )
}

# ── Server ────────────────────────────────────────────────────────────────────

#' Inputs module (server)
#'
#' Sidebar controls for ticker selection, date range, rolling-vol window,
#' and tooltip-type picker.
#'
#' @section UI:
#' `mod_inputs_ui()` returns a `bslib::sidebar()` ready to embed in a
#' `bslib::page_sidebar()` layout.
#'
#' @section Server:
#' `mod_inputs_server()` returns a reactive list with elements: `tickers`,
#' `from`, `to`, `vol_window`, `tooltip_type`, and `fetch` (the
#' action-button integer).
#'
#' @param id Module namespace id.
#'
mod_inputs_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {

    # Warn if no tickers selected when Fetch is pressed
    shiny::observe({
      shiny::req(input$fetch)
      if (length(input$tickers) == 0) {
        shiny::showNotification(
          "Please select at least one ticker.",
          type = "warning"
        )
      }
    })

    shiny::reactive({
      list(
        tickers      = input$tickers,
        from         = input$dates[1],
        to           = input$dates[2],
        vol_window   = input$vol_window,
        tooltip_type = input$tooltip_type,
        fetch        = input$fetch
      )
    })
  })
}
