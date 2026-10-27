# Additional parts contain only whitelisted data; grid objects are rebuilt on demand.
.validate_part <- function(part) {
  if (is.list(part) && is.character(part$type) && length(part$type) == 1L &&
      part$type %in% c("raster", "svg_path")) return(.validate_import_part(part))
  .named_fields(part, c("type", "x", "y", "r", "width", "height", "fill", "col",
                       "lwd", "alpha", "source", "layer"), "part")
  .scalar_text(part$type, "part type")
  if (part$type == "archive") {
    if (!setequal(names(part), c("type", "source", "layer")))
      stop("Invalid archive part fields.", call. = FALSE)
    if (!is.list(part$source) || length(part$source$parts %||% list()) ||
        any(grepl("^part_", names(part$source$layers))))
      stop("Archive parts must reference native layers, without nested parts.", call. = FALSE)
    .validate_design(part$source)
    .scalar_text(part$layer, "source layer")
    if (!grepl("^layer_[0-9]{4}$", part$layer)) stop("Invalid native source layer.", call. = FALSE)
    return(invisible(part))
  }
  geometry <- switch(part$type, circle = c("x", "y", "r"),
    rectangle = c("x", "y", "width", "height"), line = c("x", "y"),
    polygon = c("x", "y"), stop("Unknown part type.", call. = FALSE))
  if (!setequal(names(part), c("type", geometry, "fill", "col", "lwd", "alpha")))
    stop("Incomplete or invalid primitive part fields.", call. = FALSE)
  .color_value(part$fill); .color_value(part$col)
  .scalar_number(part$lwd, "lwd", 0, 1000); .scalar_number(part$alpha, "alpha", 0, 1)
  .validate_layer_edit(part[c("x", "y")])
  if (length(part$x) != length(part$y)) stop("Part coordinate lengths must match.", call. = FALSE)
  if (part$type %in% c("circle", "rectangle")) {
    .scalar_number(part$x, "x", -1, 2); .scalar_number(part$y, "y", -1, 2)
    for (key in setdiff(geometry, c("x", "y"))) .scalar_number(part[[key]], key, .001, 2)
  } else if (length(part$x) < if (part$type == "line") 2L else 3L) {
    stop("A line needs two points and a polygon needs at least three.", call. = FALSE)
  }
  invisible(part)
}

.next_part_id <- function(design) {
  ids <- names(design$parts %||% list())
  next_id <- if (length(ids)) max(as.integer(sub("part_", "", ids, fixed = TRUE))) + 1L else 1L
  if (next_id > 9999L || length(ids) >= 512L) stop("Too many additional parts.", call. = FALSE)
  sprintf("part_%04d", next_id)
}

.append_part <- function(design, part, edit = list()) {
  id <- .next_part_id(design)
  if (is.null(design$parts)) design$parts <- list()
  design$parts[[id]] <- part
  if (length(edit)) design$layers[[id]] <- edit
  .validate_design(design)
  design
}

#' Add an editable primitive to a logo
#' @param design A [hex_design()] object.
#' @param type `circle`, `rectangle`, `line`, or `polygon`.
#' @param ... Primitive geometry in normalised canvas coordinates: `x`, `y`,
#'   and `r` for circles; `x`, `y`, `width`, `height` for rectangles; numeric
#'   `x` and `y` vectors for lines and polygons. Sensible centred defaults apply.
#' @param fill,col Fill and outline colours, including `"transparent"`.
#' @param lwd Outline width in points on the master canvas.
#' @param alpha Opacity between zero and one.
#' @return An updated design with a new stable `part_` ID. The input is unchanged.
#' @export
#' @examples
#' d <- logo_design("New project")
#' d <- hex_add_part(d, "circle", x = .5, y = .6, r = .15)
#' hex_layers(d)
hex_add_part <- function(design, type = c("circle", "rectangle", "line", "polygon"),
                         ..., fill = "#009E73", col = "#FFFFFF", lwd = 1, alpha = 1) {
  .validate_design(design); type <- match.arg(type)
  geometry <- switch(type, circle = list(x = .5, y = .6, r = .12),
    rectangle = list(x = .5, y = .6, width = .25, height = .2),
    line = list(x = c(.35, .65), y = c(.6, .6)),
    polygon = list(x = c(.35, .65, .5), y = c(.45, .45, .75)))
  supplied <- list(...); .named_fields(supplied, names(geometry), "primitive geometry")
  geometry[names(supplied)] <- supplied
  part <- c(list(type = type), geometry, list(fill = fill, col = col, lwd = lwd, alpha = alpha))
  .append_part(design, part)
}

.native_snapshot <- function(source) {
  source$parts <- list()
  source$layers <- source$layers[!grepl("^part_", names(source$layers))]
  source$labels <- list()
  source$groups <- NULL
  if (is.null(source$archive)) source$archive <- TRUE
  unclass(source)
}

