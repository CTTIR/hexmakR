# ---------------------------------------------------------------------------
# Low-level hex sticker rendering with ggplot2 + grid
# ---------------------------------------------------------------------------

# Suppress R CMD check notes for ggplot2 aes() variables
utils::globalVariables(c("x", "y", "label"))

#' Build a hex sticker ggplot object
#'
#' Internal workhorse that assembles the ggplot2 representation of a hex
#' sticker from resolved parameters.
#'
#' @param name        Package name string.
#' @param subtitle    Subtitle string or NULL.
#' @param url         URL string or NULL.
#' @param colors      Named list: bg, accent, text, border, sub.
#' @param icon_name   Icon key string or NULL.
#' @param icon_image  Path to image file or NULL.
#' @param icon_size   Numeric multiplier.
#' @param font_family Resolved font family name.
#' @param font_bold   Logical.
#' @param font_italic Logical.
#' @param font_size   Base font size in pt.
#' @param border_width Border width in mm.
#' @param inner_border Logical, draw inner accent ring.
#'
#' @return A ggplot object.
#' @noRd
.build_hex <- function(name, subtitle, url, colors, icon_name, icon_image,
                       icon_size, font_family, font_bold, font_italic,
                       font_size, border_width, inner_border) {

  # ---- Coordinate system --------------------------------------------------
  # Use [0, 1] x [0, H] with coord_fixed(1) (equal axes).
  # H = 2/sqrt(3) so the canvas physical aspect matches hexb.in ratio.
  # Pixel output: width W, height = W * 2/sqrt(3) (set in save_hex).
  SQRT3 <- sqrt(3)
  W_data <- 1.0
  H_data <- 2.0 / SQRT3  # ~ 1.1547
  cx <- 0.5
  cy <- H_data / 2.0

  # Circumradius R such that the hex fills the frame with a small margin.
  # For a pointy-top hex: x_range = sqrt(3)*R, y_range = 2*R.
  # We want y_range ~ H_data * 0.97, so R = H_data/2 * 0.97.
  R_outer <- H_data / 2.0 * 0.97

  # Border hex: slightly inset
  bw_data <- border_width * R_outer / 280  # approximate data units for border
  R_border <- R_outer - bw_data / 2
  R_inner2 <- R_outer - bw_data * 2.2      # inner accent ring

  outer  <- .hex_poly(cx, cy, R_outer)
  border <- .hex_poly(cx, cy, R_border)
  inner2 <- .hex_poly(cx, cy, R_inner2)

  # ---- Build base plot ----------------------------------------------------
  # Pad limits so the border stroke is not clipped at the top/bottom vertices
  pad <- border_width * 0.012
  p <- ggplot2::ggplot() +
    ggplot2::coord_fixed(
      ratio  = 1,
      xlim   = c(-pad, W_data + pad),
      ylim   = c(-pad, H_data + pad),
      expand = FALSE,
      clip   = "off"
    ) +
    ggplot2::theme_void() +
    ggplot2::theme(
      plot.background  = ggplot2::element_rect(fill = NA, color = NA),
      panel.background = ggplot2::element_rect(fill = NA, color = NA),
      plot.margin      = ggplot2::margin(0, 0, 0, 0)
    )

  # Background fill + border in a single polygon (avoids double-line artifact)
  # Use mitre join so corners are sharp and gap-free at the hex vertices
  p <- p + ggplot2::geom_polygon(
    data    = data.frame(x = outer$x, y = outer$y),
    mapping = ggplot2::aes(x = x, y = y),
    fill    = colors$bg,
    color   = colors$border,
    linewidth = border_width * 0.75,
    linejoin  = "mitre"
  )

  # Inner accent ring
  if (inner_border) {
    p <- p + ggplot2::geom_polygon(
      data    = data.frame(x = inner2$x, y = inner2$y),
      mapping = ggplot2::aes(x = x, y = y),
      fill    = NA,
      color   = colors$accent,
      linewidth = border_width * 0.15,
      alpha   = 0.35,
      linejoin  = "mitre"
    )
  }

  # ---- Icon ---------------------------------------------------------------
  has_icon <- (!is.null(icon_name)) || (!is.null(icon_image))
  icon_cy  <- if (!is.null(subtitle)) cy + H_data * 0.08 else cy + H_data * 0.06

  if (!is.null(icon_name)) {
    draw_fn  <- .lookup_icon(icon_name)
    icon_s   <- R_outer * 0.55 * icon_size
    icon_grob <- .make_icon_grob(draw_fn, cx, icon_cy, icon_s,
                                 colors$accent, H_data)
    p <- p + ggplot2::annotation_custom(icon_grob,
                                        xmin = 0, xmax = 1,
                                        ymin = 0, ymax = H_data)
  } else if (!is.null(icon_image)) {
    img_grob <- .make_image_grob(icon_image, cx, icon_cy,
                                 R_outer * 0.45 * icon_size, H_data)
    if (!is.null(img_grob)) {
      p <- p + ggplot2::annotation_custom(img_grob,
                                          xmin = 0, xmax = 1,
                                          ymin = 0, ymax = H_data)
    }
  }

  # ---- Text ---------------------------------------------------------------
  face <- if (font_bold && font_italic) "bold.italic" else
          if (font_bold)    "bold"   else
          if (font_italic) "italic"  else "plain"

  # Vertical layout: name near lower third, subtitle + url below
  name_y <- if (has_icon) cy - H_data * 0.22 else cy - H_data * 0.02
  sub_y  <- name_y - H_data * 0.10
  url_y  <- cy - H_data * 0.38

  p <- p + ggplot2::geom_text(
    data    = data.frame(x = 0.5, y = name_y, label = name),
    mapping = ggplot2::aes(x = x, y = y, label = label),
    color    = colors$text,
    family   = font_family,
    fontface = face,
    size     = font_size * 0.36,
    hjust    = 0.5,
    vjust    = 0.5
  )

  if (!is.null(subtitle) && nzchar(subtitle)) {
    p <- p + ggplot2::geom_text(
      data    = data.frame(x = 0.5, y = sub_y, label = subtitle),
      mapping = ggplot2::aes(x = x, y = y, label = label),
      color    = colors$sub,
      family   = font_family,
      fontface = if (font_italic) "italic" else "plain",
      size     = font_size * 0.25,
      hjust    = 0.5,
      vjust    = 0.5
    )
  }

  if (!is.null(url) && nzchar(url)) {
    p <- p + ggplot2::geom_text(
      data    = data.frame(x = 0.5, y = url_y, label = url),
      mapping = ggplot2::aes(x = x, y = y, label = label),
      color    = colors$sub,
      family   = font_family,
      fontface = "plain",
      size     = font_size * 0.17,
      hjust    = 0.5,
      vjust    = 0.5
    )
  }

  p
}

