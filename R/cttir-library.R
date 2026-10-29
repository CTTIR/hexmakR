# Session cache for values read from the installed v5 library.
.cttir_cache <- new.env(parent = emptyenv())

.cttir_path <- function(...) {
  path <- system.file("cttir", ..., package = "hexmakR")
  if (!nzchar(path)) stop("The installed CTTIR library is missing.", call. = FALSE)
  path
}

# The SVG masters are installed as one compressed archive. It is unpacked once
# per session into a folder in tempdir(), the source for hex_asset() and the
# gallery; `refresh = TRUE` unpacks it again if files went missing.
.cttir_masters <- function(refresh = FALSE) {
  root <- .cttir_cache$masters
  if (refresh || is.null(root) || !dir.exists(root)) {
    root <- tempfile("hexmakR-masters-")
    utils::untar(.cttir_path("logos.tar.xz"), exdir = root, tar = "internal",
                 restore_times = FALSE)
    .cttir_cache$masters <- root
  }
  root
}

.cttir_master <- function(asset_dir, file) {
  path <- file.path(.cttir_masters(), asset_dir, file)
  if (!file.exists(path)) path <- file.path(.cttir_masters(refresh = TRUE), asset_dir, file)
  path
}

#' Browse the CTTIR v5 identities
#'
#' The registry includes 37 R packages, five companion apps, two suites and
#' the CTTIR organisation identity. Exact spelling and case are preserved.
#' @param family Optional family key used to filter the registry.
#' @return A data frame with identity, repository, family, symbol, kind and source.
#' @export
#' @examples
#' hex_catalog()
#' hex_catalog("spectral")
hex_catalog <- function(family = NULL) {
  x <- utils::read.csv(.cttir_path("packages.csv"), stringsAsFactors = FALSE)
  if (!is.null(family)) x <- x[x$family %in% family, , drop = FALSE]
  x$asset_dir <- ifelse(x$name == "CTTIR", "CTTIR-brand", x$name)
  rownames(x) <- NULL
  x
}

.identity_row <- function(package) {
  .scalar_text(package, "package")
  row <- hex_catalog()
  row <- row[row$name == package, , drop = FALSE]
  if (nrow(row) != 1L) stop("Unknown CTTIR identity: ", package, call. = FALSE)
  row
}

#' Locate an original approved v5 asset
#'
#' The 270 SVG files are the unchanged supplied masters. They are installed
#' in one compressed archive, which is unpacked once per session, and an SVG
#' request returns a copy with the master's exact bytes. PNG and PDF versions
#' are rendered from the SVG master on demand with the 'rsvg' package, at the
#' size of the supplied masters (1600 x 1848 pixels and 432 x 498 points).
#' Icons are drawn by the package renderer, which needs R with Cairo support.
#' All files keep the master's file name and are written to
#' `dir/<asset_dir>/`, where `asset_dir` comes from [hex_catalog()]; they are
#' reused until the package is reinstalled. Use [hex_export()] to regenerate
#' artwork or export an edited design.
#' @param package Exact identity from [hex_catalog()].
#' @param mode One of `dark`, `light`, `mono`.
#' @param layout `lockup` (name inside), `hex` (artwork only), or `icon`.
#' @param format File format: `svg`, `png`, or `pdf`.
#' @param size Icon width, one of 32, 48, 64, 128, 256. Icons use dark mode.
#' @param dir Directory for the SVG copies and the rendered PNG, PDF and icon
#'   files. The default is a folder in [tempdir()], so nothing is kept after
#'   the session. To keep files between sessions, pass a directory of your
#'   choice, for example `tools::R_user_dir("hexmakR", "cache")`.
#' @return An absolute file path in `dir`: the copy of the SVG master, or the
#'   rendered PNG, PDF or icon.
#' @export
#' @examples
#' hex_asset("phenoscapR")
#' if (requireNamespace("rsvg", quietly = TRUE)) {
#'   png <- hex_asset("phenoscapR", format = "png", dir = tempfile())
#'   dim(png::readPNG(png))
#' }
#' if (capabilities("cairo")) {
#'   hex_asset("phenoscapR", layout = "icon", format = "png", size = 64,
#'             dir = tempfile())
#' }
hex_asset <- function(package, mode = c("dark", "light", "mono"),
                      layout = c("lockup", "hex", "icon"),
                      format = c("svg", "png", "pdf"), size = 128L, dir = NULL) {
  row <- .identity_row(package)
  mode <- match.arg(mode); layout <- match.arg(layout); format <- match.arg(format)
  if (layout == "icon") {
    if (format != "png" || mode != "dark" || length(size) != 1L ||
        !size %in% c(32, 48, 64, 128, 256)) {
      stop("Original icons are dark PNGs in sizes 32, 48, 64, 128 or 256.", call. = FALSE)
    }
    stem <- paste0("icon-", size)
  } else stem <- paste0(layout, if (mode == "light") "" else paste0("-", mode))
  if (is.null(dir)) dir <- file.path(tempdir(), "hexmakR-assets")
  if (!is.character(dir) || length(dir) != 1L || is.na(dir) || !nzchar(dir))
    stop("dir must be a single directory path.", call. = FALSE)
  target <- file.path(dir, row$asset_dir, paste0(stem, ".", format))
  # Files are reused until the masters change or the package is reinstalled.
  sources <- file.mtime(c(.cttir_path("logos.tar.xz"),
                          system.file("DESCRIPTION", package = "hexmakR")))
  if (!file.exists(target) || file.mtime(target) < max(sources, na.rm = TRUE)) {
    # Icons are drawn by the package renderer, not from a master.
    master <- if (layout != "icon") .cttir_master(row$asset_dir, paste0(stem, ".svg"))
    .render_asset(master, target, package, layout, format, size)
  }
  normalizePath(target, winslash = "/")
}

