# Locate an original approved v5 asset

These files are the unchanged supplied masters. Use
[`hex_export()`](https://cttir.github.io/hexmakR/dev/reference/hex_export.md)
to regenerate artwork or export an edited design.

## Usage

``` r
hex_asset(
  package,
  mode = c("dark", "light", "mono"),
  layout = c("lockup", "hex", "icon"),
  format = c("svg", "png", "pdf"),
  size = 128L
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

## Value

An absolute file path.

## Examples

``` r
hex_asset("phenoscapR")
#> [1] "/home/runner/work/_temp/Library/hexmakR/cttir/logos/phenoscapR/lockup-dark.svg"
```
