#' Hover-info module
#'
#' A server-side helper that formats hover/tooltip content for table and chart
#' back-ends that construct their tooltips programmatically (plotly, reactable,
#' gt).  Returns either a character string or an `htmltools` tag, depending on
#' the back-end.
#'
#' @param type     Back-end to target.  One of `"plotly"` (default),
#'   `"reactable"`, or `"gt"`.
#' @param contents A named character vector or a single string.  For
#'   `"plotly"` and `"gt"` each *element* becomes one line / footnote row.
#'   For `"reactable"` the vector is collapsed into a single `title`
#'   attribute value.  Names are used as labels when constructing multi-line
#'   content.
#' @param size     Font-size for `"reactable"` span wrappers.  Accepts any
#'   valid CSS value (e.g. `"0.8rem"`).  Ignored by `"plotly"` and `"gt"`.
#' @param style    Inline CSS string for `"reactable"` span wrappers (e.g.
#'   `"cursor:help"`).  Ignored by `"plotly"` and `"gt"`.
#' @param sep      Separator used to join lines in `"plotly"` output.
#'   Defaults to `"\\n"`.
#' @param ...      Extra arguments forwarded to the underlying helper:
#'   * `"plotly"`    → unused (reserved for future glue/template support)
#'   * `"reactable"` → passed as additional attributes to the `<span>` tag
#'     constructed by `htmltools`
#'   * `"gt"`        → passed to [gt::tab_footnote()]
#'
#' @return
#' * `"plotly"`    — a single character string ready for the `text` aesthetic.
#' * `"reactable"` — an `htmltools` `<span>` tag with a `title` attribute set.
#' * `"gt"`        — a named list with elements `footnote` (character) and
#'   `locations` (a [gt::cells_column_labels()] call), intended to be
#'   passed to `do.call(gt::tab_footnote, .)` inside a gt pipeline.
#'
#' @examples
#' \dontrun{
#' # plotly text aesthetic
#' mod_hoverinfo(
#'   type     = "plotly",
#'   contents = c(Ticker = "AAPL", Date = "2024-01-15", "Adj Close" = "$182.3")
#' )
#' # "Ticker: AAPL\nDate: 2024-01-15\nAdj Close: $182.3"
#'
#' # reactable span
#' mod_hoverinfo(
#'   type     = "reactable",
#'   contents = c("Annualised return for AAPL: 12.4%"),
#'   style    = "color:#198754; cursor:help"
#' )
#'
#' # gt footnote args list
#' mod_hoverinfo(
#'   type     = "gt",
#'   contents = c(ann_return = "Annualised log return = mean daily log return x 252.")
#' )
#' }
#'
mod_hoverinfo <- function(
    type     = c("plotly", "reactable", "gt"),
    contents = character(0),
    size     = NULL,
    style    = NULL,
    sep      = "\n",
    ...
) {
  type <- match.arg(type)

  switch(
    type,

    # ── plotly ──────────────────────────────────────────────────────────────
    # Returns a single newline-separated string.  Named vectors produce
    # "Name: value" lines; unnamed vectors are used as-is.
    plotly = {
      if (!is.null(names(contents)) && any(nzchar(names(contents)))) {
        lines <- ifelse(
          nzchar(names(contents)),
          paste0(names(contents), ": ", contents),
          contents
        )
      } else {
        lines <- contents
      }
      paste(lines, collapse = sep)
    },

    # ── reactable ───────────────────────────────────────────────────────────
    # Returns an htmltools span with a title= attribute.  Named vectors are
    # joined as "Name: value" lines separated by " | ".
    reactable = {
      if (!is.null(names(contents)) && any(nzchar(names(contents)))) {
        tip_text <- paste(
          ifelse(nzchar(names(contents)),
                 paste0(names(contents), ": ", contents),
                 contents),
          collapse = " | "
        )
      } else {
        tip_text <- paste(contents, collapse = " | ")
      }

      css_parts <- character(0)
      if (!is.null(size))  css_parts <- c(css_parts, paste0("font-size:", size))
      if (!is.null(style)) css_parts <- c(css_parts, style)
      inline_style <- if (length(css_parts)) paste(css_parts, collapse = "; ") else NULL

      span_args <- list(title = tip_text, ...)
      if (!is.null(inline_style)) span_args[["style"]] <- inline_style

      do.call(htmltools::tags$span, span_args)
    },

    # ── gt ──────────────────────────────────────────────────────────────────
    # Returns a list of argument lists, one per footnote, ready to be
    # iterated with purrr::reduce / Reduce and do.call(gt::tab_footnote, .).
    # `contents` should be a *named* character vector where each name is a
    # column name (string) and each value is the footnote text.
    gt = {
      if (is.null(names(contents)) || !any(nzchar(names(contents)))) {
        stop(
          "`contents` must be a named character vector for type = 'gt'. ",
          "Names should be column names (as strings).",
          call. = FALSE
        )
      }

      mapply(
        function(col, footnote_text) {
          c(
            list(
              footnote  = footnote_text,
              locations = gt::cells_column_labels(columns = col)
            ),
            list(...)
          )
        },
        col           = names(contents),
        footnote_text = unname(contents),
        SIMPLIFY      = FALSE,
        USE.NAMES     = FALSE
      )
    }
  )
}
