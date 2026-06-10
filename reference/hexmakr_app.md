# Launch Interactive Hex Sticker Designer

Opens an interactive Shiny app for designing hex stickers visually. The
app provides live preview, theme selection, icon picking, custom color
overrides, and PNG export.

## Usage

``` r
hexmakr_app(...)
```

## Arguments

- ...:

  Additional arguments passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html).

## Value

Does not return; runs the Shiny app.

## Details

Launch the hexmakR Shiny App

## See also

[`hex_sticker()`](https://cttir.github.io/hexmakR/reference/hex_sticker.md),
[`save_hex()`](https://cttir.github.io/hexmakR/reference/save_hex.md)

Other stickers:
[`hex_sticker()`](https://cttir.github.io/hexmakR/reference/hex_sticker.md),
[`save_hex()`](https://cttir.github.io/hexmakR/reference/save_hex.md),
[`save_hex_svg()`](https://cttir.github.io/hexmakR/reference/save_hex_svg.md)

## Examples

``` r
if (interactive()) {
  hexmakr_app()
}
```
