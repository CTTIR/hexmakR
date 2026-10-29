# Locate an original approved v5 asset

The 270 SVG and 270 PDF files are the unchanged supplied masters. They
are installed in one compressed archive, which is unpacked once per
session, and an SVG or PDF request returns a copy with the master's
exact bytes. PNG versions are rendered from the SVG master on demand
with the 'rsvg' package, at the size of the supplied masters (1600 x
1848 pixels). Icons are drawn by the package renderer, which needs R
with Cairo support. All files keep the master's file name and are
written to `dir/<asset_dir>/`, where `asset_dir` comes from
[`hex_catalog()`](https://cttir.github.io/hexmakR/dev/reference/hex_catalog.md),
and are reused while the hexmakR version and build stay the same. A
stamp file, `dir/.hexmakR-version`, names the version and build that
wrote them; after an upgrade or a reinstall, each file is copied or
rendered again on its next request. Use
[`hex_export()`](https://cttir.github.io/hexmakR/dev/reference/hex_export.md)
to regenerate artwork or export an edited design.

## Usage

``` r
hex_asset(
  package,
  mode = c("dark", "light", "mono"),
  layout = c("lockup", "hex", "icon"),
  format = c("svg", "png", "pdf"),
  size = 128L,
  dir = NULL
)
```

## Arguments

- package:

  Exact identity from
  [`hex_catalog()`](https://cttir.github.io/hexmakR/dev/reference/hex_catalog.md).

- mode:

  One of `dark`, `light`, `mono`.

- layout:

  `lockup` (name inside), `hex` (artwork only), or `icon`.

- format:

  File format: `svg`, `png`, or `pdf`.

- size:

  Icon width, one of 32, 48, 64, 128, 256. Icons use dark mode.

- dir:

  Directory for the SVG and PDF copies and the rendered PNG and icon
  files. The default is a folder in
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html), so nothing is
  kept after the session. To keep files between sessions, pass a
  directory of your choice, for example
  `tools::R_user_dir("hexmakR", "cache")`.

## Value

An absolute file path in `dir`: the copy of the SVG or PDF master, or
the rendered PNG or icon.

## Examples

``` r
hex_asset("phenoscapR")
#> [1] "/tmp/RtmpSEeEmd/hexmakR-assets/phenoscapR/lockup-dark.svg"
if (requireNamespace("rsvg", quietly = TRUE)) {
  png <- hex_asset("phenoscapR", format = "png", dir = tempfile())
  dim(png::readPNG(png))
}
#> [1] 1848 1600    4
if (capabilities("cairo")) {
  hex_asset("phenoscapR", layout = "icon", format = "png", size = 64,
            dir = tempfile())
}
#> [1] "/tmp/RtmpSEeEmd/file1a4733d47511/phenoscapR/icon-64.png"
```
