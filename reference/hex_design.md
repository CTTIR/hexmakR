# Create an editable CTTIR v5 design

A call without a package starts a fresh composition with a frame and
name. Supplying a package explicitly loads its editable archive motif.
Archive artwork can also be reused one part at a time with
[`hex_reuse_part()`](https://cttir.github.io/hexmakR/reference/hex_reuse_part.md).
All geometry is drawn in R. Name glyphs use the bundled JetBrains Mono
font.

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
  icon = NULL,
  archive = !missing(package)
)
```

## Arguments

- package:

  Exact identity from
  [`hex_catalog()`](https://cttir.github.io/hexmakR/reference/hex_catalog.md).

- mode:

  `dark`, `light`, or `mono`.

- layout:

  `lockup` (name inside), `hex` (unnamed), or `motif` (standalone).

- label:

  Displayed name, defaulting to the exact identity.

- colors:

  Named list of colour-role overrides, for example
  `list(face = "#193E36", rim = "#009E73", ink = "white")`. Use
  [`hex_palette()`](https://cttir.github.io/hexmakR/reference/hex_palette.md)
  to see available roles.

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

  Optional generic icon key from
  [`hexmakr_icons()`](https://cttir.github.io/hexmakR/reference/hexmakr_icons.md),
  replacing the CTTIR motif.

- archive:

  Include the package's archive motif. By default this is true only when
  `package` is supplied explicitly.

## Value

A serialisable `hex_design` object.

## Examples

``` r
design <- hex_design("phenoscapR")
design
```
