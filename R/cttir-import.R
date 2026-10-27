# Uploaded artwork is reduced to bounded data, never executable SVG or file paths.
.art_input_limit <- 10 * 1024^2
.art_pixel_limit <- 16e6
.art_project_pixel_limit <- function() 32e6
.art_svg_visit_limit <- function() 8192L

.validate_import_totals <- function(parts) {
  raster_pixels <- sum(vapply(parts, function(part) if (identical(part$type, "raster"))
    part$pixel_width * part$pixel_height else 0, numeric(1)))
  vector_points <- sum(vapply(parts, function(part) if (identical(part$type, "svg_path"))
    length(part$x) else 0, numeric(1)))
  if (raster_pixels > .art_project_pixel_limit())
    .art_error("A project supports at most 32 million embedded raster pixels in total.")
  if (vector_points > 100000L)
    .art_error("A project supports at most 100000 imported vector points in total.")
  invisible(parts)
}

.art_error <- function(message) stop(message, call. = FALSE)

.art_dimensions <- function(width, height) {
  if (length(width) != 1L || length(height) != 1L || !is.finite(width) ||
      !is.finite(height) || width < 1 || height < 1 || width > 8192 ||
      height > 8192 || width * height > .art_pixel_limit)
    .art_error("Images must be at most 8192 pixels per side and 16 million pixels in total.")
  c(width = width, height = height)
}

.art_be <- function(bytes) sum(as.integer(bytes) * 256^rev(seq_along(bytes) - 1L))

.raster_header <- function(bytes, mime = NULL) {
  n <- length(bytes)
  if (n >= 24L && identical(bytes[1:8], as.raw(c(137, 80, 78, 71, 13, 10, 26, 10)))) {
    if (!is.null(mime) && mime != "image/png") .art_error("Image data and MIME type disagree.")
    if (!identical(rawToChar(bytes[13:16]), "IHDR")) .art_error("Invalid PNG header.")
    return(list(mime = "image/png", dimensions = .art_dimensions(
      .art_be(bytes[17:20]), .art_be(bytes[21:24]))))
  }
  if (n >= 4L && identical(bytes[1:2], as.raw(c(255, 216)))) {
    if (!is.null(mime) && mime != "image/jpeg") .art_error("Image data and MIME type disagree.")
    p <- 3L
    while (p + 3L <= n) {
      if (bytes[p] != as.raw(255)) .art_error("Invalid JPEG marker.")
      while (p <= n && bytes[p] == as.raw(255)) p <- p + 1L
      if (p > n) break
      marker <- as.integer(bytes[p]); p <- p + 1L
      if (marker %in% c(216L, 1L, 208:215)) next
      if (marker %in% c(217L, 218L) || p + 1L > n) break
      size <- .art_be(bytes[p:(p + 1L)])
      if (size < 2L || p + size - 1L > n) .art_error("Truncated JPEG data.")
      if (marker %in% c(192:195, 197:199, 201:203, 205:207)) {
        if (size < 8L) .art_error("Invalid JPEG dimensions.")
        return(list(mime = "image/jpeg", dimensions = .art_dimensions(
          .art_be(bytes[(p + 5L):(p + 6L)]), .art_be(bytes[(p + 3L):(p + 4L)]))))
      }
      p <- p + size
    }
    .art_error("JPEG dimensions could not be read safely.")
  }
  if (!is.null(mime)) .art_error("Invalid embedded image signature.")
  NULL
}

.decode_art_raster <- function(bytes, mime) {
  header <- .raster_header(bytes, mime)
  image <- tryCatch(if (mime == "image/png") png::readPNG(bytes, native = TRUE)
    else jpeg::readJPEG(bytes, native = TRUE), error = function(e)
      .art_error(paste("Cannot decode uploaded image:", conditionMessage(e))))
  if (!inherits(image, "nativeRaster") ||
      !identical(as.numeric(rev(dim(image))), as.numeric(header$dimensions)))
    .art_error("Decoded image dimensions disagree with its header.")
  image
}

.art_base64 <- function(bytes) gsub("\n", "", jsonlite::base64_enc(bytes), fixed = TRUE)

.embedded_art_bytes <- function(data) {
  if (!is.character(data) || length(data) != 1L || is.na(data) ||
      nchar(data, type = "bytes") > 4 * ceiling(.art_input_limit / 3) ||
      !nzchar(data) || nchar(data) %% 4L != 0L ||
      !grepl("^[A-Za-z0-9+/]*={0,2}$", data)) .art_error("Invalid embedded image data.")
  bytes <- jsonlite::base64_dec(data)
  if (length(bytes) > .art_input_limit || !identical(.art_base64(bytes), data))
    .art_error("Invalid embedded image encoding or size.")
  bytes
}

