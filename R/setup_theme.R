#' Setup tooltipexplorer theme and styling
#'
#' Creates a custom bslib theme with the app's dark "terminal" palette and
#' typography. Called internally by [app_ui()] to apply global theming.
#'
#' @return A `bs_theme()` object with custom variables and CSS
#'
#' @details
#' The theme defines a dark, Bloomberg-terminal aesthetic:
#' - **Palette:** near-black background, amber primary, green/red data accents,
#'   cyan links
#' - **Typography:** IBM Plex Mono throughout for a fixed-width terminal feel
#' - **Surfaces:** flat, sharp-cornered panels with thin borders
#'
#' @examples
#' \dontrun{
#' theme <- tooltipexplorer_theme()
#' # Use in app_ui():
#' # page_sidebar(theme = theme, ...)
#' }
#'
#' @export
tooltipexplorer_theme <- function() {
  mono <- '"IBM Plex Mono", "JetBrains Mono", "SFMono-Regular", "Courier New", monospace'
  bslib::bs_theme(
    version = 5,
    # Base surfaces
    bg = "#0b0e13",           # Terminal background (near-black)
    fg = "#d5dde5",           # Body text
    # Semantic palette
    primary = "#ff9e1b",      # Bloomberg amber
    secondary = "#8b95a1",    # Muted grey
    success = "#2ecc71",      # Up / green
    info = "#4ea1ff",         # Cyan
    warning = "#ff6a1a",      # Orange
    danger = "#ff4d4f",       # Down / red
    # Typography (mono everywhere)
    font_family_base = mono,
    font_family_monospace = mono,
    heading_font_family = mono,
    font_size_base = "0.9rem",
    line_height_base = 1.55,
    # Surfaces and borders
    body_bg = "#0b0e13",
    body_color = "#d5dde5",
    border_color = "#2a313b",
    "card-bg" = "#12161d",
    "card-cap-bg" = "#1a1f28",
    "card-border-color" = "#2a313b",
    # Links
    link_color = "#4ea1ff",
    link_hover_color = "#ffbf57"
  )
}
