test_that("hit maps use actual asymmetric geometry and topmost visible pixels", {
  d <- hex_design(layout = "motif", shape = "square")
  d <- hex_add_part(d, "circle", x = .35, y = .6, r = .08,
    fill = "#00000080", col = "transparent", lwd = 0)
  map <- .hex_hit_map(d, 160)
  expect_identical(.hex_hit_test(map, .35, .6), "part_0001")
  expect_null(.hex_hit_test(map, .42, .67)) # Inside its bounding box, outside circle.
  expect_null(.hex_hit_test(map, .6, .65)) # Native raster storage is row-major.
  expect_equal(unname(.hex_hit_bounds(map, "part_0001")),
    c(.26875, .51875, .43125, .68125), tolerance = .007)
  d <- hex_add_part(d, "circle", x = .38, y = .6, r = .05)
  expect_identical(.hex_hit_test(.hex_hit_map(d, 160), .35, .6), "part_0002")
  d <- hex_edit_layer(d, "part_0002", visible = FALSE)
  expect_identical(.hex_hit_test(.hex_hit_map(d, 160), .35, .6), "part_0001")
  d <- hex_edit_layer(d, "part_0001", alpha = 0)
  expect_null(.hex_hit_test(.hex_hit_map(d, 160), .35, .6))
  expect_null(.hex_hit_test(map, -.1, .5))
  expect_null(.hex_hit_test(map, NA_real_, .5))
})

test_that("stroke-only parts and glyph holes are not selected as rectangles", {
  d <- hex_design(layout = "motif", shape = "square")
  d <- hex_add_part(d, "circle", x = .3, y = .6, r = .12,
    fill = "transparent", col = "black", lwd = 5)
  d <- hex_add_part(d, "line", x = c(.55, .8), y = c(.25, .5),
    col = "black", lwd = 5)
  map <- .hex_hit_map(d, 200)
  expect_null(.hex_hit_test(map, .3, .6))
  expect_identical(.hex_hit_test(map, .42, .6), "part_0001")
  expect_identical(.hex_hit_test(map, .675, .375), "part_0002")
  expect_null(.hex_hit_test(map, .55, .5))
  d <- logo_design("O", shape = "square", label_size = 64)
  map <- .hex_hit_map(d, 200)
  name_id <- hex_layers(d)$id[hex_layers(d)$role == "name"]
  bounds <- .hex_hit_bounds(map, name_id)
  expect_true(any(map$index == match(name_id, map$ids)))
  expect_identical(.hex_hit_test(map, mean(bounds[c(1, 3)]),
    mean(bounds[c(2, 4)])), "layer_0001")
  expect_null(.hex_hit_test(map, 0, 0))
})

test_that("rotation, point edits and clipping match the exported geometry", {
  skip_without_cairo()
  d <- hex_add_part(logo_design(""), "rectangle", x = .5, y = .6,
    width = .4, height = .08, col = "transparent", lwd = 0)
  d <- hex_edit_layer(d, "part_0001", angle = 90)
  map <- .hex_hit_map(d, 200)
  expect_identical(.hex_hit_test(map, .5, .7), "part_0001")
  expect_identical(.hex_hit_test(map, .65, .6), "layer_0001")
  bounds <- .hex_hit_bounds(map, "part_0001")
  expect_true(bounds[4] - bounds[2] > 3 * (bounds[3] - bounds[1]))
  copy <- hex_duplicate_part(d, "part_0001")
  expect_identical(.hex_hit_test(.hex_hit_map(copy, 100), .5, .7), "part_0002")
  for (shape in c("hex", "pentagon", "square")) {
    d <- logo_design("", shape = shape, border_width = 0,
      colors = list(face = "transparent", rim = "transparent"))
    d <- hex_add_part(d, "polygon", x = c(-.5, 1.5, 1.5, -.5),
      y = c(-.5, -.5, 1.5, 1.5), fill = "black", col = "transparent", lwd = 0)
    d <- hex_edit_layer(d, "layer_0001", scale = .5, angle = 30)
    map <- .hex_hit_map(d, 100)
    file <- tempfile(fileext = ".png"); on.exit(unlink(file), add = TRUE)
    hex_export(d, file, 100)
    alpha <- png::readPNG(file)[, , 4]
    expect_identical(map$index > 0L, alpha > 0, info = shape)
    expect_null(.hex_hit_test(map, .1, .5), info = shape)
    expect_identical(.hex_hit_test(map, .5, .5), "part_0001", info = shape)
  }
})

