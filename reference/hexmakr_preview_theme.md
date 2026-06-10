# Preview a Color Theme

Renders a sample hex sticker to preview a theme's colors.

## Usage

``` r
hexmakr_preview_theme(theme = "stats", mode = "dark")
```

## Arguments

- theme:

  Character. Theme name, one of `names(hexmakr_themes())`.

- mode:

  Character. Either `"dark"` (default) or `"light"`.

## Value

A ggplot object (invisibly). Also prints the plot.

## Details

Preview a theme

## See also

[`hexmakr_themes()`](https://cttir.github.io/hexmakR/reference/hexmakr_themes.md),
[`hex_sticker()`](https://cttir.github.io/hexmakR/reference/hex_sticker.md)

Other themes:
[`hexmakr_icons()`](https://cttir.github.io/hexmakR/reference/hexmakr_icons.md),
[`hexmakr_themes()`](https://cttir.github.io/hexmakR/reference/hexmakr_themes.md)

## Examples

``` r
# \donttest{
hexmakr_preview_theme("stats")

hexmakr_preview_theme("genomics", mode = "light")

# }
```
