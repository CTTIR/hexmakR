#' Create an editable CTTIR v5 design
#'
#' Defaults to the approved named composition: artwork above the package name,
#' inside a tinted hex with an opaque family border and transparent exterior.
#' All geometry is drawn in R. Name glyphs use the bundled JetBrains Mono font.
#' @param package Exact identity from [hex_catalog()].
#' @param mode `dark`, `light`, or `mono`.
#' @param layout `lockup` (name inside), `hex` (unnamed), or `motif` (standalone).
#' @param label Displayed name, defaulting to the exact identity.
#' @param colors Named list of colour-role overrides, for example
#'   `list(face = "#193E36", rim = "#009E73", ink = "white")`.
#'   Use [hex_palette()] to see available roles.
#' @param motif_x,motif_y Motif centre in normalised canvas coordinates.
#' @param motif_scale Motif size multiplier.
#' @param label_y Name centre in normalised canvas coordinates.
#' @param label_size Maximum name size in points on the six-inch master.
#' @param border_width Border width on the six-inch master.
#' @param shape Frame shape: `hex`, `pentagon`, or `square`.
#' @param icon Optional generic icon key from [hexmakr_icons()], replacing the CTTIR motif.
#' @return A serialisable `hex_design` object.
#' @export
#' @examples
#' design <- hex_design("phenoscapR")
#' design
hex_design <- function(package = "hexmakR", mode = c("dark", "light", "mono"),
                       layout = c("lockup", "hex", "motif"), label = package,
                       colors = list(), motif_x = .5, motif_y = NULL,
                       motif_scale = 1, label_y = .215, label_size = 32,
                       border_width = 5.5, shape = c("hex", "pentagon", "square"), icon = NULL) {
  mode <- match.arg(mode); layout <- match.arg(layout); shape <- match.arg(shape)
  if (is.null(motif_y)) motif_y <- if (layout == "lockup") .585 else .5
  x <- structure(list(schema = "hexmakR/v5-design/1", package = package,
    mode = mode, layout = layout, label = label, colors = colors,
    motif_x = motif_x, motif_y = motif_y, motif_scale = motif_scale,
    label_y = label_y, label_size = label_size, border_width = border_width,
    shape = shape, icon = icon %||% "", layers = list()), class = "hex_design")
  .validate_design(x)
  x
}

.validate_design <- function(x) {
  fields <- c("schema", "package", "mode", "layout", "label", "colors", "motif_x",
              "motif_y", "motif_scale", "label_y", "label_size", "border_width", "shape", "icon", "layers")
  .named_fields(x, fields, "design")
  if (!setequal(names(x), fields) || !identical(x$schema, "hexmakR/v5-design/1"))
    stop("Unsupported or incomplete design schema.", call. = FALSE)
  .identity_row(x$package)
  .scalar_text(x$mode, "mode"); .scalar_text(x$layout, "layout")
  if (!x$mode %in% c("light", "dark", "mono") || !x$layout %in% c("hex", "lockup", "motif"))
    stop("Invalid mode or layout.", call. = FALSE)
  .scalar_text(x$shape, "shape")
  if (!x$shape %in% c("hex", "pentagon", "square")) stop("Invalid frame shape.", call. = FALSE)
  .scalar_text(x$icon, "icon", empty = TRUE)
  if (nzchar(x$icon)) .lookup_icon(x$icon)
  .scalar_text(x$label, "label", empty = TRUE)
  .named_fields(x$colors, setdiff(names(.cttir_engine()$cttir_style("spatial")), "mode"), "colour")
  lapply(x$colors, .color_value)
  for (key in c("motif_x", "motif_y", "label_y")) .scalar_number(x[[key]], key, 0, 1)
  .scalar_number(x$motif_scale, "motif_scale", .1, 2)
  .scalar_number(x$label_size, "label_size", 6, 64)
  .scalar_number(x$border_width, "border_width", 0, 20)
  if (!is.list(x$layers) || length(x$layers) > 1000L ||
      (length(x$layers) && (is.null(names(x$layers)) || anyDuplicated(names(x$layers)) ||
       any(!grepl("^layer_[0-9]{4}$", names(x$layers))))))
    stop("Invalid layer edits.", call. = FALSE)
  lapply(x$layers, .validate_layer_edit)
  invisible(x)
}

