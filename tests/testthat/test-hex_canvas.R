# Tests for the low-level renderer in R/hex_canvas.R

test_that(".hex_poly() returns 6 pointy-top vertices", {
  poly <- hexmakR:::.hex_poly(0.5, 0.5, 0.4)
  expect_named(poly, c("x", "y"))
  expect_length(poly$x, 6L)
  expect_length(poly$y, 6L)
  # First vertex sits at angle -pi/2: same x as center, y = cy - R
  expect_equal(poly$x[1], 0.5)
  expect_equal(poly$y[1], 0.5 - 0.4)
  # The hexagon spans 2*R vertically and sqrt(3)*R horizontally
  expect_equal(max(poly$y) - min(poly$y), 2 * 0.4)
  expect_equal(max(poly$x) - min(poly$x), sqrt(3) * 0.4)
})

test_that(".make_icon_grob() builds an S3 grob of the right class", {
  draw_fn <- hexmakR:::.lookup_icon("atom")
  grb <- hexmakR:::.make_icon_grob(draw_fn, 0.5, 0.5, 0.3, "#FF0000",
                                   2 / sqrt(3))
  expect_s3_class(grb, "hexmakr_icon_grob")
  expect_s3_class(grb, "grob")
})

test_that("drawDetails.hexmakr_icon_grob renders the icon grob", {
  draw_fn <- hexmakR:::.lookup_icon("star")
  grb <- hexmakR:::.make_icon_grob(draw_fn, 0.5, 0.6, 0.25, "#00FF00",
                                   2 / sqrt(3))
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  expect_no_error(grid::grid.draw(grb))
})

test_that("hex_sticker with a built-in icon renders an extra layer", {
  no_icon   <- hex_sticker("pkg")
  with_icon <- hex_sticker("pkg", icon = "dna")
  expect_gt(length(with_icon$layers), length(no_icon$layers))
})

test_that("hex_sticker without inner_border has fewer polygon layers", {
  with_ring    <- hex_sticker("pkg", inner_border = TRUE)
  without_ring <- hex_sticker("pkg", inner_border = FALSE)
  expect_gt(length(with_ring$layers), length(without_ring$layers))
})

test_that("hex_sticker with a custom PNG image renders", {
  png_path <- withr::local_tempfile(fileext = ".png")
  grDevices::png(png_path, width = 64, height = 64, units = "px")
  grid::grid.rect(gp = grid::gpar(fill = "#123456"))
  grDevices::dev.off()

  expect_no_error(hex_sticker("pkg", icon_image = png_path))
})

test_that(".make_image_grob() warns and returns NULL for a missing file", {
  expect_warning(
    res <- hexmakR:::.make_image_grob("does_not_exist.png", 0.5, 0.5,
                                      0.3, 2 / sqrt(3)),
    "not found"
  )
  expect_null(res)
})

test_that(".make_image_grob() warns on an unsupported format", {
  bad <- withr::local_tempfile(fileext = ".gif")
  writeLines("x", bad)
  expect_warning(
    res <- hexmakR:::.make_image_grob(bad, 0.5, 0.5, 0.3, 2 / sqrt(3)),
    "Unsupported image format"
  )
  expect_null(res)
})

test_that(".make_image_grob() reads a PNG into a rasterGrob", {
  png_path <- withr::local_tempfile(fileext = ".png")
  grDevices::png(png_path, width = 64, height = 64, units = "px")
  grid::grid.rect(gp = grid::gpar(fill = "#654321"))
  grDevices::dev.off()

  grb <- hexmakR:::.make_image_grob(png_path, 0.5, 0.5, 0.3, 2 / sqrt(3))
  expect_s3_class(grb, "rastergrob")
})

test_that(".make_image_grob() handles JPEG when jpeg is available", {
  skip_if_not_installed("jpeg")
  jpg_path <- withr::local_tempfile(fileext = ".jpg")
  jpeg::writeJPEG(matrix(0.5, 16, 16), target = jpg_path)
  grb <- hexmakR:::.make_image_grob(jpg_path, 0.5, 0.5, 0.3, 2 / sqrt(3))
  expect_s3_class(grb, "rastergrob")
})
