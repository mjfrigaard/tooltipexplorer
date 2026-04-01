#' Launch the Tooltip Explorer Shiny app
#'
#' Convenience wrapper that calls [shiny::shinyApp()] with the package's
#' [app_ui()] and [app_server()] functions. Pass any additional arguments
#' through to `shinyApp()` (e.g. `options = list(port = 4321)`).
#'
#' @param ... Additional arguments forwarded to [shiny::shinyApp()].
#'
#' @return A Shiny app object (invisibly). When called interactively the app
#'   opens in the viewer / browser.
#'
#' @examples
#' \dontrun{
#' tooltipexplorer::launch()
#'
#' # Custom port
#' tooltipexplorer::launch(options = list(port = 4242, launch.browser = TRUE))
#' }
#'
#' @export
launch <- function(...) {
  shiny::shinyApp(
    ui     = app_ui(),
    server = app_server,
    ...
  )
}
