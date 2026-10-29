#' Save a hex sticker to a PNG file
#'
#' @title Save a Hex Sticker
#' @description Renders and saves a hex sticker ggplot object to a PNG file
#'   with a transparent background and the correct hexb.in aspect ratio
#'   (width / height = sqrt(3) / 2).
#'
#' @param sticker A ggplot object returned by [hex_sticker()].
#' @param filename Character. Output file path. Must end in `.png`.
#' @param width Integer. Width in pixels. Default `600`.
#' @param dpi Numeric. Resolution. Default `300`.
#'
#' @return The `filename` path, invisibly.
#'
#' @examples
#' s <- hex_sticker("mypackage", icon = "atom", theme = "stats")
#' tmp <- tempfile(fileext = ".png")
#' save_hex(s, tmp)
#' file.exists(tmp)
#'
#' @seealso [hex_sticker()]
#' @family stickers
#' @export
save_hex <- function(sticker, filename, width = 600, dpi = 300) {
  if (!inherits(sticker, "gg")) {
    stop("'sticker' must be a ggplot object returned by hex_sticker().")
  }
  if (!grepl("\\.png$", tolower(filename))) {
    stop("'filename' must end in '.png'.")
  }
  ratio  <- .hex_ratio()
  height <- round(width / ratio)
  dir_path <- dirname(filename)
  if (!dir.exists(dir_path)) {
    dir.create(dir_path, recursive = TRUE)
  }
  # Cairo where available: the default device on macOS (quartz) applies colour
  # management and gives other pixel values than on Linux and Windows.
  grDevices::png(
    filename  = filename,
    width     = width,
    height    = height,
    units     = "px",
    res       = dpi,
    bg        = "transparent",
    type      = if (capabilities("cairo")) "cairo" else getOption("bitmapType")
  )
  device <- grDevices::dev.cur()
  on.exit(grDevices::dev.off(device), add = TRUE)
  print(sticker)
  invisible(filename)
}

#' Save a hex sticker to an SVG file
#'
#' @title Save a Hex Sticker as SVG
#' @description Renders and saves a hex sticker to SVG. Requires the
#'   \pkg{svglite} package.
#'
#' @param sticker A ggplot object returned by [hex_sticker()].
#' @param filename Character. Output file path. Must end in `.svg`.
#' @param width Numeric. Width in inches. Default `2`.
#'
#' @return The `filename` path, invisibly.
#'
#' @examples
#' if (requireNamespace("svglite", quietly = TRUE)) {
#'   s <- hex_sticker("mypackage")
#'   tmp <- tempfile(fileext = ".svg")
#'   save_hex_svg(s, tmp)
#' }
#'
#' @seealso [save_hex()], [hex_sticker()]
#' @family stickers
#' @export
save_hex_svg <- function(sticker, filename, width = 2) {
  if (!requireNamespace("svglite", quietly = TRUE)) {
    stop("Package 'svglite' is needed for SVG export. ",
         "Install it with: install.packages('svglite')")
  }
  if (!inherits(sticker, "gg")) {
    stop("'sticker' must be a ggplot object returned by hex_sticker().")
  }
  if (!grepl("\\.svg$", tolower(filename))) {
    stop("'filename' must end in '.svg'.")
  }
  height <- width / .hex_ratio()
  dir_path <- dirname(filename)
  if (!dir.exists(dir_path)) {
    dir.create(dir_path, recursive = TRUE)
  }
  svglite::svglite(filename = filename, width = width, height = height,
                   bg = "transparent")
  device <- grDevices::dev.cur()
  on.exit(grDevices::dev.off(device), add = TRUE)
  print(sticker)
  invisible(filename)
}