test_that("canvas dragging accounts for nested archive viewports and rotation", {
  d <- hex_add_part(logo_design("", shape = "square"), "rectangle",
    x = .4, y = .5, width = .2, height = .08, col = "transparent")
  d <- hex_edit_layer(d, "part_0001", scale = 1.2, angle = 40)
  before <- .hex_hit_bounds(.hex_hit_map(d, 300), "part_0001")
  moved <- hex_move_layer(d, "part_0001", .1, .08)
  after <- .hex_hit_bounds(.hex_hit_map(moved, 300), "part_0001")
  expect_equal(unname(after - before), c(.1, .08, .1, .08), tolerance = .005)
  expect_identical(moved$layers$part_0001$angle, 40)
  expect_identical(moved$layers$part_0001$scale, 1.2)
  source <- hex_design("delphyrApp")
  tree <- hex_grob(source)
  ids <- names(tree$children)
  paths <- vapply(tree$children, function(g) paste(as.character(.layer_leaf(g)$vp), collapse = ""), character(1))
  nested <- ids[grepl("motif-space::", paths, fixed = TRUE)][1]
  expect_false(is.na(nested))
  isolated <- hex_reuse_part(hex_design(layout = "motif", shape = "square"), source, nested)
  before <- .hex_hit_bounds(.hex_hit_map(isolated, 300), "part_0001")
  moved <- hex_move_layer(isolated, "part_0001", .04, .03)
  after <- .hex_hit_bounds(.hex_hit_map(moved, 300), "part_0001")
  expect_equal(unname(after - before), c(.04, .03, .04, .03), tolerance = .005)
  native <- hex_move_layer(source, nested, .04, .03)
  transform <- .cttir_viewport_matrix(tree$childrenvp, .layer_leaf(tree$children[[nested]])$vp,
    .design_ratio(source))
  expect_equal(as.numeric(transform[1:2, 1:2] %*%
    c(native$layers[[nested]]$dx, native$layers[[nested]]$dy)), c(.04, .03))
  expect_error(hex_move_layer(source, "layer_9999", .1, 0), "existing items")
  expect_identical(hex_move_layer(source, nested, 0, 0), source)
})

test_that("uploaded raster transparency and SVG holes participate in picking", {
  png_file <- tempfile(fileext = ".png"); svg_file <- tempfile(fileext = ".svg")
  on.exit(unlink(c(png_file, svg_file)), add = TRUE)
  pixels <- array(0, c(20, 20, 4)); pixels[6:15, 1:10, 1] <- 1
  pixels[6:15, 1:10, 4] <- 1
  png::writePNG(pixels, png_file)
  d <- hex_import_art(hex_design(layout = "motif", shape = "square"), png_file)
  part <- d$parts$part_0001
  map <- .hex_hit_map(d, 200)
  expect_identical(.hex_hit_test(map, part$x - part$width / 4, part$y), "part_0001")
  expect_null(.hex_hit_test(map, part$x + part$width / 4, part$y))
  d <- hex_edit_layer(d, "part_0001", alpha = 0)
  expect_false(any(.hex_hit_map(d, 100)$index > 0))
  writeLines('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><path fill="black" fill-rule="evenodd" d="M10 10H90V90H10Z M35 35H65V65H35Z"/></svg>', svg_file)
  d <- hex_import_art(hex_design(layout = "motif", shape = "square"), svg_file)
  map <- .hex_hit_map(d, 200)
  part <- d$parts$part_0001
  mid <- c(mean(range(part$x)), mean(range(part$y)))
  expect_null(.hex_hit_test(map, mid[1], mid[2]))
  expect_identical(.hex_hit_test(map, min(part$x) + diff(range(part$x)) / 10, mid[2]), "part_0001")
})