#' Reuse editable archive parts in another logo
#'
#' Reused parts retain a validated snapshot of their native source settings,
#' colour overrides and edits. They remain independently editable. No code,
#' external files or serialised grid objects are loaded from a project.
#' @param design Destination [hex_design()] object.
#' @param source A catalogue identity or a [hex_design()] object.
#' @param layer Native layer ID to reuse. `NULL` reuses all motif layers,
#'   excluding the source frame and name.
#' @return An updated destination design; its frame, name and palette are retained.
#' @export
#' @examples
#' d <- hex_reuse_part(logo_design("New project"), "phenoscapR", "layer_0007")
hex_reuse_part <- function(design, source, layer = NULL) {
  .validate_design(design)
  if (is.character(source)) source <- hex_design(source)
  .validate_design(source)
  source <- .native_snapshot(source)
  available <- hex_layers(source)
  if (is.null(layer)) layer <- available$id[available$role == "motif"]
  if (!is.character(layer) || anyNA(layer) || anyDuplicated(layer) ||
      any(!layer %in% available$id)) stop("Select native source layers.", call. = FALSE)
  for (id in layer) design <- .append_part(design, list(type = "archive", source = source, layer = id))
  hex_grob(design)
  design
}

#' Duplicate or remove an editable part
#' @param design A [hex_design()] object.
#' @param layer Stable native or added part ID from [hex_layers()].
#' @return An updated design. Duplication preserves the current appearance.
#'   Removal hides native geometry or removes an added part; retaining the old
#'   design object permits undo.
#' @export
hex_duplicate_part <- function(design, layer) {
  .validate_design(design); .scalar_text(layer, "layer")
  if (!layer %in% hex_layers(design)$id) stop("Unknown layer: ", layer, call. = FALSE)
  next_id <- .next_part_id(design)
  label <- (design$labels %||% list())[[layer]]
  if (layer %in% names(design$parts %||% list())) {
    design <- .append_part(design, design$parts[[layer]], design$layers[[layer]] %||% list())
  } else {
    design <- .append_part(design, list(type = "archive", source = .native_snapshot(design), layer = layer))
  }
  if (!is.null(label)) design$labels[[next_id]] <- paste0(substr(label, 1, 75), " copy")
  hex_grob(design)
  design
}

#' @rdname hex_duplicate_part
#' @export
hex_remove_part <- function(design, layer) {
  .validate_design(design); .scalar_text(layer, "layer")
  if (!layer %in% hex_layers(design)$id) stop("Unknown layer: ", layer, call. = FALSE)
  if (layer %in% names(design$parts %||% list())) {
    design$parts[[layer]] <- NULL; design$layers[[layer]] <- NULL
    return(.drop_layer_metadata(design, layer))
  }
  hex_edit_layer(design, layer, visible = FALSE)
}

.layer_leaf <- function(g) g$hex_part_leaf %||% g

.update_frame_clip <- function(vp, clip) {
  if (is.null(vp)) return(NULL)
  if (inherits(vp, "vpTree")) {
    vp$parent <- .update_frame_clip(vp$parent, clip)
    vp$children <- .update_frame_clip(vp$children, clip)
  } else if (inherits(vp, "vpList") || inherits(vp, "vpStack")) {
    for (i in seq_along(vp)) vp[[i]] <- .update_frame_clip(vp[[i]], clip)
  } else if (inherits(vp, "viewport") && identical(vp$name, "frame-clip")) {
    vp$clip <- grid::viewport(clip = clip)$clip
  }
  vp
}

.unclip_source_viewports <- function(vp) {
  if (is.null(vp)) return(NULL)
  if (inherits(vp, "vpTree")) {
    vp$parent <- .unclip_source_viewports(vp$parent)
    vp$children <- .unclip_source_viewports(vp$children)
  } else if (inherits(vp, "vpList") || inherits(vp, "vpStack")) {
    for (i in seq_along(vp)) vp[[i]] <- .unclip_source_viewports(vp[[i]])
  } else if (inherits(vp, "viewport")) vp$clip <- FALSE
  vp
}

.part_grob <- function(design, part, id, edit, cache, clip) {
  source_tree <- NULL
  if (part$type == "archive") {
    hits <- which(vapply(cache$sources %||% list(), identical, logical(1), part$source))
    if (length(hits)) source_tree <- cache$trees[[hits[1L]]] else {
      source_tree <- hex_grob(part$source)
      cache$sources <- c(cache$sources, list(part$source))
      cache$trees <- c(cache$trees, list(source_tree))
    }
    if (!part$layer %in% names(source_tree$children)) stop("Archive part refers to a missing layer.", call. = FALSE)
    leaf <- source_tree$children[[part$layer]]
  } else if (part$type %in% c("raster", "svg_path")) {
    leaf <- .import_part_grob(design, part)
  } else {
    gp <- grid::gpar(fill = part$fill, col = part$col, lwd = part$lwd, alpha = part$alpha)
    leaf <- switch(part$type,
      circle = grid::circleGrob(part$x, part$y, r = part$r, gp = gp),
      rectangle = grid::rectGrob(part$x, part$y, width = part$width, height = part$height, gp = gp),
      line = grid::linesGrob(part$x, part$y, gp = gp),
      polygon = grid::polygonGrob(part$x, part$y, gp = gp))
  }
  leaf <- .edit_cttir_grob(leaf, edit,
    .cttir_layer_ratio(leaf, if (is.null(source_tree)) design else part$source))
  child <- leaf
  if (!is.null(source_tree)) child <- grid::gTree(children = grid::gList(leaf),
    childrenvp = .unclip_source_viewports(source_tree$childrenvp),
    vp = grid::viewport(height = .design_ratio(design) / .design_ratio(part$source)))
  grid::gTree(name = id, children = grid::gList(child), vp = grid::viewport(clip = clip),
    hex_part_leaf = .layer_leaf(leaf), hex_role = "added",
    hex_part_name = if (part$type == "archive") paste(part$source$package, part$layer) else (part$name %||% part$type))
}
