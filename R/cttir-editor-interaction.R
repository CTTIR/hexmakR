# Coordinate conversion is independent of the preview container's letterboxing.
.cttir_preview_point <- function(click, width, height) {
  if (!is.list(click)) return(NULL)
  finite_pair <- function(value) {
    is.list(value) && all(vapply(value[c("x", "y")], function(x)
      is.numeric(x) && length(x) == 1L && is.finite(x), logical(1))) &&
      all(c("x", "y") %in% names(value))
  }
  pixel <- click$coords_img
  if (!finite_pair(pixel) && finite_pair(click$coords_css) &&
      finite_pair(click$img_css_ratio)) {
    pixel <- list(x = click$coords_css$x * click$img_css_ratio$x,
                  y = click$coords_css$y * click$img_css_ratio$y)
  }
  if (finite_pair(pixel)) {
    if (pixel$x < 0 || pixel$y < 0 || pixel$x > width - 1 ||
        pixel$y > height - 1) return(NULL)
    return(list(x = pixel$x / (width - 1), y = 1 - pixel$y / (height - 1)))
  }
  if (!finite_pair(click)) return(NULL)
  domain <- click$domain
  normalised <- isTRUE(click$normalized) ||
    (is.list(domain) && identical(as.numeric(unlist(domain[c("left", "right", "bottom", "top")])),
                                 c(0, 1, 0, 1)))
  if (normalised) {
    if (click$x < 0 || click$x > 1 || click$y < 0 || click$y > 1) return(NULL)
    return(list(x = click$x, y = click$y))
  }
  .cttir_preview_point(list(coords_img = list(x = click$x, y = click$y)), width, height)
}

.cttir_preview_coordmap <- function(width, height, revision) {
  list(dims = list(width = width, height = height), panels = list(list(
    domain = list(left = 0, right = 1, bottom = 0, top = 1),
    range = list(left = 0, right = width - 1, bottom = height - 1, top = 0),
    mapping = list(), panel_vars = list(render_id = revision)
  )))
}

.cttir_preview_script <- function() {
  paste(readLines(system.file("editor", "preview.js", package = "hexmakR"),
                  warn = FALSE), collapse = "\n")
}

.cttir_uploaded_art <- function(design, upload) {
  if (!is.data.frame(upload) || nrow(upload) != 1L ||
      !all(c("datapath", "name") %in% names(upload))) {
    stop("Choose one PNG, JPEG or SVG file.", call. = FALSE)
  }
  ext <- tolower(tools::file_ext(upload$name[[1]]))
  if (!ext %in% c("png", "jpg", "jpeg", "svg")) {
    stop("Use a PNG, JPEG or SVG file.", call. = FALSE)
  }
  path <- upload$datapath[[1]]
  bytes <- file.info(path)$size
  if (length(bytes) != 1L || is.na(bytes) || bytes <= 0 || bytes > 10 * 1024^2) {
    stop("Artwork uploads must be nonempty and no larger than 10 MiB.", call. = FALSE)
  }
  copy <- tempfile(fileext = paste0(".", ext))
  on.exit(unlink(copy), add = TRUE)
  if (!file.copy(path, copy)) stop("The uploaded artwork could not be read.", call. = FALSE)
  hex_import_art(design, copy)
}


# Native IDs depend on whether frame/name and which base artwork are present.
# Keep semantic frame/name metadata and unchanged motif order, never raw old IDs.
.cttir_transfer_metadata <- function(old, design) {
  before <- hex_layers(old)
  after <- hex_layers(design)
  added <- intersect(before$id[before$role == "added"], after$id[after$role == "added"])
  mapping <- stats::setNames(added, added)
  same_artwork <- identical(old$package, design$package) &&
    identical(old$icon, design$icon) && identical(old$archive, design$archive)
  for (role in c("frame", "name", if (same_artwork) "motif")) {
    source <- before$id[before$role == role]
    target <- after$id[after$role == role]
    if (length(source) == length(target) && length(source)) {
      mapping <- c(mapping, stats::setNames(target, source))
    }
  }
  labels <- old$labels %||% list()
  keep <- intersect(names(labels), names(mapping))
  design$labels <- stats::setNames(labels[keep], unname(mapping[keep]))
  if (is.null(old$groups)) {
    design$groups <- NULL
  } else {
    groups <- old$groups
    for (id in names(groups)) {
      members <- groups[[id]]$members
      groups[[id]]$members <- unname(mapping[intersect(members, names(mapping))])
      if (!length(groups[[id]]$members)) groups[[id]] <- NULL
    }
    design$groups <- if (length(groups)) groups else list()
  }
  design
}


# Visibility is a separate switch; hiding must not erase the source opacity.
.cttir_part_alpha <- function(design, id, leaf, edit) {
  if (!is.null(edit$alpha)) return(edit$alpha)
  if (identical(edit$visible, FALSE)) {
    unhidden <- design
    unhidden$layers[[id]]$visible <- NULL
    leaf <- .layer_leaf(hex_grob(unhidden)$children[[id]])
  }
  leaf$gp$alpha %||% 1
}
