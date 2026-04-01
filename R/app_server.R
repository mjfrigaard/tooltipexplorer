#' Application server
#'
#' Top-level server function that initialises all module servers and wires
#' reactive values between them.
#'
#' @param input,output,session Standard Shiny server arguments.
#'
#' @return Nothing (called for side-effects).
#' @export
app_server <- function(input, output, session) {

  # ── Logging setup ────────────────────────────────────────────────────────
  # Set INFO threshold for all namespaces; change to logger::DEBUG for
  # verbose output during development.
  app_set_log_threshold(logger::INFO)

  logger::log_info(
    "Session started | session_id: {session$token}",
    namespace = "tooltipexplorer/app"
  )

  # ── 1. Input module ──────────────────────────────────────────────────────
  logger::log_debug(
    "Initialising mod_inputs_server()",
    namespace = "tooltipexplorer/app"
  )
  inputs_r <- with_logging(
    mod_inputs_server("inputs"),
    context = "app_server / mod_inputs_server",
    ns      = "tooltipexplorer/app"
  )
  logger::log_info(
    "mod_inputs_server() ready",
    namespace = "tooltipexplorer/app"
  )

  # ── 2. Output module (returns perf reactive for download) ────────────────
  logger::log_debug(
    "Initialising mod_outputs_server()",
    namespace = "tooltipexplorer/app"
  )
  perf_r <- with_logging(
    mod_outputs_server("outputs", inputs_r = inputs_r),
    context = "app_server / mod_outputs_server",
    ns      = "tooltipexplorer/app"
  )
  logger::log_info(
    "mod_outputs_server() ready",
    namespace = "tooltipexplorer/app"
  )

  # ── 3. Download module ───────────────────────────────────────────────────
  logger::log_debug(
    "Initialising mod_download_server()",
    namespace = "tooltipexplorer/app"
  )
  with_logging(
    mod_download_server("download", inputs_r = inputs_r, perf_r = perf_r),
    context = "app_server / mod_download_server",
    ns      = "tooltipexplorer/app"
  )
  logger::log_info(
    "mod_download_server() ready",
    namespace = "tooltipexplorer/app"
  )

  # ── Session end ──────────────────────────────────────────────────────────
  session$onSessionEnded(function() {
    logger::log_info(
      "Session ended   | session_id: {session$token}",
      namespace = "tooltipexplorer/app"
    )
  })
}
