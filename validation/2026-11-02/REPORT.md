# hexmakR 0.4.1 maintenance candidate

Local verification: 2 November 2026, macOS 27.0.1 ARM64, R 4.6.1.
Public function signatures, project schema, runtime Imports and the R 4.1
minimum are unchanged. This is a locally validated candidate, not a published
release or a submitted/accepted CRAN package.

## Purpose, baseline and strategy

The package creates editable project logos and classic hex stickers. Principal
workflows are new-logo composition, image/SVG import, layer editing, gallery
reuse, portable JSON/R reproduction and faithful PNG/SVG/PDF export. The
maintenance strategy was recorded before implementation in
`plans/2026-11-02-maintenance.md`.

The original local checkout at fc533b78 was preserved. The isolated maintenance
branch first incorporated 47 already-published commits through 0bbc7ed9, the
0.4.0 audit baseline. That baseline passed 6,218 assertions and a full as-CRAN
check with zero errors/warnings and the new-submission NOTE after absent optional
rsvg/colourpicker dependencies were installed. The initial missing-dependency
check failure is retained separately in the external evidence.

## Confirmed findings and repairs

| Finding and evidence | Impact / severity | Completed change |
| --- | --- | --- |
| Failed classic drawing replaced an existing PNG/SVG; the asset cache unlinked its old file before a failed rename. | Lost completed output; high. | Shared same-directory staged writer for graphics, projects, recipes, cache assets and stamps; real draw failures and injected final-rename failures preserve original bytes. |
| Classic 4:1 image rendered approximately 0.87:1. | Distorted uploaded artwork; medium. | Fit PNG/JPEG within the existing icon area while retaining physical aspect ratio. |
| A valid 116-byte, 8193-by-1 PNG bypassed classic dimension checks. | Confirmed unbounded decoder entry; large decoded allocation is a risk, not an observed crash; high. | Reuse existing 10 MiB, 8192-per-side and 16-million-pixel bounds before decoding; native rasters limit allocations. |
| Corrupt classic upload silently removed the image from preview and downloads. | Misleading output and loss of applied composition; medium. | Validate rendering before accepting state; accessible error retains prior preview, download and filename, then clears on valid input. |
| Root SVG viewport/aspect rules were ignored; drawing after closepath used the old subpath; closed strokes used open caps. | Imported geometry changed without warning; medium. | Honour absolute viewport dimensions and supported aspect/alignment rules, closepath subpaths and closed joins; reject unsupported clipping/stretching of strokes. |
| Long names clipped at six points and unsupported bundled characters became missing-glyph boxes. | Incomplete or incorrect labels; medium. | Check glyph support and convex-frame containment, shrinking to six points then reporting impossible fits. Manual subsequent transformations remain editable. |
| Exporting changed the selected pre-existing graphics device. | Drawing could continue on the wrong user device; medium. | Restore the caller's selection while closing only the package-owned device. |
| Test dependency allowed versions without required mocking support; font prose implied 14 distinct fonts. | Unreproducible tests and misleading capabilities; low. | Declare tested testthat 3.3.2, explain system-family aliases and bundled JetBrains Mono. |

