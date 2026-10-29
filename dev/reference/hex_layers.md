# Inspect editable vector layers

Inspect editable vector layers

## Usage

``` r
hex_layers(design)
```

## Arguments

- design:

  A
  [`hex_design()`](https://cttir.github.io/hexmakR/dev/reference/hex_design.md)
  object.

## Value

A data frame with stable IDs, geometry type and current colour roles.

## Examples

``` r
hex_layers(hex_design("phenoscapR"))
#>            id     type      fill       col points  role           name visible
#> 1  layer_0001  polygon   #193F34   #009E73      6 frame          Frame    TRUE
#> 2  layer_0002    lines   #0C4E4B   #0C4E4B      7 motif    Icon Line 1    TRUE
#> 3  layer_0003    lines   #B2E1D5   #B2E1D5      2 motif    Icon Line 2    TRUE
#> 4  layer_0004  polygon #030A1240      <NA>     90 motif   Icon Shape 1    TRUE
#> 5  layer_0005  polygon   #38B391      <NA>     90 motif   Icon Shape 2    TRUE
#> 6  layer_0006    lines #F4F8FC99 #F4F8FC99     80 motif    Icon Line 3    TRUE
#> 7  layer_0007   circle   #0C4E4B      <NA>      1 motif  Icon Circle 1    TRUE
#> 8  layer_0008   circle   #F4F8FC      <NA>      1 motif  Icon Circle 2    TRUE
#> 9  layer_0009    lines   #B2E1D5   #B2E1D5      2 motif    Icon Line 4    TRUE
#> 10 layer_0010  polygon #030A1240      <NA>     90 motif   Icon Shape 3    TRUE
#> 11 layer_0011  polygon   #B2E1D5      <NA>     90 motif   Icon Shape 4    TRUE
#> 12 layer_0012    lines #F4F8FC99 #F4F8FC99     80 motif    Icon Line 5    TRUE
#> 13 layer_0013   circle   #0C4E4B      <NA>      1 motif  Icon Circle 3    TRUE
#> 14 layer_0014   circle   #F4F8FC      <NA>      1 motif  Icon Circle 4    TRUE
#> 15 layer_0015    lines   #B2E1D5   #B2E1D5      2 motif    Icon Line 6    TRUE
#> 16 layer_0016  polygon #030A1240      <NA>     90 motif   Icon Shape 5    TRUE
#> 17 layer_0017  polygon   #38B391      <NA>     90 motif   Icon Shape 6    TRUE
#> 18 layer_0018    lines #F4F8FC99 #F4F8FC99     80 motif    Icon Line 7    TRUE
#> 19 layer_0019   circle   #0C4E4B      <NA>      1 motif  Icon Circle 5    TRUE
#> 20 layer_0020   circle   #F4F8FC      <NA>      1 motif  Icon Circle 6    TRUE
#> 21 layer_0021    lines   #B2E1D5   #B2E1D5      2 motif    Icon Line 8    TRUE
#> 22 layer_0022  polygon #030A1240      <NA>     90 motif   Icon Shape 7    TRUE
#> 23 layer_0023  polygon   #0C4E4B      <NA>     90 motif   Icon Shape 8    TRUE
#> 24 layer_0024    lines #F4F8FC99 #F4F8FC99     80 motif    Icon Line 9    TRUE
#> 25 layer_0025   circle   #0C4E4B      <NA>      1 motif  Icon Circle 7    TRUE
#> 26 layer_0026   circle   #F4F8FC      <NA>      1 motif  Icon Circle 8    TRUE
#> 27 layer_0027    lines   #B2E1D5   #B2E1D5      2 motif   Icon Line 10    TRUE
#> 28 layer_0028  polygon #030A1240      <NA>     90 motif   Icon Shape 9    TRUE
#> 29 layer_0029  polygon   #B2E1D5      <NA>     90 motif  Icon Shape 10    TRUE
#> 30 layer_0030    lines #F4F8FC99 #F4F8FC99     80 motif   Icon Line 11    TRUE
#> 31 layer_0031   circle   #0C4E4B      <NA>      1 motif  Icon Circle 9    TRUE
#> 32 layer_0032   circle   #F4F8FC      <NA>      1 motif Icon Circle 10    TRUE
#> 33 layer_0033    lines   #B2E1D5   #B2E1D5      2 motif   Icon Line 12    TRUE
#> 34 layer_0034  polygon #030A1240      <NA>     90 motif  Icon Shape 11    TRUE
#> 35 layer_0035  polygon   #38B391      <NA>     90 motif  Icon Shape 12    TRUE
#> 36 layer_0036    lines #F4F8FC99 #F4F8FC99     80 motif   Icon Line 13    TRUE
#> 37 layer_0037   circle   #0C4E4B      <NA>      1 motif Icon Circle 11    TRUE
#> 38 layer_0038   circle   #F4F8FC      <NA>      1 motif Icon Circle 12    TRUE
#> 39 layer_0039  polygon #030A1240      <NA>     90 motif  Icon Shape 13    TRUE
#> 40 layer_0040  polygon   #F4F8FC      <NA>     90 motif  Icon Shape 14    TRUE
#> 41 layer_0041    lines #F4F8FC99 #F4F8FC99     80 motif   Icon Line 14    TRUE
#> 42 layer_0042   circle   #38B391      <NA>      1 motif Icon Circle 13    TRUE
#> 43 layer_0043   circle   #B2E1D5      <NA>      1 motif Icon Circle 14    TRUE
#> 44 layer_0044   circle   #F4F8FC      <NA>      1 motif Icon Circle 15    TRUE
#> 45 layer_0045   circle   #B2E1D5      <NA>      1 motif Icon Circle 16    TRUE
#> 46 layer_0046   circle   #F4F8FC      <NA>      1 motif Icon Circle 17    TRUE
#> 47 layer_0047 pathgrob   #FFFFFF      <NA>   1635  name           Name    TRUE
```
