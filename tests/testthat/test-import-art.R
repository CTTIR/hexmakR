art_svg <- function(body, attributes = 'viewBox="0 0 100 100"') {
  path <- tempfile(fileext = ".svg")
  writeLines(paste0('<svg xmlns="http://www.w3.org/2000/svg" ', attributes, '>', body, '</svg>'), path)
  path
}

art_png <- function() {
  path <- tempfile(fileext = ".png")
  pixels <- array(0, dim = c(2, 3, 4))
  pixels[, , 1] <- 1; pixels[, , 4] <- .5; pixels[1, 1, 4] <- 0
  png::writePNG(pixels, path)
  path
}

test_that("raster imports are portable, bounded and independently editable", {
  source <- art_png(); on.exit(unlink(source))
  original <- logo_design("A figure")
  d <- hex_import_art(original, source)
  expect_length(original$parts, 0)
  expect_length(d$parts, 1)
  expect_identical(d$parts[[1]]$type, "raster")
  expect_identical(d$parts[[1]]$mime, "image/png")
  expect_equal(c(d$parts[[1]]$pixel_width, d$parts[[1]]$pixel_height), c(3, 2))
  expect_false(source %in% unlist(d))
  expect_false(any(grepl("\\n", d$parts[[1]]$data)))
  d <- hex_edit_layer(d, "part_0001", dx = .05, scale = .8, angle = 35, alpha = .5)
  d <- hex_duplicate_part(d, "part_0001")
  expect_equal(d$parts[[1]], d$parts[[2]])
  file <- tempfile(fileext = ".json"); on.exit(unlink(file), add = TRUE)
  hex_save_design(d, file); unlink(source)
  restored <- hex_read_design(file)
  expect_equal(restored, d)
  expect_s3_class(hex_grob(restored), "gTree")
  output <- tempfile(fileext = ".png"); on.exit(unlink(output), add = TRUE)
  hex_export(restored, output, width = 160)
  expect_gt(file.info(output)$size, 500)
  expect_length(hex_remove_part(restored, "part_0001")$parts, 1)
})

test_that("JPEG import detects content without depending on a filename extension", {
  path <- tempfile(); on.exit(unlink(path))
  jpeg::writeJPEG(array(c(1, 0, 0), dim = c(1, 1, 3)), path)
  d <- hex_import_art(logo_design("JPEG"), path)
  expect_identical(d$parts[[1]]$mime, "image/jpeg")
  expect_equal(d$parts[[1]]$pixel_width, 1)
  expect_s3_class(hex_grob(d), "gTree")
})

test_that("SVG shapes and curves remain separate portable vector components", {
  source <- art_svg(paste0(
    '<g transform="translate(2 3) rotate(5 50 50)">',
    '<rect id="panel" x="10" y="10" width="30" height="20" rx="3" fill="#0a8"/>',
    '<circle id="cell" cx="65" cy="30" r="10" fill="rgb(100,120,200)"/>',
    '<path id="curve" d="M10 60 c10 -30 20 30 30 0 s20 30 30 0 Q80 40 90 60 T90 80 A10 15 30 0 1 70 80" fill="none" stroke="black"/>',
    '<path id="ring" d="M10 10H90V90H10Z M30 30V70H70V30Z" fill-rule="evenodd" fill="orange"/>',
    '</g>'))
  on.exit(unlink(source))
  d <- hex_import_art(logo_design("Vectors"), source)
  expect_length(d$parts, 4)
  expect_equal(vapply(d$parts, `[[`, character(1), "name"), c("panel", "cell", "curve", "ring"), ignore_attr = TRUE)
  expect_true(all(vapply(d$parts, function(p) p$type == "svg_path", logical(1))))
  expect_equal(d$parts[[3]]$closed, 0)
  expect_equal(d$parts[[4]]$closed, c(1, 1))
  expect_identical(d$parts[[4]]$rule, "evenodd")
  d <- hex_edit_layer(d, "part_0001", fill = "red", angle = 20, alpha = .7)
  project <- tempfile(fileext = ".json"); on.exit(unlink(project), add = TRUE)
  hex_save_design(d, project); unlink(source)
  expect_equal(hex_read_design(project), d)
  svg <- tempfile(fileext = ".svg"); pdf <- tempfile(fileext = ".pdf")
  on.exit(unlink(c(svg, pdf)), add = TRUE)
  hex_export(d, svg); hex_export(d, pdf)
  text <- paste(readLines(svg), collapse = "\n")
  expect_match(text, "<path")
  expect_false(grepl("<image", text, fixed = TRUE))
  pdf_bytes <- readBin(pdf, "raw", file.info(pdf)$size)
  pdf_ascii <- paste(rawToChar(pdf_bytes, multiple = TRUE), collapse = "")
  expect_false(grepl("/Subtype /Image", pdf_ascii, fixed = TRUE, useBytes = TRUE))
})

