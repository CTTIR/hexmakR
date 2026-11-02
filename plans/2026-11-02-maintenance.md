# hexmakR maintenance strategy — 2 November 2026

## Scope and baseline

Audit the public package for dependable logo creation, lossless project editing,
faithful supported artwork imports and safe PNG/SVG/PDF exports. Preserve the
45 identity definitions, supplied master bytes, font licences, author metadata,
existing APIs and the original local checkout. No private source repositories or
running unrelated applications are in scope. No publication is authorised.

The original clean local main is fc533b78b148bb42c59c42da9f96ab0cd431c9be.
The isolated maintenance branch fast-forwarded 47 published commits to
0bbc7ed9c4149fe0213a95bef747ec9e7af58c16 before substantive review; this is the
maintenance base. Original local main is untouched. Version 0.4.0 already fixes
many packaging and editor issues described in older records.

Original-local suite: 1,638 assertions pass. Current-upstream suite: 4,569 pass,
no failures/warnings and two missing-rsvg skips. Complete upstream check is
initially blocked by absent optional rsvg/colourpicker dependencies. Install
these in the isolated audit R library and provide the native SVG library before
rerunning; do not disable required checks. The existing report-only house lint
returns 103 findings, including preserved kit files and test fixture strings.

## Acceptance criteria and implementation sequence

1. Export preservation and image fidelity (essential).
   Classic image uploads must retain aspect ratio. A failed draw must leave an
   existing export byte-identical and close its own graphics device; successful
   PNG/SVG/PDF exports must be readable and contain the expected composition.
   Use staged output and validate failure/success paths on real files.
2. SVG import correctness (essential).
   Preserve SVG subpath semantics after closepath and honour root viewport,
   viewBox and preserveAspectRatio rules. Unsupported clipping/effects must be
   rejected explicitly rather than silently changing artwork. Retain supported
   Cairo self-import and encoded project round trips. Compare synthetic imports
   against W3C-defined equivalent geometry and independent SVG rendering.
3. Label integrity (dependable everyday use).
   Generated base-frame names must stay within their frame; subsequent manual
   layer transformations remain freely editable. Report unsupported glyphs rather
   than silently substituting missing-glyph boxes. Preserve exact text, font
   provenance and supported existing labels. Inspect long/scientific/non-Latin
   inputs in exported files and the browser.
4. Editor and reproduction integration (dependable everyday use).
   Repeat new-logo/parts/groups/drag/undo/gallery/import/save/reopen/download
   journeys and invalid-input recovery after repairs. Preview, project JSON,
   R recipe and downloaded graphics must represent the same applied design.
   Repair further confirmed workflow gaps without accumulating new features.
5. Release candidate and reproducibility (essential readiness).
   Correct the testthat minimum to cover the mocking APIs in use. Prepare a
   patch version and update implementation documentation, examples, NEWS and
   submission evidence together. Run full tests, the existing coverage gate,
   full as-CRAN checks, clean installation/first use and direct export/browser
   verification. Inspect package contents, master hashes, fonts/licences, manual
   and clean documentation site. Keep hosted results distinct from local checks.

Each repair gets meaningful regression coverage and independent review. No
snapshots/checks are weakened. Keep evidence under the workspace audit's
`evidence/hexmakR`; record final outcomes under `validation/2026-11-02`.

## Deferred scope and tradeoffs

Do not redesign the editor or replace the vector engine. Additional SVG effects,
font libraries, arbitrary raster editing and new gallery identities are outside
this maintenance release. Prefer explicit unsupported-input errors over an
incorrectly altered image. Do not change preserved source artwork to satisfy
style lint. Maintainer publication/CRAN acceptance and hosted platform results
remain separate gates. Open issue #1 concerns CRAN availability; the current
README already explains GitHub installation, and no issue message/closure is
authorised here.

## Dependency refinement

The attempted testthat3.2.0 lower boundary does not compile against R4.6.1's
C API. Use the tested3.3.2 minimum for this optional test dependency; the
runtime Imports/R requirement remains unchanged. See the external evidence
record dependency-review.md for the failed compiler output and primary docs.

## Refinement after independent review

The closed SVG stroke join also lost geometry: a repeated first point with
open-line caps is not a closed path join. Preserve that distinction and compare
the rendered result against librsvg. A safe 116-byte, 8193-by-1 PNG demonstrated
that classic uploads bypassed modern predecode limits. Reuse the existing
10 MiB, 8192-per-side and 16-million-pixel policy before decoding classic input;
no new arbitrary limit or format is introduced.

After optional dependencies were installed, the untouched upstream baseline
passed 6,218 assertions with no skips, failures or warnings. The complete
as-CRAN check (including manual and vignettes) returned zero errors, zero
warnings and the new-submission NOTE. This distinguishes the initial missing
dependency error from a package defect.
