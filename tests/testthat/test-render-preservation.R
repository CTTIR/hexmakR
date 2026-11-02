test_that("classic image uploads preserve wide, tall and square proportions", {
  for (format in c("png", "jpg")) {
    if (format == "jpg") skip_if_not_installed("jpeg")
    for (dimensions in list(c(40L, 160L), c(160L, 40L), c(80L, 80L))) {
      input <- withr::local_tempfile(fileext = paste0(".", format))
      output <- withr::local_tempfile(fileext = ".png")
      pixels <- array(1, c(dimensions, 3L))
      pixels[, , 2] <- 0
      if (format == "png") png::writePNG(pixels, input)
      else jpeg::writeJPEG(pixels, input, quality = 1)
      save_hex(hex_sticker("Image", icon_image = input), output, width = 600)
      rendered <- png::readPNG(output)
      ink <- which(rendered[, , 1] > .9 & rendered[, , 2] < .1 &
                     rendered[, , 3] > .9 & rendered[, , 4] > .9, arr.ind = TRUE)
      expect_gt(nrow(ink), 0L)
      measured <- (diff(range(ink[, 2])) + 1) / (diff(range(ink[, 1])) + 1)
      expect_equal(measured, dimensions[2] / dimensions[1], tolerance = .04,
                   info = paste(format, paste(dimensions, collapse = "x")))
    }
  }
})

test_that("corrupt classic uploads fail instead of exporting a missing image", {
  for (extension in c("png", "jpg")) {
    input <- withr::local_tempfile(fileext = paste0(".", extension))
    writeLines("not an image", input)
    expect_error(hex_sticker("Image", icon_image = input), "Could not read image")
  }
})

test_that("classic uploads reject oversized inputs before decoding", {
  decoded <- 0L
  testthat::local_mocked_bindings(.decode_art_raster = function(...) {
    decoded <<- decoded + 1L
    stop("decoder should not run")
  })
  for (format in c("png", "jpg")) {
    input <- withr::local_tempfile(fileext = paste0(".", format))
    # This is a valid, highly compressed image, not merely a forged header.
    pixels <- matrix(0, nrow = 1, ncol = 8193)
    if (format == "png") png::writePNG(pixels, input)
    else jpeg::writeJPEG(pixels, input)
    expect_lt(file.size(input), .art_input_limit)
    expect_error(hex_sticker("Too wide", icon_image = input),
                 "Could not read image.*8192 pixels per side")
  }
  input <- withr::local_tempfile(fileext = ".png")
  png::writePNG(matrix(0, 1, 1), input)
  bytes <- readBin(input, "raw", n = file.size(input))
  # Reject a header claiming 4096 x 4096 pixels before allocating any raster.
  bytes[17:24] <- as.raw(rep(c(0, 0, 16, 0), 2))
  writeBin(bytes, input)
  expect_error(hex_sticker("Too many pixels", icon_image = input),
               "Could not read image.*16 million pixels")
  large <- withr::local_tempfile(fileext = ".png")
  connection <- file(large, "wb")
  seek(connection, .art_input_limit, origin = "start")
  writeBin(as.raw(0), connection)
  close(connection)
  expect_error(hex_sticker("Too many bytes", icon_image = large),
               "Could not read image.*10 MiB")
  expect_identical(decoded, 0L)
})

test_that("classic draw failures preserve previous PNG and SVG exports", {
  bad <- hex_sticker("Broken") +
    ggplot2::geom_point(ggplot2::aes(x = missing_column, y = 1), data = data.frame(value = 1))
  for (extension in c("png", "svg")) {
    if (extension == "svg") skip_if_not_installed("svglite")
    path <- withr::local_tempfile(fileext = paste0(".", extension))
    export <- if (extension == "png") save_hex else save_hex_svg
    export(hex_sticker("Previous"), path)
    previous <- readBin(path, "raw", n = file.size(path))
    devices <- grDevices::dev.list()
    expect_error(export(bad, path), "missing_column")
    expect_identical(readBin(path, "raw", n = file.size(path)), previous)
    expect_identical(grDevices::dev.list(), devices)
    export(hex_sticker("Replacement"), path)
    expect_false(identical(readBin(path, "raw", n = file.size(path)), previous))
  }
})

