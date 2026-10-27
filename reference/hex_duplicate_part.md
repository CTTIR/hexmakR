# Duplicate or remove an editable part

Duplicate or remove an editable part

## Usage

``` r
hex_duplicate_part(design, layer)

hex_remove_part(design, layer)
```

## Arguments

- design:

  A [`hex_design()`](hex_design.md) object.

- layer:

  Stable native or added part ID from [`hex_layers()`](hex_layers.md).

## Value

An updated design. Duplication preserves the current appearance. Removal
hides native geometry or removes an added part; retaining the old design
object permits undo.
