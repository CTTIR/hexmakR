CTTIR R HEX SYSTEM V5 / CODER EDITION
25 October 2026

45 identities. Names inside the hex. Transparent exteriors. Entirely R-drawn.
Includes 37 R packages, five companion apps, hyperloom, phenoloom and CTTIR.

WHAT CHANGED
The named composition puts the exact package name inside the lower part of
the hex, with the scientific artwork above it. The artwork-only composition
remains available. Both use the same scientific motifs and group colours.
Names use JetBrains Mono SemiBold, matching themakR's package-brand font
role. Inter remains the prose and heading font; JetBrains Mono is the code
font. This is a CTTIR design using the familiar internal-name hex layout.

GROUP COLOURS
Each colour hex has a group-tinted fill and an opaque border in the group's
exact categorical colour. Light surfaces use a 14% group tint; dark surfaces
use a 24% group tint. The border is 5.5 points on the six-inch master.
Grayscale is supplied as a separate neutral alternative. Exact Okabe-Ito
seeds remain unchanged, and package silhouettes also support recognition.

TWO FORMS, THREE MODES
logos/<exact-name>/ contains 23 files:
  lockup.svg / .png / .pdf              artwork + name INSIDE, light surface
  lockup-dark.svg / .png / .pdf         artwork + name INSIDE, dark surface
  lockup-mono.svg / .png / .pdf         artwork + name INSIDE, grayscale
  hex.svg / .png / .pdf                 artwork only, light surface
  hex-dark.svg / .png / .pdf            artwork only, dark surface
  hex-mono.svg / .png / .pdf            artwork only, grayscale
  icon-32.png / -48.png / -64.png / -128.png / -256.png

Both master compositions are 1600 x 1848 pixels. Small icons have square
canvases. Hex interiors are filled; everything outside the hex is transparent.
There is no external package-name line or rectangular image background.
SVG and PDF are vector formats. SVG name glyphs are paths, so displaying an
export does not require the font to be installed. R source stays editable.

SMALL UPLOAD BUNDLES
Start with CTTIR_Codex_Start_v5.zip for the R source, fonts and vector assets.
Optional PNG and gallery archives supply the original rendered images.
Each supplied upload ZIP is below 5,000,000 bytes; this is a conservative
packaging target, not a claim about a documented Codex upload limit.
Extract add-ons into the same parent directory as the starter so their
CTTIR_R_Hex_System_v5/ folders merge. These are ordinary independent ZIPs,
not binary split archives. See START_HERE.txt and UPLOAD_PARTS.csv in the
upload bundles for their contents and extraction instructions.

RUN
Open R with the extracted project directory as its working directory.
  # Regenerate all images, galleries and shared CSS tokens.
  base::source("render_all.R")
  # Review colour-vision simulations and text roles.
  base::source("review_cvd.R")
  # Validate the generated exports.
  base::source("validate_exports.R")
Or use Rscript with the corresponding filenames.

To regenerate one identity:
  # Load the renderer, then select the exact registered name.
  base::source("R/cttir_hex.R")
  cttir_render_package("hyperloom", root = ".")
To regenerate both suites:
  base::source("render_looms.R")
Individual scripts/draw_<exact-name>.R entry points are also included.

REQUIREMENTS AND FONTS
R with Cairo graphics; check base::capabilities("cairo"). The renderer uses
only bundled base, grid, grDevices, utils and tools packages. No network call
or install.packages() step runs during image rendering. An R runtime is not
included in the upload bundles.
On Linux the included fontconfig profile loads fonts/ before the first device.
On Windows/macOS install the included Inter and JetBrains Mono font files and
restart R. Use JetBrains Mono SemiBold for the intended name weight. Native
R bold-face matching can select a different installed weight on other systems;
compare a proof or use the supplied outlined SVGs for identical presentation.
Font licences are included. CTTIR_BRAND_FONT can select another installed
font, but its metrics and appearance will differ from the approved profile.

FIT WITH VIGNETTES
Read integration/ADOPTION.txt. design_tokens.csv supplies the R colour and
type roles and the generated CSS. Keep themakR as the shared pkgdown template.
Use the named lockup directly in vignettes, package overview pages, figures
and README images. Names remain inside the hex in every named export.
Artwork-only hexes suit small navigation logos beside an existing text name.
Standalone html_vignette builds need explicit CSS; they do not automatically
inherit the pkgdown template. A companion stylesheet and Rmd example are
included. install_package_assets.R supports an optional local asset copy.
No GitHub repository or published site is changed by this kit.

REVIEW
Open index.html locally to browse all 45 identities and switch compositions
and colour modes. The webpage supplies its own neutral canvas; the individual
assets retain transparent exteriors. CTTIR_R_Hex_Gallery.pdf shows both forms.
gallery/ contains transparent review PNGs, and gallery/two-versions.png
compares both loom suites. CTTIR_CVD_Review.pdf compares representative marks
in normal, protan, deutan, tritan and grayscale conditions. Some generated
review files are supplied in optional add-on bundles or can be regenerated.

ACCESSIBILITY
Colour is a supporting cue. Distinct shapes and accessible package names
identify the marks without relying on hue alone. Topic colours are not body
text or interaction-state colours. Contrast checks and vision simulations
are screening aids, not certification of a complete website or every detail.
SVG name lettering is outlined: supply meaningful image alt text, such as
alt="hyperloom". If an adjacent caption already identifies the image, empty
alt can avoid repeating the package name to a screen reader.

SOURCE MAP
design_tokens.csv       shared fonts, documentation neutrals and topic seeds
R/cttir_hex.R           composition, exact-name fitting, transparent exports
R/motifs.R              45 custom scientific illustrations
R/primitives.R          reusable R vector geometry
R/palette.R             group-tinted surfaces and material roles
R/accessibility.R       documented colour-vision simulation matrices
write_integration.R    generate CSS tokens from the same design table
packages.csv           exact names, topic assignments and provenance
design_rationale.csv   intended meaning of each scientific motif
validation/            export manifest and check results
provenance/            dated source snapshot identifiers and links

hyperloom and phenoloom are user-specified suite identities without an R
suffix; their inclusion does not assert newly audited repository contents.
All illustrations are native R geometry, with no raster artwork, downloaded
icons, tracing or image-generation output embedded in the vector assets.