.validate_import_part <- function(part) {
  if (identical(part$type, "raster")) {
    fields <- c("type", "name", "data", "mime", "pixel_width", "pixel_height",
                "x", "y", "width", "height", "alpha")
    .named_fields(part, fields, "image part")
    if (!setequal(names(part), fields)) .art_error("Incomplete image part.")
    .scalar_text(part$name, "image name")
    if (!identical(part$mime, "image/png") && !identical(part$mime, "image/jpeg"))
      .art_error("Only PNG and JPEG image data are supported.")
    dimensions <- .art_dimensions(part$pixel_width, part$pixel_height)
    header <- .raster_header(.embedded_art_bytes(part$data), part$mime)
    if (!identical(as.numeric(dimensions), as.numeric(header$dimensions)))
      .art_error("Embedded image dimensions disagree with its header.")
    for (key in c("x", "y")) .scalar_number(part[[key]], key, -1, 2)
    for (key in c("width", "height")) .scalar_number(part[[key]], key, .001, 2)
    .scalar_number(part$alpha, "alpha", 0, 1)
    return(invisible(part))
  }
  fields <- c("type", "name", "x", "y", "id", "closed", "rule", "fill", "col",
              "lwd", "alpha", "linejoin", "lineend", "linemitre")
  .named_fields(part, fields, "SVG part")
  if (!identical(part$type, "svg_path") || !setequal(names(part), fields))
    .art_error("Invalid SVG part fields.")
  .scalar_text(part$name, "SVG part name")
  .validate_layer_edit(part[c("x", "y")])
  n <- length(part$x)
  if (length(part$y) != n || !is.numeric(part$id) || length(part$id) != n ||
      any(!is.finite(part$id)) || any(part$id != trunc(part$id)) ||
      any(part$id < 1 | part$id > 512) ||
      !identical(as.numeric(unique(part$id)), as.numeric(seq_len(max(part$id)))) ||
      is.unsorted(part$id) || max(part$id) > 512L)
    .art_error("Invalid SVG subpath indices.")
  if (!is.numeric(part$closed) || length(part$closed) != max(part$id) ||
      anyNA(part$closed) || any(!part$closed %in% c(0, 1)))
    .art_error("Invalid SVG subpath closure data.")
  for (key in c("rule", "linejoin", "lineend")) .scalar_text(part[[key]], key)
  if (!part$rule %in% c("winding", "evenodd") || length(part$rule) != 1L ||
      !part$linejoin %in% c("round", "mitre", "bevel") || length(part$linejoin) != 1L ||
      !part$lineend %in% c("round", "butt", "square") || length(part$lineend) != 1L)
    .art_error("Invalid SVG path style.")
  .color_value(part$fill); .color_value(part$col)
  .scalar_number(part$lwd, "lwd", 0, 1000); .scalar_number(part$alpha, "alpha", 0, 1)
  .scalar_number(part$linemitre, "linemitre", 1, 1000)
  invisible(part)
}

.import_part_grob <- function(design, part) {
  if (part$type == "raster") return(grid::grob(
    raster = .decode_art_raster(.embedded_art_bytes(part$data), part$mime),
    x = grid::unit(part$x, "npc"), y = grid::unit(part$y, "npc"),
    width = grid::unit(part$width, "npc"), height = grid::unit(part$height, "npc"),
    gp = grid::gpar(alpha = part$alpha), cl = "hex_art_raster"))
  grid::grob(x = grid::unit(part$x, "npc"), y = grid::unit(part$y, "npc"),
    id = part$id, closed = part$closed, rule = part$rule,
    gp = grid::gpar(fill = part$fill, col = part$col, lwd = part$lwd,
      alpha = part$alpha, linejoin = part$linejoin, lineend = part$lineend, linemitre = part$linemitre),
    cl = "hex_svg_path")
}

#' @exportS3Method grid::drawDetails
drawDetails.hex_svg_path <- function(x, recording = FALSE) {
  fill_gp <- x$gp; fill_gp$col <- NA_character_; fill_gp$alpha <- 1
  grid::grid.path(x$x, x$y, id = x$id, rule = x$rule, gp = fill_gp)
  stroke_gp <- x$gp; stroke_gp$fill <- NA_character_; stroke_gp$alpha <- 1
  for (id in unique(x$id)) {
    indexes <- which(x$id == id)
    if (length(indexes) < 2L) next
    if (x$closed[id] == 1) indexes <- c(indexes, indexes[1L])
    grid::grid.lines(x$x[indexes], x$y[indexes], gp = stroke_gp)
  }
}

#' @exportS3Method grid::drawDetails
drawDetails.hex_art_raster <- function(x, recording = FALSE) {
  image <- x$raster; opacity <- x$gp$alpha %||% 1
  if (opacity < 1) {
    # Convert only the alpha byte; preserve native packed RGB and source alpha.
    values <- as.numeric(image)
    values[is.na(values)] <- -2147483648
    unsigned <- ifelse(values < 0, values + 2^32, values)
    alpha <- floor(unsigned / 2^24)
    adjusted <- unsigned %% 2^24 + round(alpha * opacity) * 2^24
    adjusted[adjusted >= 2^31] <- adjusted[adjusted >= 2^31] - 2^32
    adjusted[adjusted == -2147483648] <- NA_real_
    dim(adjusted) <- dim(image)
    image <- structure(as.integer(adjusted), dim = dim(image), class = "nativeRaster")
  }
  grid::grid.raster(image, x = x$x, y = x$y, width = x$width, height = x$height,
    interpolate = TRUE, gp = grid::gpar(alpha = 1))
}

