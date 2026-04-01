# Logging utilities
#
# Centralises logger configuration and provides a thin tryCatch wrapper used
# by every module.  Call `app_set_log_threshold()` once at startup (in
# `app_server()`) to control verbosity for the entire session.
#
# Log levels (low → high):
#   TRACE  DEBUG  INFO  SUCCESS  WARN  ERROR  FATAL
#
# Default threshold: INFO  (TRACE/DEBUG lines are silent in production).

# ── Threshold helper ──────────────────────────────────────────────────────────

#' Set the application-wide log threshold
#'
#' A thin wrapper around [logger::log_threshold()] that applies the chosen
#' level to every logger namespace used by **tooltipexplorer**.
#'
#' @param level A `logger` log-level object, e.g. `logger::DEBUG`,
#'   `logger::INFO` (default), `logger::WARN`.
#'
#' @return Invisibly returns `level`.
#'
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

# ── tryCatch wrapper ──────────────────────────────────────────────────────────

#' Execute an expression with structured error and warning logging
#'
#' Wraps `expr` in a `tryCatch()` that:
#' * logs warnings via [logger::log_warn()] and re-issues them so Shiny can
#'   also handle them
#' * logs errors via [logger::log_error()] with a full
#'   [rlang::trace_back()] and re-throws so the caller / Shiny sees the
#'   error normally
#'
#' @param expr     Expression to evaluate.
#' @param context  Short string identifying the call site, e.g.
#'   `"mod_outputs / prices_r"`.  Prepended to every log message.
#' @param ns       Logger namespace string (default `"tooltipexplorer/app"`).
#'
#' @return The value of `expr` on success; re-throws on error.
#'
with_logging <- function(expr, context = "", ns = "tooltipexplorer/app") {
  tryCatch(
    withCallingHandlers(
      expr,
      warning = function(w) {
        logger::log_warn(
          "[{context}] Warning: {conditionMessage(w)}",
          namespace = ns
        )
        invokeRestart("muffleWarning")
      }
    ),
    error = function(e) {
      logger::log_error(
        "[{context}] Error: {conditionMessage(e)}",
        namespace = ns
      )
      stop(e)
    }
  )
}
