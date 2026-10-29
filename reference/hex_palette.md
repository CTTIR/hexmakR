# Inspect a design's palette roles

Inspect a design's palette roles

## Usage

``` r
hex_palette(design)
```

## Arguments

- design:

  A
  [`hex_design()`](https://cttir.github.io/hexmakR/reference/hex_design.md)
  object.

## Value

A named list of colours.

## Examples

``` r
hex_palette(hex_design("phenoscapR", "light"))
#> $accent
#> [1] "#009E73"
#> 
#> $material
#> [1] "#009E73"
#> 
#> $face
#> [1] "#D7EDE7"
#> 
#> $facet
#> [1] "#D7EDE7"
#> 
#> $facet2
#> [1] "#D7EDE7"
#> 
#> $rim
#> [1] "#009E73"
#> 
#> $ink
#> [1] "#212121"
#> 
#> $muted
#> [1] "#212121"
#> 
#> $paper
#> [1] "#F4F8FC"
#> 
#> $light
#> [1] "#B2E1D5"
#> 
#> $mid
#> [1] "#38B391"
#> 
#> $deep
#> [1] "#0C4E4B"
#> 
#> $edge
#> [1] "#0A6356"
#> 
#> $shadow
#> [1] "#030A12"
#> 
```
