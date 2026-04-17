# List Available Themes

Returns a named list of all 19 built-in color themes for hex stickers.
Each theme has `dark` and `light` sub-lists with color values for `bg`,
`accent`, `text`, `border`, and `sub` (subtitle).

## Usage

``` r
hexmakr_themes()
```

## Value

A named list of length 19. Each element contains:

- label:

  Human-readable theme name (character).

- dark:

  List of 5 color hex strings for dark mode.

- light:

  List of 5 color hex strings for light mode.

## Details

List available themes

## See also

[`hex_sticker()`](https://r-heller.github.io/hexmakR/reference/hex_sticker.md),
[`hexmakr_preview_theme()`](https://r-heller.github.io/hexmakR/reference/hexmakr_preview_theme.md)

Other themes:
[`hexmakr_icons()`](https://r-heller.github.io/hexmakR/reference/hexmakr_icons.md),
[`hexmakr_preview_theme()`](https://r-heller.github.io/hexmakR/reference/hexmakr_preview_theme.md)

## Examples

``` r
themes <- hexmakr_themes()
names(themes)
#>  [1] "stats"    "viz"      "bio"      "medical"  "tech"     "earth"   
#>  [7] "cran"     "bioc"     "tidy"     "genomics" "proteo"   "pharma"  
#> [13] "ocean"    "midnight" "cyber"    "neon"     "sunset"   "viridis" 
#> [19] "plasma"  
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
```
