# Move a logo item in canvas coordinates

Move a logo item in canvas coordinates

## Usage

``` r
hex_move_layer(design, layer, dx, dy)
```

## Arguments

- design:

  A [`hex_design()`](hex_design.md) object.

- layer:

  Stable item ID from [`hex_layers()`](hex_layers.md).

- dx, dy:

  Horizontal and vertical canvas offsets between -1 and 1. Positive
  values move right and up. Native and imported viewport scales are
  accounted for; existing point edits, size and rotation are retained.

## Value

An updated design. The input is unchanged.

## Examples

``` r
d <- hex_add_part(logo_design("Project"), "circle")
d <- hex_move_layer(d, "part_0001", .1, .05)
```
