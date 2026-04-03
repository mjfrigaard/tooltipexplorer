#' Inputs module UI
#'
#' Sidebar controls for ticker selection, date range, rolling-vol window,
#' and report download.  Returns a [bslib::sidebar()] ready to embed in a
#' [bslib::page_sidebar()] layout.
#'
#' @param id Module namespace id.
#'
#' @return A `bslib::sidebar` tag object.
#'
#' @seealso [mod_inputs_server()]
#'
#' @export
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
          type     = "bslib",
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
          type     = "bslib",
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

    shiny::actionButton(
      inputId = ns("fetch"),
      label   = "Fetch data",
      icon    = shiny::icon("download"),
      class   = "btn-primary w-100"
    ),

    shiny::hr(),

    # ── Report download ───────────────────────────────────────────────────
    mod_download_ui("download")
  )
}

#' Inputs module server
#'
#' Handles the fetch button observer and assembles a reactive list of current
#' user inputs.
#'
#' @param id Module namespace id.
#'
#' @return A reactive list with elements:
#'   \describe{
#'     \item{`tickers`}{Character vector of selected ticker symbols.}
#'     \item{`from`}{`Date`. Start of the selected date range.}
#'     \item{`to`}{`Date`. End of the selected date range.}
#'     \item{`vol_window`}{Integer. Rolling-volatility window in trading days.}
#'     \item{`fetch`}{Integer. Current value of the fetch action button.}
#'   }
#'
#' @seealso [mod_inputs_ui()]
#'
#' @export
mod_inputs_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {

    logger::log_debug(
      "mod_inputs_server() initialised | id: {id}",
      namespace = "tooltipexplorer/inputs"
    )

    # ── Fetch button observer ───────────────────────────────────────────────
    shiny::observe({
      shiny::req(input$fetch)

      logger::log_info(
        "Fetch button pressed | tickers: [{paste(input$tickers, collapse = ', ')}] | from: {input$dates[1]} | to: {input$dates[2]} | vol_window: {input$vol_window}",
        namespace = "tooltipexplorer/inputs"
      )

      if (length(input$tickers) == 0) {
        logger::log_warn(
          "Fetch pressed with no tickers selected",
          namespace = "tooltipexplorer/inputs"
        )
        shiny::showNotification(
          "Please select at least one ticker.",
          type = "warning"
        )
      }
    })

    # ── Reactive inputs list ────────────────────────────────────────────────
    shiny::reactive({
      with_logging(
        context = "mod_inputs_server / reactive list",
        ns      = "tooltipexplorer/inputs",
        {
          inp <- list(
            tickers    = input$tickers,
            from       = input$dates[1],
            to         = input$dates[2],
            vol_window = input$vol_window,
            fetch      = input$fetch
          )

          logger::log_debug(
            "Inputs reactive evaluated | tickers: [{paste(inp$tickers, collapse = ', ')}]",
            namespace = "tooltipexplorer/inputs"
          )

          inp
        }
      )
    })
  })
}
