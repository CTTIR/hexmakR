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
