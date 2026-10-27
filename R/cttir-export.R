#' Export an editable v5 design
#'
#' The same native grid geometry powers previews and all three export formats.
#' SVG and PDF contain vector paths, including outlined package-name glyphs.
#' @param design A [hex_design()] object.
#' @param filename Destination ending in `.png`, `.svg` or `.pdf`.
#' @param width PNG width in pixels; vector masters use a six-inch canvas.
#' @return The destination path, invisibly.
#' @export
#' @examples
#' f <- tempfile(fileext = ".svg")
#' hex_export(hex_design("phenoscapR"), f)
hex_export <- function(design, filename, width = 1600L) {
  .validate_design(design)
  .scalar_number(width, "width", 32, 8192)
  if (!is.character(filename) || length(filename) != 1L || is.na(filename) || !nzchar(filename))
    stop("filename must be a path.", call. = FALSE)
  ext <- tolower(tools::file_ext(filename))
  if (!ext %in% c("png", "svg", "pdf")) stop("Use a .png, .svg or .pdf filename.", call. = FALSE)
  if (!capabilities("cairo")) stop("R with Cairo support is required for v5 exports.", call. = FALSE)
  grob <- hex_grob(design)
  ratio <- .design_ratio(design)
  dir.create(dirname(filename), recursive = TRUE, showWarnings = FALSE)
  switch(ext,
    png = grDevices::png(filename, width = round(width), height = round(width / ratio),
      res = width / 6, bg = "transparent", type = "cairo", antialias = "gray"),
    svg = grDevices::svg(filename, width = 6, height = 6 / ratio, bg = "transparent"),
    pdf = grDevices::cairo_pdf(filename, width = 6, height = 6 / ratio, bg = "transparent"))
  on.exit(grDevices::dev.off(), add = TRUE)
  grid::grid.newpage(); grid::grid.draw(grob)
  invisible(filename)
}

#' Save and load a v5 editing project
#'
#' JSON projects store declarative settings and layer edits; loading never
#' evaluates R code. Files larger than 2 MB and unknown fields are rejected.
#' @param design A [hex_design()] object.
#' @param path JSON project path.
#' @return `hex_save_design()` returns the path invisibly;
#'   `hex_read_design()` returns a validated design.
#' @export
hex_save_design <- function(design, path) {
  .validate_design(design)
  hex_grob(design)
  jsonlite::write_json(unclass(design), path, pretty = TRUE, auto_unbox = TRUE, digits = 15)
  invisible(path)
}

#' @rdname hex_save_design
#' @export
hex_read_design <- function(path) {
  if (!is.character(path) || length(path) != 1L || is.na(path) || !file.exists(path) ||
      is.na(file.info(path)$size) || file.info(path)$size > 2e6)
    stop("Provide an existing JSON project of at most 2 MB.", call. = FALSE)
  x <- jsonlite::read_json(path, simplifyVector = FALSE)
  # JSON arrays become numeric vectors only for the explicitly supported fields.
  if (is.list(x$layers)) for (id in names(x$layers)) {
    for (key in c("x", "y")) if (is.list(x$layers[[id]][[key]])) {
      v <- x$layers[[id]][[key]]
      if (!all(vapply(v, function(z) is.numeric(z) && length(z) == 1L, logical(1))))
        stop("Invalid coordinate array.", call. = FALSE)
      x$layers[[id]][[key]] <- unlist(v, use.names = FALSE)
    }
  }
  .validate_design(x)
  class(x) <- "hex_design"
  hex_grob(x)
  x
}

#' Write a reproducible R recipe
#' @param design A [hex_design()] object.
#' @param path Destination R file.
#' @return The path, invisibly.
#' @export
hex_recipe <- function(design, path) {
  .validate_design(design)
  code <- c("library(hexmakR)", "", "design <-",
    utils::capture.output(dput(unclass(design))),
    "class(design) <- 'hex_design'", "", "print(design)",
    "hex_export(design, 'sticker.svg')", "hex_export(design, 'sticker.png')")
  writeLines(code, path)
  invisible(path)
}

#' Regenerate the v5 catalogue
#' @param directory Destination directory; one subdirectory per identity.
#' @param packages Exact identities to render. Defaults to the entire catalogue.
#' @param modes Colour modes to export.
#' @param layouts Master layouts to export.
#' @param formats File formats to export.
#' @param width Master PNG width in pixels.
#' @param icons Also create five square dark icons per identity.
#' @return A data frame of generated file paths and identities, invisibly.
#' @export
#' @examples
#' \dontrun{
#' hex_render_catalog("exports")
#' }
hex_render_catalog <- function(directory, packages = hex_catalog()$name,
                               modes = c("light", "dark", "mono"),
                               layouts = c("lockup", "hex"),
                               formats = c("svg", "png", "pdf"),
                               width = 1600L, icons = TRUE) {
  if (!length(packages) || anyDuplicated(packages)) stop("Select unique identities.", call. = FALSE)
  lapply(packages, .identity_row)
  if (!length(modes) || any(!modes %in% c("light", "dark", "mono")) ||
      !length(layouts) || any(!layouts %in% c("hex", "lockup", "motif")) ||
      !length(formats) || any(!formats %in% c("png", "svg", "pdf")))
    stop("Invalid export modes, layouts or formats.", call. = FALSE)
  .scalar_number(width, "width", 32, 8192)
  files <- list()
  for (package in packages) {
    out <- file.path(directory, .identity_row(package)$asset_dir)
    for (mode in modes) for (layout in layouts) for (format in formats) {
      stem <- paste0(layout, if (mode == "light") "" else paste0("-", mode))
      f <- file.path(out, paste0(stem, ".", format))
      hex_export(hex_design(package, mode, layout), f, width)
      files[[length(files) + 1L]] <- data.frame(package = package, path = f)
    }
    if (isTRUE(icons)) for (size in c(32L, 48L, 64L, 128L, 256L)) {
      dir.create(out, recursive = TRUE, showWarnings = FALSE)
      f <- file.path(out, paste0("icon-", size, ".png"))
      .export_cttir_icon(package, f, size)
      files[[length(files) + 1L]] <- data.frame(package = package, path = f)
    }
  }
  invisible(do.call(rbind, files))
}

.export_cttir_icon <- function(package, path, size) {
  engine <- .cttir_engine()
  s <- engine$cttir_style(.identity_row(package)$family, "dark")
  grDevices::png(path, width = size, height = size, res = size / 6,
    bg = "transparent", type = "cairo", antialias = "gray")
  on.exit(grDevices::dev.off(), add = TRUE)
  grid::grid.newpage()
  grid::pushViewport(grid::viewport(width = .hex_ratio(), gp = grid::gpar(lex = .hex_ratio())))
  grid::grid.polygon(.5+c(0,.48,.48,0,-.48,-.48), .5+c(.48,.24,-.24,-.48,-.24,.24),
    gp = grid::gpar(fill = s$face, col = s$rim, lwd = 5.5, linejoin = "round"))
  grid::pushViewport(grid::viewport(width = .88, height = .88 * .hex_ratio()))
  engine$cttir_motif(package, s, small = TRUE)
  grid::popViewport(2)
}
