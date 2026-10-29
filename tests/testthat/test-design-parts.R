test_that("fresh designs have no archive motif and empty canvases remain drawable", {
  skip_without_cairo()
  expect_false(hex_design()$archive)
  expect_false(logo_design("New project")$archive)
  expect_setequal(hex_layers(logo_design("New project"))$role, c("frame", "name"))
  expect_true(hex_design("phenoscapR")$archive)
  expect_true(any(hex_layers(hex_design("phenoscapR"))$role == "motif"))
  blank <- hex_design(layout = "motif")
  expect_s3_class(hex_grob(blank), "gTree")
  expect_equal(nrow(hex_layers(blank)), 0L)
  expect_type(hex_layers(blank)$id, "character")
  file <- tempfile(fileext = ".png"); on.exit(unlink(file), add = TRUE)
  hex_export(blank, file, 100)
  expect_true(all(png::readPNG(file)[, , 4] == 0))
})

test_that("primitive edits, duplication and removal retain independent stable IDs", {
  original <- logo_design("Parts")
  d <- hex_add_part(original, "circle", x = .35, y = .6, r = .1)
  d <- hex_add_part(d, "rectangle", width = .2, height = .1)
  d <- hex_add_part(d, "line", x = c(.1, .8), y = c(.4, .7))
  d <- hex_add_part(d, "polygon")
  expect_length(original$parts, 0)
  expect_equal(hex_layers(d)$points[hex_layers(d)$id == "part_0004"], 3)
  d <- hex_edit_layer(d, "part_0001", fill = "red", dx = .1, scale = 1.3)
  copy <- hex_duplicate_part(d, "part_0001")
  first <- .layer_leaf(hex_grob(copy)$children$part_0001)
  last <- .layer_leaf(hex_grob(copy)$children$part_0005)
  expect_equal(last$x, first$x)
  expect_equal(last$r, first$r)
  expect_identical(last$gp$fill, "red")
  copy <- hex_edit_layer(copy, "part_0005", fill = "blue")
  expect_identical(.layer_leaf(hex_grob(copy)$children$part_0001)$gp$fill, "red")
  removed <- hex_remove_part(copy, "part_0002")
  expect_false("part_0002" %in% hex_layers(removed)$id)
  expect_true(all(c("part_0001", "part_0003", "part_0004", "part_0005") %in% hex_layers(removed)$id))
  expect_true("part_0002" %in% hex_layers(copy)$id)
  hidden <- hex_remove_part(copy, "layer_0001")
  expect_false(hex_layers(hidden)$visible[hex_layers(hidden)$id == "layer_0001"])
  expect_true("layer_0001" %in% hex_layers(hidden)$id)
})

test_that("native duplication and archive reuse preserve edited source geometry", {
  source <- hex_edit_layer(hex_design("phenoscapR"), "layer_0007",
                           fill = "magenta", dx = .08, dy = -.03, scale = 1.2)
  duplicate <- hex_duplicate_part(source, "layer_0007")
  expected <- hex_grob(source)$children$layer_0007
  actual <- .layer_leaf(hex_grob(duplicate)$children$part_0001)
  expect_equal(actual$x, expected$x)
  expect_equal(actual$y, expected$y)
  expect_equal(actual$r, expected$r)
  expect_equal(actual$gp, expected$gp)
  destination <- logo_design("Independent", shape = "pentagon", colors = list(face = "navy"))
  reused <- hex_reuse_part(destination, source, "layer_0007")
  for (key in setdiff(names(destination), c("parts", "layers"))) {
    expect_equal(reused[[key]], destination[[key]])
  }
  source <- hex_edit_layer(source, "layer_0007", fill = "yellow")
  expect_identical(.layer_leaf(hex_grob(reused)$children$part_0001)$gp$fill, "magenta")
  expect_error(hex_reuse_part(destination, source, "part_0001"), "native source")
})

test_that("whole motif reuse preserves the original native viewport placement", {
  skip_without_cairo()
  source <- hex_design("phenoscapR")
  reused <- hex_reuse_part(hex_design("phenoscapR", archive = FALSE), source)
  expect_equal(length(reused$parts), sum(hex_layers(source)$role == "motif"))
  expect_true(all(vapply(reused$parts, function(p) p$type == "archive", logical(1))))
  files <- c(tempfile(fileext = ".png"), tempfile(fileext = ".png"))
  on.exit(unlink(files), add = TRUE)
  hex_export(source, files[1], 200)
  hex_export(reused, files[2], 200)
  expect_equal(png::readPNG(files[1]), png::readPNG(files[2]), tolerance = 0)
})

