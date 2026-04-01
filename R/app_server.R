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

  # ── 1. Input module ─────────────────────────────────────────────────────
  inputs_r <- mod_inputs_server("inputs")

  # ── 2. Output module (returns perf reactive for download) ───────────────
  perf_r <- mod_outputs_server("outputs", inputs_r = inputs_r)

  # ── 3. Download module ──────────────────────────────────────────────────
  mod_download_server("download", inputs_r = inputs_r, perf_r = perf_r)
}