# ---------------------------------------------------------------------------
# Helper: pointy-top hex polygon vertices (standard circumradius R)
# ---------------------------------------------------------------------------

#' @noRd
.hex_poly <- function(cx, cy, R) {
  # Pointy-top hexagon: first vertex at top (-90 deg)
  # x_range = sqrt(3) * R, y_range = 2 * R
  angles <- seq(-pi / 2, by = pi / 3, length.out = 6)
  list(
    x = cx + R * cos(angles),
    y = cy + R * sin(angles)
  )
}

# ---------------------------------------------------------------------------
# Helper: create an icon grob rendered via grid into the native plot viewport
# ---------------------------------------------------------------------------

#' @noRd
.make_icon_grob <- function(draw_fn, cx, cy, size, color, H_data) {
  # annotation_custom places the grob in the full plot viewport.
  # We use a custom grob that positions a sub-viewport and calls draw_fn.
  # cx, cy, size are in data coordinates. We'll convert to npc at draw time
  # by knowing the axes: x in [0,1], y in [0, H_data].
  env <- list(
    draw_fn = draw_fn,
    cx      = cx,
    cy      = cy,
    size    = size,
    color   = color,
    H_data  = H_data
  )
  grb <- grid::grob(env = env)
  class(grb) <- c("hexmakr_icon_grob", "grob")
  grb
}

#' @exportS3Method grid::drawDetails
drawDetails.hexmakr_icon_grob <- function(x, recording = FALSE) {
  e <- x$env
  # Convert data coordinates to npc
  cx_npc <- e$cx
  cy_npc <- e$cy / e$H_data
  s_npc  <- e$size / e$H_data

  vp <- grid::viewport(
    x      = grid::unit(cx_npc, "npc"),
    y      = grid::unit(cy_npc, "npc"),
    width  = grid::unit(s_npc * 2, "npc"),
    height = grid::unit(s_npc * 2, "npc"),
    just   = c("center", "center")
  )
  grid::pushViewport(vp)
  tryCatch(
    e$draw_fn(0.5, 0.5, 0.42, e$color),
    error = function(e) NULL
  )
  grid::popViewport()
}

# ---------------------------------------------------------------------------
# Helper: create an image rasterGrob from a file path
# ---------------------------------------------------------------------------

#' @noRd
.make_image_grob <- function(path, cx, cy, size, H_data) {
  if (!file.exists(path)) {
    warning(sprintf("icon_image file not found: %s", path))
    return(NULL)
  }
  # Extract extension without depending on tools package
  ext <- tolower(sub(".*\\.([^.]+)$", "\\1", path))
  img <- tryCatch({
    if (ext == "png") {
      png::readPNG(path)
    } else if (ext %in% c("jpg", "jpeg")) {
      if (requireNamespace("jpeg", quietly = TRUE)) {
        jpeg::readJPEG(path)
      } else {
        warning("Package 'jpeg' needed to load JPG images. ",
                "Install with: install.packages('jpeg')")
        return(NULL)
      }
    } else {
      warning(sprintf("Unsupported image format: .%s. Use PNG or JPEG.", ext))
      return(NULL)
    }
  }, error = function(e) {
    warning(sprintf("Could not read image '%s': %s", path,
                    conditionMessage(e)))
    NULL
  })
  if (is.null(img)) return(NULL)

  cx_npc <- cx
  cy_npc <- cy / H_data
  s_npc  <- size / H_data

  grid::rasterGrob(
    img,
    x          = grid::unit(cx_npc, "npc"),
    y          = grid::unit(cy_npc, "npc"),
    width      = grid::unit(s_npc * 2, "npc"),
    height     = grid::unit(s_npc * 2, "npc"),
    just       = c("center", "center"),
    interpolate = TRUE
  )
}

# ---------------------------------------------------------------------------
# Helper: look up icon draw function by name
# ---------------------------------------------------------------------------

#' @noRd
.lookup_icon <- function(name) {
  for (cat in .icons) {
    if (name %in% names(cat)) {
      return(cat[[name]]$draw)
    }
  }
  stop(sprintf(
    "Unknown icon '%s'. See hexmakr_icons() for available icons.", name
  ))
}
