test_that("offscreen rendering preserves the user's graphics devices", {
  devices <- grDevices::dev.list()
  current <- grDevices::dev.cur()
  hex_grob(hex_design("phenoscapR"))
  expect_identical(grDevices::dev.list(), devices)
  expect_identical(grDevices::dev.cur(), current)
})

master_stem <- function(mode, layout) paste0(layout, if (mode == "light") "" else paste0("-", mode))

test_that("all 45 identities have their 270 unchanged SVG masters", {
  registry <- hex_catalog()
  expect_equal(nrow(registry), 45)
  expect_equal(anyDuplicated(registry$name), 0)
  expect_setequal(hex_catalog("spectral")$family, "spectral")
  files <- character()
  for (name in registry$name) for (mode in c("dark", "light", "mono")) for (layout in c("lockup", "hex")) {
    f <- hex_asset(name, mode, layout, "svg")
    expect_identical(basename(f), paste0(master_stem(mode, layout), ".svg"))
    files <- c(files, f)
  }
  expect_length(files, 270)
  expect_equal(length(unique(tolower(files))), 270)
  expect_false(identical(readBin(hex_asset("CTTIR"), "raw", 1e6), readBin(hex_asset("cttiR"), "raw", 1e6)))
  expect_true(all(file.exists(files)))
  expect_error(hex_asset("../escape"), "Unknown")
  expect_error(hex_asset("phenoscapR", layout = "icon"), "Original icons")
  expect_error(hex_asset("phenoscapR", format = "png", dir = NA_character_), "dir")
})

test_that("PNG and PDF masters are rendered on demand under the master file names", {
  skip_if_not_installed("rsvg")
  dir <- withr::local_tempdir()
  for (name in c("phenoscapR", "CTTIR")) for (mode in c("dark", "light", "mono"))
    for (layout in c("lockup", "hex")) {
      asset_dir <- hex_catalog()$asset_dir[hex_catalog()$name == name]
      stem <- master_stem(mode, layout)
      pdf <- hex_asset(name, mode, layout, "pdf", dir = dir)
      expect_identical(pdf, normalizePath(file.path(dir, asset_dir, paste0(stem, ".pdf")), winslash = "/"))
      expect_identical(readBin(pdf, "raw", 5), charToRaw("%PDF-"))
      if (name != "phenoscapR") next
      png <- hex_asset(name, mode, layout, "png", dir = dir)
      expect_identical(png, normalizePath(file.path(dir, asset_dir, paste0(stem, ".png")), winslash = "/"))
      expect_equal(dim(png::readPNG(png)), c(1848, 1600, 4))
    }
  expect_length(list.files(dir, recursive = TRUE), 18)
  # Renders are reused, and a render older than the installed master is redone.
  png <- hex_asset("phenoscapR", format = "png", dir = dir)
  first <- file.mtime(png)
  expect_identical(hex_asset("phenoscapR", format = "png", dir = dir), png)
  expect_equal(file.mtime(png), first)
  Sys.setFileTime(png, as.POSIXct("2000-01-01", tz = "UTC"))
  hex_asset("phenoscapR", format = "png", dir = dir)
  expect_gt(file.mtime(png), as.POSIXct("2000-01-02", tz = "UTC"))
  expect_equal(dim(png::readPNG(png)), c(1848, 1600, 4))
  default <- hex_asset("hexmakR", "light", "hex", "pdf")
  expect_true(startsWith(default, normalizePath(tempdir(), winslash = "/")))
})

test_that("icons are drawn on demand under the master file names", {
  skip_without_cairo()
  dir <- withr::local_tempdir()
  for (size in c(32, 48, 64, 128, 256)) {
    f <- hex_asset("CTTIR", layout = "icon", format = "png", size = size, dir = dir)
    expect_identical(f, normalizePath(file.path(dir, "CTTIR-brand", paste0("icon-", size, ".png")), winslash = "/"))
    expect_equal(dim(png::readPNG(f)), c(size, size, 4))
  }
})

test_that("both branding-script forms return a file for every identity", {
  skip_on_cran()
  skip_if_not_installed("rsvg")
  skip_without_cairo()
  dir <- withr::local_tempdir()
  for (name in hex_catalog()$name) {
    for (mode in c("light", "dark", "mono")) for (layout in c("hex", "lockup")) {
      formats <- if (mode == "dark" && layout == "lockup") c("svg", "png", "pdf") else c("svg", "pdf")
      for (format in formats) {
        f <- hex_asset(name, mode, layout, format, dir = dir)
        expect_true(file.exists(f))
        expect_identical(basename(f), paste0(master_stem(mode, layout), ".", format))
      }
    }
    for (size in c(32L, 48L, 64L, 128L, 256L)) {
      f <- hex_asset(name, layout = "icon", format = "png", size = size, dir = dir)
      expect_true(file.exists(f))
      expect_identical(basename(f), paste0("icon-", size, ".png"))
    }
  }
})

