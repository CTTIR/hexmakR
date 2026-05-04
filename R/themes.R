#' @keywords internal
.themes <- list(
  stats = list(
    label = "Statistics",
    dark  = list(bg = "#1B2838", accent = "#00D4AA", text = "#FFFFFF",
                 border = "#00D4AA", sub = "#8EC8B8"),
    light = list(bg = "#F8FFFE", accent = "#0D9373", text = "#1A2E35",
                 border = "#0D9373", sub = "#4BA68E")
  ),
  viz = list(
    label = "Visualization",
    dark  = list(bg = "#0F0A2E", accent = "#FF6B6B", text = "#FFFFFF",
                 border = "#FF6B6B", sub = "#FFB4B4"),
    light = list(bg = "#FFFFFF", accent = "#E15759", text = "#2D2D2D",
                 border = "#E15759", sub = "#9C1D22")
  ),
  bio = list(
    label = "Bioinformatics",
    dark  = list(bg = "#0A1628", accent = "#4FC3F7", text = "#FFFFFF",
                 border = "#4FC3F7", sub = "#A8DFF7"),
    light = list(bg = "#F0F9FF", accent = "#0284C7", text = "#0C4A6E",
                 border = "#0284C7", sub = "#38BDF8")
  ),
  medical = list(
    label = "Medical/Clinical",
    dark  = list(bg = "#0F1923", accent = "#EF5350", text = "#FFFFFF",
                 border = "#EF5350", sub = "#EF9A9A"),
    light = list(bg = "#FFF5F5", accent = "#DC2626", text = "#450A0A",
                 border = "#DC2626", sub = "#F87171")
  ),
  tech = list(
    label = "Tech/Computing",
    dark  = list(bg = "#0D0D0D", accent = "#00FF41", text = "#FFFFFF",
                 border = "#00FF41", sub = "#66FF87"),
    light = list(bg = "#F5F5F5", accent = "#16A34A", text = "#1A1A1A",
                 border = "#16A34A", sub = "#4ADE80")
  ),
  earth = list(
    label = "Earth/Nature",
    dark  = list(bg = "#0A1A0F", accent = "#4CAF50", text = "#FFFFFF",
                 border = "#4CAF50", sub = "#81C784"),
    light = list(bg = "#F0FDF4", accent = "#15803D", text = "#14532D",
                 border = "#15803D", sub = "#22C55E")
  ),
  cran = list(
    label = "CRAN",
    dark  = list(bg = "#1A1A2E", accent = "#2266BB", text = "#FFFFFF",
                 border = "#2266BB", sub = "#6699DD"),
    light = list(bg = "#FFFFFF", accent = "#2266BB", text = "#1A1A2E",
                 border = "#2266BB", sub = "#6688BB")
  ),
  bioc = list(
    label = "Bioconductor",
    dark  = list(bg = "#0F1A12", accent = "#87B13F", text = "#FFFFFF",
                 border = "#87B13F", sub = "#A8D060"),
    light = list(bg = "#F0F4F8", accent = "#87B13F", text = "#2D3748",
                 border = "#87B13F", sub = "#5A7A28")
  ),
  tidy = list(
    label = "Tidyverse",
    dark  = list(bg = "#1A1433", accent = "#4E79A7", text = "#FFFFFF",
                 border = "#4E79A7", sub = "#76B7B2"),
    light = list(bg = "#F8F9FA", accent = "#4E79A7", text = "#2D3748",
                 border = "#4E79A7", sub = "#76B7B2")
  ),
  genomics = list(
    label = "Genomics",
    dark  = list(bg = "#0D1520", accent = "#29B6F6", text = "#FFFFFF",
                 border = "#29B6F6", sub = "#81D4FA"),
    light = list(bg = "#EFF6FF", accent = "#2563EB", text = "#1E3A5F",
                 border = "#2563EB", sub = "#60A5FA")
  ),
  proteo = list(
    label = "Proteomics",
    dark  = list(bg = "#1A0F2E", accent = "#CE93D8", text = "#FFFFFF",
                 border = "#CE93D8", sub = "#E8C8EE"),
    light = list(bg = "#FDF4FF", accent = "#A855F7", text = "#3B0764",
                 border = "#A855F7", sub = "#C084FC")
  ),
  pharma = list(
    label = "Pharma",
    dark  = list(bg = "#0E1A2B", accent = "#42A5F5", text = "#FFFFFF",
                 border = "#42A5F5", sub = "#90CAF9"),
    light = list(bg = "#EFF6FF", accent = "#2563EB", text = "#1E3A5F",
                 border = "#2563EB", sub = "#93C5FD")
  ),
  ocean = list(
    label = "Ocean",
    dark  = list(bg = "#03111A", accent = "#00BCD4", text = "#FFFFFF",
                 border = "#00BCD4", sub = "#4DD0E1"),
    light = list(bg = "#F0FDFF", accent = "#0E7490", text = "#164E63",
                 border = "#0E7490", sub = "#06B6D4")
  ),
  midnight = list(
    label = "Midnight",
    dark  = list(bg = "#0D0D0D", accent = "#FFD700", text = "#FAFAFA",
                 border = "#FFD700", sub = "#CCAA00"),
    light = list(bg = "#FAFAF9", accent = "#A16207", text = "#1C1917",
                 border = "#A16207", sub = "#D97706")
  ),
  cyber = list(
    label = "Cyber",
    dark  = list(bg = "#0A0E17", accent = "#00E5FF", text = "#FFFFFF",
                 border = "#00E5FF", sub = "#18FFFF"),
    light = list(bg = "#ECFEFF", accent = "#0891B2", text = "#164E63",
                 border = "#0891B2", sub = "#22D3EE")
  ),
  neon = list(
    label = "Neon",
    dark  = list(bg = "#0A0A0A", accent = "#00FF87", text = "#FFFFFF",
                 border = "#00FF87", sub = "#66FFB3"),
    light = list(bg = "#F0FFF4", accent = "#059669", text = "#064E3B",
                 border = "#059669", sub = "#34D399")
  ),
  sunset = list(
    label = "Sunset",
    dark  = list(bg = "#1A0D1E", accent = "#FF6F00", text = "#FFFFFF",
                 border = "#FF8F00", sub = "#FFB74D"),
    light = list(bg = "#FFFBEB", accent = "#D97706", text = "#451A03",
                 border = "#EA580C", sub = "#F59E0B")
  ),
  viridis = list(
    label = "Viridis",
    dark  = list(bg = "#0B0C2A", accent = "#21918C", text = "#FFFFFF",
                 border = "#5DC863", sub = "#FDE725"),
    light = list(bg = "#F0FDF9", accent = "#0D9488", text = "#134E4A",
                 border = "#16A34A", sub = "#65A30D")
  ),
  plasma = list(
    label = "Plasma",
    dark  = list(bg = "#140024", accent = "#F0F921", text = "#FFFFFF",
                 border = "#CC4778", sub = "#F89540"),
    light = list(bg = "#FFF7FC", accent = "#DB2777", text = "#4A1042",
                 border = "#9333EA", sub = "#E879F9")
  )
)

