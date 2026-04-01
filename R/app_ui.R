#' Application UI
#'
#' Top-level UI function that wires together all module UIs inside a
#' `bslib::page_sidebar()` layout.
#'
#' @return A `shiny.tag` UI object suitable for passing to [shiny::shinyApp()].
#' @export
app_ui <- function() {
  bslib::page_sidebar(
    title = shiny::tagList(
      bsicons::bs_icon("bar-chart-steps"),
      " Tooltip Explorer"
    ),
    theme = bslib::bs_theme(
      version    = 5,
      bootswatch = "flatly",
      primary    = "#2c7bb6",
      base_font  = bslib::font_google("Inter")
    ),
    fillable = FALSE,

    # ── HEAD extras ─────────────────────────────────────────────────────────
    shiny::tags$head(
      # tippy.js CDN (CSS)
      shiny::tags$link(
        rel  = "stylesheet",
        href = "https://unpkg.com/tippy.js@6/dist/tippy.css"
      ),
      # Enable Bootstrap tooltips globally
      shiny::tags$script(
        "document.addEventListener('DOMContentLoaded', function () {",
        "  var tooltipEls = [].slice.call(",
        "    document.querySelectorAll('[data-bs-toggle=\"tooltip\"]')",
        "  );",
        "  tooltipEls.forEach(function (el) {",
        "    new bootstrap.Tooltip(el);",
        "  });",
        "});"
      )
    ),

    # ── Sidebar ──────────────────────────────────────────────────────────────
    sidebar = mod_inputs_ui("inputs"),

    # ── Main content ──────────────────────────────────────────────────────────
    bslib::layout_columns(
      col_widths = c(9, 3),

      # Left: demo outputs
      mod_outputs_ui("outputs"),

      # Right: about card + download card
      shiny::tagList(
        bslib::card(
          bslib::card_header(
            bsicons::bs_icon("info-circle"), " About"
          ),
          bslib::card_body(
            shiny::tags$p(
              "Explore six tooltip / hover-info approaches in R using real",
              "financial data from ",
              shiny::tags$a(
                href   = "https://www.tidy-finance.org/r/",
                target = "_blank",
                "Tidy Finance"
              ),
              " and ",
              shiny::tags$a(
                href   = "https://business-science.github.io/tidyquant/",
                target = "_blank",
                "tidyquant"
              ), "."
            ),
            shiny::tags$ul(
              shiny::tags$li(shiny::tags$b("plotly"), " – interactive hover"),
              shiny::tags$li(shiny::tags$b("tippy"),  " – JS tooltip library"),
              shiny::tags$li(shiny::tags$b("bslib"),  " – popover component"),
              shiny::tags$li(shiny::tags$b("reactable"), " – cell title attr"),
              shiny::tags$li(shiny::tags$b("gt"),     " – footnote tooltips"),
              shiny::tags$li(shiny::tags$b("DT"),     " – Bootstrap tooltip")
            )
          )
        ),
        mod_download_ui("download")
      )
    )
  )
}
