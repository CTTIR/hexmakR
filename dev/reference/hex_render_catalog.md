# Regenerate the v5 catalogue

Regenerate the v5 catalogue

## Usage

``` r
hex_render_catalog(
  directory,
  packages = hex_catalog()$name,
  modes = c("light", "dark", "mono"),
  layouts = c("lockup", "hex"),
  formats = c("svg", "png", "pdf"),
  width = 1600L,
  icons = TRUE
)
```

## Arguments

- directory:

  Destination directory; one subdirectory per identity.

- packages:

  Exact identities to render. Defaults to the entire catalogue.

- modes:

  Colour modes to export.

- layouts:

  Master layouts to export.

- formats:

  File formats to export.

- width:

  Master PNG width in pixels.

- icons:

  Also create five square dark icons per identity.

## Value

A data frame of generated file paths and identities, invisibly.

## Examples

``` r
if (capabilities("cairo")) {
  files <- hex_render_catalog(tempfile(), packages = "hexmakR",
                              formats = "svg", icons = FALSE)
  basename(files$path)
}
#> [1] "lockup.svg"      "hex.svg"         "lockup-dark.svg" "hex-dark.svg"   
#> [5] "lockup-mono.svg" "hex-mono.svg"   
```
