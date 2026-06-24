# Tests for internal utilities in R/utils.R

test_that(".hex_ratio() returns sqrt(3)/2", {
  expect_equal(hexmakR:::.hex_ratio(), sqrt(3) / 2)
})

test_that(".is_hex_color() validates 6- and 8-digit hex, rejects others", {
  is_hex <- hexmakR:::.is_hex_color
  expect_true(is_hex("#FF0000"))
  expect_true(is_hex("#ff00aa"))
  expect_true(is_hex("#12345678"))   # with alpha
  expect_false(is_hex("red"))
  expect_false(is_hex("#FFF"))       # too short
  expect_false(is_hex("#GGGGGG"))    # invalid chars
  expect_false(is_hex("123456"))     # missing hash
})

test_that(".check_color() returns value when valid", {
  expect_identical(hexmakR:::.check_color("#ABCDEF", "bg"), "#ABCDEF")
})

test_that(".check_color() errors with arg name when invalid", {
  expect_error(hexmakR:::.check_color("notacolor", "accent"), "accent")
})

test_that(".blend_colors() interpolates linearly in RGB", {
  blend <- hexmakR:::.blend_colors
  # 50/50 of black and white -> mid grey
  expect_identical(toupper(blend("#000000", "#FFFFFF", 0.5)), "#808080")
  # alpha = 0 returns col1, alpha = 1 returns col2
  expect_identical(toupper(blend("#102030", "#A0B0C0", 0)), "#102030")
  expect_identical(toupper(blend("#102030", "#A0B0C0", 1)), "#A0B0C0")
})

test_that(".resolve_colors() uses theme defaults when no overrides", {
  res <- hexmakR:::.resolve_colors("stats", "dark",
                                   NULL, NULL, NULL, NULL, NULL)
  expect_named(res, c("bg", "accent", "text", "border", "sub"))
  expect_identical(res$bg, hexmakR::hexmakr_themes()$stats$dark$bg)
})

test_that(".resolve_colors() applies overrides", {
  res <- hexmakR:::.resolve_colors("stats", "dark",
                                   bg = "#010203", accent = NULL,
                                   text_color = "#040506",
                                   border_color = NULL, sub_color = NULL)
  expect_identical(res$bg, "#010203")
  expect_identical(res$text, "#040506")
  # untouched ones still come from theme
  expect_identical(res$accent, hexmakR::hexmakr_themes()$stats$dark$accent)
})

test_that(".resolve_font() maps shorthand and falls back to raw name", {
  rf <- hexmakR:::.resolve_font
  expect_identical(rf("mono"), "mono")
  expect_identical(rf("fira_code"), "mono")
  expect_identical(rf("serif"), "serif")
  # unknown shorthand returns the input unchanged
  expect_identical(rf("MyCustomFont"), "MyCustomFont")
})

test_that("%||% returns left unless NULL", {
  op <- hexmakR:::`%||%`
  expect_identical(op(1, 2), 1)
  expect_identical(op(NULL, 2), 2)
})
