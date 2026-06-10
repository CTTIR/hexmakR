# Save a Hex Sticker

Renders and saves a hex sticker ggplot object to a PNG file with a
transparent background and the correct hexb.in aspect ratio (width /
height = sqrt(3) / 2).

## Usage

``` r
save_hex(sticker, filename, width = 600, dpi = 300)
```

## Arguments

- sticker:

  A ggplot object returned by
  [`hex_sticker()`](https://cttir.github.io/hexmakR/reference/hex_sticker.md).

- filename:

  Character. Output file path. Must end in `.png`.

- width:

  Integer. Width in pixels. Default `600`.

- dpi:

  Numeric. Resolution. Default `300`.

## Value

The `filename` path, invisibly.

## Details

Save a hex sticker to a PNG file

## See also

[`hex_sticker()`](https://cttir.github.io/hexmakR/reference/hex_sticker.md)

Other stickers:
[`hex_sticker()`](https://cttir.github.io/hexmakR/reference/hex_sticker.md),
[`hexmakr_app()`](https://cttir.github.io/hexmakR/reference/hexmakr_app.md),
[`save_hex_svg()`](https://cttir.github.io/hexmakR/reference/save_hex_svg.md)

## Examples

``` r
# \donttest{
s <- hex_sticker("mypackage", icon = "atom", theme = "stats")
tmp <- tempfile(fileext = ".png")
save_hex(s, tmp)
file.exists(tmp)
#> [1] TRUE
# }
```
