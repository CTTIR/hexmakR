# ---------------------------------------------------------------------------
# Icon drawing functions
# Each function draws into the current viewport using grid.
# Coordinates are in normalized viewport units (npc): x, y = center; size
# controls scale. color is a hex string.
# ---------------------------------------------------------------------------

#' @noRd
icon_atom <- function(x, y, size, color) {
  r_nucleus <- size * 0.06
  r_orbit   <- size * 0.28
  grid::grid.circle(x = x, y = y, r = r_nucleus,
                    gp = grid::gpar(fill = color, col = color))
  for (angle in c(0, 60, 120)) {
    rad <- angle * pi / 180
    cos_a <- cos(rad); sin_a <- sin(rad)
    xs <- x + r_orbit * cos(seq(0, 2*pi, length.out = 100)) * cos_a -
          r_orbit * 0.4 * sin(seq(0, 2*pi, length.out = 100)) * sin_a
    ys <- y + r_orbit * sin(seq(0, 2*pi, length.out = 100)) * cos_a * 0.4 +
          r_orbit * 0.4 * cos(seq(0, 2*pi, length.out = 100)) * sin_a
    grid::grid.lines(x = xs, y = ys,
                     gp = grid::gpar(col = color, lwd = size * 4, lty = 1))
  }
}

#' @noRd
icon_flask <- function(x, y, size, color) {
  # Neck
  grid::grid.rect(x = x, y = y + size * 0.1,
                  width = size * 0.14, height = size * 0.22,
                  gp = grid::gpar(fill = color, col = color))
  # Body (trapezoid as polygon)
  bx <- c(x - size*0.28, x + size*0.28, x + size*0.12, x - size*0.12)
  by <- c(y - size*0.25, y - size*0.25, y + size*0.0,  y + size*0.0)
  grid::grid.polygon(x = bx, y = by,
                     gp = grid::gpar(fill = color, col = color))
  # Lip
  grid::grid.rect(x = x, y = y + size * 0.22,
                  width = size * 0.20, height = size * 0.04,
                  gp = grid::gpar(fill = color, col = color))
}

#' @noRd
icon_microscope <- function(x, y, size, color) {
  # Base
  grid::grid.rect(x = x, y = y - size*0.26,
                  width = size*0.40, height = size*0.06,
                  gp = grid::gpar(fill = color, col = color))
  # Pillar
  grid::grid.rect(x = x, y = y - size*0.06,
                  width = size*0.07, height = size*0.38,
                  gp = grid::gpar(fill = color, col = color))
  # Eyepiece arm
  grid::grid.rect(x = x + size*0.08, y = y + size*0.18,
                  width = size*0.22, height = size*0.05,
                  gp = grid::gpar(fill = color, col = color))
  # Eyepiece
  grid::grid.circle(x = x + size*0.19, y = y + size*0.22, r = size*0.05,
                    gp = grid::gpar(fill = color, col = color))
  # Objective lens
  grid::grid.rect(x = x, y = y + size*0.03,
                  width = size*0.05, height = size*0.12,
                  gp = grid::gpar(fill = color, col = color))
}

#' @noRd
icon_molecule <- function(x, y, size, color) {
  positions <- list(c(0, 0), c(0.22, 0.18), c(-0.22, 0.18),
                    c(0.22, -0.18), c(-0.22, -0.18))
  # bonds
  for (i in 2:5) {
    grid::grid.lines(
      x = c(x, x + positions[[i]][1] * size),
      y = c(y, y + positions[[i]][2] * size),
      gp = grid::gpar(col = color, lwd = size * 3)
    )
  }
  # atoms
  grid::grid.circle(x = x, y = y, r = size*0.08,
                    gp = grid::gpar(fill = color, col = color))
  for (i in 2:5) {
    grid::grid.circle(
      x = x + positions[[i]][1] * size,
      y = y + positions[[i]][2] * size,
      r = size * 0.06,
      gp = grid::gpar(fill = color, col = color)
    )
  }
}

#' @noRd
icon_magnet <- function(x, y, size, color) {
  theta <- seq(0, pi, length.out = 60)
  # U-shape: outer arc and inner arc
  r_out <- size * 0.26; r_in <- size * 0.14
  xo <- x + r_out * cos(theta); yo <- y + r_out * sin(theta)
  xi <- rev(x + r_in * cos(theta)); yi <- rev(y + r_in * sin(theta))
  px <- c(xo, xi); py <- c(yo, yi)
  grid::grid.polygon(x = px, y = py,
                     gp = grid::gpar(fill = color, col = color))
  # Left pole cap (red-ish tip simulated by same color)
  grid::grid.rect(x = x - r_out * 0.7, y = y - size*0.06,
                  width = (r_out - r_in), height = size*0.12,
                  gp = grid::gpar(fill = color, col = color))
  grid::grid.rect(x = x + r_out * 0.7, y = y - size*0.06,
                  width = (r_out - r_in), height = size*0.12,
                  gp = grid::gpar(fill = color, col = color))
}

# ---- Biology ----------------------------------------------------------------

