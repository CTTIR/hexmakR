# ---------------------------------------------------------------------------
# Internal utility functions
# ---------------------------------------------------------------------------

#' Hex aspect ratio (width / height)
#' @noRd
.hex_ratio <- function() sqrt(3) / 2

#' Validate a hex color string
#' @noRd
.is_hex_color <- function(x) {
  grepl("^#[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?$", x)
}

#' Ensure value is a valid hex color; stop with message if not
#' @noRd
.check_color <- function(x, arg) {
  if (!.is_hex_color(x)) {
    stop(sprintf("'%s' must be a valid hex color string (e.g. '#FF0000'), got: %s",
                 arg, x))
  }
  x
}

#' Blend two hex colors (simple linear interpolation in RGB)
#' @noRd
.blend_colors <- function(col1, col2, alpha = 0.5) {
  c1 <- grDevices::col2rgb(col1) / 255
  c2 <- grDevices::col2rgb(col2) / 255
  r  <- c1 * (1 - alpha) + c2 * alpha
  grDevices::rgb(r[1], r[2], r[3])
}

#' Look up a theme color list, with optional overrides
#' @noRd
.resolve_colors <- function(theme, mode, bg, accent, text_color,
                             border_color, sub_color) {
  t <- .themes[[theme]][[mode]]
  list(
    bg     = if (!is.null(bg))           bg           else t$bg,
    accent = if (!is.null(accent))       accent       else t$accent,
    text   = if (!is.null(text_color))   text_color   else t$text,
    border = if (!is.null(border_color)) border_color else t$border,
    sub    = if (!is.null(sub_color))    sub_color    else t$sub
  )
}

#' Map a font_family shorthand to a concrete font name
#' @noRd
.resolve_font <- function(font_family) {
  .fonts[[font_family]] %||% font_family
}

#' NULL-coalescing operator (like %||% in rlang)
#' @noRd
`%||%` <- function(x, y) if (is.null(x)) y else x
