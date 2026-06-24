# Tests for the font registry in R/fonts.R

test_that("hexmakr_fonts() returns the 13 built-in shorthands", {
  fonts <- hexmakR:::hexmakr_fonts()
  expect_type(fonts, "character")
  expect_length(fonts, 13L)
  expect_true(all(c("mono", "serif", "sans") %in% names(fonts)))
})

test_that("every font maps to a base R family alias", {
  fonts <- hexmakR:::hexmakr_fonts()
  expect_true(all(unname(fonts) %in% c("mono", "serif", "sans")))
})

test_that("specific shorthands resolve to expected base families", {
  fonts <- hexmakR:::hexmakr_fonts()
  expect_identical(unname(fonts[["courier"]]), "mono")
  expect_identical(unname(fonts[["times"]]), "serif")
  expect_identical(unname(fonts[["roboto"]]), "sans")
})
