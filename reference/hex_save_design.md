# Save and load a v5 editing project

JSON projects store declarative settings, additional parts and layer
edits; loading never evaluates R code. Files larger than 20 MiB and
unknown fields are rejected.

## Usage

``` r
hex_save_design(design, path)

hex_read_design(path)
```

## Arguments

- design:

  A
  [`hex_design()`](https://cttir.github.io/hexmakR/reference/hex_design.md)
  object.

- path:

  JSON project path.

## Value

`hex_save_design()` returns the path invisibly; `hex_read_design()`
returns a validated design.

## Examples

``` r
path <- tempfile(fileext = ".json")
design <- hex_add_part(logo_design("My project"), "circle")
hex_save_design(design, path)
restored <- hex_read_design(path)
hex_layers(restored)
#>           id     type    fill     col points  role   name visible
#> 1 layer_0001  polygon #191919 #000000      6 frame  Frame    TRUE
#> 2 layer_0002 pathgrob #FFFFFF    <NA>   1050  name   Name    TRUE
#> 3  part_0001   circle #009E73 #FFFFFF      1 added Circle    TRUE
```
