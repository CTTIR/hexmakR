# Export an editable v5 design

The same native grid geometry powers previews and all three export
formats. SVG and PDF contain vector paths, including outlined
package-name glyphs.

## Usage

``` r
hex_export(design, filename, width = 1600L)
```

## Arguments

- design:

  A [`hex_design()`](hex_design.md) object.

- filename:

  Destination ending in `.png`, `.svg` or `.pdf`.

- width:

  PNG width in pixels; vector masters use a six-inch canvas.

## Value

The destination path, invisibly.

## Examples

``` r
f <- tempfile(fileext = ".svg")
hex_export(hex_design("phenoscapR"), f)
```
