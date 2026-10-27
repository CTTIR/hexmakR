# Create an editable CTTIR v5 design

Defaults to the approved named composition: artwork above the package
name, inside a tinted hex with an opaque family border and transparent
exterior. All geometry is drawn in R. Name glyphs use the bundled
JetBrains Mono font.

## Usage

``` r
hex_design(
  package = "hexmakR",
  mode = c("dark", "light", "mono"),
  layout = c("lockup", "hex", "motif"),
  label = package,
  colors = list(),
  motif_x = 0.5,
  motif_y = NULL,
  motif_scale = 1,
  label_y = 0.215,
  label_size = 32,
  border_width = 5.5,
  shape = c("hex", "pentagon", "square"),
  icon = NULL
)
```

## Arguments

- package:

  Exact identity from [`hex_catalog()`](hex_catalog.md).

- mode:

  `dark`, `light`, or `mono`.

- layout:

  `lockup` (name inside), `hex` (unnamed), or `motif` (standalone).

- label:

  Displayed name, defaulting to the exact identity.

- colors:

  Named list of colour-role overrides, for example
  `list(face = "#193E36", rim = "#009E73", ink = "white")`. Use
  [`hex_palette()`](hex_palette.md) to see available roles.

- motif_x, motif_y:

  Motif centre in normalised canvas coordinates.

- motif_scale:

  Motif size multiplier.

- label_y:

  Name centre in normalised canvas coordinates.

- label_size:

  Maximum name size in points on the six-inch master.

- border_width:

  Border width on the six-inch master.

- shape:

  Frame shape: `hex`, `pentagon`, or `square`.

- icon:

  Optional generic icon key from [`hexmakr_icons()`](hexmakr_icons.md),
  replacing the CTTIR motif.

## Value

A serialisable `hex_design` object.

## Examples

``` r
design <- hex_design("phenoscapR")
design
```
