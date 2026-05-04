test_that("hexmakr_themes() returns a named list of length 19", {
  themes <- hexmakr_themes()
  expect_type(themes, "list")
  expect_length(themes, 19)
  expect_named(themes, c("stats", "viz", "bio", "medical", "tech", "earth",
                         "cran", "bioc", "tidy", "genomics", "proteo",
                         "pharma", "ocean", "midnight", "cyber", "neon",
                         "sunset", "viridis", "plasma"))
})

test_that("every theme has dark and light sub-lists", {
  themes <- hexmakr_themes()
  for (nm in names(themes)) {
    th <- themes[[nm]]
    expect_true("dark"  %in% names(th), info = paste(nm, "missing dark"))
    expect_true("light" %in% names(th), info = paste(nm, "missing light"))
  }
})

test_that("every mode has exactly the required color keys", {
  required <- c("bg", "accent", "text", "border", "sub")
  themes <- hexmakr_themes()
  for (nm in names(themes)) {
    for (mode in c("dark", "light")) {
      keys <- names(themes[[nm]][[mode]])
      expect_true(setequal(keys, required),
                  label = paste(nm, mode, "should have keys:", paste(required, collapse = ", ")))
    }
  }
})

test_that("all color values are valid hex strings", {
  themes <- hexmakr_themes()
  for (nm in names(themes)) {
    for (mode in c("dark", "light")) {
      for (col in themes[[nm]][[mode]]) {
        expect_true(grepl("^#[0-9A-Fa-f]{6}$", col),
                    info = paste(nm, mode, col))
      }
    }
  }
})

test_that("theme labels are non-empty strings", {
  themes <- hexmakr_themes()
  for (nm in names(themes)) {
    expect_type(themes[[nm]]$label, "character")
    expect_gt(nchar(themes[[nm]]$label), 0)
  }
})