test_that("SVG transforms, fill holes and open strokes retain their semantics", {
  transformed <- .svg_transform("translate(10 20) scale(2) rotate(90)") %*% c(1, 0, 1)
  expect_equal(as.numeric(transformed), c(10, 22, 1), tolerance = 1e-10)
  curve <- .svg_path("M0 0 L10 0 M20 0 l0 10 z")
  expect_equal(curve$id, c(1, 1, 2, 2))
  expect_equal(curve$closed, c(0, 1))
  arc <- .svg_arc(c(0, 0), c(20, 0), 10, 10, 0, 0, 1)
  expect_equal(as.numeric(arc[nrow(arc), ]), c(20, 0))
  expect_gt(nrow(arc), 32)
  source <- art_svg('<path d="M10 10H90V90H10Z M30 30H70V70H30Z" fill="red" fill-rule="evenodd"/>')
  on.exit(unlink(source))
  d <- hex_import_art(logo_design("", layout = "motif"), source)
  output <- tempfile(fileext = ".png"); on.exit(unlink(output), add = TRUE)
  hex_export(d, output, width = 200)
  pixels <- png::readPNG(output)
  expect_equal(pixels[80, 100, 4], 0)
  expect_gt(pixels[80, 55, 4], .9)
})

test_that("raster and vector opacity apply once and retain original raster transparency", {
  source <- art_png(); on.exit(unlink(source))
  d <- hex_import_art(logo_design("", layout = "motif"), source)
  d <- hex_edit_layer(d, "part_0001", alpha = .5)
  output <- tempfile(fileext = ".png"); on.exit(unlink(output), add = TRUE)
  hex_export(d, output, width = 200)
  pixels <- png::readPNG(output)
  expect_equal(max(pixels[, , 4]), 64 / 255, tolerance = 1 / 255)
  source2 <- art_svg('<rect x="10" y="10" width="80" height="80" fill="red" opacity="0.5"/>')
  on.exit(unlink(source2), add = TRUE)
  d2 <- hex_import_art(logo_design("", layout = "motif"), source2)
  hex_export(d2, output, width = 200)
  pixels <- png::readPNG(output)
  expect_equal(max(pixels[, , 4]), .5, tolerance = .005)
})

test_that("unsafe or unsupported SVG is rejected without changing the design", {
  original <- logo_design("Safe")
  bad <- c('<script>alert(1)</script>', '<circle r="10" onclick="evil()"/>',
    '<image href="file:///etc/passwd"/>', '<use href="#a"/>',
    '<path d="M0 0L1 1" fill="url(http://example.invalid/a)"/>',
    '<foreignObject/>', '<style>path {fill: red}</style>', '<text>Outline me</text>',
    '<defs><linearGradient id="a"/></defs>', '<g opacity="0.5"><circle r="10"/></g>',
    '<circle r="10" transform="scale(2 1)" stroke="black"/>',
    '<svg viewBox="0 0 10 10"><circle r="1"/></svg>')
  for (body in bad) {
    path <- art_svg(body)
    expect_error(hex_import_art(original, path), "SVG")
    unlink(path)
  }
  file <- tempfile(fileext = ".svg"); on.exit(unlink(file))
  writeLines('<!DOCTYPE svg [<!ENTITY x SYSTEM "file:///etc/passwd">]><svg viewBox="0 0 1 1">&x;</svg>', file)
  expect_error(hex_import_art(original, file), "declarations")
  writeLines('<?xml-stylesheet href="https://example.invalid/a"?><svg viewBox="0 0 1 1"/>', file)
  expect_error(hex_import_art(original, file), "processing")
  expect_length(original$parts, 0)
})

