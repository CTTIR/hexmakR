# Import a figure or vector artwork as editable logo parts

PNG and JPEG are embedded in the project as portable raster parts. SVG
shapes become separate vector parts that can be recoloured, moved,
rotated, resized and edited with
[`hex_edit_layer()`](https://cttir.github.io/hexmakR/reference/hex_edit_layer.md).
SVG exports retain vector paths; curves are approximated with bounded
polylines (32 segments per Bezier curve, about 32 segments per radian
for arcs, and 128 points per ellipse).

## Usage

``` r
hex_import_art(design, path)
```

## Arguments

- design:

  A
  [`hex_design()`](https://cttir.github.io/hexmakR/reference/hex_design.md)
  object.

- path:

  Local PNG, JPEG or SVG file. Its contents determine its format.

## Value

An updated design with additional stable `part_` IDs. The input design
and the source file are unchanged.

## Details

Supported SVG elements are `path`, `rect` (including rounded corners),
`circle`, `ellipse`, `line`, `polygon`, `polyline`, and transformed
groups. Paths support M/L/H/V/C/S/Q/T/A/Z commands, fill rules, solid
fills/strokes, and individual opacity. Local `defs`/`use` references are
expanded with cycle checks. Simple convex clip paths are accepted only
when they provably do not cut the component; intersecting clips must
first be flattened to paths. Text must be outlined. Gradients, masks,
filters, nested SVG viewports, CSS stylesheets and group opacity are
rejected with an explanation rather than silently rasterised.
Non-uniform transforms on strokes require outlined strokes. Scripts,
event handlers, external resources and XML entities are always rejected.

Input files are limited to 10 MiB. Raster images are limited to 8192
pixels per side and 16 million pixels total; dimensions are checked
before decoding. A project may contain at most 32 million embedded
raster pixels altogether. SVG supports at most 512 components, 5000
points per component, 100000 points total per project, 32 nested groups
and 8192 expanded element visits. The artwork is fitted proportionally
above the project name. Image bytes or vector coordinates are stored in
JSON; no original path is retained.

## Examples

``` r
svg <- tempfile(fileext = ".svg")
writeLines('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
<circle cx="50" cy="50" r="35" fill="#009E73"/></svg>', svg)
d <- hex_import_art(logo_design("New project"), svg)
d <- hex_edit_layer(d, "part_0001", angle = 20, alpha = .8)
unlink(svg)
```
