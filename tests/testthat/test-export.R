test_that("save_hex() creates a PNG file", {
  tmp <- tempfile(fileext = ".png")
  on.exit(unlink(tmp), add = TRUE)
  s <- hex_sticker("mypkg", theme = "stats")
  save_hex(s, tmp)
  expect_true(file.exists(tmp))
  expect_gt(file.size(tmp), 0L)
})

test_that("PNG output has correct hex aspect ratio (h/w = 2/sqrt(3))", {
  tmp <- tempfile(fileext = ".png")
  on.exit(unlink(tmp), add = TRUE)
  width_px <- 600L
  s <- hex_sticker("mypkg")
  save_hex(s, tmp, width = width_px)
  img <- png::readPNG(tmp)
  h_px <- dim(img)[1]
  w_px <- dim(img)[2]
  expected_h <- round(width_px / sqrt(3) * 2)
  expect_equal(w_px, width_px)
  expect_equal(h_px, expected_h, tolerance = 2)
})

test_that("PNG has an alpha channel (transparency)", {
  tmp <- tempfile(fileext = ".png")
  on.exit(unlink(tmp), add = TRUE)
  s <- hex_sticker("mypkg")
  save_hex(s, tmp)
  img <- png::readPNG(tmp)
  # Transparent PNG: 4 channels (RGBA)
  expect_equal(dim(img)[3], 4L)
})

test_that("save_hex() errors for non-ggplot input", {
  expect_error(save_hex("not_a_plot", tempfile(fileext = ".png")),
               "ggplot")
})

test_that("save_hex() errors for non-.png filename", {
  s <- hex_sticker("mypkg")
  expect_error(save_hex(s, tempfile(fileext = ".jpg")), "\\.png")
})

test_that("SVG export works when svglite is available", {
  skip_if_not_installed("svglite")
  tmp <- tempfile(fileext = ".svg")
  on.exit(unlink(tmp), add = TRUE)
  s <- hex_sticker("mypkg")
  save_hex_svg(s, tmp)
  expect_true(file.exists(tmp))
  expect_gt(file.size(tmp), 0L)
})