.svg_numbers <- function(value, label = "SVG number list") {
  if (!is.character(value) || length(value) != 1L || is.na(value)) .art_error(paste("Invalid", label))
  number <- "[-+]?(?:[0-9]+\\.?[0-9]*|\\.[0-9]+)(?:[eE][-+]?[0-9]+)?"
  remaining <- gsub(number, "", value, perl = TRUE)
  if (nzchar(gsub("[[:space:],]", "", remaining))) .art_error(paste("Unsupported", label))
  matches <- regmatches(value, gregexpr(number, value, perl = TRUE))[[1L]]
  out <- as.numeric(matches)
  if (length(out) > 15000L || any(!is.finite(out)) || any(abs(out) > 1e7))
    .art_error(paste("Out-of-bounds", label))
  out
}

.svg_scalar <- function(value, default = NULL) {
  if (is.null(value)) return(default)
  value <- sub("px$", "", trimws(value))
  out <- .svg_numbers(value)
  if (length(out) != 1L) .art_error("Expected one SVG numeric value (unitless or px).")
  out
}

.svg_transform <- function(value) {
  result <- diag(3)
  if (is.null(value) || !nzchar(trimws(value))) return(result)
  pattern <- "[A-Za-z]+[[:space:]]*\\([^()]*\\)"
  tokens <- regmatches(value, gregexpr(pattern, value, perl = TRUE))[[1L]]
  if (!length(tokens) || nzchar(gsub("[[:space:],]", "", gsub(pattern, "", value, perl = TRUE))))
    .art_error("Unsupported SVG transform.")
  for (token in tokens) {
    type <- sub("[[:space:]]*\\(.*", "", token)
    v <- .svg_numbers(sub("^[^(]*\\((.*)\\)$", "\\1", token)); m <- diag(3)
    if (type == "matrix" && length(v) == 6L) m <- matrix(c(v[1:2], 0, v[3:4], 0, v[5:6], 1), 3)
    else if (type == "translate" && length(v) %in% 1:2) m[1:2, 3] <- c(v[1L], if (length(v) == 2L) v[2L] else 0)
    else if (type == "scale" && length(v) %in% 1:2) diag(m)[1:2] <- rep(v, length.out = 2L)
    else if (type == "rotate" && length(v) %in% c(1L, 3L)) {
      angle <- v[1L] * pi / 180
      m[1:2, 1:2] <- matrix(c(cos(angle), sin(angle), -sin(angle), cos(angle)), 2)
      if (length(v) == 3L) m[1:2, 3] <- v[2:3] - m[1:2, 1:2] %*% v[2:3]
    } else if (type %in% c("skewX", "skewY") && length(v) == 1L && abs(v) < 89) {
      if (type == "skewX") m[1, 2] <- tan(v * pi / 180) else m[2, 1] <- tan(v * pi / 180)
    } else .art_error(paste("Unsupported SVG transform:", type))
    result <- result %*% m
  }
  if (any(!is.finite(result)) || any(abs(result) > 1e7)) .art_error("SVG transform exceeds bounds.")
  result
}

.svg_arc <- function(start, end, rx, ry, phi, large, sweep) {
  if (!large %in% c(0, 1) || !sweep %in% c(0, 1)) .art_error("SVG arc flags must be 0 or 1.")
  if (all(start == end)) return(matrix(numeric(), ncol = 2))
  rx <- abs(rx); ry <- abs(ry)
  if (rx == 0 || ry == 0) return(matrix(end, nrow = 1))
  phi <- phi * pi / 180
  rotation <- matrix(c(cos(phi), sin(phi), -sin(phi), cos(phi)), 2)
  p <- as.numeric(t(rotation) %*% ((start - end) / 2))
  factor <- p[1]^2 / rx^2 + p[2]^2 / ry^2
  if (factor > 1) { rx <- rx * sqrt(factor); ry <- ry * sqrt(factor) }
  denominator <- rx^2 * p[2]^2 + ry^2 * p[1]^2
  sign <- if (large == sweep) -1 else 1
  coefficient <- sign * sqrt(max(0, (rx^2 * ry^2 - denominator) / denominator))
  centre_local <- coefficient * c(rx * p[2] / ry, -ry * p[1] / rx)
  centre <- as.numeric(rotation %*% centre_local) + (start + end) / 2
  u <- (p - centre_local) / c(rx, ry); v <- (-p - centre_local) / c(rx, ry)
  first <- atan2(u[2], u[1]); extent <- atan2(u[1] * v[2] - u[2] * v[1], sum(u * v))
  if (sweep == 0 && extent > 0) extent <- extent - 2 * pi
  if (sweep == 1 && extent < 0) extent <- extent + 2 * pi
  angles <- seq(first, first + extent, length.out = max(2L, ceiling(abs(extent) * 32) + 1L))[-1L]
  result <- t(rotation %*% rbind(rx * cos(angles), ry * sin(angles)))
  result <- sweep(result, 2, centre, "+"); result[nrow(result), ] <- end
  result
}

