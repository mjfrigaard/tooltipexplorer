#' Retrieve Fama-French three-factor data via tidyfinance
#'
#' Downloads the Fama-French three-factor dataset from Tidy Finance.
#'
#' @param start_date A `Date` or date string. Start of range.
#' @param end_date   A `Date` or date string. End of range. Defaults to today.
#'
#' @return A tibble with columns: `date`, `mkt_excess`, `smb`, `hml`,
#'   `risk_free`.
#'
#' @examples
#' \dontrun{
#' get_ff3_factors("2020-01-01", "2023-12-31")
#' }
#'
#' @export
get_ff3_factors <- function(start_date, end_date = Sys.Date()) {
  tidyfinance::download_data(
    type       = "factors_ff_3_monthly",
    start_date = start_date,
    end_date   = end_date
  )
}
