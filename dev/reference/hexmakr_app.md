# Launch Interactive Hex Sticker Designer

Opens an interactive Shiny app for designing hex stickers visually. The
default workspace starts a new editable logo with a hexagonal,
pentagonal or square frame. Add, duplicate, remove and edit individual
parts; optionally reuse artwork from the secondary CTTIR Gallery.
Portable projects, R recipes and PNG/SVG/PDF export preserve the current
design. The classic designer remains available.

## Usage

``` r
hexmakr_app(workspace = c("v5", "classic"), package = "hexmakR", ...)
```

## Arguments

- workspace:

  Use the new-logo `v5` editor (default) or `classic` designer.

- package:

  Initially selected CTTIR Gallery identity. The editable logo still
  starts as a new project until a gallery action is chosen.

- ...:

  Additional arguments passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html).

## Value

Does not return; runs the Shiny app.

## Details

Launch the hexmakR Shiny App

## See also

[`hex_sticker()`](https://cttir.github.io/hexmakR/dev/reference/hex_sticker.md),
[`save_hex()`](https://cttir.github.io/hexmakR/dev/reference/save_hex.md)

Other stickers:
[`hex_sticker()`](https://cttir.github.io/hexmakR/dev/reference/hex_sticker.md),
[`save_hex()`](https://cttir.github.io/hexmakR/dev/reference/save_hex.md),
[`save_hex_svg()`](https://cttir.github.io/hexmakR/dev/reference/save_hex_svg.md)

## Examples

``` r
if (interactive()) {
  hexmakr_app()
}
```
