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

test_that("mod_colors_server() passes through all five colors", {
  shiny::testServer(hexmakR:::mod_colors_server, {
    session$setInputs(bg = "#000000", accent = "#111111",
                      text_color = "#222222", border_color = "#333333",
                      sub_color = "#444444")
    out <- session$getReturned()()
    expect_identical(out$bg, "#000000")
    expect_identical(out$accent, "#111111")
    expect_identical(out$sub_color, "#444444")
  })
})

test_that("mod_border_server() returns width and inner_border flag", {
  shiny::testServer(hexmakR:::mod_border_server, {
    session$setInputs(border_width = 3, inner_border = FALSE)
    out <- session$getReturned()()
    expect_equal(out$border_width, 3)
    expect_false(out$inner_border)
  })
})
