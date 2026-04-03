#' Null-coalescing operator
#'
#' Returns `x` if it is non-`NULL`, otherwise returns `y`.  A lightweight
#' alternative to `rlang::%||%` that avoids adding a heavy dependency.
#'
#' @param x,y Any R objects.
#'
#' @return `x` if `!is.null(x)`, else `y`.
#'
#' @examples
#' NULL %||% "default"   # "default"
#' "value" %||% "other"  # "value"
#'
#' @export
`%||%` <- function(x, y) if (!is.null(x)) x else y