#' @noRd
icon_dna <- function(x, y, size, color) {
  t <- seq(0, 2*pi, length.out = 80)
  amp <- size * 0.14; freq <- 2.5
  x1 <- x + amp * sin(freq * t)
  x2 <- x - amp * sin(freq * t)
  y_range <- seq(y - size*0.28, y + size*0.28, length.out = 80)
  grid::grid.lines(x = x1, y = y_range,
                   gp = grid::gpar(col = color, lwd = size*4))
  grid::grid.lines(x = x2, y = y_range,
                   gp = grid::gpar(col = color, lwd = size*4))
  # rungs
  n_rungs <- 6
  for (i in seq_len(n_rungs)) {
    ti <- (i / (n_rungs + 1)) * 2 * pi
    yi_rung <- y - size*0.28 + (i / (n_rungs + 1)) * size * 0.56
    xi1 <- x + amp * sin(freq * ti)
    xi2 <- x - amp * sin(freq * ti)
    grid::grid.lines(x = c(xi1, xi2), y = c(yi_rung, yi_rung),
                     gp = grid::gpar(col = color, lwd = size*2))
  }
}

#' @noRd
icon_cell <- function(x, y, size, color) {
  # Cell membrane
  grid::grid.circle(x = x, y = y, r = size*0.28,
                    gp = grid::gpar(col = color, fill = NA, lwd = size*4))
  # Nucleus
  grid::grid.circle(x = x + size*0.04, y = y + size*0.04, r = size*0.10,
                    gp = grid::gpar(col = color, fill = color, lwd = size*3))
  # Organelles (small circles)
  grid::grid.circle(x = x - size*0.14, y = y - size*0.10, r = size*0.04,
                    gp = grid::gpar(col = color, fill = color))
  grid::grid.circle(x = x + size*0.12, y = y - size*0.14, r = size*0.035,
                    gp = grid::gpar(col = color, fill = color))
}

#' @noRd
icon_brain <- function(x, y, size, color) {
  # Two hemispheres as rounded polygons approximated by arcs
  # Left hemisphere
  t_l <- seq(pi/2, 3*pi/2, length.out = 40)
  xl <- x - size*0.02 + size*0.22 * cos(t_l)
  yl <- y + size*0.18 * sin(t_l)
  grid::grid.lines(x = xl, y = yl, gp = grid::gpar(col = color, lwd = size*4))
  # Right hemisphere
  t_r <- seq(-pi/2, pi/2, length.out = 40)
  xr <- x + size*0.02 + size*0.22 * cos(t_r)
  yr <- y + size*0.18 * sin(t_r)
  grid::grid.lines(x = xr, y = yr, gp = grid::gpar(col = color, lwd = size*4))
  # Center line
  grid::grid.lines(x = c(x, x), y = c(y - size*0.18, y + size*0.18),
                   gp = grid::gpar(col = color, lwd = size*2))
  # Folds
  for (fold_y in c(0.08, 0.0, -0.08)) {
    grid::grid.lines(x = c(x - size*0.20, x - size*0.04),
                     y = c(y + fold_y*size, y + (fold_y + 0.04)*size),
                     gp = grid::gpar(col = color, lwd = size*2))
    grid::grid.lines(x = c(x + size*0.04, x + size*0.20),
                     y = c(y + (fold_y + 0.04)*size, y + fold_y*size),
                     gp = grid::gpar(col = color, lwd = size*2))
  }
}

#' @noRd
icon_leaf <- function(x, y, size, color) {
  # Leaf shape
  t <- seq(0, 2*pi, length.out = 60)
  lx <- x + size*0.22 * cos(t) * (1 - 0.4 * sin(t)^2)
  ly <- y + size*0.28 * sin(t)
  grid::grid.polygon(x = lx, y = ly,
                     gp = grid::gpar(fill = color, col = color))
  # Midrib
  grid::grid.lines(x = c(x, x), y = c(y - size*0.28, y + size*0.28),
                   gp = grid::gpar(col = grDevices::rgb(0,0,0,0.3), lwd = size*2))
  # Stem
  grid::grid.lines(x = c(x, x), y = c(y - size*0.28, y - size*0.38),
                   gp = grid::gpar(col = color, lwd = size*3))
}

#' @noRd
icon_bacteria <- function(x, y, size, color) {
  # Rod body
  grid::grid.rect(x = x, y = y, width = size*0.14, height = size*0.40,
                  gp = grid::gpar(fill = color, col = color))
  grid::grid.circle(x = x, y = y + size*0.20, r = size*0.07,
                    gp = grid::gpar(fill = color, col = color))
  grid::grid.circle(x = x, y = y - size*0.20, r = size*0.07,
                    gp = grid::gpar(fill = color, col = color))
  # Flagella
  t <- seq(0, 2*pi, length.out = 40)
  fx <- x + size*0.07 + size*0.08 * sin(3*t)
  fy <- y + size*0.22 + seq(0, size*0.22, length.out = 40)
  grid::grid.lines(x = fx, y = fy, gp = grid::gpar(col = color, lwd = size*2))
}

#' @noRd
icon_tree <- function(x, y, size, color) {
  # Trunk
  grid::grid.rect(x = x, y = y - size*0.20, width = size*0.08, height = size*0.18,
                  gp = grid::gpar(fill = color, col = color))
  # Three canopy triangles stacked
  for (i in 1:3) {
    yb <- y - size*0.08 + (i-1) * size*0.14
    yt <- yb + size*0.20
    ym <- (yb + yt) / 2
    px <- c(x - size*(0.28 - i*0.06), x + size*(0.28 - i*0.06), x)
    py <- c(yb, yb, yt)
    grid::grid.polygon(x = px, y = py,
                       gp = grid::gpar(fill = color, col = color))
  }
}

