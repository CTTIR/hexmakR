# ---------------------------------------------------------------------------
# Shiny modules for hexmakR app
# ---------------------------------------------------------------------------

# ---- Text module -----------------------------------------------------------

#' @noRd
mod_text_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::wellPanel(
    style = "background:#1E293B; border:1px solid #334155; color:#E2E8F0;",
    shiny::h4("Text", style = "color:#94A3B8; margin-top:0;"),
    shiny::textInput(ns("name"), "Package Name", value = "mypackage",
                     width = "100%"),
    shiny::textInput(ns("subtitle"), "Subtitle", value = "",
                     width = "100%"),
    shiny::textInput(ns("url"), "URL", value = "",
                     width = "100%"),
    shiny::fluidRow(
      shiny::column(6,
        shiny::sliderInput(ns("font_size"), "Font Size",
                           min = 6, max = 32, value = 12, step = 1)
      ),
      shiny::column(6,
        shiny::selectInput(ns("font_family"), "Font",
                           choices = c(
                             "Monospace" = "mono",
                             "Courier New" = "courier",
                             "Consolas" = "consolas",
                             "Source Code Pro" = "source_code",
                             "Fira Code" = "fira_code",
                             "Serif" = "serif",
                             "Times New Roman" = "times",
                             "Palatino" = "palatino",
                             "Sans-serif" = "sans",
                             "Helvetica" = "helvetica",
                             "Roboto" = "roboto",
                             "Open Sans" = "open_sans",
                             "Lato" = "lato"
                           ),
                           selected = "mono")
      )
    ),
    shiny::fluidRow(
      shiny::column(6,
        shiny::checkboxInput(ns("font_bold"), "Bold", value = TRUE)
      ),
      shiny::column(6,
        shiny::checkboxInput(ns("font_italic"), "Italic", value = FALSE)
      )
    )
  )
}

#' @noRd
mod_text_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    shiny::reactive(list(
      name        = input$name,
      subtitle    = if (nzchar(input$subtitle)) input$subtitle else NULL,
      url         = if (nzchar(input$url)) input$url else NULL,
      font_family = input$font_family,
      font_bold   = input$font_bold,
      font_italic = input$font_italic,
      font_size   = input$font_size
    ))
  })
}

# ---- Icon module -----------------------------------------------------------

#' @noRd
mod_icon_ui <- function(id) {
  ns <- shiny::NS(id)
  # Build icon choices per category
  all_cats <- names(.icons)
  icon_choices_all <- c("(none)" = "",
    unlist(lapply(all_cats, function(cat) {
      icons <- .icons[[cat]]
      setNames(names(icons), paste0("[", toupper(substr(cat,1,1)),
                                    substr(cat,2,nchar(cat)), "] ",
                                    vapply(icons, `[[`, character(1), "label")))
    }), use.names = TRUE)
  )

  shiny::wellPanel(
    style = "background:#1E293B; border:1px solid #334155; color:#E2E8F0;",
    shiny::h4("Icon", style = "color:#94A3B8; margin-top:0;"),
    shiny::selectInput(ns("icon"), "Built-in Icon",
                       choices = icon_choices_all,
                       selected = "atom",
                       width = "100%"),
    shiny::fileInput(ns("icon_image"), "Custom Image (PNG/JPG)",
                     accept = c(".png", ".jpg", ".jpeg"),
                     width = "100%"),
    shiny::sliderInput(ns("icon_size"), "Icon Size",
                       min = 0.3, max = 2.5, value = 1.0, step = 0.1)
  )
}

#' @noRd
mod_icon_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    shiny::reactive(list(
      icon       = if (nzchar(input$icon)) input$icon else NULL,
      icon_image = input$icon_image$datapath,
      icon_size  = input$icon_size
    ))
  })
}

# ---- Theme module ----------------------------------------------------------