test_that("all identities and modes produce distinct native vector layers", {
  before <- ls(globalenv(), all.names = TRUE)
  wd <- getwd()
  for (name in hex_catalog()$name) for (mode in c("dark", "light", "mono")) {
    d <- hex_design(name, mode)
    g <- hex_grob(d)
    expect_s3_class(g, "gTree")
    expect_gt(length(g$children), 5)
    expect_false(any(vapply(g$children, inherits, logical(1), "rastergrob")))
    expect_identical(class(g$children[[length(g$children)]])[1], "pathgrob")
  }
  expect_identical(getwd(), wd)
  expect_identical(ls(globalenv(), all.names = TRUE), before)
})

test_that("the packaged renderer reproduces the geometry of the shipped masters", {
  skip_on_cran() # SVG number formatting depends on the cairo version
  skip_without_cairo()
  paths <- function(file) {
    txt <- paste(readLines(file, warn = FALSE), collapse = "\n")
    unique(regmatches(txt, gregexpr(' d="[^"]+"', txt))[[1]])
  }
  for (name in c("phenoscapR", "hyperloom", "CTTIR")) for (mode in c("dark", "light", "mono")) {
    f <- tempfile(fileext = ".svg"); on.exit(unlink(f), add = TRUE)
    hex_export(hex_design(name, mode, "hex"), f)
    master <- paths(hex_asset(name, mode, "hex", "svg"))
    expect_gt(length(master), 5)
    expect_true(all(master %in% paths(f)), info = paste(name, mode))
  }
})

test_that("layer edits change only intended geometry and roundtrip through JSON", {
  original <- hex_design("phenoscapR")
  d <- hex_edit_layer(original, "layer_0005", fill = "#FF0000", dx = .05, scale = 1.1)
  g <- hex_grob(d)
  expect_identical(g$children[[5]]$gp$fill, "#FF0000")
  expect_equal(as.numeric(g$children[[5]]$x),
    .5 + (as.numeric(hex_grob(original)$children[[5]]$x) - .5) * 1.1 + .05)
  expect_length(original$layers, 0)
  expect_length(d$layers, 1)
  f <- tempfile(fileext = ".json"); on.exit(unlink(f))
  hex_save_design(d, f)
  expect_equal(hex_read_design(f), d)
  expect_equal(hex_layers(hex_read_design(f)), hex_layers(d))
  expect_length(hex_edit_layer(d, "layer_0005", reset = TRUE)$layers, 0)
  expect_error(hex_edit_layer(d, "layer_9999", fill = "red"), "Unknown layer")
  expect_error(hex_edit_layer(d, "layer_0005", x = 1), "Coordinate count")
  expect_error(hex_edit_layer(d, "layer_0005", fill = "notacolour"), "Invalid colour")
  expect_error(hex_edit_layer(d, "layer_0005", alpha = 2), "between")
})

test_that("malformed and executable project payloads are rejected", {
  f <- tempfile(); on.exit(unlink(f))
  d <- unclass(hex_design("hexmakR"))
  d$code <- "stop('do not evaluate')"
  jsonlite::write_json(d, f, auto_unbox = TRUE)
  expect_error(hex_read_design(f), "Invalid design fields")
  d$code <- NULL; d$schema <- "unknown"
  jsonlite::write_json(d, f, auto_unbox = TRUE)
  expect_error(hex_read_design(f), "schema")
  d$schema <- "hexmakR/v5-design/1"; d$layers <- list(layer_0001 = list(x = list("system('x')")))
  jsonlite::write_json(d, f, auto_unbox = TRUE)
  expect_error(hex_read_design(f), "coordinate|Coordinates")
  expect_error(hex_design("hexmakR", motif_scale = Inf), "finite")
  expect_error(hex_design("hexmakR", colors = list(not_a_role = "red")), "colour fields")
})

