fidelity_svg <- function(body, attributes = 'viewBox="0 0 100 100"') {
  path <- tempfile(fileext = ".svg")
  writeLines(paste0('<svg xmlns="http://www.w3.org/2000/svg" ', attributes,
    '>', body, '</svg>'), path)
  path
}

test_that("drawing commands after closepath start an independent open subpath", {
  prefix <- "M10 10 L30 10 L30 30 Z"
  commands <- c("L70 50", "l60 40", "H70", "v40", "C20 10 40 30 70 50",
    "s30 20 60 40", "Q40 10 70 50", "t60 40", "A30 20 0 0 1 70 50")
  for (command in commands) {
    implicit <- .svg_path(paste(prefix, command))
    explicit <- .svg_path(paste(prefix, "M10 10", command))
    expect_equal(implicit, explicit, info = command)
    expect_equal(implicit$closed, c(1, 0), info = command)
  }
  expect_equal(.svg_path(paste(prefix, "z l60 40 z")),
    .svg_path(paste(prefix, "M10 10 l60 40 z")))
  many <- paste(rep("M0 0L1 0Z", 512), collapse = " ")
  expect_error(.svg_path(paste(many, "L1 1")), "Too many SVG subpaths")
})

test_that("root viewports preserve aspect, alignment, units and transformations", {
  d <- logo_design("", shape = "square", layout = "motif")
  import <- function(body, attributes) {
    path <- fidelity_svg(body, attributes); on.exit(unlink(path))
    hex_import_art(d, path)$parts[[1L]]
  }
  circle <- '<circle id="shape" cx="50" cy="50" r="30" fill="red"/>'
  ellipse <- '<ellipse id="shape" cx="100" cy="50" rx="60" ry="30" fill="red"/>'
  stretched <- import(circle,
    'width="200" height="100" viewBox="0 0 100 100" preserveAspectRatio="none"')
  expect_equal(stretched, import(ellipse, 'width="200" height="100" viewBox="0 0 200 100"'))
  expect_equal(diff(range(stretched$x)) / diff(range(stretched$y)), 2)
  for (alignment in c("Min", "Mid", "Max")) {
    offset <- switch(alignment, Min = 0, Mid = 50, Max = 100)
    horizontal <- import(circle, paste0('width="200" height="100" viewBox="0 0 100 100" ',
      'preserveAspectRatio="x', alignment, 'YMid meet"'))
    equivalent <- import(sprintf('<circle id="shape" cx="%s" cy="50" r="30" fill="red"/>', 50 + offset),
      'width="200" height="100" viewBox="0 0 200 100"')
    expect_equal(horizontal, equivalent, info = alignment)
    vertical <- import(circle, paste0('width="100" height="200" viewBox="0 0 100 100" ',
      'preserveAspectRatio="xMidY', alignment, '"'))
    equivalent <- import(sprintf('<circle id="shape" cx="50" cy="%s" r="30" fill="red"/>', 50 + offset),
      'width="100" height="200" viewBox="0 0 100 200"')
    expect_equal(vertical, equivalent, info = alignment)
  }
  centered <- import(circle, 'width="200" height="100" viewBox="0 0 100 100"')
  expect_equal(centered, import(circle, 'width="150pt" height="75pt" viewBox="0 0 100 100"'))
  expect_equal(centered, import(circle, 'width="2in" height="2.54cm" viewBox="0 0 100 100"'))
  expect_equal(import(circle, 'width="200" viewBox="0 0 100 100"'),
    import(circle, 'viewBox="0 0 100 100"'))
  expect_equal(import(circle, 'height="200" viewBox="0 0 100 100"'),
    import(circle, 'viewBox="0 0 100 100"'))
  expect_equal(import('<circle id="shape" cx="60" cy="70" r="30" fill="red"/>',
    'viewBox="10 20 100 100"'), import(circle, 'viewBox="0 0 100 100"'))
  expect_equal(import(circle, 'width="200" height="100" viewBox="0 0 100 100" transform="translate(10 0)"'),
    import('<circle id="shape" cx="110" cy="50" r="30" fill="red"/>',
      'width="200" height="100" viewBox="0 0 200 100"'))
})