test_that("native device draw failures preserve previous output and devices", {
  skip_without_cairo()
  design <- logo_design("Previous")
  directory <- withr::local_tempdir()
  paths <- file.path(directory, paste0("sticker.", c("png", "svg", "pdf")))
  for (path in paths) hex_export(design, path, width = 100)
  previous <- lapply(paths, function(path) readBin(path, "raw", n = file.size(path)))
  # Complete geometry capture, then fail at the external draw boundary on the
  # newly opened device. This also avoids injecting invalid C-level grid units.
  grob <- hex_grob(design)
  testthat::local_mocked_bindings(hex_grob = function(...) grob)
  drawn_devices <- integer()
  testthat::local_mocked_bindings(grid.draw = function(...) {
    drawn_devices <<- c(drawn_devices, grDevices::dev.cur())
    stop("device draw failed")
  }, .package = "grid")
  devices <- grDevices::dev.list()
  for (i in seq_along(paths)) {
    expect_error(hex_export(design, paths[i], width = 100), "device draw failed")
    expect_identical(readBin(paths[i], "raw", n = file.size(paths[i])), previous[[i]])
    expect_identical(grDevices::dev.list(), devices)
  }
  expect_length(drawn_devices, 3L)
  expect_true(all(!drawn_devices %in% c(1L, devices)))
  expect_length(list.files(directory, pattern = "^\\.hexmakR-stage-", all.files = TRUE), 0L)
})

test_that("successful and failed exports restore the selected user device", {
  skip_without_cairo()
  grDevices::pdf(NULL); first <- grDevices::dev.cur()
  grDevices::pdf(NULL); second <- grDevices::dev.cur()
  on.exit({ grDevices::dev.off(second); grDevices::dev.off(first) }, add = TRUE)
  existing <- grDevices::dev.list()
  for (format in c("png", "svg", "pdf")) {
    hex_export(logo_design("Selection"), withr::local_tempfile(fileext = paste0(".", format)), 100)
    expect_identical(grDevices::dev.cur(), second)
    expect_identical(grDevices::dev.list(), existing)
  }
  bad <- hex_sticker("Broken") +
    ggplot2::geom_point(ggplot2::aes(x = missing_column, y = 1), data = data.frame(value = 1))
  path <- withr::local_tempfile(fileext = ".png")
  save_hex(hex_sticker("Selection"), path)
  expect_identical(grDevices::dev.cur(), second)
  expect_error(save_hex(bad, path), "missing_column")
  expect_identical(grDevices::dev.cur(), second)
  expect_identical(grDevices::dev.list(), existing)
})

test_that("a failed final rename preserves exports, projects, recipes and assets", {
  skip_without_cairo()
  directory <- withr::local_tempdir()
  design <- logo_design("Previous")
  asset_dir <- file.path(directory, "assets")
  asset <- hex_asset("hexmakR", format = "svg", dir = asset_dir)
  previous_asset <- readBin(asset, "raw", n = file.size(asset))
  Sys.setFileTime(asset, Sys.time() - 60)
  # Inject only the filesystem's last rename, after a real render/write.
  writer <- .write_output
  injected <- new.env(parent = environment(writer))
  injected$file.rename <- function(...) FALSE
  environment(writer) <- injected
  testthat::local_mocked_bindings(.write_output = writer)
  for (extension in c("png", "svg", "pdf", "json", "R")) {
    path <- file.path(directory, paste0("previous.", extension))
    writeBin(charToRaw("previous completed output"), path)
    previous <- readBin(path, "raw", n = file.size(path))
    export <- switch(extension, json = hex_save_design, R = hex_recipe, hex_export)
    expect_error(export(design, path), "previous file was preserved")
    expect_identical(readBin(path, "raw", n = file.size(path)), previous)
  }
  expect_error(hex_asset("hexmakR", format = "svg", dir = asset_dir),
               "previous file was preserved")
  expect_identical(readBin(asset, "raw", n = file.size(asset)), previous_asset)
  expect_length(list.files(directory, pattern = "^\\.hexmakR-stage-", all.files = TRUE,
                            recursive = TRUE), 0L)
  stamp <- file.path(asset_dir, ".hexmakR-version")
  writeLines("previous package version", stamp)
  expect_error(hex_asset("hexmakR", format = "svg", dir = asset_dir),
               "previous file was preserved")
  expect_identical(readLines(stamp), "previous package version")
  expect_identical(readBin(asset, "raw", n = file.size(asset)), previous_asset)
})

test_that("bundled names reject unrenderable characters and impossible fits", {
  missing <- intToUtf8(c(0x7814, 0x7a76))
  expect_error(hex_grob(logo_design(missing)), "cannot render: U\\+7814, U\\+7A76")
  expect_error(hex_sticker(missing, font_family = "jetbrains_mono"), "cannot render")
  expect_error(hex_grob(logo_design(strrep("W", 100))), "does not fit inside the frame")
  for (shape in c("hex", "pentagon", "square")) {
    expect_error(hex_grob(logo_design("Edge", shape = shape, label_y = 0)),
                 "does not fit inside the frame")
    expect_no_error(hex_grob(logo_design("Supported", shape = shape)))
  }
  for (name in hex_catalog()$name) expect_no_error(hex_grob(hex_design(name)))
})
