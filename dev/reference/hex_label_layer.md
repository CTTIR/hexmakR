# Label an editable logo item

Label an editable logo item

## Usage

``` r
hex_label_layer(design, layer, label)
```

## Arguments

- design:

  A
  [`hex_design()`](https://cttir.github.io/hexmakR/dev/reference/hex_design.md)
  object.

- layer:

  Stable item ID from
  [`hex_layers()`](https://cttir.github.io/hexmakR/dev/reference/hex_layers.md).

- label:

  Short item name, at most 80 characters.

## Value

An updated design. Labels survive project saves and duplication.

## Examples

``` r
d <- hex_label_layer(hex_design("phenoscapR"), "layer_0001", "Border")
```
