# hexmakR: Interactive Hex Sticker Generator for R Packages

Create publication-ready hexagon stickers for R packages interactively
via a Shiny app or programmatically via R functions.

Comes with **28 curated colour themes** (dark + light variants), led by
the nine CTTIR v5 families, **46 built-in scientific and technical
icons** across 7 categories, custom image upload support, 14 font
options including the bundled JetBrains Mono, and transparent PNG
export.

The default Designer starts a fresh logo. Add, duplicate, remove and
edit individual parts; optionally reuse components from 45 archived
vector identities. JSON projects, R recipes and PNG/SVG/PDF exports
retain edits across hexagonal, pentagonal or square logos. Import
portable PNG/JPEG figures or supported SVG components, select and drag
items, rotate individual parts, and organise named groups.

### Main functions

- [`logo_design()`](https://cttir.github.io/hexmakR/dev/reference/logo_design.md)
  –fresh project logos in three frame shapes.

- [`hex_add_part()`](https://cttir.github.io/hexmakR/dev/reference/hex_add_part.md)
  –add editable geometric parts.

- [`hex_import_art()`](https://cttir.github.io/hexmakR/dev/reference/hex_import_art.md)
  –import embedded figures or editable vector components.

- [`hex_groups()`](https://cttir.github.io/hexmakR/dev/reference/hex_groups.md)
  –organise named groups of items.

- [`hex_label_layer()`](https://cttir.github.io/hexmakR/dev/reference/hex_label_layer.md)
  –give an item a short label.

- [`hex_reuse_part()`](https://cttir.github.io/hexmakR/dev/reference/hex_reuse_part.md)
  –reuse selected archive artwork.

- [`hex_edit_layer()`](https://cttir.github.io/hexmakR/dev/reference/hex_edit_layer.md)
  –edit individual part properties and points.

- [`hex_design()`](https://cttir.github.io/hexmakR/dev/reference/hex_design.md)
  –fresh or explicitly selected archive design.

- [`hex_export()`](https://cttir.github.io/hexmakR/dev/reference/hex_export.md)
  –vector and raster export.

- [`hex_catalog()`](https://cttir.github.io/hexmakR/dev/reference/hex_catalog.md)
  –all 45 registered identities.

- [`hex_sticker()`](https://cttir.github.io/hexmakR/dev/reference/hex_sticker.md)
  –programmatic hex sticker creation; returns a ggplot object.

- [`hexmakr_app()`](https://cttir.github.io/hexmakR/dev/reference/hexmakr_app.md)
  –launch the interactive Shiny designer.

- [`hexmakr_themes()`](https://cttir.github.io/hexmakR/dev/reference/hexmakr_themes.md)
  –list all 28 built-in themes, CTTIR v5 families first.

- [`hexmakr_icons()`](https://cttir.github.io/hexmakR/dev/reference/hexmakr_icons.md)
  –list all 46 built-in icons.

- [`save_hex()`](https://cttir.github.io/hexmakR/dev/reference/save_hex.md)
  –save a sticker to a transparent PNG.

- [`save_hex_svg()`](https://cttir.github.io/hexmakR/dev/reference/save_hex_svg.md)
  –save a sticker to SVG (requires svglite).

## See also

Useful links:

- <https://cttir.github.io/hexmakR/>

- <https://github.com/CTTIR/hexmakR>

- Report bugs at <https://github.com/CTTIR/hexmakR/issues>

## Author

**Maintainer**: R. Heller <raban.heller@uni-ulm.de>
([ORCID](https://orcid.org/0000-0001-8006-9742)) \[copyright holder\]

Authors:

- R. Heller <raban.heller@uni-ulm.de>
  ([ORCID](https://orcid.org/0000-0001-8006-9742)) \[copyright holder\]

Other contributors:

- The JetBrains Mono Project Authors (JetBrains Mono font) \[copyright
  holder\]
