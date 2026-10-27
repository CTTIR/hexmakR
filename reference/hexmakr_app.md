# Launch Interactive Hex Sticker Designer

Opens an interactive Shiny app for designing hex stickers visually. The
default v5 workspace offers 45 CTTIR identities, hexagonal, pentagonal
and square frames, individual vector-layer editing, portable projects,
and PNG/SVG/PDF export. The classic designer remains available.

## Usage

``` r
hexmakr_app(workspace = c("v5", "classic"), package = "hexmakR", ...)
```

## Arguments

- workspace:

  Use the CTTIR `v5` editor (default) or the `classic` designer.

- package:

  Initial v5 identity.

- ...:

  Additional arguments passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html).

## Value

Does not return; runs the Shiny app.

## Details

Launch the hexmakR Shiny App

## See also

[`hex_sticker()`](hex_sticker.md), [`save_hex()`](save_hex.md)

Other stickers: [`hex_sticker()`](hex_sticker.md),
[`save_hex()`](save_hex.md), [`save_hex_svg()`](save_hex_svg.md)

## Examples

``` r
if (interactive()) {
  hexmakr_app()
}
```
