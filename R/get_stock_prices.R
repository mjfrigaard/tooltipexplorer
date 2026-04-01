#' Retrieve historical adjusted prices via tidyquant
#'
#' Downloads daily adjusted closing prices from Yahoo Finance for one or
#' more ticker symbols over a given date range.
#'
#' @param tickers A character vector of ticker symbols.
#' @param from    A `Date` or date string (`"YYYY-MM-DD"`). Start of range.
#' @param to      A `Date` or date string. End of range. Defaults to today.
#'
#' @return A tibble with columns:
#'   `symbol`, `date`, `open`, `high`, `low`, `close`, `volume`, `adjusted`.
#'
#' @examples
#' \dontrun{
#' get_stock_prices(c("AAPL", "MSFT"), from = "2023-01-01")
#' }
#'
#' @export
get_stock_prices <- function(tickers, from, to = Sys.Date()) {
  tidyquant::tq_get(
    x    = tickers,
    get  = "stock.prices",
    from = from,
    to   = to
  )
}
