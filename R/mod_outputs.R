#' Outputs module (UI)
#'
#' Main content area: KPI value boxes and tabbed panels for each
#' tooltip/hover demo (plotly, tippy, bslib, reactable, gt, DT, rolling vol).
#'
#' @section UI:
#' `mod_outputs_ui()` returns a `shiny::tagList()` containing a
#' `shiny::uiOutput()` for KPI boxes and a `bslib::navset_card_tab()` for
#' the demo panels.
#'
#' @section Server:
#' `mod_outputs_server()` reacts to the fetch signal from
#' [mod_inputs_server()], downloads price data, computes returns and
#' volatility, and renders all tooltip-demo outputs.  Returns the reactive
#' performance-summary tibble (`perf_r`) for the download module.
#'
#' @param id Module namespace id.
#'
mod_outputs_ui <- function(id) {
  ns <- shiny::NS(id)

  shiny::tagList(

    # ── KPI value boxes (always visible) ──────────────────────────────────
    shiny::uiOutput(ns("value_boxes")),

    shiny::br(),

    # ── Main demo tabs ─────────────────────────────────────────────────────
    bslib::navset_card_tab(
      id = ns("tabs"),

      # 1. plotly ────────────────────────────────────────────────────────
      bslib::nav_panel(
        title = shiny::tagList(bsicons::bs_icon("graph-up"), " plotly"),
        value = "plotly",
        shiny::h6(
          "Hover over the chart to see interactive plotly tooltips.",
          class = "text-muted mb-3"
        ),
        plotly::plotlyOutput(ns("plotly_prices"),  height = "380px"),
        shiny::br(),
        plotly::plotlyOutput(ns("plotly_returns"), height = "280px")
      ),

      # 2. tippy ─────────────────────────────────────────────────────────
      bslib::nav_panel(
        title = shiny::tagList(bsicons::bs_icon("cursor"), " tippy"),
        value = "tippy",
        shiny::h6(
          "Hover over the metric cards below to see tippy.js tooltips.",
          class = "text-muted mb-3"
        ),
        shiny::uiOutput(ns("tippy_cards"))
      ),

      # 3. bslib ─────────────────────────────────────────────────────────
      bslib::nav_panel(
        title = shiny::tagList(bsicons::bs_icon("box"), " bslib"),
        value = "bslib",
        shiny::h6(
          "bslib value_box() with popover hover-info.",
          class = "text-muted mb-3"
        ),
        shiny::uiOutput(ns("bslib_boxes"))
      ),

      # 4. reactable ─────────────────────────────────────────────────────
      bslib::nav_panel(
        title = shiny::tagList(bsicons::bs_icon("table"), " reactable"),
        value = "reactable",
        shiny::h6(
          "Hover over a cell to see the reactable tooltip.",
          class = "text-muted mb-3"
        ),
        reactable::reactableOutput(ns("reactable_perf"))
      ),

      # 5. gt ────────────────────────────────────────────────────────────
      bslib::nav_panel(
        title = shiny::tagList(bsicons::bs_icon("grid-3x3"), " gt"),
        value = "gt",
        shiny::h6(
          "gt table with column-header tooltips via tab_footnote().",
          class = "text-muted mb-3"
        ),
        gt::gt_output(ns("gt_perf"))
      ),

      # 6. DT ────────────────────────────────────────────────────────────
      bslib::nav_panel(
        title = shiny::tagList(bsicons::bs_icon("layout-text-window"), " DT"),
        value = "dt",
        shiny::h6(
          "DT DataTable with Bootstrap cell tooltips.",
          class = "text-muted mb-3"
        ),
        DT::dataTableOutput(ns("dt_perf"))
      ),

      # 7. Rolling volatility ────────────────────────────────────────────
      bslib::nav_panel(
        title = shiny::tagList(bsicons::bs_icon("activity"), " Vol"),
        value = "vol",
        shiny::h6(
          "Rolling annualised volatility with plotly hover.",
          class = "text-muted mb-3"
        ),
        plotly::plotlyOutput(ns("plotly_vol"), height = "380px")
      )
    )
  )
}

# ── Server ────────────────────────────────────────────────────────────────────

