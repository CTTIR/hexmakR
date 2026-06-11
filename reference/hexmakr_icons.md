# List Available Icons

Returns the built-in icon library as a named list. Icons are organized
by category. Each icon entry contains a `label` and `draw` function.

## Usage

``` r
hexmakr_icons(category = NULL)
```

## Arguments

- category:

  Character or `NULL`. If `NULL` (default), returns all categories.
  Otherwise, one of `"science"`, `"biology"`, `"stats"`, `"medical"`,
  `"tech"`, `"shapes"`, `"fun"`.

## Value

A named list of icon entries (each with `label` and `draw`), or a named
list of categories if `category = NULL`.

## Details

List available icons

## See also

[`hex_sticker()`](https://cttir.github.io/hexmakR/reference/hex_sticker.md)

Other themes:
[`hexmakr_preview_theme()`](https://cttir.github.io/hexmakR/reference/hexmakr_preview_theme.md),
[`hexmakr_themes()`](https://cttir.github.io/hexmakR/reference/hexmakr_themes.md)

## Examples

``` r
icons <- hexmakr_icons()
names(icons)
#> [1] "science" "biology" "stats"   "medical" "tech"    "shapes"  "fun"    
hexmakr_icons("science")
#> $atom
#> $atom$label
#> [1] "Atom"
#> 
#> $atom$draw
#> function (x, y, size, color) 
#> {
#>     r_nucleus <- size * 0.06
#>     r_orbit <- size * 0.28
#>     grid::grid.circle(x = x, y = y, r = r_nucleus, gp = grid::gpar(fill = color, 
#>         col = color))
#>     for (angle in c(0, 60, 120)) {
#>         rad <- angle * pi/180
#>         cos_a <- cos(rad)
#>         sin_a <- sin(rad)
#>         xs <- x + r_orbit * cos(seq(0, 2 * pi, length.out = 100)) * 
#>             cos_a - r_orbit * 0.4 * sin(seq(0, 2 * pi, length.out = 100)) * 
#>             sin_a
#>         ys <- y + r_orbit * sin(seq(0, 2 * pi, length.out = 100)) * 
#>             cos_a * 0.4 + r_orbit * 0.4 * cos(seq(0, 2 * pi, 
#>             length.out = 100)) * sin_a
#>         grid::grid.lines(x = xs, y = ys, gp = grid::gpar(col = color, 
#>             lwd = size * 4, lty = 1))
#>     }
#> }
#> <bytecode: 0x562bc290e6a0>
#> <environment: namespace:hexmakR>
#> 
#> 
#> $flask
#> $flask$label
#> [1] "Flask"
#> 
#> $flask$draw
#> function (x, y, size, color) 
#> {
#>     grid::grid.rect(x = x, y = y + size * 0.1, width = size * 
#>         0.14, height = size * 0.22, gp = grid::gpar(fill = color, 
#>         col = color))
#>     bx <- c(x - size * 0.28, x + size * 0.28, x + size * 0.12, 
#>         x - size * 0.12)
#>     by <- c(y - size * 0.25, y - size * 0.25, y + size * 0, y + 
#>         size * 0)
#>     grid::grid.polygon(x = bx, y = by, gp = grid::gpar(fill = color, 
#>         col = color))
#>     grid::grid.rect(x = x, y = y + size * 0.22, width = size * 
#>         0.2, height = size * 0.04, gp = grid::gpar(fill = color, 
#>         col = color))
#> }
#> <bytecode: 0x562bc290f718>
#> <environment: namespace:hexmakR>
#> 
#> 
#> $microscope
#> $microscope$label
#> [1] "Microscope"
#> 
#> $microscope$draw
#> function (x, y, size, color) 
#> {
#>     grid::grid.rect(x = x, y = y - size * 0.26, width = size * 
#>         0.4, height = size * 0.06, gp = grid::gpar(fill = color, 
#>         col = color))
#>     grid::grid.rect(x = x, y = y - size * 0.06, width = size * 
#>         0.07, height = size * 0.38, gp = grid::gpar(fill = color, 
#>         col = color))
#>     grid::grid.rect(x = x + size * 0.08, y = y + size * 0.18, 
#>         width = size * 0.22, height = size * 0.05, gp = grid::gpar(fill = color, 
#>             col = color))
#>     grid::grid.circle(x = x + size * 0.19, y = y + size * 0.22, 
#>         r = size * 0.05, gp = grid::gpar(fill = color, col = color))
#>     grid::grid.rect(x = x, y = y + size * 0.03, width = size * 
#>         0.05, height = size * 0.12, gp = grid::gpar(fill = color, 
#>         col = color))
#> }
#> <bytecode: 0x562bc2910fe0>
#> <environment: namespace:hexmakR>
#> 
#> 
#> $molecule
#> $molecule$label
#> [1] "Molecule"
#> 
#> $molecule$draw
#> function (x, y, size, color) 
#> {
#>     positions <- list(c(0, 0), c(0.22, 0.18), c(-0.22, 0.18), 
#>         c(0.22, -0.18), c(-0.22, -0.18))
#>     for (i in 2:5) {
#>         grid::grid.lines(x = c(x, x + positions[[i]][1] * size), 
#>             y = c(y, y + positions[[i]][2] * size), gp = grid::gpar(col = color, 
#>                 lwd = size * 3))
#>     }
#>     grid::grid.circle(x = x, y = y, r = size * 0.08, gp = grid::gpar(fill = color, 
#>         col = color))
#>     for (i in 2:5) {
#>         grid::grid.circle(x = x + positions[[i]][1] * size, y = y + 
#>             positions[[i]][2] * size, r = size * 0.06, gp = grid::gpar(fill = color, 
#>             col = color))
#>     }
#> }
#> <bytecode: 0x562bc2916198>
#> <environment: namespace:hexmakR>
#> 
#> 
#> $magnet
#> $magnet$label
#> [1] "Magnet"
#> 
#> $magnet$draw
#> function (x, y, size, color) 
#> {
#>     theta <- seq(0, pi, length.out = 60)
#>     r_out <- size * 0.26
#>     r_in <- size * 0.14
#>     xo <- x + r_out * cos(theta)
#>     yo <- y + r_out * sin(theta)
#>     xi <- rev(x + r_in * cos(theta))
#>     yi <- rev(y + r_in * sin(theta))
#>     px <- c(xo, xi)
#>     py <- c(yo, yi)
#>     grid::grid.polygon(x = px, y = py, gp = grid::gpar(fill = color, 
#>         col = color))
#>     grid::grid.rect(x = x - r_out * 0.7, y = y - size * 0.06, 
#>         width = (r_out - r_in), height = size * 0.12, gp = grid::gpar(fill = color, 
#>             col = color))
#>     grid::grid.rect(x = x + r_out * 0.7, y = y - size * 0.06, 
#>         width = (r_out - r_in), height = size * 0.12, gp = grid::gpar(fill = color, 
#>             col = color))
#> }
#> <bytecode: 0x562bc2917860>
#> <environment: namespace:hexmakR>
#> 
#> 
```