# ---- Data / Stats -----------------------------------------------------------

#' @noRd
icon_bar_chart <- function(x, y, size, color) {
  heights <- c(0.16, 0.28, 0.20, 0.34)
  n <- length(heights)
  w <- size * 0.12
  gap <- size * 0.04
  total_w <- n * w + (n - 1) * gap
  x_start <- x - total_w / 2
  base_y <- y - size * 0.26
  for (i in seq_len(n)) {
    bx <- x_start + (i-1) * (w + gap) + w/2
    by <- base_y + heights[i] * size / 2
    grid::grid.rect(x = bx, y = by, width = w, height = heights[i] * size,
                    gp = grid::gpar(fill = color, col = color))
  }
  # Axis
  grid::grid.lines(x = c(x - size*0.30, x + size*0.30),
                   y = c(base_y, base_y),
                   gp = grid::gpar(col = color, lwd = size*2))
}

#' @noRd
icon_scatter <- function(x, y, size, color) {
  pts <- list(c(-0.20, -0.18), c(-0.10, 0.05), c(0.0, -0.05),
              c(0.12, 0.14), c(0.20, 0.22), c(-0.14, 0.18),
              c(0.08, -0.18), c(0.22, -0.05))
  for (p in pts) {
    grid::grid.circle(x = x + p[[1]]*size, y = y + p[[2]]*size,
                      r = size*0.04,
                      gp = grid::gpar(fill = color, col = color))
  }
  # Axes
  grid::grid.lines(x = c(x - size*0.28, x + size*0.28),
                   y = c(y - size*0.26, y - size*0.26),
                   gp = grid::gpar(col = color, lwd = size*2))
  grid::grid.lines(x = c(x - size*0.28, x - size*0.28),
                   y = c(y - size*0.26, y + size*0.26),
                   gp = grid::gpar(col = color, lwd = size*2))
}

#' @noRd
icon_line_chart <- function(x, y, size, color) {
  pts_x <- c(-0.26, -0.14, -0.04, 0.08, 0.18, 0.26)
  pts_y <- c(-0.14,  0.04,  0.16, 0.06, 0.20, 0.10)
  grid::grid.lines(x = x + pts_x*size, y = y + pts_y*size,
                   gp = grid::gpar(col = color, lwd = size*3))
  # Axis
  grid::grid.lines(x = c(x - size*0.28, x + size*0.28),
                   y = c(y - size*0.22, y - size*0.22),
                   gp = grid::gpar(col = color, lwd = size*2))
}

#' @noRd
icon_bell_curve <- function(x, y, size, color) {
  t <- seq(-3, 3, length.out = 80)
  cx <- x + t * size * 0.09
  cy <- y - size*0.20 + size*0.38 * exp(-0.5 * t^2)
  grid::grid.lines(x = cx, y = cy, gp = grid::gpar(col = color, lwd = size*4))
  grid::grid.lines(x = c(x - size*0.30, x + size*0.30),
                   y = c(y - size*0.20, y - size*0.20),
                   gp = grid::gpar(col = color, lwd = size*2))
}

#' @noRd
icon_pie <- function(x, y, size, color) {
  slices <- list(
    list(start = 0,   end = 1.5, col = color),
    list(start = 1.5, end = 3.2, col = color),
    list(start = 3.2, end = 5.0, col = color),
    list(start = 5.0, end = 2*pi, col = color)
  )
  r <- size * 0.26
  alphas <- c(1.0, 0.7, 0.5, 0.3)
  for (i in seq_along(slices)) {
    s <- slices[[i]]
    t <- seq(s$start, s$end, length.out = 20)
    px <- c(x, x + r * cos(t), x)
    py <- c(y, y + r * sin(t), y)
    base_col <- grDevices::col2rgb(color) / 255
    col_i <- grDevices::rgb(base_col[1], base_col[2], base_col[3],
                            alpha = alphas[i])
    grid::grid.polygon(x = px, y = py,
                       gp = grid::gpar(fill = col_i, col = color, lwd = 1))
  }
}

#' @noRd
icon_sigma <- function(x, y, size, color) {
  # Sigma symbol drawn with lines
  # Top and bottom horizontal bars
  grid::grid.lines(x = c(x - size*0.18, x + size*0.20),
                   y = c(y + size*0.26, y + size*0.26),
                   gp = grid::gpar(col = color, lwd = size*4))
  grid::grid.lines(x = c(x - size*0.18, x + size*0.20),
                   y = c(y - size*0.26, y - size*0.26),
                   gp = grid::gpar(col = color, lwd = size*4))
  # Diagonal lines forming the Sigma shape
  grid::grid.lines(x = c(x - size*0.18, x + size*0.20),
                   y = c(y + size*0.26, y + size*0.02),
                   gp = grid::gpar(col = color, lwd = size*4))
  grid::grid.lines(x = c(x - size*0.18, x + size*0.20),
                   y = c(y - size*0.26, y - size*0.02),
                   gp = grid::gpar(col = color, lwd = size*4))
}

