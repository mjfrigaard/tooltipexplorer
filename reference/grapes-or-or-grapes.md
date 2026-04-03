# Null-coalescing operator

Returns `x` if it is non-`NULL`, otherwise returns `y`. A lightweight
alternative to `rlang::%||%` that avoids adding a heavy dependency.

## Usage

``` r
x %||% y
```

## Arguments

- x, y:

  Any R objects.

## Value

`x` if `!is.null(x)`, else `y`.

## Examples

``` r
NULL %||% "default"   # "default"
#> [1] "default"
"value" %||% "other"  # "value"
#> [1] "value"
```
