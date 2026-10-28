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
  "lato"          = "sans",
  # CTTIR v5 name font, bundled with the package (see .bundled_fonts)
  "jetbrains_mono" = "JetBrains Mono"
)

#' Font files shipped with the CTTIR v5 library
#'
#' These are drawn as glyph outlines rather than device text, so they look
#' the same on every graphics device without installing anything.
#' @noRd
.bundled_fonts <- list(
  "JetBrains Mono" = c(plain = "JetBrainsMono-Regular.ttf",
                       bold  = "JetBrainsMono-SemiBold.ttf")
)

#' List available font shorthands
#'
#' Returns the 14 built-in font shorthand names that can be passed as
#' `font_family` to [hex_sticker()].
#'
#' @return A named character vector mapping shorthand to font name.
#' @noRd
hexmakr_fonts <- function() {
  unlist(.fonts)
}
