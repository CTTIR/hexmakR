# hexmakR 0.2.0 verification — 27 October 2026

- Source build, including all vignettes: PASS.
- R CMD check --no-manual: Status OK (0 errors, 0 warnings, 0 notes).
- Full test suite: 80 tests, 1,265 passing assertions; 0 failures, errors,
  warnings or skips. R 4.6.1 on Apple silicon macOS, Cairo available.
- 45 current v5 identities, 1,035 original assets. Every imported master
  matches its exact ZIP entry SHA-256. Case-insensitive paths are unique;
  CTTIR uses CTTIR-brand, separate from the cttiR package.
- Full regeneration: 1,035 exports (495 PNG, 270 SVG, 270 PDF).
- All 990 original/generated PNGs decoded with expected dimensions and
  transparent corners. All 180 monochrome masters are achromatic.
- All 540 original/generated SVGs parsed without embedded image/script nodes;
  all 540 PDFs parsed by pdfinfo. Generated names are vector glyph paths.
- All 45 named designs inspected on dark, light and monochrome contact sheets.
- Hexagonal, regular pentagonal and square project frames verified. All 46
  original generic icons render in project logos.
- Browser: named phenoscapR preview, pentagonal/square project layouts,
  1600 x 1600 PNG download, shape editing, undo/reset and JSON download verified.
  The downloaded JSON retained the manual fill change (#163D50); it was read
  back with hex_read_design and its R recipe produced SVG and PNG successfully.
- Browser upload automation timed out before obtaining the native file chooser.
  Project import, validation and edit restoration passed Shiny server tests.
- Bundled-font names require no local font installation. Installed package
  size is approximately 44 MB because all original assets are included.

Source provenance and file hashes: inst/cttir/archive-inventory.json,
inst/cttir/asset-provenance.json and inst/cttir/SHA256.json.
The source archives are unchanged. Older-only SVGs are labelled as legacy.
No remote publishing or changes to other package repositories were performed.

Fresh-session regression: hex_grob/hex_export preserve the current device,
create no unintended Rplots.pdf, and produce unchanged reference pixels.