.svg_path <- function(value) {
  number <- "[-+]?(?:[0-9]+\\.?[0-9]*|\\.[0-9]+)(?:[eE][-+]?[0-9]+)?"
  pattern <- paste0("[MmLlHhVvCcSsQqTtAaZz]|", number)
  if (nzchar(gsub("[[:space:],]", "", gsub(pattern, "", value, perl = TRUE))))
    .art_error("Unsupported SVG path command or syntax.")
  tokens <- regmatches(value, gregexpr(pattern, value, perl = TRUE))[[1L]]
  if (!length(tokens) || length(tokens) > 20000L) .art_error("Empty or excessively complex SVG path.")
  paths <- list(); closed <- numeric(); current <- c(0, 0); begin <- current
  previous <- ""; control <- current; command <- NULL; i <- 1L; count <- 0L
  append <- function(points) {
    if (!length(paths)) .art_error("SVG paths must begin with a move command.")
    if (!length(points)) return(invisible(NULL))
    count <<- count + nrow(points)
    if (count > 5000L) .art_error("An SVG component may contain at most 5000 vector points.")
    paths[[length(paths)]] <<- rbind(paths[[length(paths)]], points)
  }
  while (i <= length(tokens)) {
    if (grepl("^[A-Za-z]$", tokens[i])) { command <- tokens[i]; i <- i + 1L }
    if (is.null(command)) .art_error("SVG path is missing a command.")
    type <- toupper(command); relative <- command != type
    if (type == "Z") {
      if (!length(paths)) .art_error("SVG close command has no subpath.")
      closed[length(paths)] <- 1; current <- begin; previous <- "Z"; command <- NULL
      next
    }
    size <- switch(type, M = 2L, L = 2L, H = 1L, V = 1L, C = 6L, S = 4L, Q = 4L, T = 2L, A = 7L)
    if (is.null(size) || i + size - 1L > length(tokens) ||
        any(grepl("^[A-Za-z]$", tokens[i:(i + size - 1L)]))) .art_error("Incomplete SVG path command.")
    v <- as.numeric(tokens[i:(i + size - 1L)]); i <- i + size
    if (any(!is.finite(v)) || any(abs(v) > 1e7)) .art_error("SVG path numbers exceed bounds.")
    point <- function(pair) pair + if (relative) current else c(0, 0)
    if (type == "M") {
      current <- point(v); begin <- current
      if (length(paths) >= 512L) .art_error("Too many SVG subpaths.")
      paths[[length(paths) + 1L]] <- matrix(current, nrow = 1); closed <- c(closed, 0)
      count <- count + 1L; command <- if (relative) "l" else "L"
    } else if (type %in% c("L", "H", "V")) {
      end <- if (type == "L") point(v) else if (type == "H")
        c(v + if (relative) current[1L] else 0, current[2L]) else
        c(current[1L], v + if (relative) current[2L] else 0)
      append(matrix(end, nrow = 1)); current <- end
    } else if (type %in% c("C", "S", "Q", "T")) {
      t <- seq(0, 1, length.out = 33L)[-1L]
      if (type %in% c("C", "S")) {
        c1 <- if (type == "C") point(v[1:2]) else if (previous %in% c("C", "S")) 2 * current - control else current
        c2 <- point(if (type == "C") v[3:4] else v[1:2])
        end <- point(if (type == "C") v[5:6] else v[3:4])
        points <- outer((1 - t)^3, current) + outer(3 * (1 - t)^2 * t, c1) +
          outer(3 * (1 - t) * t^2, c2) + outer(t^3, end)
        control <- c2
      } else {
        c1 <- if (type == "Q") point(v[1:2]) else if (previous %in% c("Q", "T")) 2 * current - control else current
        end <- point(if (type == "Q") v[3:4] else v[1:2])
        points <- outer((1 - t)^2, current) + outer(2 * (1 - t) * t, c1) + outer(t^2, end)
        control <- c1
      }
      append(points); current <- end
    } else if (type == "A") {
      end <- point(v[6:7]); append(.svg_arc(current, end, v[1L], v[2L], v[3L], v[4L], v[5L])); current <- end
    }
    previous <- type
  }
  list(points = do.call(rbind, paths), id = rep(seq_along(paths), lengths(lapply(paths, function(x) x[, 1L]))), closed = closed)
}