The import and rendering repairs received separate independent review. Synthetic
SVGs were compared with independently rendered librsvg output, including
non-square viewport scaling, alignment, closepath continuation and thick closed
outline joins. Three equivalent fixtures now have zero pixel differences.
The import review used the W3C SVG2 [path semantics](https://www.w3.org/TR/SVG2/paths.html)
and [viewport/aspect rules](https://www.w3.org/TR/SVG2/coords.html). Test dependency
behavior was checked against the [testthat release notes](https://testthat.r-lib.org/news/index.html)
and actual compilation/test runs.
All 1,191 protected source-artwork, font and branding files retain their
upstream bytes; all 540 compressed SVG/PDF masters match recorded provenance.

## Verification

- Full source suite: **6,418 passed; zero failures, errors, warnings or skips**.
- Full `R CMD check --as-cran`, with manual and vignette rebuilds: **zero errors,
  zero warnings, one new-submission NOTE**. Its built-package tests pass 3,695
  assertions with three expected skips (two CRAN-only and one source-only
  master-folder check).
- Dependency-only as-CRAN check: **zero errors, zero warnings, one new-submission
  NOTE**; 3,654 assertions pass with eight expected optional/CRAN/source-only
  skips. Manual and vignettes remain enabled.
- Existing coverage gate: **94.3501%, above the unchanged 90% requirement**.
- Clean installation of the checked source tarball into a new library: passed.
  New pentagonal logo, custom part, JSON reload, executed R recipe, PNG/SVG/PDF,
  gallery SVG/PDF/PNG/icon paths and classic PNG/SVG all passed. A real failed
  classic draw preserved the completed output.
- Desktop/mobile browser: modern editing, drag/undo, parts/groups, gallery reuse,
  supported/unsafe uploads, literal hostile-looking text, JSON save/reopen,
  downloads and name errors/recovery passed. Classic corrupt and oversized
  image errors preserve exact PNG bytes and the applied filename; valid input
  recovers. Downloaded PNG matches the independently rendered project; the
  downloaded R recipe recreates the design and output.
- Twenty-seven final renderer outputs across three shapes, three modes and
  three formats passed; all nine native PNGs retain baseline bytes.
- Documentation site: clean build, **45 HTML pages and 1,931 local targets with
  no broken local links**. External links were not comprehensively checked.
- The site-only duplicate README logo was hidden on the homepage; the standard
  pkgdown logo remains and mobile headings now fit normally. GitHub README
  artwork is unchanged.
- Manual: all 25 pages visually reviewed after repairing the clipped cache
  example. R's check-produced PDF has stale printed contents/index numbers.
  A separate manual from the exact checked package sources was stabilized
  with ordinary makeindex/pdflatex passes: all 27 references agree, auxiliary
  files converge, all fonts are embedded and no text exceeds page bounds.
  The reviewed derivative is `manual-final/hexmakR-manual.pdf` in the external
  evidence, SHA-256
  `ba49f34e46ed1ecb4572e5552dcfcfcdaa364cc4f79552488ffde02e051b90c3`.
  It is distinct from the preserved check-produced PDFs. `MANUAL-REVIEW.md`
  and `manual-final/converge.py` retain exact reproduction commands.
- Workflow syntax and CFF 1.2.0 schema validation passed. `git diff --check`
  passed. No public export or runtime dependency was added.
- Source archive: 2,198,125 bytes, 117 regular files, SHA-256
  `8948b99860b1ee232b0666f66aae6eccf242d2b9eeb7387ddc1ccac356e406f4`.
  Artwork archive, font bytes/licences and copyright are intact; development
  plans, validation reports, Git metadata and machine handovers are excluded.

The final documentation correction changes no runtime expression: all 26 R
source files have identical parsed code to the fully tested candidate. The
final package differs only in the hex_asset documentation/source comments and
normal build metadata.

The source test count includes development-only artwork checks absent from the
CRAN package; it must not be substituted for the packaged test count. Full raw
logs, screenshots, PDF renders, dependency versions, probes and hashes are
retained in the local audit's `evidence/hexmakR` directory.

## First use

Prerequisites: R 4.1 or newer, installed package dependencies and Cairo graphics
support for v5 rendering (`capabilities("cairo")`). macOS may require XQuartz.
Optional `rsvg` renders gallery-master PNGs, `svglite` enables classic SVG, and
`colourpicker` supplies classic colour pickers (typed values otherwise).
The candidate was tested on R 4.6.1; older supported R versions still need
hosted qualification.

From the maintenance checkout, with its dependencies installed:

```sh
R CMD build .
R CMD INSTALL hexmakR_0.4.1.tar.gz
R -e 'hexmakR::hexmakr_app()'
```

For scripted use:

```r
library(hexmakR)
logo <- logo_design("My project", shape = "pentagon")
logo <- hex_add_part(logo, "circle", x = .5, y = .6, r = .15)
hex_save_design(logo, "project.json")
hex_export(hex_read_design("project.json"), "project.svg")
hex_export(logo, "project.png")
hex_recipe(logo, "project.R")
```

Reproduce checks with testthat 3.3.2 and the complete Suggests set:

```r
withr::with_envvar(c(NOT_CRAN = "true"), testthat::test_local())
rcmdcheck::rcmdcheck(args = "--as-cran", error_on = "warning")
coverage <- withr::with_envvar(c(NOT_CRAN = "true"),
  covr::package_coverage(type = "tests"))
stopifnot(covr::percent_coverage(coverage) >= 90)
```

## Deferred work and release gates

- Run the configured Windows/Linux/macOS and R release/devel/oldrel CI on the
  actual candidate. Previously green upstream jobs validate 0.4.0, not these
  changes. Windows replacement/device behavior has not been observed here.
- Maintain the existing report-only house-lint policy: 112 findings (111
  condition-style and one global-variable declaration), comprising 96 package
  source, nine preserved source-kit and seven test findings. Baseline had 103.
  No lint rule, assertion, coverage floor or test was suppressed. A package-wide
  condition-style migration is outside this correctness release.
- SVG curves remain bounded polylines. Relative viewport dimensions, cropped
  artwork, unsupported effects and anisotropically scaled strokes need
  flattening or conversion before import. Conservative miter bounds can reject
  some near-edge strokes even when the actual join fits. Additional fonts and
  arbitrary font fallback are deferred; supported characters render explicitly.
- On first search focus, immediately pasting before the asynchronous index
  finishes loading can show no suggestions until another input event. Normal
  typing and navigation after initialization work. This upstream pkgdown search
  race remains deferred; generated dependency code was not patched.
- When producing a standalone reference manual, verify printed contents/index
  references after R CMD Rd2pdf and repeat ordinary index/LaTeX passes until
  stable. The checked source package itself does not contain these PDFs.
- Site generation emits upstream Pandoc mathjax/katex option-deprecation
  warnings; the generated pages still build and link.
- GitHub's Dependabot endpoint reports alerts disabled (HTTP 403). This is an
  evidence gap, not a clean vulnerability result. Dependency versions and native
  installation logs are recorded; no broad vulnerability-free claim is made.
- This local editor is not an authenticated hosted service. Shared deployment,
  operational monitoring and user access controls require a chosen environment.
- Review maintainer metadata, hosted results and CRAN requirements, then obtain
  the existing required publication authorization before pushing/releasing or
  submitting. No push, issue message, deployment, release or submission occurred.

## Local environment footprint

Optional rsvg 2.7.0 and colourpicker 1.3.0 were installed in the isolated audit
R library. Native librsvg 2.63.4 and its required Homebrew dependencies were
installed; harfbuzz changed from 14.6.0 to 15.0.0_1. Homebrew automatic updating
and cleanup were disabled, retaining prior kegs. System and personal R library directories and
unrelated application files were not modified.
