# Render a design to native grid geometry

Render a design to native grid geometry

## Usage

``` r
hex_grob(design)
```

## Arguments

- design:

  A
  [`hex_design()`](https://cttir.github.io/hexmakR/dev/reference/hex_design.md)
  object.

## Value

A grid gTree with stable, editable child layer names.

## Examples

``` r
g <- hex_grob(logo_design("My project"))
names(g$children)
#> [1] "layer_0001" "layer_0002"
```
