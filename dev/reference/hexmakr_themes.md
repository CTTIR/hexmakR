# List Available Themes

Returns a named list of all 28 built-in colour themes for hex stickers.
Each theme has `dark` and `light` sub-lists with colour values for `bg`,
`accent`, `text`, `border`, and `sub` (subtitle).

The first nine are the CTTIR v5 families (`spectral`, `spatial`,
`omics`, `clinical`, `methods`, `simulation`, `evidence`, `platform`,
`brand`) and are the house standard. They are derived from the bundled
v5 design tokens by the same engine as
[`hex_design()`](https://cttir.github.io/hexmakR/dev/reference/hex_design.md):
`bg` is the family's tile face, `border` its rim, `text` the v5 heading
ink and `sub` the muted text colour. `accent`, used for icons and the
inner ring, follows the colour v5 motifs use on each tile: the mid shade
(the default motif fill) on dark tiles and the darker edge shade
(strokes on a pale badge) on light tiles. Icons reach at least 3:1 and
text at least 4.5:1 contrast on every tile. The 19 generic themes follow
unchanged. For complete v5 artwork with motifs and outlined names, use
[`hex_design()`](https://cttir.github.io/hexmakR/dev/reference/hex_design.md).

## Usage

``` r
hexmakr_themes()
```

## Value

A named list of length 28. Each element contains:

- label:

  Human-readable theme name (character).

- group:

  `"CTTIR v5"` for the nine v5 families; absent for the generic themes.

- dark:

  List of 5 colour hex strings for dark mode.

- light:

  List of 5 colour hex strings for light mode.

## Details

List available themes

## See also

[`hex_sticker()`](https://cttir.github.io/hexmakR/dev/reference/hex_sticker.md),
[`hexmakr_preview_theme()`](https://cttir.github.io/hexmakR/dev/reference/hexmakr_preview_theme.md),
[`hex_design()`](https://cttir.github.io/hexmakR/dev/reference/hex_design.md)

Other themes:
[`hexmakr_icons()`](https://cttir.github.io/hexmakR/dev/reference/hexmakr_icons.md),
[`hexmakr_preview_theme()`](https://cttir.github.io/hexmakR/dev/reference/hexmakr_preview_theme.md)

## Examples

``` r
themes <- hexmakr_themes()
names(themes)
#>  [1] "spectral"   "spatial"    "omics"      "clinical"   "methods"   
#>  [6] "simulation" "evidence"   "platform"   "brand"      "stats"     
#> [11] "viz"        "bio"        "medical"    "tech"       "earth"     
#> [16] "cran"       "bioc"       "tidy"       "genomics"   "proteo"    
#> [21] "pharma"     "ocean"      "midnight"   "cyber"      "neon"      
#> [26] "sunset"     "viridis"    "plasma"    
themes$stats$dark
#> $bg
#> [1] "#1B2838"
#> 
#> $accent
#> [1] "#00D4AA"
#> 
#> $text
#> [1] "#FFFFFF"
#> 
#> $border
#> [1] "#00D4AA"
#> 
#> $sub
#> [1] "#8EC8B8"
#> 
themes$spatial$light
#> $bg
#> [1] "#D7EDE7"
#> 
#> $accent
#> [1] "#0A6356"
#> 
#> $text
#> [1] "#212121"
#> 
#> $border
#> [1] "#009E73"
#> 
#> $sub
#> [1] "#212121"
#> 
```
