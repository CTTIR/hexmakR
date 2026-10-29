# Write a reproducible R recipe

Write a reproducible R recipe

## Usage

``` r
hex_recipe(design, path)
```

## Arguments

- design:

  A
  [`hex_design()`](https://cttir.github.io/hexmakR/reference/hex_design.md)
  object.

- path:

  Destination R file.

## Value

The path, invisibly.

## Examples

``` r
path <- tempfile(fileext = ".R")
hex_recipe(logo_design("My project"), path)
head(readLines(path))
#> [1] "library(hexmakR)"                                                               
#> [2] ""                                                                               
#> [3] "design <-"                                                                      
#> [4] "list(schema = \"hexmakR/v5-design/1\", package = \"hexmakR\", mode = \"dark\", "
#> [5] "    layout = \"lockup\", label = \"My project\", colors = list(), "             
#> [6] "    motif_x = 0.5, motif_y = 0.585, motif_scale = 1, label_y = 0.215, "         
```
