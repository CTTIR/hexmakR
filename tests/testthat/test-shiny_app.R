# Tests for the app assembly in R/shiny_app.R

test_that(".build_shiny_app() returns a shiny app object with ui + server", {
  app <- hexmakR:::.build_shiny_app()
  expect_s3_class(app, "shiny.appobj")
  expect_true(is.function(app$serverFuncSource()))
  page <- app$httpHandler(list(PATH_INFO = "/", REQUEST_METHOD = "GET"))
  brand <- regmatches(page$content, regexpr(
    '(?s)<(?:span|a)[^>]*class="navbar-brand"[^>]*>.*?</(?:span|a)>', page$content, perl = TRUE
  ))
  expect_identical(trimws(gsub("<[^>]+>", "", brand)), "hexmakR")
  expect_false(grepl("<img", brand, fixed = TRUE))
  expect_match(page$content, "<title>hexmakR</title>", fixed = TRUE)
  expect_match(page$content, "CTTIR Gallery", fixed = TRUE)
  expect_match(page$content, 'id="art_upload"', fixed = TRUE)
  expect_match(page$content, 'id="mouse_target"', fixed = TRUE)
})

test_that(".shiny_logo_svg() embeds the SVG when the logo file exists", {
  logo_path <- system.file("logo", "logo.svg", package = "hexmakR")
  expect_true(file.exists(logo_path))
  local_mocked_bindings(
    system.file = function(...) logo_path, .package = "base"
  )
  html <- hexmakR:::.shiny_logo_svg()
  expect_type(html, "character")
  # Package ships inst/logo/logo.svg, so an <svg> should be embedded
  expect_match(html, "svg|hexmakR")
  expect_match(html, '<svg style="width:80px;height:93px;max-width:100%;"',
               fixed = TRUE)
})

test_that(".shiny_logo_svg() falls back to a heading when logo is absent", {
  # Force system.file() to return "" so the fallback branch is taken
  local_mocked_bindings(
    system.file = function(...) "",
    .package = "base"
  )
  html <- hexmakR:::.shiny_logo_svg()
  expect_match(html, "hexmakR")
})

test_that("hexmakr_app() forwards to shiny::runApp()", {
  called <- new.env()
  local_mocked_bindings(
    runApp = function(appDir, ...) {
      called$hit <- TRUE
      invisible(NULL)
    },
    .package = "shiny"
  )
  hexmakr_app()
  expect_true(isTRUE(called$hit))
})


test_that("upload request size is scoped to the running v5 editor", {
  before <- getOption("shiny.maxRequestSize")
  observed <- NULL
  local_mocked_bindings(
    runApp = function(appDir, ...) {
      observed <<- getOption("shiny.maxRequestSize")
      invisible(NULL)
    }, .package = "shiny"
  )
  hexmakr_app()
  expect_equal(observed, 20 * 1024^2)
  expect_identical(getOption("shiny.maxRequestSize"), before)
  hexmakr_app(workspace = "classic")
  expect_identical(observed, before)
  local_mocked_bindings(runApp = function(...) stop("launch failed"), .package = "shiny")
  expect_error(hexmakr_app(), "launch failed")
  expect_identical(getOption("shiny.maxRequestSize"), before)
})


test_that("the classic editor also uses a text-only package heading", {
  app <- hexmakR:::.build_classic_app()
  page <- app$httpHandler(list(PATH_INFO = "/", REQUEST_METHOD = "GET"))
  expect_match(page$content, '>hexmakR</h1>', fixed = TRUE)
  expect_false(grepl('<img[^>]+alt="hexmakR logo"', page$content))
})
