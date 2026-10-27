# CTTIR v5 artwork library

45 identities, 1,035 original masters and icons. `logos/` is an unchanged
import from the supplied v5 starter and seven PNG archives. Archive hashes
are recorded in `archive-inventory.json`; file hashes in `SHA256.json`.

`source/` preserves the supplied native R renderer, 45 drawing entry points,
fonts and their OFL licences. The package loads geometry in a private R
environment; its editable renderer uses bundled glyph outlines and does not
require fonts to be installed. Run the packaged `hex_render_catalog()` API
to rebuild exports with the package's renderer.

`legacy/` preserves the twelve older catalogue names absent from v5 as SVG
references. They are not v5 R motifs. `hexmakeR` maps to `hexmakR`; `delphyR`
maps to `delphyr`. No equivalence is assumed for the other names.

The artwork was supplied by the repository owner for this library. Original
CTTIR brand identities and older internal artwork are retained as reference
assets; their inclusion does not grant third-party trademark rights. Font
licences are included separately. Package code retains its MIT licence.

The identities `CTTIR` and `cttiR` differ only in case. To prevent collisions
on macOS and Windows, the organisation's asset folder is `CTTIR-brand`; the
R package retains `cttiR`. `hex_catalog()$asset_dir` records the mapping, and
asset lookup, the gallery and batch rendering use it. Displayed names remain
exact. Original assets were re-imported directly from distinct ZIP entries.
