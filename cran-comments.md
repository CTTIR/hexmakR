## Submission

This is a new submission of hexmakR 0.5.0.

## Test environments

* local: macOS (aarch64-apple-darwin), R 4.6.1, `R CMD check --as-cran
  --no-manual` on the built tarball. The PDF manual was built locally with
  TinyTeX (TeX Live 2026) via `R CMD Rd2pdf` without errors; the check run
  itself used `--no-manual`.
* GitHub Actions (r-lib/actions v2, `--as-cran`):
  macOS-latest (release), windows-latest (release),
  ubuntu-latest (devel, release, oldrel-1) and an informational
  ubuntu-latest (oldrel-3) row.

## R CMD check results

0 errors | 0 warnings | 1 note

* checking CRAN incoming feasibility ... NOTE
  Maintainer: 'R. Heller <raban.heller@uni-ulm.de>'
  New submission

  This is the first submission of the package.

## Notes for the CRAN team

* The source tarball is about 2.2 MB. The 270 SVG and 270 PDF logo masters
  are shipped as one compressed archive (`inst/cttir/logos.tar.xz`) and
  unpacked into the session temporary directory when first used; PNG versions
  are rendered on demand and never written outside `tempdir()` unless the
  user names an output path.
* Two JetBrains Mono font files are bundled under the SIL Open Font License
  1.1. The copyright holder is listed in `Authors@R` (role `cph`), the notice
  is in `inst/COPYRIGHTS` (referenced by the `Copyright` field), and the
  licence text is shipped next to the fonts.
* `hexmakr_app()` starts a 'shiny' application and is only run in examples
  when `interactive()` is `TRUE`.
