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

test_that("a theme switch redraws the classic sticker once, without the old colours", {
  skip_without_cairo()
  real <- hex_sticker
  drawn <- list()
  local_mocked_bindings(hex_sticker = function(...) {
    args <- list(...)
    colours <- args[c("bg", "accent", "text_color", "border_color", "sub_color")]
    drawn[[length(drawn) + 1L]] <<- list(theme = args$theme,
                                         overrides = Filter(Negate(is.null), colours))
    real(...)
  })
  stats <- hexmakr_themes()$stats$dark
  genomics <- hexmakr_themes()$genomics$dark
  shiny::testServer(hexmakR:::.build_classic_app(), {
    session$setInputs(`text-name` = "demo", `text-subtitle` = "", `text-url` = "",
      `text-font_family` = "mono", `text-font_bold` = TRUE, `text-font_italic` = FALSE,
      `text-font_size` = 12, `icon-icon` = "atom", `icon-icon_size` = 1,
      `theme-theme` = "stats", `theme-mode` = "dark",
      `colors-bg` = stats$bg, `colors-accent` = stats$accent,
      `colors-text_color` = stats$text, `colors-border_color` = stats$border,
      `colors-sub_color` = stats$sub, `border-border_width` = 2,
      `border-inner_border` = TRUE)
    expect_length(drawn, 1)
    # Nothing is drawn until the browser shows the genomics colours ...
    session$setInputs(`theme-theme` = "genomics")
    expect_length(drawn, 1)
    # ... and sends back the fields that changed (the text stays white).
    session$setInputs(`colors-bg` = genomics$bg, `colors-accent` = genomics$accent,
                      `colors-border_color` = genomics$border,
                      `colors-sub_color` = genomics$sub)
  })
  expect_length(drawn, 2)
  expect_identical(drawn[[2]]$theme, "genomics")
  expect_length(drawn[[2]]$overrides, 0)
})
