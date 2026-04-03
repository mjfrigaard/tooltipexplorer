# Inputs module server

Handles the fetch button observer and assembles a reactive list of
current user inputs.

## Usage

``` r
mod_inputs_server(id)
```

## Arguments

- id:

  Module namespace id.

## Value

A reactive list with elements:

- `tickers`:

  Character vector of selected ticker symbols.

- `from`:

  `Date`. Start of the selected date range.

- `to`:

  `Date`. End of the selected date range.

- `vol_window`:

  Integer. Rolling-volatility window in trading days.

- `fetch`:

  Integer. Current value of the fetch action button.

## See also

[`mod_inputs_ui()`](https://mjfrigaard.github.io/tooltipexplorer/reference/mod_inputs_ui.md)
