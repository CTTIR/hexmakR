v5_families <- c("spectral", "spatial", "omics", "clinical", "methods",
                 "simulation", "evidence", "platform", "brand")
classic_themes <- c("stats", "viz", "bio", "medical", "tech", "earth",
                    "cran", "bioc", "tidy", "genomics", "proteo",
                    "pharma", "ocean", "midnight", "cyber", "neon",
                    "sunset", "viridis", "plasma")

test_that("hexmakr_themes() returns a named list of length 28", {
  themes <- hexmakr_themes()
  expect_type(themes, "list")
  expect_length(themes, 28)
  expect_named(themes, c(v5_families, classic_themes))
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

test_that("hexmakr_preview_theme() returns a ggplot invisibly", {
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  p <- hexmakr_preview_theme("stats")
  expect_s3_class(p, "gg")
})

test_that("hexmakr_preview_theme() honors the mode argument", {
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  expect_no_error(hexmakr_preview_theme("genomics", mode = "light"))
})

test_that("hexmakr_preview_theme() errors on an unknown theme", {
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  expect_error(hexmakr_preview_theme("nonexistent"), "Unknown theme")
})

# ---- CTTIR v5 families -----------------------------------------------------

test_that("the nine CTTIR v5 families come first with the v5 labels", {
  themes <- hexmakr_themes()
  engine <- hexmakR:::.cttir_engine()
  expect_identical(names(themes)[1:9], v5_families)
  expect_identical(names(themes)[1:9], names(engine$cttir_accents))
  for (family in v5_families) {
    expect_identical(themes[[family]]$label,
                     engine$cttir_family_labels[[family]], info = family)
    expect_identical(themes[[family]]$group, "CTTIR v5", info = family)
  }
  expect_identical(themes$spatial$label, "Spatial biology")
  expect_identical(themes$methods$label, "Learning & inference")
  expect_identical(themes$brand$label, "Science, connected")
})

test_that("v5 theme colours equal the engine's style in both modes", {
  themes <- hexmakr_themes()
  engine <- hexmakR:::.cttir_engine()
  for (family in v5_families) {
    for (mode in c("dark", "light")) {
      s <- engine$cttir_style(family, mode)
      expect_identical(
        themes[[family]][[mode]],
        list(bg = s$face, accent = if (mode == "light") s$edge else s$mid,
             text = s$ink, border = s$rim, sub = s$muted),
        info = paste(family, mode)
      )
    }
  }
})

test_that("v5 themes follow the bundled design tokens", {
  tokens <- utils::read.csv(system.file("cttir", "design_tokens.csv",
                                        package = "hexmakR"),
                            stringsAsFactors = FALSE)
  token <- function(group, name) tokens$value[tokens$group == group &
                                                tokens$token == name]
  themes <- hexmakr_themes()
  for (family in v5_families) {
    # The rim is the family colour; icons use the v5 motif shades
    expect_identical(themes[[family]]$dark$border, token("topic", family))
    expect_identical(themes[[family]]$light$border, token("topic", family))
    expect_identical(themes[[family]]$dark$text, token("dark", "heading"))
    expect_identical(themes[[family]]$dark$sub, token("dark", "text"))
    expect_identical(themes[[family]]$light$text, token("light", "heading"))
    expect_identical(themes[[family]]$light$sub, token("light", "text"))
  }
  expect_identical(themes$spatial$dark$accent, "#38B391")
  expect_identical(themes$spatial$light$accent, "#0A6356")
  expect_identical(themes$evidence$light$accent, "#82863E")
  expect_identical(themes$platform$dark$accent, "#A7BCCB")
  expect_identical(themes$platform$dark$border, "#000000")
  expect_identical(themes$spatial$dark$bg, "#193F34")
  expect_identical(themes$spatial$light$bg, "#D7EDE7")
})

test_that("v5 text reaches WCAG AA and icons 3:1 on the tile", {
  themes <- hexmakr_themes()
  for (family in v5_families) {
    for (mode in c("dark", "light")) {
      th <- themes[[family]][[mode]]
      expect_gte(contrast_ratio(th$text, th$bg), 4.5)
      expect_gte(contrast_ratio(th$sub, th$bg), 4.5)
      expect_gte(contrast_ratio(th$accent, th$bg), 3)
    }
  }
})

test_that("the 19 generic themes are unchanged", {
  pinned <- list(
    stats    = c("#1B2838 #00D4AA #FFFFFF #00D4AA #8EC8B8",
                 "#F8FFFE #0D9373 #1A2E35 #0D9373 #4BA68E"),
    viz      = c("#0F0A2E #FF6B6B #FFFFFF #FF6B6B #FFB4B4",
                 "#FFFFFF #E15759 #2D2D2D #E15759 #9C1D22"),
    bio      = c("#0A1628 #4FC3F7 #FFFFFF #4FC3F7 #A8DFF7",
                 "#F0F9FF #0284C7 #0C4A6E #0284C7 #38BDF8"),
    medical  = c("#0F1923 #EF5350 #FFFFFF #EF5350 #EF9A9A",
                 "#FFF5F5 #DC2626 #450A0A #DC2626 #F87171"),
    tech     = c("#0D0D0D #00FF41 #FFFFFF #00FF41 #66FF87",
                 "#F5F5F5 #16A34A #1A1A1A #16A34A #4ADE80"),
    earth    = c("#0A1A0F #4CAF50 #FFFFFF #4CAF50 #81C784",
                 "#F0FDF4 #15803D #14532D #15803D #22C55E"),
    cran     = c("#1A1A2E #2266BB #FFFFFF #2266BB #6699DD",
                 "#FFFFFF #2266BB #1A1A2E #2266BB #6688BB"),
    bioc     = c("#0F1A12 #87B13F #FFFFFF #87B13F #A8D060",
                 "#F0F4F8 #87B13F #2D3748 #87B13F #5A7A28"),
    tidy     = c("#1A1433 #4E79A7 #FFFFFF #4E79A7 #76B7B2",
                 "#F8F9FA #4E79A7 #2D3748 #4E79A7 #76B7B2"),
    genomics = c("#0D1520 #29B6F6 #FFFFFF #29B6F6 #81D4FA",
                 "#EFF6FF #2563EB #1E3A5F #2563EB #60A5FA"),
    proteo   = c("#1A0F2E #CE93D8 #FFFFFF #CE93D8 #E8C8EE",
                 "#FDF4FF #A855F7 #3B0764 #A855F7 #C084FC"),
    pharma   = c("#0E1A2B #42A5F5 #FFFFFF #42A5F5 #90CAF9",
                 "#EFF6FF #2563EB #1E3A5F #2563EB #93C5FD"),
    ocean    = c("#03111A #00BCD4 #FFFFFF #00BCD4 #4DD0E1",
                 "#F0FDFF #0E7490 #164E63 #0E7490 #06B6D4"),
    midnight = c("#0D0D0D #FFD700 #FAFAFA #FFD700 #CCAA00",
                 "#FAFAF9 #A16207 #1C1917 #A16207 #D97706"),
    cyber    = c("#0A0E17 #00E5FF #FFFFFF #00E5FF #18FFFF",
                 "#ECFEFF #0891B2 #164E63 #0891B2 #22D3EE"),
    neon     = c("#0A0A0A #00FF87 #FFFFFF #00FF87 #66FFB3",
                 "#F0FFF4 #059669 #064E3B #059669 #34D399"),
    sunset   = c("#1A0D1E #FF6F00 #FFFFFF #FF8F00 #FFB74D",
                 "#FFFBEB #D97706 #451A03 #EA580C #F59E0B"),
    viridis  = c("#0B0C2A #21918C #FFFFFF #5DC863 #FDE725",
                 "#F0FDF9 #0D9488 #134E4A #16A34A #65A30D"),
    plasma   = c("#140024 #F0F921 #FFFFFF #CC4778 #F89540",
                 "#FFF7FC #DB2777 #4A1042 #9333EA #E879F9")
  )
  roles <- c("bg", "accent", "text", "border", "sub")
  themes <- hexmakr_themes()
  expect_identical(names(themes)[-(1:9)], names(pinned))
  for (nm in names(pinned)) {
    expect_named(themes[[nm]], c("label", "dark", "light"))
    for (i in 1:2) {
      expected <- as.list(strsplit(pinned[[nm]][i], " ")[[1]])
      names(expected) <- roles
      expect_identical(themes[[nm]][[c("dark", "light")[i]]], expected,
                       info = nm)
    }
  }
  expect_identical(themes$stats$label, "Statistics")
  expect_identical(themes[classic_themes], hexmakR:::.themes)
})

test_that("the classic defaults stay on the stats theme in dark mode", {
  expect_identical(formals(hex_sticker)$theme, "stats")
  expect_identical(formals(hex_sticker)$mode, "dark")
  expect_identical(formals(hexmakr_preview_theme)$theme, "stats")
  expect_identical(formals(hexmakr_preview_theme)$mode, "dark")
})

test_that("hexmakr_preview_theme() previews a v5 family", {
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  p <- hexmakr_preview_theme("clinical", mode = "light")
  expect_s3_class(p, "gg")
})
