#' Set the application-wide log threshold
#'
#' A thin wrapper around [logger::log_threshold()] that applies the chosen
#' level to every logger namespace used by **tooltipexplorer**.
#'
#' Log levels from lowest to highest verbosity:
#' `TRACE`, `DEBUG`, `INFO`, `SUCCESS`, `WARN`, `ERROR`, `FATAL`.
#' The default threshold is `INFO` — `TRACE` and `DEBUG` lines are silent
#' in production.
#'
#' @param level A `logger` log-level object, e.g. [logger::DEBUG],
#'   [logger::INFO] (default), [logger::WARN].
#'
#' @return Invisibly returns `level`.
#'
#' @examples
#' \dontrun{
#' # Verbose output during development
#' app_set_log_threshold(logger::DEBUG)
#'
#' # Quiet production mode
#' app_set_log_threshold(logger::WARN)
#' }
#'
#' @export
app_set_log_threshold <- function(level = logger::INFO) {
  namespaces <- c(
    "global",
    "tooltipexplorer/app",
    "tooltipexplorer/inputs",
    "tooltipexplorer/outputs",
    "tooltipexplorer/download",
    "tooltipexplorer/tooltip",
    "tooltipexplorer/hoverinfo"
  )
  for (ns in namespaces) {
    logger::log_threshold(level, namespace = ns)
  }
  invisible(level)
}
