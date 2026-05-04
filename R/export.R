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
#' \donttest{
#' s <- hex_sticker("mypackage", icon = "atom", theme = "stats")
#' tmp <- tempfile(fileext = ".png")
#' save_hex(s, tmp)
#' file.exists(tmp)
#' }
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
  grDevices::png(
    filename  = filename,
    width     = width,
    height    = height,
    units     = "px",
    res       = dpi,
    bg        = "transparent"
  )
  print(sticker)
  grDevices::dev.off()
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
#' \donttest{
#' if (requireNamespace("svglite", quietly = TRUE)) {
#'   s <- hex_sticker("mypackage")
#'   tmp <- tempfile(fileext = ".svg")
#'   save_hex_svg(s, tmp)
#' }
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
  print(sticker)
  grDevices::dev.off()
  invisible(filename)
}