#' @noRd
icon_boxplot <- function(x, y, size, color) {
  # Whiskers
  grid::grid.lines(x = c(x, x), y = c(y - size*0.28, y - size*0.16),
                   gp = grid::gpar(col = color, lwd = size*2))
  grid::grid.lines(x = c(x, x), y = c(y + size*0.14, y + size*0.26),
                   gp = grid::gpar(col = color, lwd = size*2))
  grid::grid.lines(x = c(x - size*0.10, x + size*0.10),
                   y = c(y - size*0.28, y - size*0.28),
                   gp = grid::gpar(col = color, lwd = size*2))
  grid::grid.lines(x = c(x - size*0.10, x + size*0.10),
                   y = c(y + size*0.26, y + size*0.26),
                   gp = grid::gpar(col = color, lwd = size*2))
  # Box
  grid::grid.rect(x = x, y = y - size*0.01, width = size*0.28, height = size*0.30,
                  gp = grid::gpar(fill = NA, col = color, lwd = size*3))
  # Median
  grid::grid.lines(x = c(x - size*0.14, x + size*0.14),
                   y = c(y + size*0.02, y + size*0.02),
                   gp = grid::gpar(col = color, lwd = size*3))
}

#' @noRd
icon_network <- function(x, y, size, color) {
  nodes <- list(c(0,0), c(-0.20, 0.16), c(0.20, 0.18),
                c(0.0, -0.22), c(-0.18, -0.14), c(0.18, -0.10))
  edges <- list(c(1,2), c(1,3), c(1,4), c(2,5), c(3,6), c(4,5), c(4,6))
  for (e in edges) {
    n1 <- nodes[[e[1]]]; n2 <- nodes[[e[2]]]
    grid::grid.lines(x = c(x + n1[1]*size, x + n2[1]*size),
                     y = c(y + n1[2]*size, y + n2[2]*size),
                     gp = grid::gpar(col = color, lwd = size*2))
  }
  for (n in nodes) {
    grid::grid.circle(x = x + n[1]*size, y = y + n[2]*size, r = size*0.05,
                      gp = grid::gpar(fill = color, col = color))
  }
}

# ---- Medical ----------------------------------------------------------------

#' @noRd
icon_stethoscope <- function(x, y, size, color) {
  # Earpiece
  grid::grid.lines(x = c(x - size*0.10, x - size*0.10),
                   y = c(y + size*0.26, y + size*0.10),
                   gp = grid::gpar(col = color, lwd = size*4))
  grid::grid.lines(x = c(x + size*0.10, x + size*0.10),
                   y = c(y + size*0.26, y + size*0.10),
                   gp = grid::gpar(col = color, lwd = size*4))
  grid::grid.lines(x = c(x - size*0.10, x + size*0.10),
                   y = c(y + size*0.26, y + size*0.26),
                   gp = grid::gpar(col = color, lwd = size*4))
  # Tube arch
  t <- seq(pi, 0, length.out = 40)
  tx <- x + size*0.18 * cos(t)
  ty <- y + size*0.10 + size*0.10 * sin(t)
  grid::grid.lines(x = tx, y = ty, gp = grid::gpar(col = color, lwd = size*4))
  # Down tube
  grid::grid.lines(x = c(x + size*0.18, x + size*0.18),
                   y = c(y + size*0.10, y - size*0.10),
                   gp = grid::gpar(col = color, lwd = size*4))
  # Chest piece
  grid::grid.circle(x = x + size*0.18, y = y - size*0.18, r = size*0.10,
                    gp = grid::gpar(fill = NA, col = color, lwd = size*4))
}

#' @noRd
icon_heart <- function(x, y, size, color) {
  t <- seq(0, 2*pi, length.out = 100)
  hx <- x + size*0.24 * (16 * sin(t)^3) / 16
  hy <- y + size*0.24 * (13*cos(t) - 5*cos(2*t) - 2*cos(3*t) - cos(4*t)) / 16
  grid::grid.polygon(x = hx, y = hy,
                     gp = grid::gpar(fill = color, col = color))
}

#' @noRd
icon_pulse <- function(x, y, size, color) {
  xs <- c(-0.28, -0.14, -0.08, -0.04, 0.02, 0.12, 0.18, 0.28)
  ys <- c(  0.0,   0.0,  0.22,  -0.22, 0.22, 0.0,  0.0,  0.0)
  grid::grid.lines(x = x + xs*size, y = y + ys*size,
                   gp = grid::gpar(col = color, lwd = size*4))
}

#' @noRd
icon_pill <- function(x, y, size, color) {
  # Capsule shape - two semicircles + rectangle
  grid::grid.circle(x = x - size*0.14, y = y, r = size*0.10,
                    gp = grid::gpar(fill = color, col = color))
  grid::grid.circle(x = x + size*0.14, y = y, r = size*0.10,
                    gp = grid::gpar(fill = color, col = color))
  grid::grid.rect(x = x, y = y, width = size*0.28, height = size*0.20,
                  gp = grid::gpar(fill = color, col = color))
  # Dividing line
  grid::grid.lines(x = c(x, x), y = c(y - size*0.10, y + size*0.10),
                   gp = grid::gpar(col = grDevices::rgb(0,0,0,0.25), lwd = size*2))
}

#' @noRd
icon_cross <- function(x, y, size, color) {
  grid::grid.rect(x = x, y = y, width = size*0.12, height = size*0.52,
                  gp = grid::gpar(fill = color, col = color))
  grid::grid.rect(x = x, y = y + size*0.08, width = size*0.40, height = size*0.12,
                  gp = grid::gpar(fill = color, col = color))
}