.validate_layer_edit <- function(edit) {
  .named_fields(edit, c("fill", "col", "lwd", "alpha", "dx", "dy", "scale", "visible", "x", "y"), "layer")
  for (k in intersect(names(edit), c("fill", "col"))) .color_value(edit[[k]])
  for (k in intersect(names(edit), c("dx", "dy"))) .scalar_number(edit[[k]], k, -1, 1)
  if (!is.null(edit$lwd)) .scalar_number(edit$lwd, "lwd", 0, 30)
  if (!is.null(edit$alpha)) .scalar_number(edit$alpha, "alpha", 0, 1)
  if (!is.null(edit$scale)) .scalar_number(edit$scale, "scale", .1, 3)
  if (!is.null(edit$visible) && (!is.logical(edit$visible) || length(edit$visible) != 1L || is.na(edit$visible)))
    stop("visible must be TRUE or FALSE.", call. = FALSE)
  for (k in intersect(names(edit), c("x", "y"))) {
    v <- edit[[k]]
    if (!is.numeric(v) || !length(v) || length(v) > 5000L || any(!is.finite(v)) || any(v < -1 | v > 2))
      stop("Coordinates must be finite numeric values between -1 and 2.", call. = FALSE)
  }
  invisible(edit)
}

#' Inspect a design's palette roles
#' @param design A [hex_design()] object.
#' @return A named list of colours.
#' @export
hex_palette <- function(design) {
  .validate_design(design)
  s <- .cttir_engine()$cttir_style(.identity_row(design$package)$family, design$mode)
  s[names(design$colors)] <- design$colors
  s[setdiff(names(s), "mode")]
}

#' @export
print.hex_design <- function(x, ...) {
  grid::grid.newpage()
  grid::grid.draw(hex_grob(x))
  invisible(x)
}

# Draw glyph outlines from the supplied font; no font installation or fallback.
.cttir_name_path <- function(label, y, size, colour, ratio) {
  if (!nzchar(label)) return(invisible(NULL))
  font <- .cttir_path("source", "fonts", "JetBrainsMono-SemiBold.ttf")
  shape <- systemfonts::shape_string(label, path = font, size = size)
  while (shape$metrics$width > .62 * 432 && size > 6) {
    size <- size - .25
    shape <- systemfonts::shape_string(label, path = font, size = size)
  }
  o <- systemfonts::glyph_outline(shape$shape$index, font, size = size, tolerance = .04)
  if (!nrow(o)) return(invisible(NULL))
  o$x <- o$x + shape$shape$x_offset[o$glyph]
  o$y <- o$y + shape$shape$y_offset[o$glyph]
  ids <- as.integer(factor(paste(o$glyph, o$contour), levels = unique(paste(o$glyph, o$contour))))
  grid::grid.path(x = .5 + (o$x - shape$metrics$width / 2) / 432,
    y = y + (o$y - mean(range(o$y))) / (432 / ratio),
    id = ids, rule = "winding", gp = grid::gpar(fill = colour, col = NA), name = "package-name")
}

.draw_cttir <- function(design) {
  engine <- .cttir_engine()
  s <- engine$cttir_style(.identity_row(design$package)$family, design$mode)
  s[names(design$colors)] <- design$colors
  if (design$layout != "motif") {
    xy <- .logo_frame(design$shape)
    grid::grid.polygon(xy$x, xy$y,
      gp = grid::gpar(fill = s$face, col = s$rim, lwd = design$border_width, linejoin = "round"),
      name = "hex-frame")
    grid::pushViewport(grid::viewport(name = "frame-clip", clip = grid::polygonGrob(xy$x, xy$y)))
    on.exit(grid::popViewport(), add = TRUE)
  }
  size <- switch(design$layout, lockup = .73, hex = .88, motif = .95) * design$motif_scale
  grid::pushViewport(grid::viewport(x = design$motif_x, y = design$motif_y,
    width = size, height = size * .design_ratio(design), name = "motif-space"))
  if (nzchar(design$icon)) .lookup_icon(design$icon)(.5, .5, .85, s$mid)
  else engine$cttir_motif(design$package, s, small = FALSE)
  grid::popViewport()
  if (design$layout == "lockup") .cttir_name_path(design$label, design$label_y, design$label_size, s$ink, .design_ratio(design))
}

#' Render a design to native grid geometry
#' @param design A [hex_design()] object.
#' @return A grid gTree with stable, editable child layer names.
#' @export
hex_grob <- function(design) {
  .validate_design(design)
  tree <- .capture_cttir(design)
  ids <- sprintf("layer_%04d", seq_along(tree$children))
  names(tree$children) <- ids
  tree$childrenOrder <- ids
  for (i in seq_along(ids)) tree$children[[i]]$name <- ids[i]
  if (any(!names(design$layers) %in% ids)) stop("A saved edit refers to a missing layer.", call. = FALSE)
  for (id in names(design$layers)) tree$children[[id]] <- .edit_cttir_grob(tree$children[[id]], design$layers[[id]])
  tree
}

