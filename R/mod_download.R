#' Download module UI
#'
#' A [bslib::card()] containing a report-format selector (HTML / PDF) and a
#' download button.  Embed inside the sidebar via [mod_inputs_ui()].
#'
#' @param id Module namespace id.
#'
#' @return A `bslib::card` tag object.
#'
#' @seealso [mod_download_server()]
#'
#' @export
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

#' Download module server
#'
#' Renders a parameterised R Markdown report from
#' `inst/report_template.Rmd` and serves it as a file download.  The report
#' is rendered into an isolated temporary directory so the working directory
#' of the Shiny session is not affected.
#'
#' @param id       Module namespace id.
#' @param inputs_r Reactive list returned by [mod_inputs_server()].
#' @param perf_r   Reactive tibble returned by [mod_outputs_server()].
#'
#' @return Called for side-effects; returns `NULL` invisibly.
#'
#' @seealso [mod_download_ui()]
#'
#' @export
mod_download_server <- function(id, inputs_r, perf_r) {
  shiny::moduleServer(id, function(input, output, session) {

    logger::log_debug(
      "mod_download_server() initialised | id: {id}",
      namespace = "tooltipexplorer/download"
    )

    output$download <- shiny::downloadHandler(

      filename = function() {
        with_logging(
          context = "mod_download / filename",
          ns      = "tooltipexplorer/download",
          {
            ts    <- format(Sys.time(), "%Y%m%d_%H%M%S")
            ext   <- if (input$format == "html") "html" else "pdf"
            fname <- glue::glue("tooltipexplorer_report_{ts}.{ext}")
            logger::log_info(
              "Download filename generated | file: {fname}",
              namespace = "tooltipexplorer/download"
            )
            fname
          }
        )
      },

      content = function(file) {
        shiny::req(perf_r())
        inp <- inputs_r()

        logger::log_info(
          "Report render started | format: {input$format} | tickers: [{paste(inp$tickers, collapse = ', ')}]",
          namespace = "tooltipexplorer/download"
        )

        template <- system.file(
          "report_template.Rmd",
          package = "tooltipexplorer"
        )

        if (!nzchar(template)) {
          logger::log_error(
            "report_template.Rmd not found in package inst/",
            namespace = "tooltipexplorer/download"
          )
          stop("Report template not found. Is the package installed correctly?")
        }

        # Render into an isolated temp directory
        tmp_dir <- tempfile()
        dir.create(tmp_dir, recursive = TRUE)
        tmp_rmd <- file.path(tmp_dir, "report.Rmd")
        file.copy(template, tmp_rmd)

        logger::log_debug(
          "Rendering to temp dir | path: {tmp_dir}",
          namespace = "tooltipexplorer/download"
        )

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

        tryCatch(
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
          ),
          error = function(e) {
            logger::log_error(
              "rmarkdown::render() failed | format: {input$format} | error: {conditionMessage(e)}",
              namespace = "tooltipexplorer/download"
            )
            shiny::showNotification(
              paste("Report generation failed:", conditionMessage(e)),
              type     = "error",
              duration = 15
            )
            stop(e)
          }
        )

        logger::log_info(
          "Report render complete | format: {input$format} | file: {file}",
          namespace = "tooltipexplorer/download"
        )
      }
    )
  })
}