test_that("invalid embedded data and resource bounds fail before rendering", {
  source <- art_png(); on.exit(unlink(source))
  d <- hex_import_art(logo_design("Safe"), source)
  bad <- d; bad$parts[[1]]$data <- "file:///tmp/test.png"
  expect_error(hex_grob(bad), "embedded image")
  bad <- d; bad$parts[[1]]$mime <- "image/svg+xml"
  expect_error(hex_grob(bad), "Only PNG and JPEG")
  bad <- d; bad$parts[[1]]$pixel_width <- 99999
  expect_error(hex_grob(bad), "8192")
  raw <- readBin(source, "raw", file.info(source)$size)
  raw[17:20] <- as.raw(c(0, 1, 0, 0))
  large <- tempfile(); on.exit(unlink(large), add = TRUE)
  writeBin(raw, large)
  expect_error(hex_import_art(logo_design("Safe"), large), "8192")
  local_mocked_bindings(.design_json_limit = function() 100)
  expect_error(hex_import_art(logo_design("Safe"), source), "project limit")
})

test_that("local references and redundant clips support ordinary Cairo SVG exports", {
  source <- tempfile(fileext = ".svg"); on.exit(unlink(source))
  hex_export(hex_add_part(logo_design("Own"), "circle"), source)
  imported <- hex_import_art(logo_design("Import"), source)
  expect_gte(length(imported$parts), 3)
  expect_true(all(vapply(imported$parts, function(p) p$type == "svg_path", logical(1))))
  canonical <- hex_import_art(logo_design("Canonical"), hex_asset("hexmakR", "light", "lockup", "svg"))
  expect_gt(length(canonical$parts), 10)
  expect_true(all(vapply(canonical$parts, function(p) p$type == "svg_path", logical(1))))
  expect_equal(.svg_color("rgb(100%,0%,50%)"), "#FF0080FF")
  source2 <- art_svg('<defs><g id="a"><use href="#a"/></g></defs><use href="#a"/>')
  on.exit(unlink(source2), add = TRUE)
  expect_error(hex_import_art(logo_design("Cycle"), source2), "Cyclic SVG")
  source3 <- art_svg('<defs><clipPath id="clip"><rect x="25" y="25" width="50" height="50"/></clipPath></defs><circle cx="50" cy="50" r="40" clip-path="url(#clip)"/>')
  on.exit(unlink(source3), add = TRUE)
  expect_error(hex_import_art(logo_design("Clip"), source3), "clipping intersects")
  source4 <- art_svg('<circle cx="0.5" cy="0.5" r="0.3"/>', 'viewBox="0 0 1 1"')
  on.exit(unlink(source4), add = TRUE)
  expect_length(hex_import_art(logo_design("Tiny units"), source4)$parts, 1)
})

test_that("aggregate image budgets prevent compressed project expansion", {
  source <- art_png(); on.exit(unlink(source))
  d <- hex_import_art(logo_design("Bounded"), source)
  local_mocked_bindings(.art_project_pixel_limit = function() 10)
  expect_error(hex_duplicate_part(d, "part_0001"), "raster pixels in total")
  expect_length(d$parts, 1)
})

test_that("acyclic empty references cannot expand without a traversal budget", {
  source <- art_svg(paste0('<defs><g id="a"/><g id="b"><use href="#a"/><use href="#a"/></g>',
    '<g id="c"><use href="#b"/><use href="#b"/></g></defs><use href="#c"/>'))
  on.exit(unlink(source))
  local_mocked_bindings(.art_svg_visit_limit = function() 8L)
  expect_error(hex_import_art(logo_design("Bounded"), source), "reference expansion")
})

test_that("generated R recipes restore embedded uploads without source files", {
  source <- art_png(); on.exit(unlink(source))
  d <- hex_import_art(logo_design("Recipe"), source)
  directory <- tempfile(); dir.create(directory)
  on.exit(unlink(directory, recursive = TRUE), add = TRUE)
  recipe <- file.path(directory, "recipe.R")
  hex_recipe(d, recipe); unlink(source)
  withr::local_dir(directory)
  grDevices::pdf(file.path(directory, "preview.pdf"))
  on.exit(grDevices::dev.off(), add = TRUE)
  env <- new.env(parent = globalenv())
  sys.source(recipe, envir = env)
  expect_equal(env$design, d)
  expect_true(all(file.exists(c("sticker.svg", "sticker.png"))))
})
