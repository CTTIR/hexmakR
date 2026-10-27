# Item labels and groups are declarative metadata, separate from geometry.
.validate_groups <- function(design, available = NULL) {
  labels <- design$labels %||% list()
  if (!is.list(labels) || length(labels) > 1512L || (length(labels) &&
      (is.null(names(labels)) || anyDuplicated(names(labels)) ||
       any(!grepl("^(layer|part)_[0-9]{4}$", names(labels)))))) {
    stop("Invalid item labels.", call. = FALSE)
  }
  label_text <- function(x) {
    .scalar_text(x, "item or group label")
    if (nchar(x) > 80L || grepl("[[:cntrl:]]", x)) {
      stop("Labels must be short, single-line text.", call. = FALSE)
    }
  }
  invisible(lapply(labels, label_text))
  groups <- design$groups %||% list()
  if (!is.list(groups) || length(groups) > 512L || (length(groups) &&
      (is.null(names(groups)) || anyDuplicated(names(groups)) ||
       any(!grepl("^(frame|icon|name|group_[0-9]{4})$", names(groups)))))) {
    stop("Invalid image groups.", call. = FALSE)
  }
  members <- character()
  for (g in groups) {
    .named_fields(g, c("label", "members"), "group")
    if (!setequal(names(g), c("label", "members"))) {
      stop("Incomplete group.", call. = FALSE)
    }
    label_text(g$label)
    if (!is.character(g$members) || anyNA(g$members) ||
        !length(g$members) || anyDuplicated(g$members) ||
        any(!grepl("^(layer|part)_[0-9]{4}$", g$members))) {
      stop("Invalid group members.", call. = FALSE)
    }
    members <- c(members, g$members)
  }
  if (anyDuplicated(members)) {
    stop("An item can belong to only one group.", call. = FALSE)
  }
  if (!is.null(available) && any(!c(names(labels), members) %in% available)) {
    stop("An item label or group refers to a missing layer.", call. = FALSE)
  }
  invisible(design)
}

.apply_layer_metadata <- function(design, table) {
  if (!nrow(table)) return(table)
  primitive <- c(polygon = "Shape", pathgrob = "Path", lines = "Line",
                 polyline = "Line", segments = "Line", circle = "Circle",
                 rect = "Rectangle", rastergrob = "Image", text = "Text",
                 gTree = "Part", hex_art_raster = "Image", hex_svg_path = "Path")
  names <- unname(primitive[table$type])
  names[is.na(names)] <- "Part"
  names[table$role == "frame"] <- "Frame"
  names[table$role == "name"] <- "Name"
  names[table$role == "motif"] <- paste("Icon", names[table$role == "motif"])
  # Use user-supplied source labels for imported artwork where available.
  for (i in which(table$role == "added")) {
    part <- (design$parts %||% list())[[table$id[i]]]
    if (!is.null(part$name) && is.character(part$name) && nzchar(part$name)) {
      names[i] <- substr(gsub("[[:cntrl:]]", " ", part$name), 1L, 70L)
    }
  }
  duplicated_names <- names %in% names[duplicated(names)]
  for (label in unique(names[duplicated_names])) {
    at <- which(names == label)
    names[at] <- paste(label, seq_along(at))
  }
  overrides <- design$labels %||% list()
  for (id in intersect(table$id, names(overrides))) {
    names[match(id, table$id)] <- overrides[[id]]
  }
  table$name <- names
  table
}

#' Inspect and organise groups of logo items
#'
#' Native designs begin with Frame, Icon and Name groups when those items are
#' present. Custom groups have stable IDs and one membership per item. Grouping
#' changes metadata only: appearance and stacking order are retained.
#' @param design A [hex_design()] object.
#' @param layers Character vector of IDs from [hex_layers()].
#' @param label Short item or group name, at most 80 characters.
#' @param group Existing group ID to update; `NULL` creates a new group.
#' @return `hex_groups()` returns a named list of groups, each with a `label`
#'   and `members`. The other functions return an updated design.
#' @export
#' @examples
#' d <- hex_design("phenoscapR")
#' hex_groups(d)
#' d <- hex_group_layers(d, hex_groups(d)$icon$members, "Package icon")
hex_groups <- function(design) {
  .validate_design(design)
  if (!is.null(design$groups)) {
    return(if (length(design$groups)) design$groups else list())
  }
  layers <- hex_layers(design)
  out <- list()
  for (id in c("frame", "icon", "name")) {
    roles <- if (id == "icon") c("motif", "added") else id
    members <- layers$id[layers$role %in% roles]
    if (length(members)) {
      out[[id]] <- list(label = switch(id, frame = "Frame", icon = "Icon",
                                       name = "Name"), members = members)
    }
  }
  out
}

