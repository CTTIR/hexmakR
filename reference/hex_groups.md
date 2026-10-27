# Inspect and organise groups of logo items

Native designs begin with Frame, Icon and Name groups when those items
are present. Custom groups have stable IDs and one membership per item.
Grouping changes metadata only: appearance and stacking order are
retained.

## Usage

``` r
hex_groups(design)

hex_group_layers(design, layers, label = "Group", group = NULL)

hex_ungroup_layers(design, layers)

hex_rename_group(design, group, label)
```

## Arguments

- design:

  A [`hex_design()`](hex_design.md) object.

- layers:

  Character vector of IDs from [`hex_layers()`](hex_layers.md).

- label:

  Short item or group name, at most 80 characters.

- group:

  Existing group ID to update; `NULL` creates a new group.

## Value

`hex_groups()` returns a named list of groups, each with a `label` and
`members`. The other functions return an updated design.

## Examples

``` r
d <- hex_design("phenoscapR")
hex_groups(d)
#> $frame
#> $frame$label
#> [1] "Frame"
#> 
#> $frame$members
#> [1] "layer_0001"
#> 
#> 
#> $icon
#> $icon$label
#> [1] "Icon"
#> 
#> $icon$members
#>  [1] "layer_0002" "layer_0003" "layer_0004" "layer_0005" "layer_0006"
#>  [6] "layer_0007" "layer_0008" "layer_0009" "layer_0010" "layer_0011"
#> [11] "layer_0012" "layer_0013" "layer_0014" "layer_0015" "layer_0016"
#> [16] "layer_0017" "layer_0018" "layer_0019" "layer_0020" "layer_0021"
#> [21] "layer_0022" "layer_0023" "layer_0024" "layer_0025" "layer_0026"
#> [26] "layer_0027" "layer_0028" "layer_0029" "layer_0030" "layer_0031"
#> [31] "layer_0032" "layer_0033" "layer_0034" "layer_0035" "layer_0036"
#> [36] "layer_0037" "layer_0038" "layer_0039" "layer_0040" "layer_0041"
#> [41] "layer_0042" "layer_0043" "layer_0044" "layer_0045" "layer_0046"
#> 
#> 
#> $name
#> $name$label
#> [1] "Name"
#> 
#> $name$members
#> [1] "layer_0047"
#> 
#> 
d <- hex_group_layers(d, hex_groups(d)$icon$members, "Package icon")
```
