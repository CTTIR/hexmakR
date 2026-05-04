#' hexmakR: Interactive Hex Sticker Generator for R Packages
#'
#' @description
#' \if{html}{\figure{logo.svg}{options: style="float:right;" alt="hexmakR logo" width="120"}}
#'
#' Create publication-ready hexagon stickers for R packages interactively via a
#' Shiny app or programmatically via R functions.
#'
#' Comes with **19 curated color themes** (dark + light variants), **46
#' built-in scientific and technical icons** across 7 categories, custom image
#' upload support, 13 font options, and transparent PNG export.
#'
#' ## Main functions
#'
#' * [hex_sticker()] --programmatic hex sticker creation; returns a ggplot
#'   object.
#' * [hexmakr_app()] --launch the interactive Shiny designer.
#' * [hexmakr_themes()] --list all 19 built-in themes.
#' * [hexmakr_icons()] --list all 46 built-in icons.
#' * [save_hex()] --save a sticker to a transparent PNG.
#' * [save_hex_svg()] --save a sticker to SVG (requires svglite).
#'
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom stats setNames
#' @importFrom ggplot2 aes
#' @importFrom ggplot2 annotation_custom
#' @importFrom ggplot2 coord_fixed
#' @importFrom ggplot2 element_rect
#' @importFrom ggplot2 geom_polygon
#' @importFrom ggplot2 geom_text
#' @importFrom ggplot2 ggplot
#' @importFrom ggplot2 margin
#' @importFrom ggplot2 theme
#' @importFrom ggplot2 theme_void
#' @importFrom grDevices col2rgb
#' @importFrom grDevices dev.off
#' @importFrom grDevices png
#' @importFrom grDevices rgb
#' @importFrom grid drawDetails
#' @importFrom grid grob
#' @importFrom grid gpar
#' @importFrom grid grid.circle
#' @importFrom grid grid.lines
#' @importFrom grid grid.polygon
#' @importFrom grid grid.rect
#' @importFrom grid popViewport
#' @importFrom grid pushViewport
#' @importFrom grid rasterGrob
#' @importFrom grid unit
#' @importFrom grid viewport
#' @importFrom png readPNG
#' @importFrom shiny actionButton
#' @importFrom shiny checkboxInput
#' @importFrom shiny column
#' @importFrom shiny div
#' @importFrom shiny downloadButton
#' @importFrom shiny downloadHandler
#' @importFrom shiny fileInput
#' @importFrom shiny fluidPage
#' @importFrom shiny fluidRow
#' @importFrom shiny h3
#' @importFrom shiny h4
#' @importFrom shiny HTML
#' @importFrom shiny moduleServer
#' @importFrom shiny NS
#' @importFrom shiny observeEvent
#' @importFrom shiny plotOutput
#' @importFrom shiny reactive
#' @importFrom shiny renderPlot
#' @importFrom shiny runApp
#' @importFrom shiny selectInput
#' @importFrom shiny shinyApp
#' @importFrom shiny sliderInput
#' @importFrom shiny tabPanel
#' @importFrom shiny tabsetPanel
#' @importFrom shiny tags
#' @importFrom shiny textInput
#' @importFrom shiny updateSelectInput
#' @importFrom shiny wellPanel
## usethis namespace: end
NULL