.svg_shape <- function(type, attrs) {
  get <- function(name, default = 0) .svg_scalar(attrs[[name]], default)
  if (type == "path") return(.svg_path(attrs$d %||% ""))
  if (type %in% c("polygon", "polyline")) {
    values <- .svg_numbers(attrs$points %||% "")
    if (length(values) < 4L || length(values) %% 2L) .art_error("Invalid SVG polygon points.")
    points <- matrix(values, ncol = 2, byrow = TRUE)
  } else if (type == "line") points <- rbind(c(get("x1"), get("y1")), c(get("x2"), get("y2")))
  else if (type == "rect") {
    x <- get("x"); y <- get("y"); width <- get("width"); height <- get("height")
    if (width <= 0 || height <= 0) .art_error("SVG rectangle dimensions must be positive.")
    rx <- get("rx", get("ry")); ry <- get("ry", rx)
    if (rx < 0 || ry < 0) .art_error("SVG corner radii must be nonnegative.")
    rx <- min(rx, width / 2); ry <- min(ry, height / 2)
    if (rx == 0 || ry == 0) points <- cbind(x + c(0, width, width, 0), y + c(0, 0, height, height))
    else {
      centres <- rbind(c(x + width - rx, y + ry), c(x + width - rx, y + height - ry),
        c(x + rx, y + height - ry), c(x + rx, y + ry))
      points <- do.call(rbind, lapply(1:4, function(i) {
        a <- seq(-pi / 2 + (i - 1) * pi / 2, (i - 1) * pi / 2, length.out = 17L)
        cbind(centres[i, 1] + rx * cos(a), centres[i, 2] + ry * sin(a))
      }))
    }
  } else if (type %in% c("circle", "ellipse")) {
    rx <- if (type == "circle") get("r") else get("rx"); ry <- if (type == "circle") rx else get("ry")
    if (rx <= 0 || ry <= 0) .art_error("SVG ellipse radii must be positive.")
    a <- seq(0, 2 * pi, length.out = 129L)[-129L]
    points <- cbind(get("cx") + rx * cos(a), get("cy") + ry * sin(a))
  } else .art_error(paste("Unsupported SVG element:", type))
  list(points = points, id = rep(1, nrow(points)), closed = as.numeric(!type %in% c("line", "polyline")))
}

.svg_color <- function(value, opacity = 1) {
  value <- trimws(value)
  if (value == "none") return("transparent")
  if (grepl("^rgb\\(", value)) {
    body <- sub("^rgb\\((.*)\\)$", "\\1", value)
    percent <- lengths(regmatches(body, gregexpr("%", body, fixed = TRUE)))
    if (!percent %in% c(0L, 3L)) .art_error("Unsupported SVG RGB colour.")
    values <- .svg_numbers(gsub("%", "", body, fixed = TRUE))
    if (length(values) != 3L || any(values < 0 | values > if (percent) 100 else 255)) .art_error("Unsupported SVG RGB colour.")
    if (percent) values <- values * 255 / 100
    values <- round(values)
    value <- grDevices::rgb(values[1], values[2], values[3], maxColorValue = 255)
  }
  if (grepl("^#[0-9A-Fa-f]{3}$", value)) {
    v <- strsplit(substring(value, 2), "")[[1L]]; value <- paste0("#", paste0(rep(v, each = 2L), collapse = ""))
  }
  .color_value(value)
  rgba <- grDevices::col2rgb(value, alpha = TRUE)[, 1L]
  grDevices::rgb(rgba[1], rgba[2], rgba[3], alpha = round(rgba[4] * opacity), maxColorValue = 255)
}

