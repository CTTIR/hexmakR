# Tests for the Shiny modules in R/shiny_modules.R

test_that("all module UI functions return shiny tags", {
  expect_s3_class(hexmakR:::mod_text_ui("text"), "shiny.tag")
  expect_s3_class(hexmakR:::mod_icon_ui("icon"), "shiny.tag")
  expect_s3_class(hexmakR:::mod_theme_ui("theme"), "shiny.tag")
  expect_s3_class(hexmakR:::mod_colors_ui("colors"), "shiny.tag")
  expect_s3_class(hexmakR:::mod_border_ui("border"), "shiny.tag")
})

test_that("mod_text_server() returns reactive values; empty -> NULL", {
  shiny::testServer(hexmakR:::mod_text_server, {
    session$setInputs(name = "mypkg", subtitle = "", url = "",
                      font_family = "mono", font_bold = TRUE,
                      font_italic = FALSE, font_size = 12)
    out <- session$getReturned()()
    expect_identical(out$name, "mypkg")
    expect_null(out$subtitle)
    expect_null(out$url)
    expect_identical(out$font_family, "mono")

    session$setInputs(subtitle = "Sub", url = "x.org")
    out2 <- session$getReturned()()
    expect_identical(out2$subtitle, "Sub")
    expect_identical(out2$url, "x.org")
  })
})

test_that("mod_icon_server() returns NULL icon when '(none)' selected", {
  shiny::testServer(hexmakR:::mod_icon_server, {
    session$setInputs(icon = "", icon_size = 1.0)
    out <- session$getReturned()()
    expect_null(out$icon)
    expect_equal(out$icon_size, 1.0)

    session$setInputs(icon = "atom")
    out2 <- session$getReturned()()
    expect_identical(out2$icon, "atom")
  })
})

test_that("mod_theme_server() returns theme and mode", {
  shiny::testServer(hexmakR:::mod_theme_server, {
    session$setInputs(theme = "genomics", mode = "light")
    out <- session$getReturned()()
    expect_identical(out$theme, "genomics")
    expect_identical(out$mode, "light")
  })
})

test_that("the colour fields are bound Shiny inputs", {
  colour_fields <- c("bg", "accent", "text_color", "border_color", "sub_color")
  bound <- function(html, class) {
    for (field in colour_fields) {
      input <- regmatches(html, regexpr(
        sprintf('<input id="colors-%s"[^>]*>', field), html))
      expect_length(input, 1)
      expect_match(input, class, fixed = TRUE)
    }
    expect_false(grepl('type="color"', html, fixed = TRUE))
  }
  if (requireNamespace("colourpicker", quietly = TRUE)) {
    bound(as.character(hexmakR:::mod_colors_ui("colors")), "shiny-colour-input")
  }
  local_mocked_bindings(.has_colourpicker = function() FALSE)
  html <- as.character(hexmakR:::mod_colors_ui("colors"))
  bound(html, "shiny-input-text")
  bg <- regmatches(html, regexpr('<input id="colors-bg"[^>]*>', html))
  expect_match(bg, 'value="#1B2838"', fixed = TRUE)
})

test_that("mod_colors_server() passes only colours that differ from the theme", {
  theme <- shiny::reactiveVal(list(theme = "stats", mode = "dark"))
  shiny::testServer(hexmakR:::mod_colors_server, args = list(theme = theme), {
    # What a sticker drawn from the module receives at each update.
    seen <- list()
    shiny::observe(seen[[length(seen) + 1L]] <<- session$getReturned()())
    # The browser starts with the stats colours in the fields.
    stats <- hexmakr_themes()$stats$dark
    session$setInputs(bg = stats$bg, accent = stats$accent, text_color = stats$text,
                      border_color = stats$border, sub_color = stats$sub)
    session$setInputs(bg = "#1b2838", accent = "#111111",
                      text_color = "#FFFFFF", border_color = "#00D4AA",
                      sub_color = "#444444")
    out <- session$getReturned()()
    expect_null(out$bg)
    expect_identical(out$accent, "#111111")
    expect_null(out$text_color)
    expect_null(out$border_color)
    expect_identical(out$sub_color, "#444444")
    session$setInputs(accent = "#12")
    expect_null(session$getReturned()()$accent)
    # Until the browser shows the genomics colours, the fields still hold the
    # stats colours. They are frozen meanwhile, so the sticker is not drawn
    # with those as overrides; it is drawn once the new colours arrive, and
    # then nothing is overridden.
    before <- length(seen)
    theme(list(theme = "genomics", mode = "dark"))
    session$flushReact()
    expect_length(seen, before)
    genomics <- hexmakr_themes()$genomics$dark
    session$setInputs(bg = genomics$bg, accent = genomics$accent,
                      text_color = genomics$text, border_color = genomics$border,
                      sub_color = genomics$sub)
    expect_length(seen, before + 1L)
    expect_true(all(vapply(seen[[before + 1L]], is.null, logical(1))))
    expect_true(all(vapply(session$getReturned()(), is.null, logical(1))))
  })
})

test_that("a theme change shows that theme's colours in the fields", {
  updates <- list()
  local_mocked_bindings(.update_colour_input = function(session, inputId, value) {
    updates[[inputId]] <<- value
  })
  theme <- shiny::reactiveVal(list(theme = "stats", mode = "dark"))
  stats <- hexmakr_themes()$stats$dark
  shiny::testServer(hexmakR:::mod_colors_server, args = list(theme = theme), {
    # Fields that already show the theme's colours are left alone.
    session$setInputs(bg = stats$bg, accent = stats$accent, text_color = stats$text,
                      border_color = stats$border, sub_color = stats$sub)
    expect_length(updates, 0)
    theme(list(theme = "genomics", mode = "light"))
    session$flushReact()
  })
  expected <- hexmakr_themes()$genomics$light
  expect_identical(updates, list(bg = expected$bg, accent = expected$accent,
    text_color = expected$text, border_color = expected$border,
    sub_color = expected$sub))
})

test_that("mod_border_server() returns width and inner_border flag", {
  shiny::testServer(hexmakR:::mod_border_server, {
    session$setInputs(border_width = 3, inner_border = FALSE)
    out <- session$getReturned()()
    expect_equal(out$border_width, 3)
    expect_false(out$inner_border)
  })
})

test_that("the classic theme picker lists the CTTIR v5 families first", {
  html <- as.character(hexmakR:::mod_theme_ui("theme"))
  v5 <- regexpr('<optgroup label="CTTIR v5">', html, fixed = TRUE)
  classic <- regexpr('<optgroup label="Classic">', html, fixed = TRUE)
  expect_gt(v5, 0)
  expect_gt(classic, v5)
  expect_gt(regexpr('value="spatial"', html, fixed = TRUE), v5)
  expect_lt(regexpr('value="spatial"', html, fixed = TRUE), classic)
  expect_gt(regexpr('value="stats" selected', html, fixed = TRUE), classic)
  expect_match(html, "Spatial biology", fixed = TRUE)
})
