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
if (FALSE) { # \dontrun{
hex_render_catalog("exports")
} # }
```