.svg_parts <- function(bytes, design) {
  text <- tryCatch(rawToChar(bytes), error = function(e) .art_error("SVG must be UTF-8 text."))
  if (grepl("<![[:space:]]*(DOCTYPE|ENTITY)|<\\?(?!xml[[:space:]])", text, ignore.case = TRUE, perl = TRUE))
    .art_error("SVG declarations, entities and processing instructions are not allowed.")
  doc <- tryCatch(xml2::read_xml(bytes, options = "NONET"), error = function(e)
    .art_error(paste("Invalid SVG XML:", conditionMessage(e))))
  root <- xml2::xml_root(doc)
  if (xml2::xml_name(root) != "svg") .art_error("Upload an SVG document with an svg root.")
  all <- xml2::xml_find_all(root, ".//*")
  if (length(all) > 2048L) .art_error("SVG has too many elements.")
  allowed <- c("svg", "g", "defs", "use", "clipPath", "title", "desc", "path", "rect", "circle", "ellipse", "line", "polygon", "polyline")
  nodes <- c(list(root), as.list(all))
  for (node in nodes) {
    type <- xml2::xml_name(node); attrs <- xml2::xml_attrs(node)
    attrs <- attrs[!grepl("^xmlns(:|$)", names(attrs))]
    if (!type %in% allowed) .art_error(paste0("Unsupported SVG element <", type,
      ">. Outline text and simplify gradients, masks and referenced objects before importing."))
    hrefs <- attrs[grepl("href$", names(attrs), ignore.case = TRUE)]
    paint_refs <- attrs[grepl("url[[:space:]]*\\(", attrs, ignore.case = TRUE)]
    local_clip <- names(paint_refs) == "clip-path" & grepl("^url\\(#[A-Za-z0-9_.:-]+\\)$", paint_refs)
    if (any(grepl("^on", names(attrs), ignore.case = TRUE)) ||
        any(!grepl("^#[A-Za-z0-9_.:-]+$", hrefs)) || any(!local_clip) ||
        any(grepl("javascript:|data:|file:|https?:", attrs, ignore.case = TRUE)))
      .art_error("SVG active content and external references are not allowed.")
  }
  attrs <- as.list(xml2::xml_attrs(root))
  view <- if (!is.null(attrs$viewBox)) .svg_numbers(attrs$viewBox) else
    c(0, 0, .svg_scalar(attrs$width), .svg_scalar(attrs$height))
  if (length(view) != 4L || any(!is.finite(view)) || any(view[3:4] <= 0))
    .art_error("SVG needs a positive viewBox or numeric width and height.")
  ratio <- .design_ratio(design)
  width <- min(.68, .58 * view[3] / view[4] / ratio)
  height <- width * view[4] / view[3] * ratio
  sx <- width / view[3]; sy <- height / view[4]
  presentation <- c("fill", "stroke", "stroke-width", "opacity", "fill-opacity", "stroke-opacity",
                    "fill-rule", "stroke-linejoin", "stroke-linecap", "stroke-miterlimit")
  defaults <- list(fill = "black", stroke = "none", `stroke-width` = "1", opacity = "1",
    `fill-opacity` = "1", `stroke-opacity` = "1", `fill-rule` = "nonzero",
    `stroke-linejoin` = "miter", `stroke-linecap` = "butt", `stroke-miterlimit` = "4")
  ids <- vapply(nodes, function(node) xml2::xml_attr(node, "id"), character(1))
  if (anyDuplicated(ids[!is.na(ids)])) .art_error("SVG IDs must be unique.")
  resolve <- function(id) {
    at <- which(!is.na(ids) & ids == id)
    if (length(at) != 1L) .art_error("SVG local reference does not identify one element.")
    nodes[[at]]
  }
  clip_polygon <- function(id, transform) {
    node <- resolve(id); attrs <- as.list(xml2::xml_attrs(node))
    if (xml2::xml_name(node) != "clipPath" ||
        any(!names(attrs) %in% c("id", "clipPathUnits", "transform")) ||
        !is.null(attrs$clipPathUnits) && attrs$clipPathUnits != "userSpaceOnUse")
      .art_error("SVG clipping supports simple local user-space paths only.")
    children <- xml2::xml_children(node)
    if (length(children) != 1L) .art_error("Simplify SVG clipping to one convex path before importing.")
    child <- children[[1L]]; ca <- as.list(xml2::xml_attrs(child))
    type <- xml2::xml_name(child)
    geometry <- switch(type, path = "d", rect = c("x", "y", "width", "height", "rx", "ry"),
      circle = c("cx", "cy", "r"), ellipse = c("cx", "cy", "rx", "ry"), polygon = "points", character())
    if (!length(geometry) || any(!names(ca) %in% c(geometry, "id", "transform", "clip-rule", "fill-rule")))
      .art_error("Simplify SVG clipping to one convex path before importing.")
    shape <- .svg_shape(type, ca)
    # Cairo may append a final move-only subpath; it contributes no clip area.
    counts <- table(shape$id); valid <- as.numeric(names(counts)[counts >= 3L])
    if (length(valid) != 1L) .art_error("Compound SVG clipping must be flattened before import.")
    p <- shape$points[shape$id == valid, , drop = FALSE]
    p <- p[!duplicated(data.frame(p)), , drop = FALSE]
    m <- transform %*% .svg_transform(attrs$transform) %*% .svg_transform(ca$transform)
    p <- t(m %*% rbind(t(p), 1))[, 1:2, drop = FALSE]
    edges <- p[c(2:nrow(p), 1), , drop = FALSE] - p
    next_edges <- edges[c(2:nrow(p), 1), , drop = FALSE]
    cross <- edges[, 1] * next_edges[, 2] - edges[, 2] * next_edges[, 1]
    if (nrow(p) < 3L || all(abs(cross) < 1e-10) ||
        any(cross > 1e-8) && any(cross < -1e-8))
      .art_error("Nonconvex SVG clipping must be flattened before import.")
    list(points = p, edges = edges, sign = if (sum(cross) > 0) 1 else -1)
  }
  contained <- function(points, clip, margin) {
    for (i in seq_len(nrow(clip$points))) {
      d <- sweep(points, 2, clip$points[i, ], "-"); e <- clip$edges[i, ]
      distance <- clip$sign * (e[1] * d[, 2] - e[2] * d[, 1]) / sqrt(sum(e^2))
      if (any(distance < margin - 1e-7)) return(FALSE)
    }
    TRUE
  }
  parts <- list(); total_points <- 0L; visits <- 0L
  visit <- function(node, inherited, transform, depth = 0L, references = character(), clips = list()) {
    visits <<- visits + 1L
    if (visits > .art_svg_visit_limit()) .art_error("SVG local reference expansion exceeds its safe limit.")
    if (depth > 32L) .art_error("SVG nesting exceeds 32 groups.")
    type <- xml2::xml_name(node); attrs <- as.list(xml2::xml_attrs(node))
    attrs <- attrs[!grepl("^xmlns(:|$)", names(attrs))]
    if (type %in% c("title", "desc", "defs", "clipPath")) return(invisible(NULL))
    geometry <- switch(type, svg = c("viewBox", "width", "height", "version", "preserveAspectRatio"),
      g = character(), use = c("x", "y", "href"), path = "d", rect = c("x", "y", "width", "height", "rx", "ry"),
      circle = c("cx", "cy", "r"), ellipse = c("cx", "cy", "rx", "ry"),
      line = c("x1", "y1", "x2", "y2"), c("points"))
    unknown <- setdiff(names(attrs), c(presentation, geometry, "id", "class", "style", "transform", "clip-path"))
    if (length(unknown)) .art_error(paste("Unsupported SVG attribute:", unknown[1L]))
    style <- inherited
    if (!is.null(attrs$style)) {
      declarations <- strsplit(attrs$style, ";", fixed = TRUE)[[1L]]
      for (declaration in declarations[nzchar(trimws(declarations))]) {
        pair <- strsplit(declaration, ":", fixed = TRUE)[[1L]]
        if (length(pair) != 2L || !trimws(pair[1L]) %in% presentation)
          .art_error("SVG styles may contain only supported fill, stroke and opacity properties.")
        attrs[[trimws(pair[1L])]] <- trimws(pair[2L])
      }
    }
    style[intersect(names(attrs), presentation)] <- attrs[intersect(names(attrs), presentation)]
    # Opacity is not inherited; group compositing cannot be flattened faithfully.
    style$opacity <- attrs$opacity %||% "1"
    opacity <- .svg_scalar(style$opacity); .scalar_number(opacity, "SVG opacity", 0, 1)
    transform <- transform %*% .svg_transform(attrs$transform)
    if (!is.null(attrs[["clip-path"]])) {
      ref <- sub("^url\\(#([^)]*)\\)$", "\\1", attrs[["clip-path"]])
      clips <- c(clips, list(clip_polygon(ref, transform)))
    }
    if (type == "use") {
      if (opacity != 1) .art_error("Flatten SVG use opacity before importing referenced components.")
      href <- attrs$href
      if (is.null(href) || !grepl("^#[A-Za-z0-9_.:-]+$", href)) .art_error("SVG use needs a local fragment reference.")
      id <- substring(href, 2)
      if (id %in% references) .art_error("Cyclic SVG local references are not allowed.")
      translation <- diag(3); translation[1:2, 3] <- c(.svg_scalar(attrs$x, 0), .svg_scalar(attrs$y, 0))
      visit(resolve(id), style, transform %*% translation, depth + 1L, c(references, id), clips)
      return(invisible(NULL))
    }
    if (type %in% c("svg", "g")) {
      if (depth > 0L && type == "svg") .art_error("Nested SVG viewports are not supported.")
      if (opacity != 1) .art_error("Flatten SVG group opacity before importing individual components.")
      for (child in xml2::xml_children(node)) visit(child, style, transform, depth + 1L, references, clips)
      return(invisible(NULL))
    }
    if (length(parts) >= 512L) .art_error("SVG may contain at most 512 editable components.")
    shape <- .svg_shape(type, attrs)
    total_points <<- total_points + nrow(shape$points)
    if (total_points > 100000L) .art_error("SVG may contain at most 100000 vector points in total.")
    points <- t(transform %*% rbind(t(shape$points), 1))[, 1:2, drop = FALSE]
    x <- .5 - width / 2 + (points[, 1] - view[1]) * sx
    y <- .6 + height / 2 - (points[, 2] - view[2]) * sy
    fill_opacity <- .svg_scalar(style[["fill-opacity"]]); stroke_opacity <- .svg_scalar(style[["stroke-opacity"]])
    .scalar_number(fill_opacity, "SVG fill opacity", 0, 1); .scalar_number(stroke_opacity, "SVG stroke opacity", 0, 1)
    scale <- sqrt(abs(det(transform[1:2, 1:2])))
    stroke_width <- if (style$stroke == "none") 0 else .svg_scalar(style[["stroke-width"]]) * sx * 72 * 6 * scale / .75
    mitre <- .svg_scalar(style[["stroke-miterlimit"]]); .scalar_number(mitre, "SVG miter limit", 1, 1000)
    stroke_extent <- max(if (style[["stroke-linejoin"]] == "miter") mitre else 1,
      if (style[["stroke-linecap"]] == "square") sqrt(2) else 1)
    margin <- if (style$stroke == "none") 0 else .svg_scalar(style[["stroke-width"]]) * scale / 2 * stroke_extent
    if (length(clips) && any(!vapply(clips, function(clip) contained(points, clip, margin), logical(1))))
      .art_error("SVG clipping intersects artwork. Flatten the clipped paths before importing editable components.")
    if (!style[["fill-rule"]] %in% c("nonzero", "evenodd")) .art_error("Unsupported SVG fill rule.")
    if (!style[["stroke-linejoin"]] %in% c("miter", "round", "bevel") ||
        !style[["stroke-linecap"]] %in% c("butt", "round", "square")) .art_error("Unsupported SVG stroke style.")
    # Anisotropic stroke transforms require outlined strokes to remain faithful.
    singular <- svd(transform[1:2, 1:2], nu = 0, nv = 0)$d
    if (style$stroke != "none" && abs(diff(singular)) > 1e-7 * max(1, singular))
      .art_error("Outline strokes with nonuniform SVG transforms before importing.")
    name <- substr(attrs$id %||% paste(type, length(parts) + 1L), 1, 80)
    part <- list(type = "svg_path", name = name, x = x, y = y, id = as.numeric(shape$id),
      closed = as.numeric(shape$closed), rule = if (style[["fill-rule"]] == "evenodd") "evenodd" else "winding",
      fill = .svg_color(if (type == "line") "none" else style$fill, fill_opacity),
      col = .svg_color(style$stroke, stroke_opacity), lwd = stroke_width, alpha = opacity,
      linejoin = if (style[["stroke-linejoin"]] == "miter") "mitre" else style[["stroke-linejoin"]],
      lineend = style[["stroke-linecap"]], linemitre = mitre)
    .validate_import_part(part)
    parts[[length(parts) + 1L]] <<- part
  }
  visit(root, defaults, diag(3))
  if (!length(parts)) .art_error("SVG contains no supported visible components.")
  parts
}

