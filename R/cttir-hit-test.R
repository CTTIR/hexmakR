# Rotation is a grid transform of the same vector/raster geometry used for export.
.cttir_layer_ratio <- function(g, design) {
  vp <- .layer_leaf(g)$vp
  if (!is.null(vp) && grepl("motif-space", as.character(vp), fixed = TRUE)) 1 else .design_ratio(design)
}

.rotate_cttir_grob <- function(g, angle, ratio) {
  angle <- (angle + 180) %% 360 - 180
  if (angle == 0 || is.null(g$x) || is.null(g$y)) return(g)
  x <- as.numeric(g$x); y <- as.numeric(g$y)
  cx <- mean(range(x)); cy <- mean(range(y))
  unrotated <- g
  original_vp <- g$vp
  g$vp <- NULL
  g$x <- g$x + grid::unit(.5 - cx, "npc")
  g$y <- g$y + grid::unit(.5 - cy, "npc")
  rotated <- grid::gTree(name = unrotated$name, vp = original_vp,
    children = grid::gList(grid::gTree(children = grid::gList(g),
      vp = grid::viewport(x = cx, y = cy, angle = angle))),
    hex_part_leaf = unrotated, hex_rotation = angle,
    hex_role = unrotated$hex_role %||% "motif")
  if (identical(unrotated$hex_role, "frame")) {
    radians <- angle * pi / 180
    rotated$hex_frame_clip <- grid::polygonGrob(
      cx + (x - cx) * cos(radians) - (y - cy) * sin(radians) / ratio,
      cy + (x - cx) * sin(radians) * ratio + (y - cy) * cos(radians))
  }
  rotated
}

# Render one real layer at preview resolution. Separate alpha masks avoid colour
# ID blending at antialiased edges and respect transparent fills and image pixels.
.hex_layer_mask <- function(tree, path, width, height) {
  grDevices::png(path, width = width, height = height, res = width / 6,
    bg = "transparent", type = "cairo", antialias = "gray")
  on.exit(grDevices::dev.off(), add = TRUE)
  grid::grid.newpage()
  grid::grid.draw(tree)
  invisible(NULL)
}

.hex_hit_map <- function(design, width = 800L) {
  .validate_design(design)
  .scalar_number(width, "hit-map width", 32, 1600)
  if (!capabilities("cairo")) stop("Cairo graphics are required for mouse selection.", call. = FALSE)
  width <- as.integer(round(width)); height <- as.integer(round(width / .design_ratio(design)))
  tree <- hex_grob(design)
  ids <- names(tree$children) %||% character()
  index <- matrix(0L, nrow = height, ncol = width)
  path <- tempfile(fileext = ".png")
  on.exit(unlink(path), add = TRUE)
  for (i in seq_along(ids)) {
    child <- tree$children[[i]]
    alpha <- .layer_leaf(child)$gp$alpha
    if (!is.null(alpha) && all(alpha == 0)) next
    layer <- tree
    layer$children <- grid::gList(child)
    names(layer$children) <- ids[i]
    layer$childrenOrder <- ids[i]
    .hex_layer_mask(layer, path, width, height)
    raster <- png::readPNG(path, native = TRUE)
    values <- as.integer(raster)
    # Native ARGB 0x80000000 is half-opaque black and shares R's NA integer bits.
    # nativeRaster stores rows contiguously; ordinary R matrices store columns.
    covered <- matrix(is.na(values) | bitwAnd(bitwShiftR(values, 24L), 255L) > 0L,
      nrow = height, ncol = width, byrow = TRUE)
    index[covered] <- as.integer(i)
  }
  list(index = index, ids = ids, width = width, height = height)
}

# Normalised canvas coordinates have their origin at the bottom-left, matching R.
.hex_hit_test <- function(map, x, y) {
  if (!is.numeric(x) || !is.numeric(y) || length(x) != 1L || length(y) != 1L ||
      !is.finite(x) || !is.finite(y) || x < 0 || x > 1 || y < 0 || y > 1) return(NULL)
  column <- min(map$width, as.integer(floor(x * map$width)) + 1L)
  row <- min(map$height, as.integer(floor((1 - y) * map$height)) + 1L)
  value <- map$index[row, column]
  if (is.na(value) || value == 0L) NULL else map$ids[[value]]
}

.hex_hit_bounds <- function(map, id) {
  position <- match(id, map$ids)
  if (is.na(position)) return(NULL)
  pixels <- which(map$index == position, arr.ind = TRUE)
  if (!nrow(pixels)) return(NULL)
  c(xmin = (min(pixels[, 2]) - 1) / map$width,
    ymin = 1 - max(pixels[, 1]) / map$height,
    xmax = max(pixels[, 2]) / map$width,
    ymax = 1 - (min(pixels[, 1]) - 1) / map$height)
}