# Write to a temporary file first so an interrupted render leaves no partial asset.
.render_asset <- function(master, target, package, layout, format, size) {
  if (layout == "icon") {
    if (!capabilities("cairo")) stop("R with Cairo support is required to draw icons.", call. = FALSE)
  } else if (format != "svg" && !requireNamespace("rsvg", quietly = TRUE)) {
    stop("Package 'rsvg' is required to render PNG and PDF masters.", call. = FALSE)
  }
  dir.create(dirname(target), recursive = TRUE, showWarnings = FALSE)
  temp <- tempfile("asset-", tmpdir = dirname(target), fileext = paste0(".", format))
  on.exit(unlink(temp), add = TRUE)
  if (layout == "icon") .export_cttir_icon(package, temp, as.integer(size))
  else if (format == "svg") {
    if (!file.copy(master, temp)) stop("Could not write ", target, call. = FALSE)
  } else if (format == "png") {
    # The supplied PNG masters fill 1600 x 1848 pixels with the 432 x 498 point
    # drawing, a slightly different aspect ratio, so scale the axes separately.
    svg <- readChar(master, file.size(master), useBytes = TRUE)
    svg <- sub("<svg ", "<svg preserveAspectRatio=\"none\" ", svg, fixed = TRUE)
    rsvg::rsvg_png(charToRaw(svg), temp, width = 1600L, height = 1848L)
  } else rsvg::rsvg_pdf(master, temp)
  if (file.exists(target)) unlink(target)
  if (!file.rename(temp, target)) stop("Could not write ", target, call. = FALSE)
  invisible(target)
}

.scalar_text <- function(x, name, empty = FALSE) {
  if (!is.character(x) || length(x) != 1L || is.na(x) ||
      (!empty && !nzchar(x)) || nchar(x, type = "bytes") > 200L) {
    stop(name, " must be a single short string.", call. = FALSE)
  }
  invisible(x)
}
.scalar_number <- function(x, name, low, high) {
  if (!is.numeric(x) || length(x) != 1L || !is.finite(x) || x < low || x > high) {
    stop(name, " must be a finite number between ", low, " and ", high, ".", call. = FALSE)
  }
  invisible(x)
}
.named_fields <- function(x, allowed, what) {
  if (!is.list(x) || (length(x) && (is.null(names(x)) || anyDuplicated(names(x)) ||
      any(!nzchar(names(x))) || any(!names(x) %in% allowed)))) {
    stop("Invalid ", what, " fields.", call. = FALSE)
  }
}
.color_value <- function(x) {
  .scalar_text(x, "colour")
  tryCatch(grDevices::col2rgb(x), error = function(e) stop("Invalid colour: ", x, call. = FALSE))
  invisible(x)
}
