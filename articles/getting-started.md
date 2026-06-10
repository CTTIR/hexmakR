# Getting Started with hexmakR

![](../../../_temp/Library/hexmakR/logo/logo.svg)

### Installation

Install hexmakR from CRAN:

``` r

install.packages("hexmakR")
```

Or install the development version from GitHub:

``` r

# install.packages("pak")
pak::pak("cttir/hexmakR")
```

### Your first hex sticker in 3 lines

``` r

library(hexmakR)

hex_sticker("mypackage", icon = "atom", theme = "stats")
```

That’s it. The default settings produce a dark-themed sticker with the
`stats` color palette and an atom icon.

### Saving to a file

Pass `filename` to write a transparent PNG directly:

``` r

hex_sticker(
  "mypackage",
  icon     = "dna",
  theme    = "genomics",
  filename = "man/figures/logo.png"
)
```

The file will have the correct hexb.in aspect ratio (width / height = √3
/ 2) and a transparent background, ready for use in your README or
pkgdown site.

### Exploring themes

``` r

names(hexmakr_themes())
```

Preview a theme interactively:

``` r

hexmakr_preview_theme("genomics", mode = "dark")
hexmakr_preview_theme("genomics", mode = "light")
```

### Exploring icons

``` r

# All categories
names(hexmakr_icons())

# Icons in a specific category
hexmakr_icons("biology")
```

### Customizing colors

Override any theme color individually:

``` r

hex_sticker(
  "mypackage",
  theme        = "stats",
  mode         = "dark",
  bg           = "#0D1117",
  accent       = "#58A6FF",
  text_color   = "#FFFFFF",
  border_color = "#58A6FF",
  sub_color    = "#8B949E"
)
```

### Choosing a font

``` r

hex_sticker(
  "mypackage",
  font_family = "serif",
  font_bold   = TRUE,
  font_italic = TRUE,
  font_size   = 14
)
```

Available font shorthands: `"mono"`, `"courier"`, `"consolas"`,
`"source_code"`, `"fira_code"`, `"serif"`, `"times"`, `"palatino"`,
`"sans"`, `"helvetica"`, `"roboto"`, `"open_sans"`, `"lato"`.

### Next steps

- For full parameter reference:
  [`vignette("programmatic-usage")`](https://cttir.github.io/hexmakR/articles/programmatic-usage.md)
- To use the interactive designer:
  [`vignette("shiny-app")`](https://cttir.github.io/hexmakR/articles/shiny-app.md)
  or just run
  [`hexmakr_app()`](https://cttir.github.io/hexmakR/reference/hexmakr_app.md)

## Use of LLM tools

Portions of this package were prepared with assistance from large
language model tooling for narrowly defined, non-authorial tasks:
copyediting, prose smoothing, Markdown/LaTeX formatting, scaffolding of
boilerplate files (CI configs, build scripts), code refactoring. The
tools used were [Chat
AI](https://kisski.gwdg.de/leistungen/2-02-llm-service/), the LLM
service of KISSKI (GWDG), and a self-hosted **Mistral Small (24B,
Apache-2.0)** run locally via [Ollama](https://ollama.com/) and the
`ollamar` R package — local inference only, with no data sent to third
parties for the self-hosted model.

All scientific claims, methodological choices, analyses,
interpretations, and conclusions are the author’s own. No LLM-generated
text was incorporated without review and revision, and every reference
was verified against its DOI, arXiv ID, or ISBN.
