# ---------------------------------------------------------------------------
# Internal utility functions
# ---------------------------------------------------------------------------

#' Hex aspect ratio (width / height)
#' @noRd
.hex_ratio <- function() sqrt(3) / 2

#' Validate a hex colour string
#' @noRd
.is_hex_color <- function(x) {
  grepl("^#[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?$", x)
}

#' Ensure value is a valid hex colour; stop with message if not
#' @noRd
.check_color <- function(x, arg) {
  if (!is.character(x) || length(x) != 1L || is.na(x) || !.is_hex_color(x)) {
    stop(sprintf("'%s' must be a valid hex color string (e.g. '#FF0000'), got: %s",
                 arg, paste(format(x), collapse = ", ")))
  }
  x
}

#' Ensure value is a single non-missing string; stop with a clear message if not
#' @noRd
.check_string <- function(x, arg) {
  if (!is.character(x) || length(x) != 1L || is.na(x)) {
    stop(sprintf("'%s' must be a single string.", arg))
  }
  x
}

#' Ensure value is a single label: a non-missing string or number
#' @noRd
.check_label <- function(x, arg) {
  if (!(is.character(x) || is.numeric(x)) || length(x) != 1L || is.na(x)) {
    stop(sprintf("'%s' must be a single string or NULL.", arg), call. = FALSE)
  }
  x
}

#' Ensure value is a single finite, non-negative number
#' @noRd
.check_size <- function(x, arg) {
  if (!is.numeric(x) || length(x) != 1L || !is.finite(x) || x < 0) {
    stop(sprintf("'%s' must be a single non-negative number.", arg),
         call. = FALSE)
  }
  x
}

#' Ensure value is a single TRUE or FALSE
#' @noRd
.check_flag <- function(x, arg) {
  if (!is.logical(x) || length(x) != 1L || is.na(x)) {
    stop(sprintf("'%s' must be TRUE or FALSE.", arg), call. = FALSE)
  }
  x
}

#' Blend two hex colours (simple linear interpolation in RGB)
#' @noRd
.blend_colors <- function(col1, col2, alpha = 0.5) {
  c1 <- grDevices::col2rgb(col1) / 255
  c2 <- grDevices::col2rgb(col2) / 255
  r  <- c1 * (1 - alpha) + c2 * alpha
  grDevices::rgb(r[1], r[2], r[3])
}

#' Look up a theme colour list, with optional overrides
#' @noRd
.resolve_colors <- function(theme, mode, bg, accent, text_color,
                             border_color, sub_color) {
  t <- hexmakr_themes()[[theme]][[mode]]
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
