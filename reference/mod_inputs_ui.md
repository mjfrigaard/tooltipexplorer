# Inputs module UI

Sidebar controls for ticker selection, date range, rolling-vol window,
and report download. Returns a
[`bslib::sidebar()`](https://rstudio.github.io/bslib/reference/sidebar.html)
ready to embed in a
[`bslib::page_sidebar()`](https://rstudio.github.io/bslib/reference/page_sidebar.html)
layout.

## Usage

``` r
mod_inputs_ui(id)
```

## Arguments

- id:

  Module namespace id.

## Value

A
[`bslib::sidebar`](https://rstudio.github.io/bslib/reference/sidebar.html)
tag object.

## See also

[`mod_inputs_server()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_inputs_server.md)
