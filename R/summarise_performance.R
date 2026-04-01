#' Summarise performance metrics by ticker
#'
#' Computes annualised return, annualised volatility, and Sharpe ratio
#' (assuming zero risk-free rate) for each ticker.
#'
#' @param returns A tibble returned by [get_stock_returns()].
#'
#' @return A tibble with columns:
#'   `symbol`, `ann_return`, `ann_vol`, `sharpe`.
#'
#' @export
summarise_performance <- function(returns) {
  returns |>
    dplyr::summarise(
      ann_return = mean(.data$daily_return, na.rm = TRUE) * 252,
      ann_vol    = sd(.data$daily_return,   na.rm = TRUE) * sqrt(252),
      sharpe     = ann_return / ann_vol,
      .by        = symbol
    )
}
