# Tests for the font registry in R/fonts.R

test_that("the font registry has the 14 built-in shorthands", {
  fonts <- unlist(hexmakR:::.fonts)
  expect_type(fonts, "character")
  expect_length(fonts, 14L)
  expect_true(all(c("mono", "serif", "sans", "jetbrains_mono") %in% names(fonts)))
})

test_that("every system font maps to a base R family alias", {
  fonts <- unlist(hexmakR:::.fonts)
  system <- fonts[names(fonts) != "jetbrains_mono"]
  expect_true(all(unname(system) %in% c("mono", "serif", "sans")))
})

test_that("specific shorthands resolve to expected base families", {
  fonts <- unlist(hexmakR:::.fonts)
  expect_identical(unname(fonts[["courier"]]), "mono")
  expect_identical(unname(fonts[["times"]]), "serif")
  expect_identical(unname(fonts[["roboto"]]), "sans")
})

# ---- Bundled JetBrains Mono -----------------------------------------------

test_that("jetbrains_mono resolves to the font files bundled for v5 names", {
  expect_identical(hexmakR:::.resolve_font("jetbrains_mono"), "JetBrains Mono")
  files <- hexmakR:::.bundled_fonts[["JetBrains Mono"]]
  expect_named(files, c("plain", "bold"))
  for (file in files) {
    expect_true(file.exists(system.file("cttir", "source", "fonts", file,
                                        package = "hexmakR")))
  }
})

test_that("the classic default font is unchanged", {
  expect_identical(formals(hex_sticker)$font_family, "mono")
  p <- hex_sticker("pkg", subtitle = "sub", url = "x.org")
  text <- Filter(function(l) inherits(l$geom, "GeomText"), p$layers)
  expect_length(text, 3L)
  expect_identical(text[[1]]$aes_params$family, "mono")
})

test_that("jetbrains_mono draws name, subtitle and url as outlines", {
  p <- hex_sticker("pkg", subtitle = "sub", url = "x.org",
                   theme = "spatial", font_family = "jetbrains_mono")
  expect_false(any(vapply(p$layers, function(l) inherits(l$geom, "GeomText"),
                          logical(1))))
  outlines <- Filter(function(l) inherits(l$geom, "GeomCustomAnn"), p$layers)
  expect_length(outlines, 3L)
  name <- outlines[[1]]$geom_params$grob
  expect_s3_class(name, "pathgrob")
  expect_identical(name$gp$fill, hexmakr_themes()$spatial$dark$text)
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  expect_no_error(print(p))
})

test_that("jetbrains_mono renders to PNG on the default device", {
  path <- withr::local_tempfile(fileext = ".png")
  hex_sticker("pkg", icon = "dna", theme = "omics",
              font_family = "jetbrains_mono", filename = path)
  img <- png::readPNG(path)
  # The white name ink appears in the lower part of the tile
  rows <- round(dim(img)[1] * c(.6, .8))
  band <- img[rows[1]:rows[2], , 1:3]
  expect_true(any(apply(band, c(1, 2), function(p) all(p > .95))))
})

test_that(".make_glyph_grob() centres outlines and handles empty labels", {
  font <- system.file("cttir", "source", "fonts", "JetBrainsMono-SemiBold.ttf",
                      package = "hexmakR")
  expect_s3_class(hexmakR:::.make_glyph_grob("", .5, .5, 12, "#000000", font),
                  "null")
  expect_s3_class(hexmakR:::.make_glyph_grob(" ", .5, .5, 12, "#000000", font),
                  "null")
  g <- hexmakR:::.make_glyph_grob("hexmakR", .5, .5, 12, "#123456", font)
  # On a 144 x 144 bigpt page, 0.5 npc lies at 72 bigpts
  grDevices::pdf(file = NULL, width = 2, height = 2)
  on.exit(grDevices::dev.off(), add = TRUE)
  x <- grid::convertX(g$x, "bigpts", valueOnly = TRUE) - 72
  y <- grid::convertY(g$y, "bigpts", valueOnly = TRUE) - 72
  expect_equal(mean(range(y)), 0, tolerance = 1e-6)
  expect_lt(abs(mean(range(x))), 1)
  slanted <- hexmakR:::.make_glyph_grob("hexmakR", .5, .5, 12, "#123456", font,
                                        italic = TRUE)
  expect_false(isTRUE(all.equal(grid::convertX(slanted$x, "bigpts", TRUE) - 72, x)))
  expect_equal(grid::convertY(slanted$y, "bigpts", TRUE) - 72, y)
})

test_that("the classic designer offers jetbrains_mono but keeps mono selected", {
  html <- as.character(hexmakR:::mod_text_ui("text"))
  expect_match(html, 'value="jetbrains_mono"', fixed = TRUE)
  expect_match(html, 'value="mono" selected', fixed = TRUE)
})
