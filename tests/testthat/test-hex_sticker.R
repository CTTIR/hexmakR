test_that("hex_sticker() returns a ggplot object", {
  p <- hex_sticker("mypackage")
  expect_s3_class(p, "gg")
})

test_that("default call with only name doesn't error", {
  expect_no_error(hex_sticker("testpkg"))
})

test_that("all themes work in dark mode", {
  themes <- names(hexmakr_themes())
  for (th in themes) {
    expect_no_error(hex_sticker("pkg", theme = th, mode = "dark"),
                    message = paste("theme", th, "dark failed"))
  }
})

test_that("all themes work in light mode", {
  themes <- names(hexmakr_themes())
  for (th in themes) {
    expect_no_error(hex_sticker("pkg", theme = th, mode = "light"),
                    message = paste("theme", th, "light failed"))
  }
})

test_that("custom color overrides are accepted", {
  expect_no_error(
    hex_sticker("pkg",
                bg           = "#000000",
                accent       = "#FF0000",
                text_color   = "#FFFFFF",
                border_color = "#FF0000",
                sub_color    = "#AAAAAA")
  )
})

test_that("filename argument saves a PNG file", {
  tmp <- tempfile(fileext = ".png")
  on.exit(unlink(tmp), add = TRUE)
  hex_sticker("testpkg", filename = tmp)
  expect_true(file.exists(tmp))
  expect_gt(file.size(tmp), 0)
})

test_that("invalid theme name gives informative error", {
  expect_error(hex_sticker("pkg", theme = "nonexistent_theme"),
               "Unknown theme")
})

test_that("invalid icon name gives informative error", {
  expect_error(hex_sticker("pkg", icon = "not_an_icon"),
               "Unknown icon")
})

test_that("invalid mode gives informative error", {
  expect_error(hex_sticker("pkg", mode = "blurple"),
               "mode")
})

test_that("invalid color string gives informative error", {
  expect_error(hex_sticker("pkg", bg = "notacolor"), "bg")
})

test_that("all valid icon names work", {
  icon_names <- unlist(lapply(hexmakr_icons(), names))
  # Test a representative subset to keep tests fast
  for (ic in icon_names[seq(1, length(icon_names), by = 7)]) {
    expect_no_error(hex_sticker("pkg", icon = ic),
                    message = paste("icon", ic, "failed"))
  }
})

test_that("subtitle and url parameters are rendered without error", {
  expect_no_error(
    hex_sticker("pkg", subtitle = "A subtitle", url = "cran.r-project.org")
  )
})

test_that("providing both icon and icon_image messages and uses the image", {
  png_path <- withr::local_tempfile(fileext = ".png")
  grDevices::png(png_path, width = 64, height = 64, units = "px")
  grid::grid.rect(gp = grid::gpar(fill = "#abcdef"))
  grDevices::dev.off()

  expect_message(
    hex_sticker("pkg", icon = "atom", icon_image = png_path),
    "icon_image"
  )
})

test_that("light mode resolves light theme colors", {
  expect_no_error(hex_sticker("pkg", theme = "cran", mode = "light"))
})

test_that("a classic sticker draws a v5 family's tile, rim and ink", {
  th <- hexmakr_themes()$spatial$dark
  p  <- hex_sticker("pkg", icon = "microscope", theme = "spatial")
  frame <- p$layers[[1]]$aes_params
  expect_identical(frame$fill, th$bg)
  expect_identical(frame$colour, th$border)
  name <- Filter(function(l) inherits(l$geom, "GeomText"), p$layers)[[1]]
  expect_identical(name$aes_params$colour, th$text)
  icon <- Filter(function(l) inherits(l$geom, "GeomCustomAnn"), p$layers)[[1]]
  expect_identical(icon$geom_params$grob$env$color, th$accent)
})

test_that("a classic sticker with a v5 theme renders the v5 face to PNG", {
  for (mode in c("dark", "light")) {
    path <- withr::local_tempfile(fileext = ".png")
    hex_sticker("pkg", theme = "clinical", mode = mode, filename = path)
    img <- png::readPNG(path)
    # Sample the empty upper part of the tile, away from text and rings
    pixel <- img[round(dim(img)[1] * .2), round(dim(img)[2] * .5), 1:3]
    face  <- grDevices::col2rgb(hexmakr_themes()$clinical[[mode]]$bg)[, 1] / 255
    expect_equal(pixel, unname(face), tolerance = 2 / 255, info = mode)
  }
})

test_that("scalar arguments give clear errors", {
  expect_error(hex_sticker(name = NULL), "'name' must be a single string")
  expect_error(hex_sticker(name = NA_character_), "'name' must be a single string")
  expect_error(hex_sticker("pkg", theme = c("stats", "viz")),
               "'theme' must be a single string")
  expect_error(hex_sticker("pkg", mode = c("dark", "light")),
               "'mode' must be a single string")
  expect_error(hex_sticker("pkg", font_family = c("mono", "serif")),
               "'font_family' must be a single string")
  expect_error(hexmakr_icons(c("science", "fun")),
               "'category' must be a single string")
  expect_error(hexmakr_icons(NA_character_), "'category' must be a single string")
})
