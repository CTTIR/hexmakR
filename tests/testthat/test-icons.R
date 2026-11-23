test_that("hexmakr_icons() returns all 7 categories", {
  icons <- hexmakr_icons()
  expect_type(icons, "list")
  expect_named(icons, c("science", "biology", "stats", "medical",
                         "tech", "shapes", "fun"))
})

test_that("total icon count is 46", {
  icons <- hexmakr_icons()
  total <- sum(vapply(icons, length, integer(1)))
  expect_equal(total, 46)
})

test_that("each icon has label and draw function", {
  icons <- hexmakr_icons()
  for (cat_name in names(icons)) {
    cat <- icons[[cat_name]]
    for (icon_name in names(cat)) {
      icon <- cat[[icon_name]]
      expect_true(is.character(icon$label),
                  label = paste(cat_name, icon_name, "label should be character"))
      expect_true(is.function(icon$draw),
                  info = paste(cat_name, icon_name, "draw"))
    }
  }
})

test_that("icon draw functions accept (x, y, size, color) without error", {
  # Test a sample from each category using a null device
  sample_icons <- list(
    science  = "atom",
    biology  = "dna",
    stats    = "bar_chart",
    medical  = "heart",
    tech     = "terminal",
    shapes   = "star",
    fun      = "rocket"
  )
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  for (cat_name in names(sample_icons)) {
    icon_name <- sample_icons[[cat_name]]
    draw_fn <- hexmakr_icons(cat_name)[[icon_name]]$draw
    expect_no_error(
      draw_fn(0.5, 0.5, 0.5, "#FF0000"),
      message = paste(cat_name, icon_name, "draw failed")
    )
  }
})

test_that("hexmakr_icons('science') returns 5 icons", {
  sci <- hexmakr_icons("science")
  expect_length(sci, 5)
})

test_that("hexmakr_icons() with invalid category errors informatively", {
  expect_error(hexmakr_icons("nonexistent"), "Unknown category")
})

test_that("category counts are correct", {
  expected <- c(science = 5, biology = 6, stats = 8,
                medical = 6, tech = 6, shapes = 7, fun = 8)
  for (cat_name in names(expected)) {
    expect_equal(length(hexmakr_icons(cat_name)), expected[[cat_name]],
                 label = paste(cat_name, "count"))
  }
})

test_that("ALL 46 icon draw functions render without error", {
  # Call each icon_* drawing function by name through the namespace so the
  # body of every function is exercised (and counted for coverage).
  ns <- asNamespace("hexmakR")
  draw_fns <- grep("^icon_", ls(ns, all.names = TRUE), value = TRUE)
  expect_equal(length(draw_fns), 46L)

  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  for (fn_name in draw_fns) {
    fn <- get(fn_name, envir = ns)
    expect_no_error(
      fn(0.5, 0.5, 0.5, "#3366CC"),
      message = paste(fn_name, "draw failed")
    )
  }
})

test_that(".lookup_icon() returns a draw function for a valid name", {
  fn <- hexmakR:::.lookup_icon("dna")
  expect_true(is.function(fn))
})

test_that(".lookup_icon() errors informatively for an unknown icon", {
  expect_error(hexmakR:::.lookup_icon("not_a_real_icon"), "Unknown icon")
})

# Vertical extent of everything an icon draws, in npc of its own viewport.
icon_extent <- function(name, size = 0.42) {
  grDevices::pdf(file = NULL, width = 4, height = 4)
  on.exit(grDevices::dev.off(), add = TRUE)
  grid::grid.newpage()
  hexmakR:::.lookup_icon(name)(0.5, 0.5, size, "#FF0000")
  grobs <- grid::grid.grab(wrap = FALSE)$children
  values <- function(key) unlist(lapply(grobs, function(g) {
    v <- as.numeric(g[[key]])
    r <- if (is.null(g$r)) 0 else as.numeric(g$r)
    half <- g[[if (key == "y") "height" else "width"]]
    half <- if (is.null(half)) 0 else as.numeric(half) / 2
    c(v - r - half, v + r + half)
  }))
  list(x = range(values("x")), y = range(values("y")), grobs = grobs)
}

test_that("every icon stays inside its own drawing area", {
  for (name in unlist(lapply(hexmakr_icons(), names), use.names = FALSE)) {
    extent <- icon_extent(name)
    expect_gte(extent$y[1], 0, label = paste(name, "bottom"))
    expect_lte(extent$y[2], 1, label = paste(name, "top"))
    expect_gte(extent$x[1], 0, label = paste(name, "left"))
    expect_lte(extent$x[2], 1, label = paste(name, "right"))
  }
})

test_that("the fire icon is a filled flame rather than a sliver", {
  flame <- icon_extent("fire")$grobs[[1]]
  x <- as.numeric(flame$x); y <- as.numeric(flame$y)
  next_point <- c(seq_along(x)[-1], 1L)
  area <- abs(sum(x * y[next_point] - x[next_point] * y)) / 2
  box <- diff(range(x)) * diff(range(y))
  expect_gt(area / box, 0.4)
  expect_gt(diff(range(y)), diff(range(x)))
})
