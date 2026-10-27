# hexmakR 0.3.0 and public branding verification

## Delivered editor behavior

The default application creates a new named hexagonal logo. The secondary
**CTTIR Gallery** contains all 45 supplied identities and explicit actions to
reuse one component, a motif or a complete design. Browsing does not replace
current work. Both editor title lines contain only **hexmakR**.

The editor supports mouse selection and release-to-commit dragging of a part
or a named group; circles, rectangles, lines and triangles; editable short
labels; default Frame/Icon/Name groups and custom membership; native point
editing; position, size, rotation, fill, stroke, opacity and visibility; undo;
and portable JSON, R recipes and PNG/SVG/PDF output. Hexagonal, pentagonal and
square frames remain available.

PNG/JPEG uploads become embedded image parts. Supported SVG shape/path
components become editable vector parts, including local references and
provably redundant convex clips. Curves are approximated with bounded vector
polylines. Text must be outlined; gradients, filters, masks and intersecting
clips must be flattened to supported geometry. Unsupported features produce
an explicit error. Files are limited to 10 MiB, projects to 20 MiB, with bounded
pixel, path-point and local-reference expansion budgets.

## Package validation

- Full suite: 124 tests, 1,638 assertions; 0 failures, errors, warnings or skips.
- Source build and all four vignette builds passed on R 4.6.1, Apple silicon.
- R CMD check --no-manual: Status OK; zero errors, warnings and notes.
- All four standalone vignettes rendered with both named light/dark logos.
- Dedicated regression coverage includes rendered-geometry picking, asymmetric
  coordinates, transparency and holes, nested viewports, edited-frame clipping,
  grouped drag with one undo step, metadata remapping after composition changes,
  source-opacity preservation, labels/groups/project roundtrips and malformed
  imports. A generated SVG and a supplied canonical logo import as vectors.
- Original 1,035 assets remain unchanged. The 0.2.0 full 45-identity regeneration
  evidence remains in REPORT.md; it was not repeated unnecessarily here.
- Live browser checks confirmed the fresh blank design, text-only title,
  CTTIR Gallery label, adding a circle and renaming it. Additional screenshot,
  mouse-drag and browser file-chooser checks were interrupted by browser-control
  timeouts. Automated Shiny/geometry/import tests cover those code paths; actual
  browser upload/drag verification is not claimed.

## Public checkout branding

Inventory covered 51 public repositories and 39 canonical R package roots.
Changes span 45 repositories including hexmakR:

- Named exact v5 masters in applicable READMEs, app headers and asset aliases.
- All 132 vignette/article sources, plus one supporting vignette README.
- All 79 tracked generated HTML pages, with resolving local navbar images and
  correct navbar clearance verified through the browser.
- 27 package Shiny identities and their audited entry points; the subsequent
  explicit hexmakR text-only title request takes precedence over its logo header.
- Shared themakR navbar, light/dark switching and branding render scripts.
- Companion applications and the CTTIR website's local logo gallery.

The branding-only pass preserved all 132 scientific R chunk bodies. The four
hexmakR guides were subsequently updated for the requested editor features.
All 632 audited real image placements resolve. Current renderer maps contain
1,845 destinations across 45 repositories; generated build folders are excluded.

The first deployment verified 1,856 file hashes across 44 nonhex repositories.
Final deployment also applies hexmakR, one harmless harbouR line wrap, LF CSV
normalization and removal of a stale generated-build map entry. Destination
hashes are checked against a sealed manifest and recoverable backups are kept.

Representative validation: themakR 28 assertions; harbouR 2,116 assertions with
8 existing skips and no failures/warnings, plus clean lint; selected app suites;
full representative standalone/pkgdown builds; shinylaunchR and pwa-quest builds;
and a 21-page local Hugo build. This is not a full R CMD check of all 39 packages.

## Publication and running applications

hexmakR main publication is authorized. Other public checkout changes are local
and uncommitted. harbouR and hyperannotatR explicitly reserve pushing for the
maintainer; pressR and scimapR have existing work on non-main branches. Their
unrelated changes were preserved. Existing application sessions, particularly
the active annotation app, were not restarted.

Remote documentation sites are not refreshed by local edits. In particular,
themakR's unpublished changes govern larger navbar images, spacing and the
homepage dark-logo switch. The existing remote theme still resolves named logo
aliases, but those theme improvements await publication.

Detailed machine-readable evidence and recoverable backups are under
`/private/tmp/cttir-branding-20261027`. The source archives are unchanged.