#' @noRd
icon_syringe <- function(x, y, size, color) {
  # Barrel
  grid::grid.rect(x = x - size*0.04, y = y, width = size*0.32, height = size*0.10,
                  gp = grid::gpar(fill = color, col = color))
  # Plunger
  grid::grid.rect(x = x + size*0.14, y = y, width = size*0.06, height = size*0.18,
                  gp = grid::gpar(fill = color, col = color))
  # Needle
  grid::grid.lines(x = c(x - size*0.20, x - size*0.30),
                   y = c(y, y),
                   gp = grid::gpar(col = color, lwd = size*3))
  # Tip
  grid::grid.lines(x = c(x - size*0.30, x - size*0.34),
                   y = c(y, y + size*0.02),
                   gp = grid::gpar(col = color, lwd = size*2))
}

# ---- Tech / Code ------------------------------------------------------------

#' @noRd
icon_terminal <- function(x, y, size, color) {
  # Screen border
  grid::grid.rect(x = x, y = y, width = size*0.56, height = size*0.40,
                  gp = grid::gpar(fill = NA, col = color, lwd = size*3))
  # Prompt >
  grid::grid.lines(x = c(x - size*0.18, x - size*0.06),
                   y = c(y + size*0.08, y + size*0.02),
                   gp = grid::gpar(col = color, lwd = size*3))
  grid::grid.lines(x = c(x - size*0.06, x - size*0.18),
                   y = c(y + size*0.02, y - size*0.04),
                   gp = grid::gpar(col = color, lwd = size*3))
  # Cursor
  grid::grid.rect(x = x + size*0.02, y = y + size*0.02,
                  width = size*0.08, height = size*0.06,
                  gp = grid::gpar(fill = color, col = color))
}

#' @noRd
icon_brackets <- function(x, y, size, color) {
  # < >
  grid::grid.lines(x = c(x - size*0.06, x - size*0.22),
                   y = c(y + size*0.20, y),
                   gp = grid::gpar(col = color, lwd = size*5))
  grid::grid.lines(x = c(x - size*0.22, x - size*0.06),
                   y = c(y, y - size*0.20),
                   gp = grid::gpar(col = color, lwd = size*5))
  grid::grid.lines(x = c(x + size*0.06, x + size*0.22),
                   y = c(y + size*0.20, y),
                   gp = grid::gpar(col = color, lwd = size*5))
  grid::grid.lines(x = c(x + size*0.22, x + size*0.06),
                   y = c(y, y - size*0.20),
                   gp = grid::gpar(col = color, lwd = size*5))
}

#' @noRd
icon_gear <- function(x, y, size, color) {
  n_teeth <- 8
  r_outer <- size * 0.26; r_inner <- size * 0.20; r_core <- size * 0.10
  angles <- seq(0, 2*pi, length.out = n_teeth * 4 + 1)
  px <- numeric(n_teeth * 4); py <- numeric(n_teeth * 4)
  for (i in seq_len(n_teeth * 4)) {
    r <- if ((i %% 4) %in% c(1, 2)) r_outer else r_inner
    px[i] <- x + r * cos(angles[i])
    py[i] <- y + r * sin(angles[i])
  }
  grid::grid.polygon(x = px, y = py,
                     gp = grid::gpar(fill = color, col = color))
  grid::grid.circle(x = x, y = y, r = r_core,
                    gp = grid::gpar(fill = NA, col = "#000000", lwd = size*2))
}

#' @noRd
icon_database <- function(x, y, size, color) {
  # Three disk layers
  for (i in 1:3) {
    cy <- y + (2 - i) * size * 0.14 - size * 0.14
    t <- seq(0, 2*pi, length.out = 40)
    ex <- x + size*0.24 * cos(t)
    ey_top <- cy + size*0.06 * sin(t)
    # Top ellipse
    grid::grid.polygon(x = ex, y = ey_top,
                       gp = grid::gpar(fill = color, col = color))
    # Side rect
    grid::grid.rect(x = x, y = cy - size*0.07, width = size*0.48, height = size*0.07,
                    gp = grid::gpar(fill = color, col = color))
  }
}

#' @noRd
icon_hash <- function(x, y, size, color) {
  # Two horizontal
  grid::grid.lines(x = c(x - size*0.22, x + size*0.22),
                   y = c(y + size*0.08, y + size*0.08),
                   gp = grid::gpar(col = color, lwd = size*4))
  grid::grid.lines(x = c(x - size*0.22, x + size*0.22),
                   y = c(y - size*0.08, y - size*0.08),
                   gp = grid::gpar(col = color, lwd = size*4))
  # Two vertical (slightly angled)
  grid::grid.lines(x = c(x - size*0.08, x - size*0.08),
                   y = c(y - size*0.22, y + size*0.22),
                   gp = grid::gpar(col = color, lwd = size*4))
  grid::grid.lines(x = c(x + size*0.08, x + size*0.08),
                   y = c(y - size*0.22, y + size*0.22),
                   gp = grid::gpar(col = color, lwd = size*4))
}