#' @noRd
mod_theme_ui <- function(id) {
  ns <- shiny::NS(id)

  theme_buttons <- lapply(names(.themes), function(tn) {
    th <- .themes[[tn]]
    shiny::tags$button(
      id    = ns(paste0("theme_", tn)),
      class = "hexmakr-theme-btn",
      style = paste0(
        "background:", th$dark$bg, ";",
        "color:", th$dark$text, ";",
        "border:2px solid ", th$dark$accent, ";",
        "border-radius:6px; padding:4px 8px; margin:2px;",
        "cursor:pointer; font-size:11px; white-space:nowrap;"
      ),
      shiny::tags$span(
        style = paste0(
          "display:inline-block; width:10px; height:10px;",
          "border-radius:50%; background:", th$dark$accent,
          "; margin-right:4px;"
        )
      ),
      th$label
    )
  })

  shiny::wellPanel(
    style = "background:#1E293B; border:1px solid #334155; color:#E2E8F0;",
    shiny::h4("Theme", style = "color:#94A3B8; margin-top:0;"),
    shiny::fluidRow(
      shiny::column(6,
        shiny::selectInput(ns("theme"), "Theme",
                           choices = setNames(names(.themes),
                                              vapply(.themes, `[[`, character(1), "label")),
                           selected = "stats", width = "100%")
      ),
      shiny::column(6,
        shiny::selectInput(ns("mode"), "Mode",
                           choices = c("Dark" = "dark", "Light" = "light"),
                           selected = "dark", width = "100%")
      )
    )
  )
}

#' @noRd
mod_theme_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    shiny::reactive(list(
      theme = input$theme,
      mode  = input$mode
    ))
  })
}

# ---- Colors module ---------------------------------------------------------

#' @noRd
mod_colors_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::wellPanel(
    style = "background:#1E293B; border:1px solid #334155; color:#E2E8F0;",
    shiny::h4("Custom Colors (override theme)", style = "color:#94A3B8; margin-top:0;"),
    shiny::fluidRow(
      shiny::column(6,
        shiny::tags$label("Background", style = "color:#94A3B8;"),
        shiny::tags$input(id = ns("bg"), type = "color", value = "#1B2838",
                          style = "width:100%; height:36px;")
      ),
      shiny::column(6,
        shiny::tags$label("Accent", style = "color:#94A3B8;"),
        shiny::tags$input(id = ns("accent"), type = "color", value = "#00D4AA",
                          style = "width:100%; height:36px;")
      )
    ),
    shiny::fluidRow(
      shiny::column(6,
        shiny::tags$label("Text", style = "color:#94A3B8;"),
        shiny::tags$input(id = ns("text_color"), type = "color", value = "#FFFFFF",
                          style = "width:100%; height:36px;")
      ),
      shiny::column(6,
        shiny::tags$label("Border", style = "color:#94A3B8;"),
        shiny::tags$input(id = ns("border_color"), type = "color", value = "#00D4AA",
                          style = "width:100%; height:36px;")
      )
    ),
    shiny::fluidRow(
      shiny::column(6,
        shiny::tags$label("Subtitle", style = "color:#94A3B8;"),
        shiny::tags$input(id = ns("sub_color"), type = "color", value = "#8EC8B8",
                          style = "width:100%; height:36px;")
      )
    ),
    shiny::tags$small(
      style = "color:#64748B;",
      "These override the selected theme colors."
    )
  )
}

#' @noRd
mod_colors_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    shiny::reactive(list(
      bg           = input$bg,
      accent       = input$accent,
      text_color   = input$text_color,
      border_color = input$border_color,
      sub_color    = input$sub_color
    ))
  })
}

# ---- Border module ---------------------------------------------------------

#' @noRd
mod_border_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::wellPanel(
    style = "background:#1E293B; border:1px solid #334155; color:#E2E8F0;",
    shiny::h4("Border", style = "color:#94A3B8; margin-top:0;"),
    shiny::sliderInput(ns("border_width"), "Border Width (mm)",
                       min = 0, max = 8, value = 2, step = 0.5),
    shiny::checkboxInput(ns("inner_border"), "Inner Accent Ring",
                         value = TRUE)
  )
}

#' @noRd
mod_border_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    shiny::reactive(list(
      border_width = input$border_width,
      inner_border = input$inner_border
    ))
  })
}
