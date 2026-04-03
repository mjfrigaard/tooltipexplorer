# Outputs module UI

Main content area: a
[`shiny::uiOutput()`](https://rdrr.io/pkg/shiny/man/htmlOutput.html) for
KPI value boxes and a
[`bslib::navset_card_tab()`](https://rstudio.github.io/bslib/reference/navset.html)
with one tab per tooltip/hover-info demo (bslib, shinyhelper, prompter,
shinyalert, reactable).

## Usage

``` r
mod_outputs_ui(id)
```

## Arguments

- id:

  Module namespace id.

## Value

A
[`shiny::tagList()`](https://rstudio.github.io/htmltools/reference/tagList.html)
ready to embed in
[`app_ui()`](https://mjfrigaard.github.io/tooltipexplorer/reference/app_ui.md).

## See also

[`mod_outputs_server()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_outputs_server.md)
