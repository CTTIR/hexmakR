## Local R CMD check results for 0.4.1

0 errors | 0 warnings | 1 note

* This is a new submission.

Checked on macOS 27.0.1 ARM64 with R 4.6.1 on 2 November 2026, including
manual, examples and vignette rebuilds. The source suite passes 6,418 assertions
with no failures, warnings or skips; the built-package CRAN suite passes
3,695 assertions with three expected skips (two CRAN-only skips and one
source-master-folder check whose inputs are deliberately outside the package).

The installed package occupies approximately 3.1 MiB of file contents. The
270 SVG and 270 PDF logo masters are shipped as a compressed archive, unpacked
into the session temporary directory when first used. SVG and PDF copies retain
the supplied master bytes; PNG versions and icons are rendered on demand.

## Other environments

Hosted Ubuntu, Windows and macOS jobs passed for published 0.4.0 commit
0bbc7ed9c4149fe0213a95bef747ec9e7af58c16. Those runs do not validate this
0.4.1 candidate. The configured hosted R release, devel and oldrel matrix
must run on the candidate before submission. No submission has been made.

## Changes and downstream dependencies

This candidate repairs export preservation, image decoding/proportions, SVG
geometry, label handling and editor error recovery. Public function signatures
and project schema are unchanged. Invalid images, unsupported bundled glyphs
and names that cannot fit now report errors instead of silently altered output.

This is a proposed first CRAN submission. Downstream checks against the final
release and maintainer approval remain part of the submission review.
