# Dark terminal theme for reactable tables

Returns a
[`reactable::reactableTheme()`](https://glin.github.io/reactable/reference/reactableTheme.html)
matching the app's Bloomberg-terminal palette (dark panels, amber
headers, mono type, tabular numerals). Set once as the global
`reactable.theme` option in
[`launch()`](https://mjfrigaard.github.io/tooltipexplorer/reference/launch.md)
so every table inherits it without per-call theming.

## Usage

``` r
utils_reactable_theme()
```

## Value

A
[`reactable::reactableTheme`](https://glin.github.io/reactable/reference/reactableTheme.html)
object
