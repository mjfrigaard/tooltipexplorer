#' Tooltip module
#'
#' A lightweight UI helper that wraps several tooltip back-ends behind a
#' single, consistent interface.  Drop it anywhere inside a UI or another
#' module — no paired server function is required.
#'
#' @param trigger  A `shiny.tag` (or plain text) that the tooltip attaches to.
#'   Defaults to a small `bsicons::bs_icon("info-circle")`.
#' @param type     Back-end to use.  One of `"tippy"` (default), `"bslib"`, or
#'   `"bootstrap"`.
#' @param contents Character string — the tooltip body.  HTML is allowed for
#'   `"tippy"` and `"bslib"`.
#' @param size     Font-size passed through to the rendered element.  Accepts
#'   any valid CSS value, e.g. `"0.8rem"`, `"12px"`.  `NULL` (default) leaves
#'   the font size unchanged.
#' @param style    Additional inline CSS string applied to the trigger wrapper,
#'   e.g. `"color:#2c7bb6; cursor:help"`.  `NULL` (default) applies none.
#' @param ...      Extra arguments forwarded directly to the underlying
#'   back-end function:
#'   * `"tippy"`     → [tippy::tippy()]
#'   * `"bslib"`     → [bslib::popover()]
#'   * `"bootstrap"` → ignored (all options live in HTML attributes)
#'
#' @return A `shiny.tag` ready to embed in any UI.
#'
#' @examples
#' \dontrun{
#' # tippy tooltip on a custom trigger
#' mod_tooltip(shiny::tags$span("Hover me"), contents = "Hello tippy!")
#'
#' # bslib popover
#' mod_tooltip(type = "bslib", contents = "A <b>bslib</b> popover")
#'
#' # plain Bootstrap tooltip
#' mod_tooltip(type = "bootstrap", contents = "Bootstrap tooltip")
#' }
#'
mod_tooltip <- function(
    trigger  = bsicons::bs_icon("info-circle"),
    type     = c("tippy", "bslib", "bootstrap"),
    contents = "",
    size     = NULL,
    style    = NULL,
    ...
) {
  type <- match.arg(type)

  # Build inline style string from size + style args
  css_parts <- character(0)
  if (!is.null(size))  css_parts <- c(css_parts, paste0("font-size:", size))
  if (!is.null(style)) css_parts <- c(css_parts, style)
  inline_style <- if (length(css_parts)) paste(css_parts, collapse = "; ") else NULL

  # Optionally wrap trigger in a styled span
  wrapped_trigger <- if (!is.null(inline_style)) {
    shiny::tags$span(style = inline_style, trigger)
  } else {
    trigger
  }

  switch(
    type,

    tippy = {
      tippy::tippy(
        wrapped_trigger,
        tooltip   = contents,
        allowHTML = TRUE,
        ...
      )
    },

    bslib = {
      bslib::popover(
        wrapped_trigger,
        shiny::HTML(contents),
        ...
      )
    },

    bootstrap = {
      # Render trigger as a tag so we can add data-bs-* attributes
      if (inherits(wrapped_trigger, "shiny.tag")) {
        wrapped_trigger$attribs[["data-bs-toggle"]] <- "tooltip"
        wrapped_trigger$attribs[["data-bs-title"]]  <- contents
        wrapped_trigger$attribs[["title"]]          <- contents
        wrapped_trigger
      } else {
        shiny::tags$span(
          `data-bs-toggle` = "tooltip",
          `data-bs-title`  = contents,
          title            = contents,
          wrapped_trigger
        )
      }
    }
  )
}
