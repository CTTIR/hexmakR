#' Launch the hexmakR Shiny App
#'
#' @title Launch Interactive Hex Sticker Designer
#' @description Opens an interactive Shiny app for designing hex stickers
#'   visually. The app provides live preview, theme selection, icon picking,
#'   custom color overrides, and PNG export.
#'
#' @param ... Additional arguments passed to [shiny::runApp()].
#'
#' @return Does not return; runs the Shiny app.
#'
#' @examples
#' if (interactive()) {
#'   hexmakr_app()
#' }
#'
#' @seealso [hex_sticker()], [save_hex()]
#' @family stickers
#' @export
hexmakr_app <- function(...) {
  app <- .build_shiny_app()
  shiny::runApp(app, ...)
}

#' @noRd
.build_shiny_app <- function() {

  # ---- CSS ---------------------------------------------------------------
  custom_css <- "
    body { background: #0F172A !important; }
    .hexmakr-preview-panel {
      background: #1E293B;
      border-radius: 12px;
      padding: 20px;
      text-align: center;
    }
    .hexmakr-controls-panel {
      max-height: 90vh;
      overflow-y: auto;
    }
    .well { background: #1E293B !important; border-color: #334155 !important; }
    label { color: #94A3B8 !important; }
    h3 { color: #F1F5F9; }
    .form-control {
      background: #0F172A !important;
      color: #E2E8F0 !important;
      border-color: #334155 !important;
    }
    .hexmakr-theme-btn:hover {
      opacity: 0.85;
      transform: scale(1.03);
    }
    .btn-primary {
      background: #0EA5E9 !important;
      border-color: #0EA5E9 !important;
    }
    .btn-success {
      background: #10B981 !important;
      border-color: #10B981 !important;
    }
  "

  # ---- UI ----------------------------------------------------------------
  ui <- shiny::fluidPage(
    shiny::tags$head(
      shiny::tags$style(shiny::HTML(custom_css))
    ),
    title = "hexmakR - Hex Sticker Designer",
    shiny::fluidRow(
      # Left: Preview + info
      shiny::column(5,
        shiny::div(
          class = "hexmakr-preview-panel",
          shiny::HTML(.shiny_logo_svg()),
          shiny::tags$p("Interactive Hex Sticker Designer",
                        style = "color:#94A3B8; font-size:13px; margin-top:8px; margin-bottom:16px;"),
          shiny::plotOutput("hex_preview", width = "100%", height = "340px"),
          shiny::tags$hr(style = "border-color:#334155;"),
          shiny::downloadButton("download_png", "Export PNG",
                                class = "btn-success",
                                style = "width:100%;"),

          # --- About section ---
          shiny::tags$hr(style = "border-color:#334155; margin-top:20px;"),
          shiny::tags$div(
            style = "text-align:left; color:#94A3B8; font-size:12px; line-height:1.6;",
            shiny::tags$p(
              style = "margin-bottom:8px; color:#CBD5E1;",
              shiny::tags$strong("About hexmakR")
            ),
            shiny::tags$p(
              "Design publication-ready hexagon stickers for R packages. ",
              "Choose from 19 curated color themes (dark + light), 46 built-in ",
              "scientific and technical icons, 13 fonts, and export to transparent PNG."
            ),
            shiny::tags$p(
              style = "margin-bottom:6px;",
              shiny::tags$strong("How to use:"),
              shiny::tags$br(),
              "1. Enter your package name and optional subtitle",
              shiny::tags$br(),
              "2. Pick an icon or upload your own image",
              shiny::tags$br(),
              "3. Choose a theme and adjust colors as needed",
              shiny::tags$br(),
              "4. Click ", shiny::tags$em("Export PNG"), " to download"
            ),
            shiny::tags$p(
              style = "margin-bottom:6px;",
              shiny::tags$strong("Programmatic usage:"),
              shiny::tags$br(),
              shiny::tags$code(
                style = "color:#38BDF8; background:#0F172A; padding:2px 6px; border-radius:4px; font-size:11px;",
                "hex_sticker(\"mypkg\", icon = \"dna\", theme = \"genomics\")"
              )
            ),
            shiny::tags$p(
              style = "margin-top:12px; font-size:11px; color:#64748B;",
              shiny::tags$span(
                paste0("hexmakR v", utils::packageVersion("hexmakR"))
              ),
              shiny::tags$span(" | "),
              shiny::tags$a(
                href = "https://github.com/r-heller/hexmakR",
                target = "_blank",
                style = "color:#38BDF8; text-decoration:none;",
                "GitHub"
              ),
              shiny::tags$span(" | "),
              shiny::tags$a(
                href = "https://r-heller.github.io/hexmakR/",
                target = "_blank",
                style = "color:#38BDF8; text-decoration:none;",
                "Documentation"
              )
            )
          )
        )
      ),
      # Right: Controls
      shiny::column(7,
        shiny::div(
          class = "hexmakr-controls-panel",
          mod_text_ui("text"),
          mod_icon_ui("icon"),
          mod_theme_ui("theme"),
          mod_colors_ui("colors"),
          mod_border_ui("border")
        )
      )
    )
  )

  # ---- Server ------------------------------------------------------------
  server <- function(input, output, session) {
    text_vals   <- mod_text_server("text")
    icon_vals   <- mod_icon_server("icon")
    theme_vals  <- mod_theme_server("theme")
    color_vals  <- mod_colors_server("colors")
    border_vals <- mod_border_server("border")

    # Reactive sticker
    current_sticker <- shiny::reactive({
      tv <- text_vals()
      iv <- icon_vals()
      thv <- theme_vals()
      cv <- color_vals()
      bv <- border_vals()

      # Use custom colors only if they differ from defaults
      # (always pass them through; hex_sticker() overrides theme when provided)
      tryCatch(
        hex_sticker(
          name         = tv$name,
          subtitle     = tv$subtitle,
          url          = tv$url,
          icon         = iv$icon,
          icon_image   = iv$icon_image,
          icon_size    = iv$icon_size,
          theme        = thv$theme,
          mode         = thv$mode,
          bg           = cv$bg,
          accent       = cv$accent,
          text_color   = cv$text_color,
          border_color = cv$border_color,
          sub_color    = cv$sub_color,
          font_family  = tv$font_family,
          font_bold    = tv$font_bold,
          font_italic  = tv$font_italic,
          font_size    = tv$font_size,
          border_width = bv$border_width,
          inner_border = bv$inner_border
        ),
        error = function(e) {
          # Return a minimal sticker on error
          hex_sticker(name = tv$name %||% "package",
                      theme = "stats", mode = "dark")
        }
      )
    })

    output$hex_preview <- shiny::renderPlot({
      current_sticker()
    }, bg = "transparent")

    output$download_png <- shiny::downloadHandler(
      filename = function() {
        paste0(text_vals()$name %||% "hexsticker", ".png")
      },
      content = function(file) {
        save_hex(current_sticker(), filename = file, width = 600, dpi = 300)
      }
    )
  }

  shiny::shinyApp(ui = ui, server = server)
}

#' @noRd
.shiny_logo_svg <- function() {
  logo_path <- system.file("logo", "logo.svg", package = "hexmakR")
  if (nzchar(logo_path) && file.exists(logo_path)) {
    svg_text <- paste(readLines(logo_path, warn = FALSE), collapse = "\n")
    # Wrap in a div to control sizing
    paste0('<div style="display:inline-block; width:80px; height:93px;">',
           gsub('width="500" height="580"',
                'width="80" height="93" style="max-width:80px;"',
                svg_text),
           '</div>')
  } else {
    '<h3 style="color:#38BDF8; margin-bottom:4px;">hexmakR</h3>'
  }
}