#' @rdname hex_groups
#' @export
hex_group_layers <- function(design, layers, label = "Group", group = NULL) {
  .validate_design(design)
  ids <- hex_layers(design)$id
  if (!is.character(layers) || !length(layers) || anyNA(layers) ||
      anyDuplicated(layers) || any(!layers %in% ids)) {
    stop("Choose existing items to group.", call. = FALSE)
  }
  groups <- hex_groups(design)
  if (is.null(group)) {
    current <- grep("^group_[0-9]{4}$", names(groups), value = TRUE)
    next_id <- if (length(current)) {
      max(as.integer(sub("group_", "", current, fixed = TRUE))) + 1L
    } else 1L
    if (next_id > 9999L) stop("Too many groups.", call. = FALSE)
    group <- sprintf("group_%04d", next_id)
  } else if (!is.character(group) || length(group) != 1L ||
             is.na(group) || !group %in% names(groups)) {
    stop("Unknown image group.", call. = FALSE)
  }
  for (id in names(groups)) {
    groups[[id]]$members <- setdiff(groups[[id]]$members, layers)
    if (!length(groups[[id]]$members)) groups[[id]] <- NULL
  }
  groups[[group]] <- list(label = label, members = layers)
  design$groups <- groups
  .validate_groups(design, ids)
  design
}

#' @rdname hex_groups
#' @export
hex_ungroup_layers <- function(design, layers) {
  .validate_design(design)
  if (!is.character(layers) || anyNA(layers) ||
      any(!layers %in% hex_layers(design)$id)) {
    stop("Choose existing items to ungroup.", call. = FALSE)
  }
  groups <- hex_groups(design)
  for (id in names(groups)) {
    groups[[id]]$members <- setdiff(groups[[id]]$members, layers)
    if (!length(groups[[id]]$members)) groups[[id]] <- NULL
  }
  design$groups <- if (length(groups)) groups else list()
  .validate_groups(design)
  design
}

#' @rdname hex_groups
#' @export
hex_rename_group <- function(design, group, label) {
  .validate_design(design)
  groups <- hex_groups(design)
  if (!is.character(group) || length(group) != 1L || is.na(group) ||
      !group %in% names(groups)) stop("Unknown image group.", call. = FALSE)
  groups[[group]]$label <- label
  design$groups <- if (length(groups)) groups else list()
  .validate_groups(design)
  design
}

#' Label an editable logo item
#' @param design A [hex_design()] object.
#' @param layer Stable item ID from [hex_layers()].
#' @param label Short item name, at most 80 characters.
#' @return An updated design. Labels survive project saves and duplication.
#' @export
#' @examples
#' d <- hex_label_layer(hex_design("phenoscapR"), "layer_0001", "Border")
hex_label_layer <- function(design, layer, label) {
  .validate_design(design)
  .scalar_text(layer, "layer")
  if (!layer %in% hex_layers(design)$id) stop("Unknown item.", call. = FALSE)
  if (is.null(design$labels)) design$labels <- list()
  design$labels[[layer]] <- label
  .validate_groups(design)
  design
}

.drop_layer_metadata <- function(design, ids) {
  for (id in ids) design$labels[[id]] <- NULL
  if (!is.null(design$groups)) for (group in names(design$groups)) {
    design$groups[[group]]$members <- setdiff(design$groups[[group]]$members, ids)
    if (!length(design$groups[[group]]$members)) design$groups[[group]] <- NULL
  }
  design
}
