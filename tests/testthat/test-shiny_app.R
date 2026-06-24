# Tests for the app assembly in R/shiny_app.R

test_that(".build_shiny_app() returns a shiny app object with ui + server", {
  app <- hexmakR:::.build_shiny_app()
  expect_s3_class(app, "shiny.appobj")
  expect_true(is.function(app$serverFuncSource()))
})

test_that(".shiny_logo_svg() embeds the SVG when the logo file exists", {
  html <- hexmakR:::.shiny_logo_svg()
  expect_type(html, "character")
  # Package ships inst/logo/logo.svg, so an <svg> should be embedded
  expect_match(html, "svg|hexmakR")
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
