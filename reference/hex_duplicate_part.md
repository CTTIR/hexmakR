# Duplicate or remove an editable part

Duplicate or remove an editable part

## Usage

``` r
hex_duplicate_part(design, layer)

hex_remove_part(design, layer)
```

## Arguments

- design:

  A
  [`hex_design()`](https://cttir.github.io/hexmakR/reference/hex_design.md)
  object.

- layer:

  Stable native or added part ID from
  [`hex_layers()`](https://cttir.github.io/hexmakR/reference/hex_layers.md).

## Value

An updated design. Duplication preserves the current appearance. Removal
hides native geometry or removes an added part; retaining the old design
object permits undo.

## Examples

``` r
d <- hex_add_part(logo_design("New project"), "circle")
d <- hex_duplicate_part(d, "part_0001")
d <- hex_remove_part(d, "part_0001")
hex_layers(d)
#>           id     type    fill     col points  role   name visible
#> 1 layer_0001  polygon #191919 #000000      6 frame  Frame    TRUE
#> 2 layer_0002 pathgrob #FFFFFF    <NA>   1260  name   Name    TRUE
#> 3  part_0002   circle #009E73 #FFFFFF      1 added Circle    TRUE
```
