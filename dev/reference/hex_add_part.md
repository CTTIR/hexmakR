# Add an editable primitive to a logo

Add an editable primitive to a logo

## Usage

``` r
hex_add_part(
  design,
  type = c("circle", "rectangle", "line", "polygon"),
  ...,
  fill = "#009E73",
  col = "#FFFFFF",
  lwd = 1,
  alpha = 1
)
```

## Arguments

- design:

  A
  [`hex_design()`](https://cttir.github.io/hexmakR/dev/reference/hex_design.md)
  object.

- type:

  `circle`, `rectangle`, `line`, or `polygon`.

- ...:

  Primitive geometry in normalised canvas coordinates: `x`, `y`, and `r`
  for circles; `x`, `y`, `width`, `height` for rectangles; numeric `x`
  and `y` vectors for lines and polygons. Sensible centred defaults
  apply.

- fill, col:

  Fill and outline colours, including `"transparent"`.

- lwd:

  Outline width in points on the master canvas.

- alpha:

  Opacity between zero and one.

## Value

An updated design with a new stable `part_` ID. The input is unchanged.

## Examples

``` r
d <- logo_design("New project")
d <- hex_add_part(d, "circle", x = .5, y = .6, r = .15)
hex_layers(d)
#>           id     type    fill     col points  role   name visible
#> 1 layer_0001  polygon #191919 #000000      6 frame  Frame    TRUE
#> 2 layer_0002 pathgrob #FFFFFF    <NA>   1260  name   Name    TRUE
#> 3  part_0001   circle #009E73 #FFFFFF      1 added Circle    TRUE
```
