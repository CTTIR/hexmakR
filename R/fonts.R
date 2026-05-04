# ---------------------------------------------------------------------------
# Font registry
# ---------------------------------------------------------------------------

#' @keywords internal
.fonts <- list(
  # Monospace -use R's built-in "mono" alias for safe cross-platform default
  "mono"          = "mono",
  "courier"       = "mono",
  "consolas"      = "mono",
  "source_code"   = "mono",
  "fira_code"     = "mono",
  # Serif -use R's built-in "serif" alias
  "serif"         = "serif",
  "times"         = "serif",
  "palatino"      = "serif",
  # Sans-serif -use R's built-in "sans" alias
  "sans"          = "sans",
  "helvetica"     = "sans",
  "roboto"        = "sans",
  "open_sans"     = "sans",
  "lato"          = "sans"
)

#' List available font shorthands
#'
#' Returns the 13 built-in font shorthand names that can be passed as
#' `font_family` to [hex_sticker()].
#'
#' @return A named character vector mapping shorthand to font name.
#' @noRd
hexmakr_fonts <- function() {
  unlist(.fonts)
}