#' @noRd
icon_rlogo <- function(x, y, size, color) {
  # Simplified R letter
  # Vertical stroke
  grid::grid.lines(x = c(x - size*0.12, x - size*0.12),
                   y = c(y - size*0.24, y + size*0.24),
                   gp = grid::gpar(col = color, lwd = size*5))
  # Bump (top of R)
  t <- seq(pi/2, -pi/2, length.out = 30)
  rx <- x - size*0.12 + size*0.14 * cos(t)
  ry <- y + size*0.06 + size*0.14 * sin(t)
  grid::grid.lines(x = rx, y = ry, gp = grid::gpar(col = color, lwd = size*5))
  # Leg
  grid::grid.lines(x = c(x - size*0.02, x + size*0.16),
                   y = c(y + size*0.06, y - size*0.24),
                   gp = grid::gpar(col = color, lwd = size*5))
}

# ---- Shapes -----------------------------------------------------------------

#' @noRd
icon_star <- function(x, y, size, color) {
  n <- 5
  outer_r <- size * 0.28; inner_r <- size * 0.12
  angles_out <- seq(-pi/2, 3*pi/2, length.out = n + 1)[-(n+1)]
  angles_in  <- angles_out + pi/n
  px <- numeric(2*n); py <- numeric(2*n)
  for (i in seq_len(n)) {
    px[2*i-1] <- x + outer_r * cos(angles_out[i])
    py[2*i-1] <- y + outer_r * sin(angles_out[i])
    px[2*i]   <- x + inner_r * cos(angles_in[i])
    py[2*i]   <- y + inner_r * sin(angles_in[i])
  }
  grid::grid.polygon(x = px, y = py,
                     gp = grid::gpar(fill = color, col = color))
}

#' @noRd
icon_shield <- function(x, y, size, color) {
  px <- c(x, x + size*0.22, x + size*0.22, x, x - size*0.22, x - size*0.22)
  py <- c(y + size*0.28, y + size*0.14, y - size*0.04, y - size*0.28,
          y - size*0.04, y + size*0.14)
  grid::grid.polygon(x = px, y = py,
                     gp = grid::gpar(fill = color, col = color))
}

#' @noRd
icon_diamond <- function(x, y, size, color) {
  px <- c(x, x + size*0.22, x, x - size*0.22)
  py <- c(y + size*0.30, y, y - size*0.30, y)
  grid::grid.polygon(x = px, y = py,
                     gp = grid::gpar(fill = color, col = color))
}

#' @noRd
icon_hexagon <- function(x, y, size, color) {
  angles <- seq(pi/6, 2*pi + pi/6, length.out = 7)[1:6]
  px <- x + size*0.28 * cos(angles)
  py <- y + size*0.28 * sin(angles)
  grid::grid.polygon(x = px, y = py,
                     gp = grid::gpar(fill = color, col = color))
}

#' @noRd
icon_infinity <- function(x, y, size, color) {
  t <- seq(0, 2*pi, length.out = 100)
  # Lemniscate of Bernoulli
  denom <- 1 + sin(t)^2
  ix <- x + size*0.30 * cos(t) / denom
  iy <- y + size*0.18 * sin(t) * cos(t) / denom
  grid::grid.lines(x = ix, y = iy, gp = grid::gpar(col = color, lwd = size*5))
}

#' @noRd
icon_arrow_up <- function(x, y, size, color) {
  # Arrow head
  px <- c(x, x + size*0.20, x + size*0.08, x + size*0.08,
          x - size*0.08, x - size*0.08, x - size*0.20)
  py <- c(y + size*0.28, y + size*0.06, y + size*0.06, y - size*0.26,
          y - size*0.26, y + size*0.06, y + size*0.06)
  grid::grid.polygon(x = px, y = py,
                     gp = grid::gpar(fill = color, col = color))
}

#' @noRd
icon_circle <- function(x, y, size, color) {
  grid::grid.circle(x = x, y = y, r = size*0.26,
                    gp = grid::gpar(fill = NA, col = color, lwd = size*6))
  grid::grid.circle(x = x, y = y, r = size*0.10,
                    gp = grid::gpar(fill = color, col = color))
}

# ---- Fun --------------------------------------------------------------------

#' @noRd
icon_rocket <- function(x, y, size, color) {
  # Body
  t <- seq(0, pi, length.out = 30)
  rx <- x + size*0.10 * cos(t)
  ry <- y + size*0.10 * sin(t) + y + size*0.04
  grid::grid.lines(x = rx, y = ry, gp = grid::gpar(col = color, lwd = size*4))
  # Main body rect
  grid::grid.rect(x = x, y = y, width = size*0.20, height = size*0.30,
                  gp = grid::gpar(fill = color, col = color))
  # Nose cone
  px <- c(x - size*0.10, x + size*0.10, x)
  py <- c(y + size*0.15, y + size*0.15, y + size*0.30)
  grid::grid.polygon(x = px, y = py,
                     gp = grid::gpar(fill = color, col = color))
  # Fins
  pxl <- c(x - size*0.10, x - size*0.24, x - size*0.10)
  pyl <- c(y - size*0.10, y - size*0.24, y - size*0.22)
  grid::grid.polygon(x = pxl, y = pyl,
                     gp = grid::gpar(fill = color, col = color))
  pxr <- c(x + size*0.10, x + size*0.24, x + size*0.10)
  grid::grid.polygon(x = pxr, y = pyl,
                     gp = grid::gpar(fill = color, col = color))
  # Exhaust
  grid::grid.circle(x = x, y = y - size*0.22, r = size*0.06,
                    gp = grid::gpar(fill = NA, col = color, lwd = size*3))
}

