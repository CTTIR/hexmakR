#' Create a hex sticker
#'
#' @title Create a Hex Sticker
#' @description Generates a publication-ready hexagon sticker for an R package.
#'   Returns a ggplot object that can be printed, further customised with `+`,
#'   or saved with [save_hex()].
#'
#' @param name Character. The package name displayed on the sticker.
#' @param subtitle Character or `NULL`. Optional subtitle shown below the
#'   package name.
#' @param url Character or `NULL`. Optional URL shown near the bottom of the
#'   sticker.
#' @param icon Character or `NULL`. Name of a built-in icon. See
#'   [hexmakr_icons()] for valid values. Ignored if `icon_image` is provided.
#' @param icon_image Character or `NULL`. Path to a custom image file (PNG or
#'   JPEG). If provided, overrides `icon`.
#' @param icon_size Numeric. Size multiplier for the icon (default `1.0`).
#' @param theme Character. Theme name. One of `names(hexmakr_themes())`.
#'   Default `"stats"`.
#' @param mode Character. Color mode, either `"dark"` (default) or `"light"`.
#' @param bg Character or `NULL`. Override the background color (hex string,
#'   e.g. `"#1B2838"`).
#' @param accent Character or `NULL`. Override the accent color.
#' @param text_color Character or `NULL`. Override the text color.
#' @param border_color Character or `NULL`. Override the border color.
#' @param sub_color Character or `NULL`. Override the subtitle/URL color.
#' @param font_family Character. Font shorthand (e.g. `"mono"`, `"serif"`,
#'   `"sans"`) or a system font name. Default `"mono"`.
#' @param font_bold Logical. Use bold weight. Default `TRUE`.
#' @param font_italic Logical. Use italic style. Default `FALSE`.
#' @param font_size Numeric. Base font size in pt for the package name.
#'   Default `12`.
#' @param border_width Numeric. Border line width in mm. Default `2`.
#' @param inner_border Logical. Draw a thin inner accent ring. Default `TRUE`.
#' @param filename Character or `NULL`. If provided, save the sticker as a
#'   transparent PNG at this path using [save_hex()].
#' @param width Integer. Export width in pixels (height is derived from the hex
#'   aspect ratio). Default `600`.
#' @param dpi Numeric. Resolution for PNG export. Default `300`.
#'
#' @return A ggplot object (invisibly if `filename` is not `NULL`).
#'
#' @examples
#' \donttest{
#' # Minimal sticker
#' hex_sticker("mypackage")
#'
#' # With icon and theme
#' hex_sticker("mypackage", icon = "dna", theme = "genomics")
#'
#' # Save to file
#' tmp <- tempfile(fileext = ".png")
#' hex_sticker("mypackage", icon = "atom", theme = "stats", filename = tmp)
#' file.exists(tmp)
#' }
#'
#' @seealso [hexmakr_themes()], [hexmakr_icons()], [save_hex()],
#'   [hexmakr_app()]
#' @family stickers
#' @export
hex_sticker <- function(
  name         = "package",
  subtitle     = NULL,
  url          = NULL,
  icon         = NULL,
  icon_image   = NULL,
  icon_size    = 1.0,
  theme        = "stats",
  mode         = "dark",
  bg           = NULL,
  accent       = NULL,
  text_color   = NULL,
  border_color = NULL,
  sub_color    = NULL,
  font_family  = "mono",
  font_bold    = TRUE,
  font_italic  = FALSE,
  font_size    = 12,
  border_width = 2,
  inner_border = TRUE,
  filename     = NULL,
  width        = 600,
  dpi          = 300
) {
  # ---- Input validation ---------------------------------------------------
  if (!theme %in% names(.themes)) {
    stop(sprintf(
      "Unknown theme '%s'. Available themes: %s",
      theme, paste(names(.themes), collapse = ", ")
    ))
  }
  if (!mode %in% c("dark", "light")) {
    stop("'mode' must be either \"dark\" or \"light\".")
  }
  for (col_arg in list(list(bg, "bg"), list(accent, "accent"),
                       list(text_color, "text_color"),
                       list(border_color, "border_color"),
                       list(sub_color, "sub_color"))) {
    if (!is.null(col_arg[[1]])) .check_color(col_arg[[1]], col_arg[[2]])
  }
  if (!is.null(icon) && !is.null(icon_image)) {
    message("Both 'icon' and 'icon_image' provided; 'icon_image' will be used.")
    icon <- NULL
  }
  if (!is.null(icon)) {
    .lookup_icon(icon)  # validates; throws on unknown icon
  }

  # ---- Resolve colors & font ----------------------------------------------
  colors     <- .resolve_colors(theme, mode, bg, accent, text_color,
                                 border_color, sub_color)
  font_name  <- .resolve_font(font_family)

  # ---- Build --------------------------------------------------------------
  p <- .build_hex(
    name         = as.character(name),
    subtitle     = if (!is.null(subtitle)) as.character(subtitle) else NULL,
    url          = if (!is.null(url)) as.character(url) else NULL,
    colors       = colors,
    icon_name    = icon,
    icon_image   = icon_image,
    icon_size    = icon_size,
    font_family  = font_name,
    font_bold    = font_bold,
    font_italic  = font_italic,
    font_size    = font_size,
    border_width = border_width,
    inner_border = inner_border
  )

  # ---- Export if requested ------------------------------------------------
  if (!is.null(filename)) {
    save_hex(p, filename = filename, width = width, dpi = dpi)
    invisible(p)
  } else {
    p
  }
}
