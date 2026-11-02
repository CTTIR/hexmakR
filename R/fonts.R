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

# A glyph index of zero is the font's missing-character placeholder.
.check_bundled_glyphs <- function(shape) {
  missing <- unique(shape$shape$glyph[shape$shape$index == 0L])
  if (length(missing)) {
    codes <- sprintf("U+%04X", utf8ToInt(paste(missing, collapse = "")))
    stop("The bundled JetBrains Mono font cannot render: ",
         paste(codes, collapse = ", "), ". Use supported characters.", call. = FALSE)
  }
  invisible(shape)
}
