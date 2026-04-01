#' Download module (UI)
#'
#' A `bslib::card()` containing a format selector (HTML / PDF) and a
#' download button for exporting a parameterised performance report.
#'
#' @section UI:
#' `mod_download_ui()` returns a `bslib::card()`.
#'
#' @section Server:
#' `mod_download_server()` renders a parameterised R Markdown report from
#' `inst/report_template.Rmd` and serves it as a file download.
#'
#' @param id Module namespace id.
#'
mod_download_ui <- function(id) {
  ns <- shiny::NS(id)

  bslib::card(
    bslib::card_header(
      bsicons::bs_icon("file-earmark-arrow-down"), " Download Report"
    ),
    bslib::card_body(
      shiny::selectInput(
        inputId  = ns("format"),
        label    = "Report format",
        choices  = c("HTML" = "html", "PDF" = "pdf"),
        selected = "html"
      ),
      shiny::downloadButton(
        outputId = ns("download"),
        label    = "Download",
        icon     = shiny::icon("download"),
        class    = "btn-outline-primary w-100"
      )
    )
  )
}

#' Download module (server)
#'
#' A `bslib::card()` containing a format selector (HTML / PDF) and a
#' download button for exporting a parameterised performance report.
#'
#' @section UI:
#' `mod_download_ui()` returns a `bslib::card()`.
#'
#' @section Server:
#' `mod_download_server()` renders a parameterised R Markdown report from
#' `inst/report_template.Rmd` and serves it as a file download.
#'
#' @param id       Module namespace id.
#' @param inputs_r Reactive list from [mod_inputs_server()].
#' @param perf_r   Reactive tibble from [mod_outputs_server()].
#'
mod_download_server <- function(id, inputs_r, perf_r) {
  shiny::moduleServer(id, function(input, output, session) {

    output$download <- shiny::downloadHandler(
      filename = function() {
        ts  <- format(Sys.time(), "%Y%m%d_%H%M%S")
        ext <- if (input$format == "html") "html" else "pdf"
        glue::glue("tooltipexplorer_report_{ts}.{ext}")
      },
      content = function(file) {
        shiny::req(perf_r())
        inp <- inputs_r()

        template <- system.file(
          "report_template.Rmd",
          package = "tooltipexplorer"
        )

        # Render into an isolated temp directory
        tmp_dir <- tempfile()
        dir.create(tmp_dir, recursive = TRUE)
        tmp_rmd <- file.path(tmp_dir, "report.Rmd")
        file.copy(template, tmp_rmd)

        out_fmt <- if (input$format == "html") {
          rmarkdown::html_document(
            toc            = TRUE,
            toc_float      = TRUE,
            theme          = "cosmo",
            highlight      = "tango",
            self_contained = TRUE
          )
        } else {
          rmarkdown::pdf_document(toc = TRUE)
        }

        rmarkdown::render(
          input         = tmp_rmd,
          output_format = out_fmt,
          output_file   = file,
          params        = list(
            tickers    = inp$tickers,
            from       = as.character(inp$from),
            to         = as.character(inp$to),
            vol_window = inp$vol_window,
            perf_data  = perf_r()
          ),
          envir = new.env(parent = globalenv()),
          quiet = TRUE
        )
      }
    )
  })
}
