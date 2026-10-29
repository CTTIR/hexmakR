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

test_that("hexmakr_app() hands the app to the launcher", {
  called <- new.env()
  local_mocked_bindings(
    .run_shiny_app = function(app, ...) {
      called$app <- app
      called$args <- list(...)
      invisible(NULL)
    }
  )
  hexmakr_app(port = 1234)
  expect_s3_class(called$app, "shiny.appobj")
  expect_identical(called$args, list(port = 1234))
})


test_that("upload request size is scoped to the running v5 editor", {
  before <- getOption("shiny.maxRequestSize")
  observed <- NULL
  local_mocked_bindings(
    .run_shiny_app = function(app, ...) {
      observed <<- getOption("shiny.maxRequestSize")
      invisible(NULL)
    }
  )
  hexmakr_app()
  expect_equal(observed, 20 * 1024^2)
  expect_identical(getOption("shiny.maxRequestSize"), before)
  hexmakr_app(workspace = "classic")
  expect_identical(observed, before)
  local_mocked_bindings(.run_shiny_app = function(...) stop("launch failed"))
  expect_error(hexmakr_app(), "launch failed")
  expect_identical(getOption("shiny.maxRequestSize"), before)
})


test_that("the classic editor also uses a text-only package heading", {
  app <- hexmakR:::.build_classic_app()
  page <- app$httpHandler(list(PATH_INFO = "/", REQUEST_METHOD = "GET"))
  expect_match(page$content, '>hexmakR</h1>', fixed = TRUE)
  expect_false(grepl('<img[^>]+alt="hexmakR logo"', page$content))
})