test_that("PNG and vector exports preserve transparency and canvas geometry", {
  skip_without_cairo()
  d <- hex_design("phenoscapR")
  f <- tempfile(fileext = ".png"); on.exit(unlink(f), add = TRUE)
  hex_export(d, f, 400)
  pixels <- png::readPNG(f)
  expect_equal(dim(pixels), c(462, 400, 4))
  expect_equal(pixels[1, 1, 4], 0)
  expect_equal(pixels[462, 400, 4], 0)
  expect_equal(pixels[231, 200, 4], 1)
  for (ext in c("svg", "pdf")) {
    p <- tempfile(fileext = paste0(".", ext)); on.exit(unlink(p), add = TRUE)
    hex_export(d, p)
    expect_gt(file.info(p)$size, 1000)
    if (ext == "svg") {
      txt <- paste(readLines(p), collapse = "\n")
      expect_false(grepl("<image|<script|<text", txt))
      expect_match(txt, "<path")
    }
  }
  motif <- tempfile(fileext = ".png"); on.exit(unlink(motif), add = TRUE)
  hex_export(hex_design("phenoscapR", layout = "motif"), motif, 128)
  expect_equal(dim(png::readPNG(motif)), c(128, 128, 4))
  before <- grDevices::dev.cur()
  expect_error(hex_export(d, tempfile(fileext = ".bad")), "filename")
  expect_identical(grDevices::dev.cur(), before)
})

test_that("batch generation supplies both layouts, all modes and small icons", {
  skip_without_cairo()
  out <- tempfile(); on.exit(unlink(out, recursive = TRUE))
  files <- hex_render_catalog(out, packages = "hexmakR", width = 128)
  expect_equal(nrow(files), 23)
  expect_true(all(file.exists(files$path)))
  expect_equal(dim(png::readPNG(file.path(out, "hexmakR", "icon-32.png"))), c(32, 32, 4))
})

test_that("editor applies edits, undo, reset and safe project loading", {
  server <- hexmakR:::.cttir_editor_server
  formals(server)$package <- "phenoscapR"
  shiny::testServer(server, {
    session$setInputs(identity = "phenoscapR", archive_load = 1)
    session$setInputs(mode = "dark", layout = "lockup", label = "phenoscapR",
      role = "face", layer = "layer_0005", highlight = FALSE)
    session$setInputs(fill = "red", stroke = "", dx = .05, dy = 0, scale = 1,
      lwd = 1, alpha = 1, visible = TRUE, coords_x = "", coords_y = "", apply_layer = 1)
    expect_equal(current()$layers$layer_0005$fill, "red")
    expect_null(error())
    session$setInputs(undo = 1)
    expect_length(current()$layers, 0)
    session$setInputs(role_color = "invalid", apply_color = 1)
    expect_match(error(), "Invalid colour")
    expect_length(current()$colors, 0)
    session$setInputs(role_color = "#112233", apply_color = 2)
    expect_equal(current()$colors$face, "#112233")
    session$setInputs(reset = 1)
    expect_length(current()$colors, 0)
    f <- tempfile(fileext = ".json"); on.exit(unlink(f), add = TRUE)
    d <- hex_design("scimapR", "light", label = "My science")
    hex_save_design(d, f)
    session$setInputs(project = data.frame(datapath = f))
    expect_equal(current(), d)
    expect_null(error())
  })
})

test_that("project logos support regular pentagonal and square frames", {
  skip_without_cairo()
  for (shape in c("hex", "pentagon", "square")) {
    d <- logo_design("My project", "phenoscapR", shape)
    g <- hex_grob(d)
    expect_equal(length(g$children[[1]]$x), switch(shape, hex = 6, pentagon = 5, square = 4))
    expect_identical(d$label, "My project")
    f <- tempfile(fileext = ".png"); on.exit(unlink(f), add = TRUE)
    hex_export(d, f, width = 200)
    expect_equal(dim(png::readPNG(f))[1:2], c(if (shape == "hex") 231 else 200, 200))
    j <- tempfile(); on.exit(unlink(j), add = TRUE)
    hex_save_design(d, j)
    expect_equal(hex_read_design(j), d)
  }
  d <- logo_design("Study", shape = "square", icon = "microscope")
  expect_gt(nrow(hex_layers(d)), 3)
  expect_error(logo_design("Study", icon = "not-an-icon"), "Unknown icon")
})

test_that("all generic icons are reusable and editable in project logos", {
  for (group in hexmakr_icons()) for (icon in names(group)) {
    g <- hex_grob(logo_design("Study", shape = "square", icon = icon))
    expect_gt(length(g$children), 2)
  }
})