#' @noRd
icon_lightning <- function(x, y, size, color) {
  px <- c(x + size*0.10, x - size*0.06, x + size*0.04, x - size*0.10)
  py <- c(y + size*0.28, y + size*0.04, y + size*0.04, y - size*0.28)
  grid::grid.polygon(x = px, y = py,
                     gp = grid::gpar(fill = color, col = color))
}

#' @noRd
icon_fire <- function(x, y, size, color) {
  # Main flame
  t <- seq(0, 2*pi, length.out = 60)
  fx <- x + size*0.18 * cos(t) * (1 + 0.3 * sin(3*t))
  fy <- y - size*0.10 + size*0.28 * (0.5 + 0.5*sin(t - pi/2)) *
        (1 + 0.2 * sin(5*t))
  grid::grid.polygon(x = fx, y = fy,
                     gp = grid::gpar(fill = color, col = color))
}

#' @noRd
icon_sparkle <- function(x, y, size, color) {
  # 4-pointed star / sparkle
  for (angle in c(0, pi/2, pi, 3*pi/2)) {
    grid::grid.lines(
      x = c(x + size*0.04 * cos(angle + pi/2),
            x + size*0.26 * cos(angle)),
      y = c(y + size*0.04 * sin(angle + pi/2),
            y + size*0.26 * sin(angle)),
      gp = grid::gpar(col = color, lwd = size*4)
    )
    grid::grid.lines(
      x = c(x - size*0.04 * cos(angle + pi/2),
            x + size*0.26 * cos(angle)),
      y = c(y - size*0.04 * sin(angle + pi/2),
            y + size*0.26 * sin(angle)),
      gp = grid::gpar(col = color, lwd = size*4)
    )
  }
  # Diagonals
  for (angle in c(pi/4, 3*pi/4, 5*pi/4, 7*pi/4)) {
    grid::grid.lines(
      x = c(x, x + size*0.14 * cos(angle)),
      y = c(y, y + size*0.14 * sin(angle)),
      gp = grid::gpar(col = color, lwd = size*3)
    )
  }
}

#' @noRd
icon_crown <- function(x, y, size, color) {
  # Base band
  grid::grid.rect(x = x, y = y - size*0.14, width = size*0.52, height = size*0.10,
                  gp = grid::gpar(fill = color, col = color))
  # Three points
  px <- c(x - size*0.26, x - size*0.26, x - size*0.10, x,
          x + size*0.10, x + size*0.26, x + size*0.26)
  py <- c(y - size*0.09, y + size*0.04, y + size*0.22, y + size*0.06,
          y + size*0.22, y + size*0.04, y - size*0.09)
  grid::grid.polygon(x = px, y = py,
                     gp = grid::gpar(fill = color, col = color))
}

#' @noRd
icon_coffee <- function(x, y, size, color) {
  # Cup body
  px <- c(x - size*0.18, x + size*0.18, x + size*0.14, x - size*0.14)
  py <- c(y + size*0.10, y + size*0.10, y - size*0.22, y - size*0.22)
  grid::grid.polygon(x = px, y = py,
                     gp = grid::gpar(fill = color, col = color))
  # Handle
  t <- seq(-pi/2, pi/2, length.out = 30)
  hx <- x + size*0.18 + size*0.10 * cos(t)
  hy <- y - size*0.06 + size*0.10 * sin(t)
  grid::grid.lines(x = hx, y = hy, gp = grid::gpar(col = color, lwd = size*4))
  # Steam
  grid::grid.lines(x = c(x - size*0.06, x - size*0.10),
                   y = c(y + size*0.14, y + size*0.26),
                   gp = grid::gpar(col = color, lwd = size*3))
  grid::grid.lines(x = c(x + size*0.06, x + size*0.10),
                   y = c(y + size*0.14, y + size*0.26),
                   gp = grid::gpar(col = color, lwd = size*3))
  # Saucer
  grid::grid.rect(x = x, y = y - size*0.24, width = size*0.44, height = size*0.04,
                  gp = grid::gpar(fill = color, col = color))
}

#' @noRd
icon_music <- function(x, y, size, color) {
  # Eighth note
  # Notehead
  t <- seq(0, 2*pi, length.out = 40)
  nx <- x - size*0.10 + size*0.08 * cos(t)
  ny <- y - size*0.18 + size*0.06 * sin(t) * 0.7
  grid::grid.polygon(x = nx, y = ny,
                     gp = grid::gpar(fill = color, col = color))
  # Stem
  grid::grid.lines(x = c(x - size*0.02, x - size*0.02),
                   y = c(y - size*0.18, y + size*0.18),
                   gp = grid::gpar(col = color, lwd = size*3))
  # Flag
  t2 <- seq(0, pi/2, length.out = 20)
  grid::grid.lines(x = x - size*0.02 + size*0.14 * sin(t2),
                   y = y + size*0.18 - size*0.14 * (1 - cos(t2)),
                   gp = grid::gpar(col = color, lwd = size*3))
}

