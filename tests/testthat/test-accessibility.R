test_that("colour-vision simulations keep achromatic colours unchanged", {
  greys <- c("#000000", "#FFFFFF", "#808080", "#212121", "#FAFAFA")
  for (type in c("protan", "deutan", "tritan", "gray")) {
    simulated <- cttir_simulate_cvd(greys, type)
    # Six-decimal matrix rows sum to one within rounding: allow one 8-bit step.
    expect_lte(max(abs(grDevices::col2rgb(simulated) - grDevices::col2rgb(greys))), 1,
               label = type)
  }
})

test_that("colour-vision simulations follow Machado et al. (2009) at severity 1", {
  # A pure linear-sRGB primary returns the matching matrix column.
  column <- function(type, colour) {
    out <- grDevices::col2rgb(cttir_simulate_cvd(colour, type))[, 1] / 255
    ifelse(out <= .04045, out / 12.92, ((out + .055) / 1.055)^2.4)
  }
  expect_equal(unname(column("protan", "#00FF00")), c(1, .786281, 0), tolerance = .01)
  expect_equal(unname(column("deutan", "#FF0000")), c(.367322, .280085, 0), tolerance = .01)
  expect_equal(unname(column("tritan", "#0000FF")), c(0, .147602, .303900), tolerance = .01)
  # Red and green of equal luminance become hard to tell apart for a protan
  # observer, while the tritan simulation keeps them apart.
  distance <- function(type) {
    z <- grDevices::col2rgb(cttir_simulate_cvd(c("#D55E00", "#009E73"), type))
    sqrt(sum((z[, 1] - z[, 2])^2))
  }
  original <- sqrt(sum((grDevices::col2rgb("#D55E00") - grDevices::col2rgb("#009E73"))^2))
  expect_lt(distance("protan"), original)
  expect_gt(distance("tritan"), distance("protan"))
})

test_that("grey simulation is achromatic and vectorised", {
  out <- grDevices::col2rgb(cttir_simulate_cvd(c("#D55E00", "#0072B2", "#F0E442"), "gray"))
  expect_equal(ncol(out), 3L)
  expect_true(all(out[1, ] == out[2, ] & out[2, ] == out[3, ]))
  expect_error(cttir_simulate_cvd("#D55E00", "unknown"))
})

test_that("the cttir.vision option recolours a v5 style and leaves the mode", {
  normal <- cttir_style("spatial", "dark")
  simulated <- withr::with_options(list(cttir.vision = "deutan"),
                                   cttir_style("spatial", "dark"))
  expect_identical(simulated$mode, normal$mode)
  expect_identical(names(simulated), names(normal))
  expect_false(identical(simulated$accent, normal$accent))
  expect_true(all(grepl("^#[0-9A-F]{6}$", unlist(simulated[names(simulated) != "mode"]))))
})
