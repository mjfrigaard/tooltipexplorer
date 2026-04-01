#' Application UI
#'
#' Top-level UI function that wires together all module UIs inside a
#' `bslib::page_sidebar()` layout.
#'
#' @return A `shiny.tag` UI object suitable for passing to [shiny::shinyApp()].
#' @export
app_ui <- function() {

  logger::log_info(
    "Building app UI",
    namespace = "tooltipexplorer/app"
  )

  with_logging(
    context = "app_ui",
    ns      = "tooltipexplorer/app",
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

      # ── HEAD extras ─────────────────────────────────────────────────────
      shiny::tags$head(
        # Load shinyalert JS library unconditionally — required for the
        # delegated .sa-trigger handler below, which calls shinyalert()
        # directly from JS without going through the R server function.
        shinyalert::useShinyalert(force = TRUE),

        # Delegated shinyalert handler — reads content from data-sa-* attrs.
        # The browser dataset API decodes HTML entities automatically, so
        # storing HTML in data-sa-text is safe and avoids onclick escaping.
        shiny::tags$script(htmltools::HTML(
          "$(document).on('click', '.sa-trigger', function () {",
          "  var d = $(this).data();",
          "  swal({",
          "    title:            d.saTitle || '',",
          "    text:             d.saText  || '',",
          "    type:             d.saType  || 'info',",
          "    html:             true,",
          "    confirmButtonText: d.saBtn  || 'OK'",
          "  });",
          "});"
        )),

        # Delegated shinyhelper click handler — replaces the direct .on()
        # binding in shinyhelper.js, which only captures icons present at
        # bind time and misses icons injected by renderUI.
        shiny::tags$script(htmltools::HTML(
          "$(document).on('click', '.shinyhelper-icon', function () {",
          "  var data = this.dataset;",
          "  var nonce = Math.random();",
          "  var modal_params = {",
          "    size:      data.modalSize,",
          "    type:      data.modalType,",
          "    title:     data.modalTitle,",
          "    content:   data.modalContent,",
          "    label:     data.modalLabel,",
          "    easyClose: data.modalEasyclose,",
          "    fade:      data.modalFade,",
          "    nonce:     nonce",
          "  };",
          "  Shiny.onInputChange('shinyhelper-modal_params', modal_params);",
          "});"
        ))
      ),

      # ── Sidebar (inputs + download) ──────────────────────────────────────
      sidebar = mod_inputs_ui("inputs"),

      # ── Main content — full width ────────────────────────────────────────
      mod_outputs_ui("outputs"),

      # ── Footer ──────────────────────────────────────────────────────────
      shiny::tags$footer(
        class = "mt-4 pt-3 pb-2 border-top text-muted small",
        shiny::tags$div(
          class = "d-flex flex-wrap gap-4 align-items-start",
          shiny::tags$div(
            shiny::tags$strong("Tooltip Explorer"),
            shiny::tags$span(
              " \u2014 explore six tooltip/hover-info approaches in R using real",
              " financial data from ",
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
              ),
              "."
            )
          ),
          shiny::tags$div(
            shiny::tags$strong("Packages: "),
            shiny::tags$span(
              shiny::tags$b("bslib"),        " (popover), ",
              shiny::tags$b("shinyhelper"),  " (help modal), ",
              shiny::tags$b("prompter"),     " (attribute tooltip), ",
              shiny::tags$b("shinyalert"),   " (modal alert), ",
              shiny::tags$b("reactable"),    " (cell title attr)"
            )
          )
        )
      )
    )
  )
}
