# Editor and public branding continuation

## Accepted requirements

1. Start with a fresh named hexagonal project. Keep the 45 supplied designs in
   a secondary **CTTIR Gallery** for inspiration, complete reuse and reuse of
   individual vector parts. Browsing alone must not change the working design.
2. Use only **hexmakR** as the application title; omit its logo from the title
   line. Retain its canonical logo in documentation and its compact favicon.
3. Add circles, rectangles, lines and triangles. Select a visible item directly
   on the preview, drag it with the mouse, and keep precise controls for position,
   size, rotation, stroke, colour, opacity and native vector coordinates.
4. Give all existing items short names, allow renaming, and organize items into
   named groups such as Package icon. Move a selected group together. Preserve
   stable item IDs and stacking order; grouping is metadata rather than a redraw.
5. Add uploaded PNG/JPEG figures and SVG vector artwork. Embed raster data in
   portable project files; decompose supported SVG into editable vector parts.
   Reject unsupported effects explicitly rather than silently altering artwork.
6. Preserve edits, uploads, labels and groups through undo, JSON save/load,
   reproducible R recipes and PNG/SVG/PDF export. Keep existing APIs usable.
7. Apply exact supplied v5 named assets to every applicable public package
   README, vignette/article, pkgdown navbar and Shiny entry point. Use compact
   symbols only where icon dimensions require them. Preserve scientific content.

## Implementation sequence and verification

- Inventory current public repositories, package roots, all image references,
  existing local edits, app entry points and tracked generated sites. Hash the
  baseline and original masters before replacing assets.
- Stage repository copies. Add pure declarative item/group/import metadata,
  validation, rendering and hit-testing APIs before wiring the Shiny controls.
- Mouse picking uses the rendered geometry, clipping and current transforms;
  one completed drag adds one undo state. Use asymmetric fixtures to catch
  flipped coordinates and nested-frame fixtures to exercise viewport conversion.
- Test image signatures and size limits before decoding; SVG import rejects
  active content and external resources. Bound path expansion and reject
  transforms/effects that cannot be represented faithfully. Test self-import
  of exported SVG and a supplied canonical logo.
- Test legacy and current projects, isolated layers, groups, uploads, exports,
  preview selection, fresh default and independent gallery browsing. Run the
  whole package suite, source build and R CMD check, followed by actual browser
  interactions for the editor and representative branded sites/apps.
- For public branding, audit all README references and all 132 vignette/article
  sources. Verify all 79 tracked HTML pages, light/dark switching, local links,
  artwork dimensions and navbar clearance. Build representative standalone and
  pkgdown vignettes and run affected app/theme tests.
- Deploy only reviewed paths after checking their original hash and staged
  hash. Back up modified files and verify destination hashes. Do not overwrite
  concurrent user edits, restart the active annotation app, or include unrelated
  work in commits. Publish hexmakR main under the user's prior authorization;
  respect repository-specific publication rules elsewhere.

## Completion evidence

The final validation report records exact checks, tested scope, installation,
commit and remote state. A source update is not evidence that an already running
app or a remote documentation site has been refreshed.
