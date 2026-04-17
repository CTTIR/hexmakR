# Save a Hex Sticker as SVG

Renders and saves a hex sticker to SVG. Requires the svglite package.

## Usage

``` r
save_hex_svg(sticker, filename, width = 2)
```

## Arguments

- sticker:

  A ggplot object returned by
  [`hex_sticker()`](https://r-heller.github.io/hexmakR/reference/hex_sticker.md).

- filename:

  Character. Output file path. Must end in `.svg`.

- width:

  Numeric. Width in inches. Default `2`.

## Value

The `filename` path, invisibly.

## Details

Save a hex sticker to an SVG file

## See also

[`save_hex()`](https://r-heller.github.io/hexmakR/reference/save_hex.md),
[`hex_sticker()`](https://r-heller.github.io/hexmakR/reference/hex_sticker.md)

Other stickers:
[`hex_sticker()`](https://r-heller.github.io/hexmakR/reference/hex_sticker.md),
[`hexmakr_app()`](https://r-heller.github.io/hexmakR/reference/hexmakr_app.md),
[`save_hex()`](https://r-heller.github.io/hexmakR/reference/save_hex.md)

## Examples

``` r
# \donttest{
if (requireNamespace("svglite", quietly = TRUE)) {
  s <- hex_sticker("mypackage")
  tmp <- tempfile(fileext = ".svg")
  save_hex_svg(s, tmp)
}
# }
```
