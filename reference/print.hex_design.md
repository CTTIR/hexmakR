# Draw a design on the current graphics device

The design is centred on a new page and keeps its own proportions on a
device of any shape: a hexagonal design is drawn at the standard sticker
ratio (width / height = sqrt(3) / 2), pentagonal, square and frameless
designs in a square. Line widths are scaled with the drawing, so the
picture matches the files written by
[`hex_export()`](https://cttir.github.io/hexmakR/reference/hex_export.md),
which use a six-inch master canvas.

## Usage

``` r
# S3 method for class 'hex_design'
print(x, ...)
```

## Arguments

- x:

  A
  [`hex_design()`](https://cttir.github.io/hexmakR/reference/hex_design.md)
  object.

- ...:

  Ignored.

## Value

`x`, invisibly.

## Examples

``` r
print(logo_design("My project", shape = "pentagon"))
```