.edit_cttir_grob <- function(g, edit) {
  for (key in c("x", "y")) {
    if (!is.null(edit[[key]])) {
      if (is.null(g[[key]]) || length(edit[[key]]) != length(g[[key]]))
        stop("Coordinate count does not match this layer.", call. = FALSE)
      g[[key]] <- grid::unit(edit[[key]], "npc")
    }
  }
  sc <- edit$scale %||% 1
  for (key in intersect(c("x", "y"), names(g))) {
    center <- if (length(g[[key]]) > 1) grid::unit(.5, "npc") else g[[key]]
    g[[key]] <- center + (g[[key]] - center) * sc + grid::unit(edit[[paste0("d", key)]] %||% 0, "npc")
  }
  for (key in intersect(c("width", "height", "r"), names(g))) g[[key]] <- g[[key]] * sc
  for (key in intersect(c("fill", "col", "lwd", "alpha"), names(edit))) g$gp[[key]] <- edit[[key]]
  if (identical(edit$visible, FALSE)) g$gp$alpha <- 0
  g
}

#' Inspect editable vector layers
#' @param design A [hex_design()] object.
#' @return A data frame with stable IDs, geometry type and current colour roles.
#' @export
hex_layers <- function(design) {
  g <- hex_grob(design)
  out <- lapply(seq_along(g$children), function(i) {
    child <- g$children[[i]]
    data.frame(id = names(g$children)[i], type = class(child)[1],
      fill = as.character(child$gp$fill %||% NA_character_),
      col = as.character(child$gp$col %||% NA_character_),
      points = length(child$x %||% numeric()), stringsAsFactors = FALSE)
  })
  do.call(rbind, out)
}

#' Edit one vector layer
#' @param design A [hex_design()] object.
#' @param layer A stable layer ID from [hex_layers()].
#' @param ... Edits: `fill`, `col`, `lwd`, `alpha`, `dx`, `dy`, `scale`, `visible`,
#'   or explicit numeric `x`/`y` coordinates in the layer's local viewport.
#' @param reset Remove earlier edits to this layer before applying new values.
#' @return An updated design. The input is unchanged.
#' @export
#' @examples
#' d <- hex_design("phenoscapR")
#' hex_edit_layer(d, "layer_0001", fill = "#193E36")
hex_edit_layer <- function(design, layer, ..., reset = FALSE) {
  .validate_design(design); .scalar_text(layer, "layer")
  if (!layer %in% hex_layers(design)$id) stop("Unknown layer: ", layer, call. = FALSE)
  edits <- list(...); .validate_layer_edit(edits)
  if (isTRUE(reset)) design$layers[[layer]] <- NULL
  if (length(edits)) design$layers[[layer]] <- utils::modifyList(design$layers[[layer]] %||% list(), edits)
  .validate_design(design)
  hex_grob(design) # Also validate coordinate lengths before accepting an edit.
  design
}

.design_ratio <- function(design) {
  if (design$layout == "motif" || design$shape != "hex") 1 else .hex_ratio()
}
.logo_frame <- function(shape) {
  switch(shape,
    hex = list(x = .5 + c(0,.48,.48,0,-.48,-.48), y = .5 + c(.48,.24,-.24,-.48,-.24,.24)),
    pentagon = { a <- pi / 2 + (0:4) * 2 * pi / 5
      list(x = .5 + .48 * cos(a), y = .5 + .48 * sin(a)) },
    square = list(x = c(.02,.98,.98,.02), y = c(.98,.98,.02,.02)))
}

#' Create a project logo in three frame shapes
#'
#' Reuse a CTTIR scientific motif or a generic icon for a project, with its
#' name inside a hexagonal, pentagonal or square frame. The same editing,
#' project and export functions work with all shapes.
#' @param name Project name shown inside the frame.
#' @param motif CTTIR identity supplying the motif and default palette.
#' @param shape `hex`, `pentagon` or `square`.
#' @param icon Optional generic icon key, replacing the CTTIR motif.
#' @param ... Other settings passed to [hex_design()].
#' @return An editable `hex_design` object.
#' @export
#' @examples
#' logo_design("My project", motif = "phenoscapR", shape = "pentagon")
#' logo_design("Study", shape = "square", icon = "microscope")
logo_design <- function(name, motif = "hexmakR", shape = c("hex", "pentagon", "square"),
                        icon = NULL, ...) {
  hex_design(package = motif, label = name, shape = match.arg(shape), icon = icon, ...)
}

# grid.grabExpr restores device 1 with dev.set(), which opens a new default
# device in a fresh R session. Close only our offscreen device instead.
.capture_cttir <- function(design) {
  previous <- grDevices::dev.cur()
  grDevices::pdf(NULL, width = 6, height = 6 / .design_ratio(design))
  capture <- grDevices::dev.cur()
  on.exit({
    grDevices::dev.off(capture)
    if (previous > 1L && previous %in% grDevices::dev.list()) grDevices::dev.set(previous)
  }, add = TRUE)
  .draw_cttir(design)
  grid::grid.grab(wrap = FALSE)
}