#' Outputs module (server)
#'
#' Main content area: KPI value boxes and tabbed panels for each
#' tooltip/hover demo (plotly, tippy, bslib, reactable, gt, DT, rolling vol).
#'
#' @section UI:
#' `mod_outputs_ui()` returns a `shiny::tagList()` containing a
#' `shiny::uiOutput()` for KPI boxes and a `bslib::navset_card_tab()` for
#' the demo panels.
#'
#' @section Server:
#' `mod_outputs_server()` reacts to the fetch signal from
#' [mod_inputs_server()], downloads price data, computes returns and
#' volatility, and renders all tooltip-demo outputs.  Returns the reactive
#' performance-summary tibble (`perf_r`) for the download module.
#'
#' @param id       Module namespace id.
#' @param inputs_r Reactive list returned by [mod_inputs_server()].
#'
mod_outputs_server <- function(id, inputs_r) {
  shiny::moduleServer(id, function(input, output, session) {

    # ── Fetch prices on button click ───────────────────────────────────────
    prices_r <- shiny::eventReactive(inputs_r()$fetch, {
      inp <- inputs_r()
      shiny::req(length(inp$tickers) > 0)

      shiny::withProgress(message = "Fetching prices\u2026", value = 0.3, {
        p <- tooltipexplorer::get_stock_prices(
          tickers = inp$tickers,
          from    = inp$from,
          to      = inp$to
        )
        shiny::incProgress(0.4)
        p
      })
    })

    returns_r <- shiny::reactive({
      shiny::req(prices_r())
      tooltipexplorer::get_stock_returns(prices_r())
    })

    perf_r <- shiny::reactive({
      shiny::req(returns_r())
      tooltipexplorer::summarise_performance(returns_r())
    })

    vol_r <- shiny::reactive({
      shiny::req(returns_r())
      tooltipexplorer::compute_rolling_vol(
        returns_r(),
        window = inputs_r()$vol_window
      )
    })

    # ── KPI value boxes ────────────────────────────────────────────────────
    output$value_boxes <- shiny::renderUI({
      shiny::req(perf_r())
      df <- perf_r()

      boxes <- lapply(seq_len(nrow(df)), function(i) {
        row    <- df[i, ]
        sharpe <- round(row$sharpe, 2)
        theme  <- if (sharpe >= 1) "success" else if (sharpe >= 0) "warning" else "danger"

        bslib::value_box(
          title    = row$symbol,
          value    = scales::percent(row$ann_return, accuracy = 0.1),
          showcase = bsicons::bs_icon("bar-chart-fill"),
          theme    = theme,
          shiny::p(glue::glue(
            "Vol: {scales::percent(row$ann_vol, accuracy = 0.1)}",
            "  |  Sharpe: {sharpe}"
          ))
        )
      })

      n_cols <- min(nrow(df), 4L)
      bslib::layout_columns(!!!boxes, col_widths = rep(12L %/% n_cols, n_cols))
    })

    # ── 1. plotly price chart ──────────────────────────────────────────────
    output$plotly_prices <- plotly::renderPlotly({
      shiny::req(prices_r())
      df <- prices_r()

      p <- ggplot2::ggplot(df, ggplot2::aes(
        x      = date,
        y      = adjusted,
        colour = symbol,
        text   = mapply(
          function(sym, dt, adj) {
            mod_hoverinfo(
              type     = "plotly",
              contents = c(Ticker = sym, Date = as.character(dt),
                           "Adj Close" = paste0("$", round(adj, 2)))
            )
          },
          sym = symbol, dt = date, adj = adjusted,
          SIMPLIFY = TRUE
        )
      )) +
        ggplot2::geom_line(linewidth = 0.7) +
        ggplot2::scale_y_continuous(labels = scales::dollar) +
        ggplot2::labs(
          title  = "Adjusted Closing Prices",
          x      = NULL,
          y      = "Price (USD)",
          colour = NULL
        ) +
        ggplot2::theme_minimal(base_size = 13)

      plotly::ggplotly(p, tooltip = "text") |>
        plotly::layout(hovermode = "x unified")
    })

    # ── 1b. plotly returns chart ───────────────────────────────────────────
    output$plotly_returns <- plotly::renderPlotly({
      shiny::req(returns_r())
      df <- returns_r()

      p <- ggplot2::ggplot(df, ggplot2::aes(
        x      = date,
        y      = daily_return,
        colour = symbol,
        text   = mapply(
          function(sym, dt, ret) {
            mod_hoverinfo(
              type     = "plotly",
              contents = c(
                Ticker = sym,
                Date   = as.character(dt),
                Return = scales::percent(ret, accuracy = 0.01)
              )
            )
          },
          sym = symbol, dt = date, ret = daily_return,
          SIMPLIFY = TRUE
        )
      )) +
        ggplot2::geom_line(linewidth = 0.4, alpha = 0.7) +
        ggplot2::scale_y_continuous(labels = scales::percent) +
        ggplot2::labs(
          title  = "Daily Log Returns",
          x      = NULL,
          y      = "Log Return",
          colour = NULL
        ) +
        ggplot2::theme_minimal(base_size = 13)

      plotly::ggplotly(p, tooltip = "text") |>
        plotly::layout(hovermode = "x unified")
    })

    # ── 2. tippy cards ─────────────────────────────────────────────────────
    output$tippy_cards <- shiny::renderUI({
      shiny::req(perf_r())
      df <- perf_r()

      cards <- lapply(seq_len(nrow(df)), function(i) {
        row <- df[i, ]

        tip_html <- paste0(
          "<b>", row$symbol, "</b><br>",
          "Ann. Return: ", scales::percent(row$ann_return, accuracy = 0.1), "<br>",
          "Ann. Vol: ",    scales::percent(row$ann_vol,    accuracy = 0.1), "<br>",
          "Sharpe: ",      round(row$sharpe, 2)
        )

        bslib::card(
          class = "text-center p-3",
          mod_tooltip(
            trigger  = shiny::tags$span(class = "fs-4 fw-bold", row$symbol),
            type     = "tippy",
            contents = tip_html,
            theme    = "light-border",
            placement = "top"
          ),
          shiny::tags$p(
            class = "text-muted mb-0",
            scales::percent(row$ann_return, accuracy = 0.1)
          )
        )
      })

      n_cols <- min(nrow(df), 4L)
      bslib::layout_columns(!!!cards, col_widths = rep(12L %/% n_cols, n_cols))
    })

    # ── 3. bslib popover boxes ─────────────────────────────────────────────
    output$bslib_boxes <- shiny::renderUI({
      shiny::req(perf_r())
      df <- perf_r()

      boxes <- lapply(seq_len(nrow(df)), function(i) {
        row <- df[i, ]

        popover_body <- shiny::tags$ul(
          shiny::tags$li(glue::glue(
            "Ann. Return: {scales::percent(row$ann_return, accuracy = 0.1)}"
          )),
          shiny::tags$li(glue::glue(
            "Ann. Vol: {scales::percent(row$ann_vol, accuracy = 0.1)}"
          )),
          shiny::tags$li(glue::glue(
            "Sharpe Ratio: {round(row$sharpe, 2)}"
          ))
        )

        bslib::value_box(
          title = shiny::tagList(
            row$symbol,
            mod_tooltip(
              trigger  = bsicons::bs_icon("info-circle-fill",
                                          class = "ms-1 text-info"),
              type     = "bslib",
              contents = as.character(popover_body),
              title    = glue::glue("{row$symbol} \u2013 Performance Summary")
            )
          ),
          value    = scales::percent(row$ann_return, accuracy = 0.1),
          showcase = bsicons::bs_icon("graph-up-arrow")
        )
      })

      n_cols <- min(nrow(df), 4L)
      bslib::layout_columns(!!!boxes, col_widths = rep(12L %/% n_cols, n_cols))
    })

    # ── 4. reactable ──────────────────────────────────────────────────────
    output$reactable_perf <- reactable::renderReactable({
      shiny::req(perf_r())
      df <- perf_r() |>
        dplyr::mutate(
          ann_return = round(ann_return * 100, 2),
          ann_vol    = round(ann_vol    * 100, 2),
          sharpe     = round(sharpe,           2)
        )

      reactable::reactable(
        df,
        columns = list(
          symbol = reactable::colDef(name = "Ticker"),

          ann_return = reactable::colDef(
            name = "Ann. Return (%)",
            cell = function(value, index) {
              mod_hoverinfo(
                type     = "reactable",
                contents = glue::glue(
                  "Annualised log return for {df$symbol[index]}: {value}%"
                ),
                style    = paste0(
                  "color:", if (value >= 0) "#198754" else "#dc3545",
                  "; cursor:help"
                ),
                glue::glue("{value}%")
              )
            }
          ),

          ann_vol = reactable::colDef(
            name = "Ann. Vol (%)",
            cell = function(value, index) {
              mod_hoverinfo(
                type     = "reactable",
                contents = glue::glue(
                  "Annualised volatility for {df$symbol[index]}: {value}%"
                ),
                style    = "cursor:help",
                glue::glue("{value}%")
              )
            }
          ),

          sharpe = reactable::colDef(
            name = "Sharpe",
            cell = function(value, index) {
              col <- if (value >= 1) "#198754" else if (value >= 0) "#fd7e14" else "#dc3545"
              mod_hoverinfo(
                type     = "reactable",
                contents = glue::glue(
                  "Sharpe ratio (zero risk-free) for {df$symbol[index]}: {value}"
                ),
                style    = paste0("color:", col, "; cursor:help"),
                value
              )
            }
          )
        ),
        striped         = TRUE,
        highlight       = TRUE,
        bordered        = TRUE,
        defaultPageSize = 10L
      )
    })

    # ── 5. gt table ───────────────────────────────────────────────────────
    output$gt_perf <- gt::render_gt({
      shiny::req(perf_r())
      df <- perf_r()

      # Build footnote arg-lists via mod_hoverinfo()
      footnotes <- mod_hoverinfo(
        type     = "gt",
        contents = c(
          ann_return = "Annualised log return = mean daily log return \u00d7 252.",
          ann_vol    = "Annualised volatility = SD of daily log returns \u00d7 \u221a252.",
          sharpe     = "Sharpe ratio assumes a zero risk-free rate."
        )
      )

      tbl <- df |>
        gt::gt() |>
        gt::fmt_percent(columns = c(ann_return, ann_vol), decimals = 1) |>
        gt::fmt_number(columns  = sharpe, decimals = 2) |>
        gt::cols_label(
          symbol     = gt::md("**Ticker**"),
          ann_return = gt::md("**Ann. Return**"),
          ann_vol    = gt::md("**Ann. Vol**"),
          sharpe     = gt::md("**Sharpe**")
        ) |>
        gt::tab_spanner(
          label   = gt::md("*Performance Metrics (hover column headers for details)*"),
          columns = c(ann_return, ann_vol, sharpe)
        ) |>
        gt::tab_style(
          style     = gt::cell_text(color = "#198754"),
          locations = gt::cells_body(columns = ann_return, rows = ann_return >= 0)
        ) |>
        gt::tab_style(
          style     = gt::cell_text(color = "#dc3545"),
          locations = gt::cells_body(columns = ann_return, rows = ann_return < 0)
        ) |>
        gt::opt_interactive(use_search = TRUE, use_highlight = TRUE) |>
        gt::opt_stylize(style = 3)

      # Apply each footnote from mod_hoverinfo()
      for (fn_args in footnotes) {
        tbl <- do.call(gt::tab_footnote, c(list(tbl), fn_args))
      }

      tbl
    })

    # ── 6. DT table ───────────────────────────────────────────────────────
    output$dt_perf <- DT::renderDataTable({
      shiny::req(perf_r())
      df <- perf_r() |>
        dplyr::mutate(
          ann_return = scales::percent(ann_return, accuracy = 0.1),
          ann_vol    = scales::percent(ann_vol,    accuracy = 0.1),
          sharpe     = round(sharpe, 2)
        ) |>
        dplyr::rename(
          Ticker        = symbol,
          `Ann. Return` = ann_return,
          `Ann. Vol`    = ann_vol,
          Sharpe        = sharpe
        )

      DT::datatable(
        df,
        rownames = FALSE,
        class    = "table table-striped table-hover",
        options  = list(
          dom        = "tp",
          pageLength = 10L,
          initComplete = DT::JS(
            "function(settings, json) {",
            "  $('[data-toggle=\"tooltip\"]').tooltip();",
            "}"
          )
        ),
        callback = DT::JS(
          "table.on('draw', function() {",
          "  $('[data-toggle=\"tooltip\"]').tooltip();",
          "});"
        )
      ) |>
        DT::formatStyle(
          "Sharpe",
          color = DT::styleInterval(c(0, 1), c("#dc3545", "#fd7e14", "#198754"))
        )
    })

    # ── 7. Rolling volatility ─────────────────────────────────────────────
    output$plotly_vol <- plotly::renderPlotly({
      shiny::req(vol_r())
      df <- vol_r() |> dplyr::filter(!is.na(rolling_vol))

      p <- ggplot2::ggplot(df, ggplot2::aes(
        x      = date,
        y      = rolling_vol,
        colour = symbol,
        text   = mapply(
          function(sym, dt, vol) {
            mod_hoverinfo(
              type     = "plotly",
              contents = c(
                Ticker        = sym,
                Date          = as.character(dt),
                "Rolling Vol" = scales::percent(vol, accuracy = 0.1)
              )
            )
          },
          sym = symbol, dt = date, vol = rolling_vol,
          SIMPLIFY = TRUE
        )
      )) +
        ggplot2::geom_line(linewidth = 0.7) +
        ggplot2::scale_y_continuous(labels = scales::percent) +
        ggplot2::labs(
          title  = glue::glue(
            "Rolling {inputs_r()$vol_window}-Day Annualised Volatility"
          ),
          x      = NULL,
          y      = "Annualised Vol",
          colour = NULL
        ) +
        ggplot2::theme_minimal(base_size = 13)

      plotly::ggplotly(p, tooltip = "text") |>
        plotly::layout(hovermode = "x unified")
    })

    # Return perf data for download module
    perf_r
  })
}
