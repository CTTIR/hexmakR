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
