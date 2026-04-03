# Download module server

Renders a parameterised R Markdown report from
`inst/report_template.Rmd` and serves it as a file download. The report
is rendered into an isolated temporary directory so the working
directory of the Shiny session is not affected.

## Usage

``` r
mod_download_server(id, inputs_r, perf_r)
```

## Arguments

- id:

  Module namespace id.

- inputs_r:

  Reactive list returned by
  [`mod_inputs_server()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_inputs_server.md).

- perf_r:

  Reactive tibble returned by
  [`mod_outputs_server()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_outputs_server.md).

## Value

Called for side-effects; returns `NULL` invisibly.

## See also

[`mod_download_ui()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_download_ui.md)
