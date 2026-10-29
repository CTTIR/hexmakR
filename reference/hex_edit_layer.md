# Edit one vector layer

Edit one vector layer

## Usage

``` r
hex_edit_layer(design, layer, ..., reset = FALSE)
```

## Arguments

- design:

  A
  [`hex_design()`](https://cttir.github.io/hexmakR/reference/hex_design.md)
  object.

- layer:

  A stable layer ID from
  [`hex_layers()`](https://cttir.github.io/hexmakR/reference/hex_layers.md).

- ...:

  Edits: `fill`, `col`, `lwd`, `alpha`, `dx`, `dy`, `scale`, `angle`,
  `visible`, or explicit numeric `x`/`y` coordinates in the layer's
  local viewport. `angle` rotates a part around its centre in degrees,
  from -180 to 180.

- reset:

  Remove earlier edits to this layer before applying new values.

## Value

An updated design. The input is unchanged.

## Examples

``` r
d <- hex_design("phenoscapR")
hex_edit_layer(d, "layer_0001", fill = "#193E36")
```