#' @noRd
icon_gamepad <- function(x, y, size, color) {
  # Body
  t <- seq(0, 2*pi, length.out = 60)
  gx <- x + size*0.28 * cos(t) * (1 + 0.2*cos(2*t))
  gy <- y + size*0.16 * sin(t)
  grid::grid.polygon(x = gx, y = gy,
                     gp = grid::gpar(fill = color, col = color))
  # D-pad (left side)
  grid::grid.rect(x = x - size*0.14, y = y, width = size*0.12, height = size*0.04,
                  gp = grid::gpar(fill = grDevices::rgb(0,0,0,0.3), col = NA))
  grid::grid.rect(x = x - size*0.14, y = y, width = size*0.04, height = size*0.12,
                  gp = grid::gpar(fill = grDevices::rgb(0,0,0,0.3), col = NA))
  # Buttons (right side)
  for (bx_off in c(0.08, 0.16)) {
    for (by_off in c(0.04, -0.04)) {
      grid::grid.circle(x = x + bx_off * size, y = y + by_off * size,
                        r = size*0.025,
                        gp = grid::gpar(fill = grDevices::rgb(0,0,0,0.3), col = NA))
    }
  }
}

# ---------------------------------------------------------------------------
# Icon registry
# ---------------------------------------------------------------------------

#' @keywords internal
.icons <- list(
  science = list(
    atom      = list(label = "Atom",       draw = icon_atom),
    flask     = list(label = "Flask",      draw = icon_flask),
    microscope = list(label = "Microscope", draw = icon_microscope),
    molecule  = list(label = "Molecule",   draw = icon_molecule),
    magnet    = list(label = "Magnet",     draw = icon_magnet)
  ),
  biology = list(
    dna       = list(label = "DNA",        draw = icon_dna),
    cell      = list(label = "Cell",       draw = icon_cell),
    brain     = list(label = "Brain",      draw = icon_brain),
    leaf      = list(label = "Leaf",       draw = icon_leaf),
    bacteria  = list(label = "Bacteria",   draw = icon_bacteria),
    tree      = list(label = "Tree",       draw = icon_tree)
  ),
  stats = list(
    bar_chart  = list(label = "Bar Chart",  draw = icon_bar_chart),
    scatter    = list(label = "Scatter",    draw = icon_scatter),
    line_chart = list(label = "Line Chart", draw = icon_line_chart),
    bell_curve = list(label = "Bell Curve", draw = icon_bell_curve),
    pie        = list(label = "Pie Chart",  draw = icon_pie),
    sigma      = list(label = "Sigma",      draw = icon_sigma),
    boxplot    = list(label = "Boxplot",    draw = icon_boxplot),
    network    = list(label = "Network",    draw = icon_network)
  ),
  medical = list(
    stethoscope = list(label = "Stethoscope", draw = icon_stethoscope),
    heart       = list(label = "Heart",       draw = icon_heart),
    pulse       = list(label = "Pulse",       draw = icon_pulse),
    pill        = list(label = "Pill",        draw = icon_pill),
    cross       = list(label = "Cross",       draw = icon_cross),
    syringe     = list(label = "Syringe",     draw = icon_syringe)
  ),
  tech = list(
    terminal  = list(label = "Terminal",  draw = icon_terminal),
    brackets  = list(label = "Brackets",  draw = icon_brackets),
    gear      = list(label = "Gear",      draw = icon_gear),
    database  = list(label = "Database",  draw = icon_database),
    hash      = list(label = "Hash",      draw = icon_hash),
    rlogo     = list(label = "R Logo",    draw = icon_rlogo)
  ),
  shapes = list(
    star      = list(label = "Star",      draw = icon_star),
    shield    = list(label = "Shield",    draw = icon_shield),
    diamond   = list(label = "Diamond",   draw = icon_diamond),
    hexagon   = list(label = "Hexagon",   draw = icon_hexagon),
    infinity  = list(label = "Infinity",  draw = icon_infinity),
    arrow_up  = list(label = "Arrow Up",  draw = icon_arrow_up),
    circle    = list(label = "Circle",    draw = icon_circle)
  ),
  fun = list(
    rocket    = list(label = "Rocket",    draw = icon_rocket),
    lightning = list(label = "Lightning", draw = icon_lightning),
    fire      = list(label = "Fire",      draw = icon_fire),
    sparkle   = list(label = "Sparkle",   draw = icon_sparkle),
    crown     = list(label = "Crown",     draw = icon_crown),
    coffee    = list(label = "Coffee",    draw = icon_coffee),
    music     = list(label = "Music",     draw = icon_music),
    gamepad   = list(label = "Gamepad",   draw = icon_gamepad)
  )
)

#' List available icons
#'
#' @title List Available Icons
#' @description Returns the built-in icon library as a named list. Icons are
#'   organized by category. Each icon entry contains a `label` and `draw`
#'   function.
#'
#' @param category Character or `NULL`. If `NULL` (default), returns all
#'   categories. Otherwise, one of `"science"`, `"biology"`, `"stats"`,
#'   `"medical"`, `"tech"`, `"shapes"`, `"fun"`.
#'
#' @return A named list of icon entries (each with `label` and `draw`), or
#'   a named list of categories if `category = NULL`.
#'
#' @examples
#' icons <- hexmakr_icons()
#' names(icons)
#' hexmakr_icons("science")
#'
#' @seealso [hex_sticker()]
#' @family themes
#' @export
hexmakr_icons <- function(category = NULL) {
  if (is.null(category)) return(.icons)
  valid <- names(.icons)
  if (!category %in% valid) {
    stop(sprintf(
      "Unknown category '%s'. Valid categories: %s",
      category, paste(valid, collapse = ", ")
    ))
  }
  .icons[[category]]
}
