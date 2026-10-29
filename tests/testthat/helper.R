# Load package before tests (for devtools::test() workflow)
# When running via R CMD check this is handled automatically.

# WCAG 2 contrast ratio, as used by the v5 review in inst/cttir/source.
contrast_ratio <- function(a, b) {
  luminance <- function(hex) {
    x <- grDevices::col2rgb(hex) / 255
    x <- ifelse(x <= .04045, x / 12.92, ((x + .055) / 1.055)^2.4)
    sum(x * c(.2126, .7152, .0722))
  }
  z <- sort(c(luminance(a), luminance(b)))
  (z[2] + .05) / (z[1] + .05)
}

# hex_export() and hex_render_catalog() need R with Cairo support.
skip_without_cairo <- function() skip_if_not(capabilities("cairo"), "R without Cairo support")
