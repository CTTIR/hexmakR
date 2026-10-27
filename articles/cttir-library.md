# CTTIR v5 and project logos

The v5 library contains 45 identities. Named designs place the exact
package name inside the lower part of the hex, with the native R
scientific artwork above. The exterior is transparent. Light, dark and
monochrome modes share this layout. The original 1,035 assets are
included unchanged.

``` r

head(hex_catalog())
#>          name        repo   family      symbol      kind
#> 1    molpathR    molpathR clinical    molpathR R package
#> 2      pressR      pressR clinical      pressR R package
#> 3     scimagR     scimagR clinical     scimagR R package
#> 4 zhncommandR zhncommandR clinical zhncommandR R package
#> 5  brainwritR  brainwritR evidence  brainwritR R package
#> 6     delphyr     delphyR evidence     delphyr R package
#>                                                                    source
#> 1                 https://github.com/CTTIR/molpathR/blob/main/DESCRIPTION
#> 2                   https://github.com/CTTIR/pressR/blob/main/DESCRIPTION
#> 3                  https://github.com/CTTIR/scimagR/blob/main/DESCRIPTION
#> 4              https://github.com/CTTIR/zhncommandR/blob/main/DESCRIPTION
#> 5               https://github.com/CTTIR/brainwritR/blob/main/DESCRIPTION
#> 6 https://github.com/CTTIR/delphyR/blob/main/packages/delphyr/DESCRIPTION
#>     asset_dir
#> 1    molpathR
#> 2      pressR
#> 3     scimagR
#> 4 zhncommandR
#> 5  brainwritR
#> 6     delphyr
```

Create an editable design or locate an approved original:

``` r

design <- hex_design("phenoscapR")
print(design)
hex_export(design, "phenoscapR.svg")
hex_export(design, "phenoscapR.png", width = 1600)
hex_asset("phenoscapR", mode = "dark", layout = "lockup", format = "pdf")
```

Project logos can use hexagonal, regular pentagonal or square frames.
Choose any CTTIR motif and palette as a starting point, or a generic
built-in icon:

``` r

project <- logo_design("My project", motif = "phenoscapR", shape = "pentagon")
hex_export(project, "project.svg")
study <- logo_design("Study", shape = "square", icon = "microscope")
hex_export(study, "study.pdf")
```

Shapes use the same design object, palette roles, editable layers and
project format. Pentagonal and square exports have square canvases.
Hexagonal masters use the width/height ratio sqrt(3)/2. The
`layout = "motif"` option exports the standalone artwork on a
transparent square without a frame or name.

Inspect and modify vector geometry:

``` r

design <- hex_design("phenoscapR")
head(hex_layers(design))
#>           id    type      fill       col points
#> 1 layer_0001 polygon   #193F34   #009E73      6
#> 2 layer_0002   lines   #0C4E4B   #0C4E4B      7
#> 3 layer_0003   lines   #B2E1D5   #B2E1D5      2
#> 4 layer_0004 polygon #030A1240      <NA>     90
#> 5 layer_0005 polygon   #38B391      <NA>     90
#> 6 layer_0006   lines #F4F8FC99 #F4F8FC99     80
```

``` r

# Layer 1 is the frame. Shape IDs are deterministic within a composition.
edited <- hex_edit_layer(design, "layer_0001", fill = "#193E36")
# Move or recolour an individual shape; the input object stays unchanged.
edited <- hex_edit_layer(edited, "layer_0005", dx = 0.03, fill = "#45B59A")
hex_save_design(edited, "project.json")
restored <- hex_read_design("project.json")
hex_recipe(restored, "reproduce.R")
```

Coordinates refer to each shape’s local viewport. Fill, stroke, line
width, opacity, visibility, translation, scale and explicit point
coordinates can be edited. Artwork is clipped to its frame. Changes to a
silhouette can alter its scientific meaning; review the result at full
size and icon size. Changing the composition, frame or icon in the
editor resets shape overrides; Undo can restore the previous design. The
original assets are never modified.

``` r

hexmakr_app(package = "phenoscapR")
hexmakr_app(workspace = "classic")
```

Select a package, shape and name, then **Apply design**. Choose a vector
layer, optionally highlight it, edit its properties, then **Apply shape
edit**. The point editor can load the original coordinates for manual
adjustment. **Save project** downloads JSON; **Open saved project**
resumes that work. PNG, SVG, PDF and R-recipe downloads use the current
saved design settings. Pending form changes take effect only after
Apply. JSON loading validates fields and never evaluates uploaded R
code.

The bundled JetBrains Mono font supplies outlined name glyphs, so vector
exports do not depend on installed fonts. The shipped font OFL licences
are in `system.file("cttir/source/fonts", package = "hexmakR")`.

``` r

# 45 x (2 layouts x 3 modes x 3 formats + 5 icons) = 1,035 exports
hex_render_catalog("exports")
```

The twelve catalogue names present only in the older hexstickers
repository are preserved as legacy SVG references under `cttir/legacy`.
They are not claimed as approved v5 motifs. `hexmakeR` maps to
`hexmakR`; `delphyR` maps to `delphyr`. Archive and asset hashes
document the imported source material.

The identities `CTTIR` and `cttiR` differ only in case. To prevent
collisions on macOS and Windows, the organisation’s asset folder is
`CTTIR-brand`; the R package retains `cttiR`. `hex_catalog()$asset_dir`
records the mapping, and asset lookup, the gallery and batch rendering
use it. Displayed names remain exact. Original assets were re-imported
directly from distinct ZIP entries.
