# hexmakR: Interactive Hex Sticker Generator for R Packages

Create publication-ready hexagon stickers for R packages interactively
via a Shiny app or programmatically via R functions.

Comes with **19 curated color themes** (dark + light variants), **46
built-in scientific and technical icons** across 7 categories, custom
image upload support, 13 font options, and transparent PNG export.

The default Designer starts a fresh logo. Add, duplicate, remove and
edit individual parts; optionally reuse components from 45 archived
vector identities. JSON projects, R recipes and PNG/SVG/PDF exports
retain edits across hexagonal, pentagonal or square logos. Import
portable PNG/JPEG figures or supported SVG components, select and drag
items, rotate individual parts, and organise named groups.

### Main functions

- [`logo_design()`](logo_design.md) –fresh project logos in three frame
  shapes.

- [`hex_add_part()`](hex_add_part.md) –add editable geometric parts.

- [`hex_import_art()`](hex_import_art.md) –import embedded figures or
  editable vector components.

- [`hex_groups()`](hex_groups.md) –organise named groups of items.

- [`hex_label_layer()`](hex_label_layer.md) –give an item a short label.

- [`hex_reuse_part()`](hex_reuse_part.md) –reuse selected archive
  artwork.

- [`hex_edit_layer()`](hex_edit_layer.md) –edit individual part
  properties and points.

- [`hex_design()`](hex_design.md) –fresh or explicitly selected archive
  design.

- [`hex_export()`](hex_export.md) –vector and raster export.

- [`hex_catalog()`](hex_catalog.md) –all 45 registered identities.

- [`hex_sticker()`](hex_sticker.md) –programmatic hex sticker creation;
  returns a ggplot object.

- [`hexmakr_app()`](hexmakr_app.md) –launch the interactive Shiny
  designer.

- [`hexmakr_themes()`](hexmakr_themes.md) –list all 19 built-in themes.

- [`hexmakr_icons()`](hexmakr_icons.md) –list all 46 built-in icons.

- [`save_hex()`](save_hex.md) –save a sticker to a transparent PNG.

- [`save_hex_svg()`](save_hex_svg.md) –save a sticker to SVG (requires
  svglite).

## See also

Useful links:

- <https://cttir.github.io/hexmakR/>

- <https://github.com/cttir/hexmakR>

- Report bugs at <https://github.com/cttir/hexmakR/issues>

## Author

**Maintainer**: R. Heller <raban.heller@uni-ulm.de>
([ORCID](https://orcid.org/0000-0001-8006-9742))

Authors:

- R. Heller <raban.heller@uni-ulm.de>
  ([ORCID](https://orcid.org/0000-0001-8006-9742))