#' Import a figure or vector artwork as editable logo parts
#'
#' PNG and JPEG are embedded in the project as portable raster parts. SVG
#' shapes become separate vector parts that can be recoloured, moved, rotated,
#' resized and edited with [hex_edit_layer()]. SVG exports retain vector paths;
#' curves are approximated with bounded polylines (32 segments per Bezier curve,
#' about 32 segments per radian for arcs, and 128 points per ellipse).
#'
#' Supported SVG elements are `path`, `rect` (including rounded corners),
#' `circle`, `ellipse`, `line`, `polygon`, `polyline`, and transformed groups.
#' Paths support M/L/H/V/C/S/Q/T/A/Z commands, fill rules, solid fills/strokes,
#' and individual opacity. Local `defs`/`use` references are expanded with cycle
#' checks. Simple convex clip paths are accepted only when they provably do not
#' cut the component; intersecting clips must first be flattened to paths.
#' Text must be outlined. Gradients, masks, filters, nested SVG viewports,
#' CSS stylesheets and group opacity are rejected with an explanation rather
#' than silently rasterised. Nonuniform
#' transforms on strokes require outlined strokes. Scripts, event handlers,
#' external resources and XML entities are always rejected.
#'
#' Input files are limited to 10 MiB. Raster images are limited to 8192 pixels
#' per side and 16 million pixels total; dimensions are checked before decoding.
#' A project may contain at most 32 million embedded raster pixels altogether.
#' SVG supports at most 512 components, 5000 points per component, 100000 points
#' total per project, 32 nested groups and 8192 expanded element visits. The
#' artwork is fitted proportionally above the project name. Image
#' bytes or vector coordinates are stored in JSON; no original path is retained.
#' @param design A [hex_design()] object.
#' @param path Local PNG, JPEG or SVG file. Its contents determine its format.
#' @return An updated design with additional stable `part_` IDs. The input
#'   design and the source file are unchanged.
#' @export
#' @examples
#' svg <- tempfile(fileext = ".svg")
#' writeLines('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
#' <circle cx="50" cy="50" r="35" fill="#009E73"/></svg>', svg)
#' d <- hex_import_art(logo_design("New project"), svg)
#' d <- hex_edit_layer(d, "part_0001", angle = 20, alpha = .8)
#' unlink(svg)
hex_import_art <- function(design, path) {
  .validate_design(design)
  if (!is.character(path) || length(path) != 1L || is.na(path) || !file.exists(path) ||
      isTRUE(file.info(path)$isdir) || is.na(file.info(path)$size) ||
      file.info(path)$size < 1 || file.info(path)$size > .art_input_limit)
    .art_error("Provide a PNG, JPEG or SVG file of at most 10 MiB.")
  bytes <- readBin(path, "raw", n = .art_input_limit + 1L)
  if (length(bytes) > .art_input_limit) .art_error("Artwork exceeds the 10 MiB limit.")
  header <- .raster_header(bytes)
  if (!is.null(header)) {
    .decode_art_raster(bytes, header$mime)
    dimensions <- header$dimensions; ratio <- .design_ratio(design)
    width <- min(.68, .58 * dimensions[1] / dimensions[2] / ratio)
    height <- width * dimensions[2] / dimensions[1] * ratio
    parts <- list(list(type = "raster", name = if (header$mime == "image/png") "PNG figure" else "JPEG figure",
      data = .art_base64(bytes), mime = header$mime,
      pixel_width = unname(dimensions[1]), pixel_height = unname(dimensions[2]),
      x = .5, y = .6, width = unname(width), height = unname(height), alpha = 1))
  } else parts <- .svg_parts(bytes, design)
  if (length(design$parts %||% list()) + length(parts) > 512L) .art_error("A design supports at most 512 additional parts.")
  for (part in parts) design <- .append_part(design, part)
  json <- jsonlite::toJSON(unclass(design), pretty = TRUE, auto_unbox = TRUE, digits = 15)
  if (nchar(json, type = "bytes") + 1L > .design_json_limit()) .art_error("Imported artwork would exceed the 20 MiB project limit.")
  hex_grob(design)
  design
}