test_that("viewport cropping and unsupported relative dimensions fail explicitly", {
  d <- logo_design("")
  check <- function(body, attributes, error) {
    path <- fidelity_svg(body, attributes); on.exit(unlink(path))
    expect_error(hex_import_art(d, path), error)
    expect_length(d$parts, 0)
  }
  circle <- '<circle cx="50" cy="50" r="30"/>'
  check(circle, 'width="200" height="100" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid slice"',
    "viewport clipping intersects")
  check('<circle cx="95" cy="50" r="10"/>', 'viewBox="0 0 100 100"', "viewport clipping intersects")
  check('<circle cx="50" cy="50" r="30" stroke="black"/>',
    'width="200" height="100" viewBox="0 0 100 100" preserveAspectRatio="none"', "Outline strokes")
  for (dimension in c("100%", "2em", "0", "-100", "1e100")) {
    check(circle, paste0('width="', dimension, '" height="100" viewBox="0 0 100 100"'),
      "viewport dimensions")
  }
  check(circle, 'viewBox="0 0 100 100" preserveAspectRatio="xMiddleYMiddle"', "preserveAspectRatio")
})

test_that("corrected imports retain their appearance through JSON and R recipes", {
  skip_without_cairo()
  directory <- tempfile(); dir.create(directory); on.exit(unlink(directory, recursive = TRUE))
  path <- fidelity_svg('<path d="M10 10L30 10L30 30Z L70 50" fill="red" stroke="black"/>',
    'width="200" height="100" viewBox="0 0 100 100"')
  on.exit(unlink(path), add = TRUE)
  d <- hex_import_art(logo_design("", shape = "square", layout = "motif"), path)
  project <- file.path(directory, "design.json")
  hex_save_design(d, project)
  expect_equal(hex_read_design(project), d)
  recipe <- file.path(directory, "recipe.R")
  hex_recipe(d, recipe)
  env <- new.env(parent = globalenv())
  withr::with_dir(directory, {
    grDevices::pdf(NULL)
    tryCatch(sys.source(recipe, envir = env), finally = grDevices::dev.off())
  })
  expect_equal(env$design, d)
  expect_true(all(file.info(file.path(directory, c("sticker.svg", "sticker.png")))$size > 0))
})

test_that("imported SVG silhouettes agree with independent librsvg rendering", {
  skip_without_cairo()
  skip_if_not_installed("rsvg")
  cases <- list(
    list(attributes = 'width="200" height="100" viewBox="0 0 100 100" preserveAspectRatio="none"',
      body = '<circle cx="50" cy="50" r="30" fill="red"/>', width = 200, height = 100),
    list(attributes = 'width="200" height="100" viewBox="0 0 100 100" preserveAspectRatio="xMaxYMid"',
      body = '<circle cx="50" cy="50" r="30" fill="red"/>', width = 200, height = 100),
    list(attributes = 'width="100" height="100" viewBox="0 0 100 100"',
      body = '<path d="M10 10L30 10L30 30Z L70 50" fill="red" stroke="black" stroke-width="2"/>',
      width = 100, height = 100),
    list(attributes = 'width="100" height="100" viewBox="0 0 100 100"',
      body = '<path d="M30 30L70 30L70 70Z" fill="none" stroke="black" stroke-width="10"/>',
      width = 100, height = 100)
  )
  directory <- tempfile(); dir.create(directory); on.exit(unlink(directory, recursive = TRUE))
  for (case in cases) {
    path <- fidelity_svg(case$body, case$attributes); on.exit(unlink(path), add = TRUE)
    d <- hex_import_art(logo_design("", shape = "square", layout = "motif"), path)
    output <- file.path(directory, "import.png"); hex_export(d, output, width = 1000)
    imported <- png::readPNG(output)[, , 4] > .5
    width <- min(.68, .58 * case$width / case$height)
    height <- width * case$height / case$width
    original <- rsvg::rsvg_nativeraster(path, width = round(width * 1000), height = round(height * 1000))
    reference <- file.path(directory, "reference.png")
    grDevices::png(reference, width = 1000, height = 1000, bg = "transparent", type = "cairo")
    tryCatch({
      grid::grid.newpage()
      grid::grid.raster(original, x = .5, y = .6, width = width, height = height, interpolate = FALSE)
    }, finally = grDevices::dev.off())
    expected <- png::readPNG(reference)[, , 4] > .5
    # Curves are bounded polylines; rasterisers can differ along their edges.
    expect_gt(sum(imported & expected) / sum(imported | expected), .98)
  }
})
