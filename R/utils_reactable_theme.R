#' Dark terminal theme for reactable tables
#'
#' Returns a `reactable::reactableTheme()` matching the app's Bloomberg-terminal
#' palette (dark panels, amber headers, mono type, tabular numerals). Set once as
#' the global `reactable.theme` option in [launch()] so every table inherits
#' it without per-call theming.
#'
#' @return A `reactable::reactableTheme` object
#' @keywords internal
utils_reactable_theme <- function() {
  mono <- "'IBM Plex Mono','JetBrains Mono','SFMono-Regular','Courier New',monospace"
  reactable::reactableTheme(
    color = "#d5dde5",
    backgroundColor = "#12161d",
    borderColor = "#2a313b",
    borderWidth = "1px",
    stripedColor = "rgba(255, 158, 27, 0.04)",
    highlightColor = "rgba(255, 158, 27, 0.09)",
    cellPadding = "6px 9px",
    style = list(
      fontFamily = mono,
      fontSize = "0.82rem",
      fontVariantNumeric = "tabular-nums"
    ),
    tableStyle = list(borderColor = "#2a313b"),
    headerStyle = list(
      backgroundColor = "#1a1f28",
      color = "#ff9e1b",
      fontWeight = 600,
      textTransform = "uppercase",
      letterSpacing = "0.03em",
      borderBottom = "1px solid #ff9e1b",
      "&:hover[aria-sort]" = list(color = "#ffbf57"),
      "&[aria-sort='ascending'], &[aria-sort='descending']" = list(color = "#ffbf57")
    ),
    groupHeaderStyle = list(color = "#ffbf57", borderColor = "#2a313b"),
    footerStyle = list(color = "#8b95a1", borderTop = "1px solid #2a313b"),
    rowHighlightStyle = list(backgroundColor = "rgba(255, 158, 27, 0.09)"),
    rowSelectedStyle = list(backgroundColor = "rgba(78, 161, 255, 0.12)"),
    inputStyle = list(
      backgroundColor = "#1a1f28",
      color = "#d5dde5",
      border = "1px solid #2a313b"
    ),
    filterInputStyle = list(
      backgroundColor = "#1a1f28",
      color = "#d5dde5",
      border = "1px solid #2a313b"
    ),
    searchInputStyle = list(
      backgroundColor = "#1a1f28",
      color = "#d5dde5",
      border = "1px solid #2a313b"
    ),
    selectStyle = list(
      backgroundColor = "#1a1f28",
      color = "#d5dde5",
      borderColor = "#2a313b"
    ),
    paginationStyle = list(color = "#8b95a1", borderTop = "1px solid #2a313b"),
    pageButtonStyle = list(color = "#d5dde5"),
    pageButtonHoverStyle = list(backgroundColor = "#1a1f28", color = "#ffbf57"),
    pageButtonActiveStyle = list(backgroundColor = "#ff9e1b", color = "#05070a"),
    pageButtonCurrentStyle = list(backgroundColor = "#ff9e1b", color = "#05070a")
  )
}