# Recover a native leaf's actual local-to-canvas affine transform from grid's
# captured viewport tree. This includes nested viewports, not just motif scale.
.cttir_viewport_matrix <- function(viewports, target, ratio) {
  if (is.null(target)) return(diag(3))
  transforms <- new.env(parent = emptyenv())
  walk <- function(vp, matrix = diag(3), path = character(), aspect = ratio) {
    if (is.null(vp)) return(list(matrix = matrix, path = path, aspect = aspect))
    if (inherits(vp, "vpTree")) {
      state <- walk(vp$parent, matrix, path, aspect)
      walk(vp$children, state$matrix, state$path, state$aspect)
      return(state)
    }
    if (inherits(vp, "vpList") || inherits(vp, "vpStack")) {
      state <- list(matrix = matrix, path = path, aspect = aspect)
      for (item in vp) {
        next_state <- walk(item, state$matrix, state$path, state$aspect)
        if (inherits(vp, "vpStack")) state <- next_state
      }
      return(state)
    }
    width <- as.numeric(vp$width); height <- as.numeric(vp$height)
    x <- as.numeric(vp$x); y <- as.numeric(vp$y)
    if (any(!is.finite(c(width, height, x, y))) || length(width) != 1L ||
        length(height) != 1L || width <= 0 || height <= 0) {
      stop("This layer has an unsupported viewport transform.", call. = FALSE)
    }
    angle <- (vp$angle %||% 0) * pi / 180
    linear <- matrix(c(cos(angle) * width, sin(angle) * width * aspect,
      -sin(angle) * height / aspect, cos(angle) * height), nrow = 2)
    local <- diag(3)
    local[1:2, 1:2] <- linear
    local[1:2, 3] <- c(x, y) - linear %*% (vp$justification %||% c(.5, .5))
    combined <- matrix %*% local
    path <- c(path, vp$name)
    transforms[[paste(path, collapse = "::")]] <- combined
    list(matrix = combined, path = path, aspect = aspect * width / height)
  }
  walk(viewports)
  if (inherits(target, "viewport") && !inherits(target, "vpPath")) {
    walk(target)
    key <- target$name
  } else key <- as.character(target)
  result <- transforms[[key]]
  if (is.null(result)) stop("Could not resolve the selected layer's viewport.", call. = FALSE)
  result
}

.hex_translate_layers <- function(design, ids, dx, dy) {
  .validate_design(design)
  .scalar_number(dx, "canvas dx", -1, 1); .scalar_number(dy, "canvas dy", -1, 1)
  tree <- hex_grob(design)
  if (!is.character(ids) || !length(ids) || anyNA(ids) || anyDuplicated(ids) ||
      any(!ids %in% names(tree$children))) stop("Choose existing items to move.", call. = FALSE)
  if (dx == 0 && dy == 0) return(design)
  sources <- list(); source_trees <- list()
  for (id in ids) {
    part <- (design$parts %||% list())[[id]]
    if (!is.null(part) && identical(part$type, "archive")) {
      hit <- which(vapply(sources, identical, logical(1), part$source))
      if (length(hit)) native <- source_trees[[hit[1L]]] else {
        native <- hex_grob(part$source)
        sources <- c(sources, list(part$source)); source_trees <- c(source_trees, list(native))
      }
      leaf <- .layer_leaf(native$children[[part$layer]])
      transform <- .cttir_viewport_matrix(native$childrenvp, leaf$vp, .design_ratio(part$source))
      outer <- diag(3)
      outer[2, 2] <- .design_ratio(design) / .design_ratio(part$source)
      outer[2, 3] <- .5 - outer[2, 2] / 2
      transform <- outer %*% transform
    } else if (!is.null(part)) {
      transform <- diag(3)
    } else {
      leaf <- .layer_leaf(tree$children[[id]])
      transform <- .cttir_viewport_matrix(tree$childrenvp, leaf$vp, .design_ratio(design))
    }
    delta <- as.numeric(solve(transform[1:2, 1:2, drop = FALSE], c(dx, dy)))
    edit <- design$layers[[id]] %||% list()
    edit$dx <- (edit$dx %||% 0) + delta[1]
    edit$dy <- (edit$dy %||% 0) + delta[2]
    .validate_layer_edit(edit)
    design$layers[[id]] <- edit
  }
  .validate_design(design)
  hex_grob(design)
  design
}

#' Move a logo item in canvas coordinates
#' @param design A [hex_design()] object.
#' @param layer Stable item ID from [hex_layers()].
#' @param dx,dy Horizontal and vertical canvas offsets between -1 and 1.
#'   Positive values move right and up. Native and imported viewport scales are
#'   accounted for; existing point edits, size and rotation are retained.
#' @return An updated design. The input is unchanged.
#' @export
#' @examples
#' d <- hex_add_part(logo_design("Project"), "circle")
#' d <- hex_move_layer(d, "part_0001", .1, .05)
hex_move_layer <- function(design, layer, dx, dy) {
  .scalar_text(layer, "layer")
  .hex_translate_layers(design, layer, dx, dy)
}
