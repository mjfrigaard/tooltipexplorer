#' Compute rolling annualised volatility
#'
#' Computes a rolling standard deviation of daily log returns, annualised
#' by multiplying by `sqrt(252)`.
#'
#' @param returns A tibble returned by [get_stock_returns()].
#' @param window  Integer. Rolling window in trading days. Default 30.
#'
#' @return The input tibble with an additional `rolling_vol` column.
#'
#' @export
compute_rolling_vol <- function(returns, window = 30L) {
  returns |>
    dplyr::group_by(.data$symbol) |>
    dplyr::mutate(
      rolling_vol = slider::slide_dbl(
        .x        = .data$daily_return,
        .f        = sd,
        .before   = window - 1L,
        .complete = TRUE
      ) * sqrt(252)
    ) |>
    dplyr::ungroup()
}
