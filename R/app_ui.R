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
        # shinyalert JS — required for the delegated .sa-trigger handler.
        shinyalert::useShinyalert(force = TRUE),

        # Delegated shinyalert handler — reads content from data-sa-* attrs.
        shiny::tags$script(htmltools::HTML(
          "$(document).on('click', '.sa-trigger', function () {",
          "  var d = $(this).data();",
          "  swal({",
          "    title:             d.saTitle || '',",
          "    text:              d.saText  || '',",
          "    type:              d.saType  || 'info',",
          "    html:              true,",
          "    confirmButtonText: d.saBtn   || 'OK'",
          "  });",
          "});"
        )),

        # Delegated shinyhelper handler.
        #
        # shinyhelper's own .on('click', '.shinyhelper-icon') binding runs
        # once at page load, so it misses icons injected later by renderUI.
        # This document-level delegated handler catches every click regardless
        # of when the icon was inserted, stops the (now-duplicate) built-in
        # handler via stopImmediatePropagation(), then sets the same input
        # that shinyhelper's observe_helpers() observeEvent listens on.
        # {priority: 'event'} ensures re-firing when the same ticker is
        # clicked twice in a row (identical value would otherwise be dropped).
        shiny::tags$script(htmltools::HTML(
          "$(document).on('click', '.shinyhelper-icon', function(e) {",
          "  e.stopImmediatePropagation();",
          "  var d = $(this).data();",
          "  Shiny.setInputValue('shinyhelper_params', {",
          "    size:      d.modalSize,",
          "    type:      d.modalType,",
          "    title:     d.modalTitle,",
          "    content:   d.modalContent,",
          "    label:     d.modalLabel,",
          "    easyClose: d.modalEasyclose,",
          "    fade:      d.modalFade",
          "  }, {priority: 'event'});",
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
              " \u2014 explore five tooltip/hover-info approaches in R using real",
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
