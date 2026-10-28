#' hexmakR: Interactive Hex Sticker Generator for R Packages
#'
#' @description
#' \if{html}{\figure{logo.svg}{options: style="float:right;" alt="hexmakR logo" width="120"}}
#'
#' Create publication-ready hexagon stickers for R packages interactively via a
#' Shiny app or programmatically via R functions.
#'
#' Comes with **28 curated color themes** (dark + light variants), led by the
#' nine CTTIR v5 families, **46 built-in scientific and technical icons**
#' across 7 categories, custom image upload support, 14 font options
#' including the bundled JetBrains Mono, and transparent PNG export.
#'
#' The default Designer starts a fresh logo. Add, duplicate, remove and edit
#' individual parts; optionally reuse components from 45 archived vector
#' identities. JSON projects, R recipes and PNG/SVG/PDF exports retain edits
#' across hexagonal, pentagonal or square logos.
#' Import portable PNG/JPEG figures or supported SVG components, select and
#' drag items, rotate individual parts, and organise named groups.
#'
#' ## Main functions
#'
#' * [logo_design()] --fresh project logos in three frame shapes.
#' * [hex_add_part()] --add editable geometric parts.
#' * [hex_import_art()] --import embedded figures or editable vector components.
#' * [hex_groups()] --organise named groups of items.
#' * [hex_label_layer()] --give an item a short label.
#' * [hex_reuse_part()] --reuse selected archive artwork.
#' * [hex_edit_layer()] --edit individual part properties and points.
#' * [hex_design()] --fresh or explicitly selected archive design.
#' * [hex_export()] --vector and raster export.
#' * [hex_catalog()] --all 45 registered identities.
#'
#' * [hex_sticker()] --programmatic hex sticker creation; returns a ggplot
#'   object.
#' * [hexmakr_app()] --launch the interactive Shiny designer.
#' * [hexmakr_themes()] --list all 28 built-in themes, CTTIR v5 families first.
#' * [hexmakr_icons()] --list all 46 built-in icons.
#' * [save_hex()] --save a sticker to a transparent PNG.
#' * [save_hex_svg()] --save a sticker to SVG (requires svglite).
#'
#' @rdname hexmakr-package
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
