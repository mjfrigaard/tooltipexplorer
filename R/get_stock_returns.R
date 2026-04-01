#' Compute daily log returns from price data
#'
#' Calculates daily log returns from the adjusted closing price column
#' produced by [get_stock_prices()].
#'
#' @param prices A tibble returned by [get_stock_prices()].
#'
#' @return A tibble with columns `symbol`, `date`, `daily_return`.
#'
#' @export
get_stock_returns <- function(prices) {
  prices |>
    dplyr::arrange(.data$symbol, .data$date) |>
    dplyr::group_by(.data$symbol) |>
    dplyr::mutate(
      daily_return = log(.data$adjusted / dplyr::lag(.data$adjusted))
    ) |>
    dplyr::ungroup() |>
    dplyr::filter(!is.na(.data$daily_return)) |>
    dplyr::select("symbol", "date", "daily_return")
}
