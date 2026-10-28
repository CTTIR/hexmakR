# hexmakR (development version)

* `save_hex()` writes PNG files with the cairo device where available, so
  stickers have the same pixel values on macOS as on Linux and Windows.

* The classic sticker API now speaks the CTTIR v5 design language. The nine
  v5 families (`spectral`, `spatial`, `omics`, `clinical`, `methods`,
  `simulation`, `evidence`, `platform`, `brand`) lead `hexmakr_themes()` and
  the classic theme picker under "CTTIR v5", with the v5 labels. Their
  colours are derived at run time from the v5 design tokens by the engine
  behind `hex_design()`: tile face as background, family rim as border, v5
  ink and muted text. Icons follow the v5 motif colours: the mid shade (the
  default motif fill) on dark tiles and the darker edge shade on light
  tiles. Text and subtitles reach at least 5.99:1 and icons at least 3.55:1
  contrast on every tile. The 19 generic themes and the `stats`/dark
  defaults are unchanged; use `hex_design()` for complete v5 artwork.
* `hex_sticker(font_family = "jetbrains_mono")` uses the JetBrains Mono font
  bundled for v5 names, drawn as glyph outlines on every device without
  installing the font. The classic default font is unchanged.

# hexmakR 0.3.0

* Start the default designer with a fresh logo. Add, duplicate, remove and
  edit individual parts; browse the archive separately and explicitly reuse
  selected components or whole motifs without replacing the current project.
* Select and drag visible items, use short labels, organise Frame/Icon/Name or
  custom groups, and move groups together. Rotate individual parts.
* Import PNG/JPEG figures as embedded image parts and supported SVG artwork as
  independently editable vector components. Support local SVG references and
  redundant convex clips; reject active content and unsupported features.
* Preserve added parts, uploaded artwork, labels, groups and edits in portable
  JSON projects and R recipes, with a 20 MiB save/load limit and data-only
  validation. Uploads are limited to 10 MiB. Older v5 projects
  retain their archive behaviour.
* Keep artwork clipping aligned with edited frame geometry and preserve source
  appearance when copying archive components.
* Standardize the named v5 package logo across README, every vignette and
  documentation page with matching light/dark artwork. Keep the application
  title as plain hexmakR text and label its archive tab CTTIR Gallery.

# hexmakR 0.2.0

* Add the complete CTTIR v5 library: 45 native R vector identities and 1,035
  unchanged original assets. Named designs place the package name inside.
* Add hexagonal, pentagonal and square project logos with `logo_design()`;
  reuse CTTIR motifs or any of the 46 generic icons.
* Add a default v5 editor with palette/layout controls, individual shape and
  coordinate editing, highlighting, undo/reset, JSON projects and R recipes.
* Add catalogue/asset lookup, editable design objects, layer inspection,
  PNG/SVG/PDF export and complete catalogue regeneration.
* Render name glyphs from the bundled JetBrains Mono font without requiring
  font installation. Preserve transparent exteriors and vector geometry.
* Preserve the classic API/designer and record the twelve legacy-only names.

# hexmakR 0.1.0

* Initial release
* 19 curated color themes with dark and light variants
* 46 built-in icons across 7 categories (science, biology, data/stats, medical, tech/code, shapes, fun)
* Custom image upload support (PNG, JPG, SVG)
* 13 font options with bold/italic toggles
* Interactive Shiny app for visual sticker design
* Programmatic API for scripted/batch sticker creation
* Export to transparent PNG at configurable resolution
* Full roxygen2 documentation and 3 vignettes