test_that("parts roundtrip with native coordinate edits and legacy v1 projects", {
  source <- hex_design("phenoscapR")
  leaf <- hex_grob(source)$children$layer_0005
  source <- hex_edit_layer(source, "layer_0005", x = as.numeric(leaf$x) + .01)
  d <- hex_reuse_part(logo_design("Roundtrip"), source, "layer_0005")
  d <- hex_add_part(d, "polygon", x = c(.25, .5, .75), y = c(.4, .7, .4))
  d <- hex_edit_layer(d, "part_0002", y = c(.3, .6, .3), col = "pink")
  d <- hex_duplicate_part(d, "part_0002")
  d <- hex_remove_part(d, "layer_0002")
  file <- tempfile(); on.exit(unlink(file), add = TRUE)
  hex_save_design(d, file)
  expect_equal(hex_read_design(file), d)
  legacy <- hex_design("phenoscapR")
  legacy$archive <- NULL; legacy$parts <- NULL
  jsonlite::write_json(unclass(legacy), file, auto_unbox = TRUE)
  loaded <- hex_read_design(file)
  expect_true(loaded$archive)
  expect_length(loaded$parts, 0)
  expect_equal(hex_layers(loaded), hex_layers(legacy))
})

test_that("declarative part validation rejects unknown and executable structures", {
  d <- hex_add_part(logo_design("Safety"), "polygon")
  bad <- d; bad$parts[[1]]$file <- "/tmp/arbitrary.svg"
  expect_error(hex_grob(bad), "Invalid part fields")
  bad <- d; bad$parts[[1]]$type <- "eval"
  expect_error(hex_grob(bad), "Unknown part type")
  bad <- d; bad$parts[[1]]$x <- c(0, Inf, 1)
  expect_error(hex_grob(bad), "finite numeric")
  bad <- d; bad$parts[[2]] <- bad$parts[[1]]; names(bad$parts) <- rep("part_0001", 2)
  expect_error(hex_grob(bad), "additional parts")
  bad <- hex_reuse_part(logo_design("Safety"), "phenoscapR", "layer_0007")
  bad$parts[[1]]$source$parts <- d$parts
  expect_error(hex_grob(bad), "without nested parts")
  bad$parts[[1]]$source$parts <- list()
  bad$parts[[1]]$layer <- "layer_9999"
  expect_error(hex_grob(bad), "missing layer")
  expect_error(hex_add_part(logo_design("Safety"), "circle", file = "anything"), "geometry")
  expect_error(hex_add_part(logo_design("Safety"), "polygon", x = 1:5001, y = 1:5001), "Coordinates")
  file <- tempfile(); on.exit(unlink(file), add = TRUE)
  jsonlite::write_json(unclass(bad), file, auto_unbox = TRUE)
  expect_error(hex_read_design(file), "missing layer")
  bad <- d; bad$parts[[1]]$x <- list(unexpected = .3, field = .5, names = .7)
  jsonlite::write_json(unclass(bad), file, auto_unbox = TRUE)
  expect_error(hex_read_design(file), "Invalid coordinate array")
})

test_that("oversized projects fail before replacing an existing file", {
  local_mocked_bindings(.design_json_limit = function() 2e6)
  d <- hex_add_part(logo_design("Large"), "polygon",
    x = seq(.2, .8, length.out = 5000), y = rep(.5, 5000))
  d$parts <- stats::setNames(rep(d$parts, 20), sprintf("part_%04d", 1:20))
  file <- tempfile(); on.exit(unlink(file), add = TRUE)
  writeLines("preserve existing file", file)
  expect_error(hex_save_design(d, file), "size limit")
  expect_identical(readLines(file), "preserve existing file")
})

test_that("new and reused parts clip to the current edited frame in every shape", {
  skip_without_cairo()
  for (shape in c("hex", "pentagon", "square")) {
    d <- logo_design("", shape = shape, border_width = 0,
      colors = list(face = "transparent", rim = "transparent"))
    d <- hex_add_part(d, "rectangle", width = 2, height = 2,
      fill = "red", col = "transparent", lwd = 0)
    d <- hex_edit_layer(d, "layer_0001", scale = .5)
    file <- tempfile(fileext = ".png"); on.exit(unlink(file), add = TRUE)
    hex_export(d, file, 100)
    alpha <- png::readPNG(file)[, , 4]
    expect_true(all(alpha[, 1:20] == 0), info = shape)
    expect_true(all(alpha[1:20, ] == 0), info = shape)
    expect_equal(alpha[round(nrow(alpha) / 2), 50], 1, info = shape)
  }
})

test_that("R recipes preserve added parts and quote user labels as data", {
  d <- hex_add_part(logo_design("x'); stop('not code'); #"), "circle")
  dir <- tempfile(); dir.create(dir)
  on.exit(unlink(dir, recursive = TRUE), add = TRUE)
  old <- setwd(dir); on.exit(setwd(old), add = TRUE)
  hex_recipe(d, "project.R")
  grDevices::pdf(NULL); on.exit(grDevices::dev.off(), add = TRUE)
  env <- new.env(parent = globalenv())
  sys.source("project.R", envir = env)
  expect_equal(env$design, d)
  expect_true(all(file.exists(c("sticker.svg", "sticker.png"))))
})
