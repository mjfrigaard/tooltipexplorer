#' Custom head tags for tooltipexplorer app
#'
#' Adds Google Fonts (IBM Plex Mono) and the Bloomberg-terminal custom CSS to
#' the app head.
#'
#' @return A `shiny::tags$head()` containing font imports and custom styles
#' @noRd
tooltipexplorer_head <- function() {
  shiny::tags$head(
    # Import IBM Plex fonts (mono for the terminal look, sans for long-form text)
    shiny::tags$link(
      href = "https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600;700&family=IBM+Plex+Sans:wght@400;500;600&display=swap",
      rel = "stylesheet"
    ),
    # Custom CSS
    shiny::tags$style(htmltools::HTML("
      :root {
        --bbg-bg:       #0b0e13;
        --bbg-panel:    #12161d;
        --bbg-panel-2:  #1a1f28;
        --bbg-border:   #2a313b;
        --bbg-amber:    #ff9e1b;
        --bbg-amber-2:  #ffbf57;
        --bbg-orange:   #ff6a1a;
        --bbg-green:    #2ecc71;
        --bbg-red:      #ff4d4f;
        --bbg-cyan:     #4ea1ff;
        --bbg-text:     #d5dde5;
        --bbg-dim:      #8b95a1;
        --bbg-white:    #f2f5f8;
        --bbg-mono: 'IBM Plex Mono', 'JetBrains Mono', 'SFMono-Regular', 'Courier New', monospace;
      }

      /* Typography */
      body {
        font-family: var(--bbg-mono);
        font-size: 0.9rem;
        line-height: 1.55;
        color: var(--bbg-text);
        background-color: var(--bbg-bg);
        -webkit-font-smoothing: antialiased;
      }

      h1, h2, h3, h4, h5, h6, .navbar-brand {
        font-family: var(--bbg-mono);
        font-weight: 600;
        letter-spacing: 0.02em;
        color: var(--bbg-white);
        text-transform: uppercase;
      }

      code, pre, .formula, kbd, .verbatim {
        font-family: var(--bbg-mono);
        font-size: 0.85em;
        color: var(--bbg-amber-2);
        background-color: var(--bbg-panel-2);
      }

      /* Help text */
      .help-text, .form-text {
        font-size: 0.8rem;
        color: var(--bbg-dim);
      }

      /* Form controls */
      .form-label {
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.04em;
        font-size: 0.78rem;
        color: var(--bbg-amber);
      }

      .form-control, .form-select, input[type='number'], select, textarea {
        background-color: var(--bbg-panel-2);
        border: 1px solid var(--bbg-border);
        border-radius: 2px;
        color: var(--bbg-text);
      }

      .form-control::placeholder { color: var(--bbg-dim); }

      .form-control:focus, .form-select:focus, input[type='number']:focus,
      select:focus, textarea:focus {
        background-color: var(--bbg-panel-2);
        color: var(--bbg-text);
        border-color: var(--bbg-amber);
        box-shadow: 0 0 0 0.15rem rgba(255, 158, 27, 0.35);
        outline: none;
      }

      /* Value boxes */
      .bslib-value-box {
        border: 1px solid var(--bbg-border);
        border-left: 3px solid var(--bbg-amber);
        border-radius: 2px;
        box-shadow: none;
        padding: 1.25rem;
        background: var(--bbg-panel);
        transition: background-color 0.2s ease;
      }

      .bslib-value-box .bslib-value-box-title {
        font-size: 0.72rem;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.08em;
        color: var(--bbg-amber);
        margin-bottom: 0.4rem;
      }

      .bslib-value-box .bslib-value-box-value {
        font-size: 1.4rem;
        font-weight: 700;
        color: var(--bbg-white);
        font-variant-numeric: tabular-nums;
      }

      /* Cards / panels */
      .card, .bslib-card {
        background-color: var(--bbg-panel);
        border: 1px solid var(--bbg-border);
        border-radius: 2px;
        box-shadow: none;
      }

      .card-header, .bslib-card .card-header {
        background-color: var(--bbg-panel-2);
        border-bottom: 1px solid var(--bbg-amber);
        font-family: var(--bbg-mono);
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        font-size: 0.82rem;
        color: var(--bbg-amber);
      }

      /* Navbar */
      .navbar {
        background-color: #05070a !important;
        border-bottom: 1px solid var(--bbg-amber);
        box-shadow: none;
      }

      .navbar-brand {
        font-size: 1.15rem;
        font-weight: 700;
        letter-spacing: 0.06em;
        color: var(--bbg-amber) !important;
      }

      .nav-link {
        color: var(--bbg-dim) !important;
        font-weight: 500;
        text-transform: uppercase;
        letter-spacing: 0.03em;
        font-size: 0.82rem;
        transition: color 0.15s ease;
      }

      .nav-link:hover { color: var(--bbg-amber-2) !important; }

      .nav-link.active {
        color: var(--bbg-amber) !important;
        border-bottom: 2px solid var(--bbg-amber);
      }

      /* Buttons */
      .btn {
        border-radius: 2px;
        text-transform: uppercase;
        letter-spacing: 0.04em;
        font-size: 0.8rem;
        font-weight: 600;
      }

      .btn-primary {
        background-color: var(--bbg-amber);
        border-color: var(--bbg-amber);
        color: #05070a;
      }

      .btn-primary:hover, .btn-primary:focus, .btn-primary:active {
        background-color: var(--bbg-amber-2);
        border-color: var(--bbg-amber-2);
        color: #05070a;
        box-shadow: 0 0 0 0.15rem rgba(255, 158, 27, 0.4);
      }

      .btn-success { background-color: var(--bbg-green); border-color: var(--bbg-green); color: #05070a; }
      .btn-danger  { background-color: var(--bbg-red);   border-color: var(--bbg-red);   color: #05070a; }
      .btn-info    { background-color: var(--bbg-cyan);  border-color: var(--bbg-cyan);  color: #05070a; }

      .btn-outline-secondary {
        color: var(--bbg-cyan);
        border-color: var(--bbg-border);
      }
      .btn-outline-secondary:hover {
        background-color: var(--bbg-cyan);
        color: #05070a;
        border-color: var(--bbg-cyan);
      }

      /* Tabs */
      .nav-tabs { border-bottom: 1px solid var(--bbg-border); }

      .nav-tabs .nav-link {
        color: var(--bbg-dim) !important;
        border: none;
        border-bottom: 2px solid transparent;
        font-weight: 500;
      }

      .nav-tabs .nav-link:hover {
        color: var(--bbg-amber-2) !important;
        border-bottom-color: var(--bbg-border);
      }

      .nav-tabs .nav-link.active {
        color: var(--bbg-amber) !important;
        border-bottom-color: var(--bbg-amber);
        background-color: transparent;
      }

      .card-header .nav-tabs .nav-link.active { color: var(--bbg-amber) !important; }

      /* Tables */
      table { color: var(--bbg-text); }

      table th {
        background-color: var(--bbg-panel-2);
        color: var(--bbg-amber);
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.03em;
        border-bottom: 1px solid var(--bbg-amber);
      }

      table td {
        color: var(--bbg-text);
        border-bottom: 1px solid var(--bbg-border);
        font-variant-numeric: tabular-nums;
      }

      tr:hover { background-color: rgba(255, 158, 27, 0.06); }

      /* reactable dark theme */
      .Reactable, .rt-table {
        background-color: var(--bbg-panel);
        color: var(--bbg-text);
      }
      .rt-th, .rt-td {
        border-color: var(--bbg-border) !important;
        color: var(--bbg-text);
      }
      .rt-th {
        background-color: var(--bbg-panel-2);
        color: var(--bbg-amber);
        text-transform: uppercase;
        letter-spacing: 0.03em;
        font-size: 0.75rem;
      }
      .rt-tr-striped, .rt-tr:hover { background-color: rgba(255, 158, 27, 0.05) !important; }
      .rt-pagination { color: var(--bbg-dim); border-top-color: var(--bbg-border); }

      /* Selectize (ticker picker) */
      .selectize-input {
        background-color: var(--bbg-panel-2) !important;
        border: 1px solid var(--bbg-border) !important;
        color: var(--bbg-text) !important;
        box-shadow: none !important;
      }
      .selectize-input.focus {
        border-color: var(--bbg-amber) !important;
        box-shadow: 0 0 0 0.15rem rgba(255, 158, 27, 0.35) !important;
      }
      .selectize-input > input { color: var(--bbg-text) !important; }
      .selectize-control.multi .selectize-input > div {
        background-color: var(--bbg-panel) !important;
        border: 1px solid var(--bbg-border) !important;
        color: var(--bbg-text) !important;
      }
      .selectize-dropdown, .selectize-dropdown.form-control {
        background-color: var(--bbg-panel-2) !important;
        border: 1px solid var(--bbg-border) !important;
        color: var(--bbg-text) !important;
      }
      .selectize-dropdown-content .option,
      .selectize-dropdown-content .create {
        color: var(--bbg-text) !important;
      }
      .selectize-dropdown-content .option.active {
        background-color: rgba(255, 158, 27, 0.15) !important;
        color: var(--bbg-amber-2) !important;
      }

      /* ionRangeSlider (rolling vol window) */
      .irs--shiny .irs-line { background: var(--bbg-panel-2); border-color: var(--bbg-border); }
      .irs--shiny .irs-bar { background: var(--bbg-amber); border-color: var(--bbg-amber); }
      .irs--shiny .irs-min, .irs--shiny .irs-max { color: var(--bbg-dim); background: var(--bbg-panel-2); }
      .irs--shiny .irs-from, .irs--shiny .irs-to, .irs--shiny .irs-single {
        background-color: var(--bbg-amber);
        color: #05070a;
      }
      .irs--shiny .irs-handle > i:first-child { background-color: var(--bbg-amber-2); }
      .irs--shiny .irs-grid-text { color: var(--bbg-dim); }

      /* Bootstrap datepicker (date range) */
      .datepicker {
        background-color: var(--bbg-panel-2) !important;
        border: 1px solid var(--bbg-border) !important;
        color: var(--bbg-text) !important;
      }
      .datepicker table tr td, .datepicker table tr th {
        color: var(--bbg-text) !important;
      }
      .datepicker table tr td.old, .datepicker table tr td.new {
        color: var(--bbg-dim) !important;
      }
      .datepicker table tr td.day:hover, .datepicker table tr th:hover {
        background-color: var(--bbg-panel) !important;
      }
      .datepicker table tr td.active.day, .datepicker table tr td.active.day:hover {
        background-color: var(--bbg-amber) !important;
        background-image: none !important;
        color: #05070a !important;
      }
      .datepicker table tr td.today, .datepicker table tr td.today:hover {
        background-color: var(--bbg-panel) !important;
        background-image: none !important;
        color: var(--bbg-amber-2) !important;
      }
      .datepicker .datepicker-switch,
      .datepicker .prev,
      .datepicker .next {
        color: var(--bbg-text) !important;
      }

      /* Popovers / tooltips (bslib, hint.css) */
      .popover {
        background-color: var(--bbg-panel-2);
        border: 1px solid var(--bbg-border);
        color: var(--bbg-text);
      }
      .popover-header {
        background-color: var(--bbg-panel);
        border-bottom: 1px solid var(--bbg-border);
        color: var(--bbg-amber);
      }
      .popover-body { color: var(--bbg-text); }
      .bs-popover-auto[data-popper-placement^='top'] > .popover-arrow::before,
      .bs-popover-top > .popover-arrow::before { border-top-color: var(--bbg-border); }
      .bs-popover-auto[data-popper-placement^='bottom'] > .popover-arrow::before,
      .bs-popover-bottom > .popover-arrow::before { border-bottom-color: var(--bbg-border); }

      /* shinyhelper modal */
      .modal-content {
        background-color: var(--bbg-panel);
        color: var(--bbg-text);
        border: 1px solid var(--bbg-border);
      }
      .modal-header { border-bottom: 1px solid var(--bbg-border); }
      .modal-footer { border-top: 1px solid var(--bbg-border); }

      /* Alerts */
      .alert {
        border: none;
        border-left: 3px solid;
        border-radius: 2px;
        background-color: var(--bbg-panel);
        color: var(--bbg-text);
      }
      .alert-warning { border-left-color: var(--bbg-orange); }
      .alert-info    { border-left-color: var(--bbg-cyan); }
      .alert-success { border-left-color: var(--bbg-green); }
      .alert-danger  { border-left-color: var(--bbg-red); }

      /* Sidebar */
      .bslib-sidebar-layout > .sidebar, .sidebar {
        background-color: var(--bbg-panel);
        border-right: 1px solid var(--bbg-border);
      }

      /* Footer */
      footer {
        color: var(--bbg-dim);
        border-color: var(--bbg-border) !important;
      }

      /* Scrollbars */
      ::-webkit-scrollbar { width: 10px; height: 10px; }
      ::-webkit-scrollbar-track { background: var(--bbg-bg); }
      ::-webkit-scrollbar-thumb { background: var(--bbg-border); border-radius: 0; }
      ::-webkit-scrollbar-thumb:hover { background: var(--bbg-amber); }

      /* Responsive */
      @media (max-width: 768px) {
        .bslib-sidebar-layout > .sidebar, .sidebar {
          margin-bottom: 1.5rem;
          border-right: none;
          border-bottom: 1px solid var(--bbg-border);
        }
      }
    "))
  )
}