#' List available themes
#'
#' @title List Available Themes
#' @description Returns a named list of all 19 built-in color themes for hex
#'   stickers. Each theme has `dark` and `light` sub-lists with color values
#'   for `bg`, `accent`, `text`, `border`, and `sub` (subtitle).
#'
#' @return A named list of length 19. Each element contains:
#'   \describe{
#'     \item{label}{Human-readable theme name (character).}
#'     \item{dark}{List of 5 color hex strings for dark mode.}
#'     \item{light}{List of 5 color hex strings for light mode.}
#'   }
#'
#' @examples
#' themes <- hexmakr_themes()
#' names(themes)
#' themes$stats$dark
#'
#' @seealso [hex_sticker()], [hexmakr_preview_theme()]
#' @family themes
#' @export
hexmakr_themes <- function() {
  .themes
}

#' Preview a theme
#'
#' @title Preview a Color Theme
#' @description Renders a sample hex sticker to preview a theme's colors.
#'
#' @param theme Character. Theme name, one of `names(hexmakr_themes())`.
#' @param mode Character. Either `"dark"` (default) or `"light"`.
#'
#' @return A ggplot object (invisibly). Also prints the plot.
#'
#' @examples
#' \donttest{
#' hexmakr_preview_theme("stats")
#' hexmakr_preview_theme("genomics", mode = "light")
#' }
#'
#' @seealso [hexmakr_themes()], [hex_sticker()]
#' @family themes
#' @export
hexmakr_preview_theme <- function(theme = "stats", mode = "dark") {
  p <- hex_sticker(
    name     = theme,
    subtitle = .themes[[theme]]$label,
    theme    = theme,
    mode     = mode
  )
  print(p)
  invisible(p)
}
