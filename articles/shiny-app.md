# Interactive Shiny App

![](../../../_temp/Library/hexmakR/logo/logo.svg)

## Launching the app

``` r

library(hexmakR)
hexmakr_app()
```

This opens the hexmakR Shiny designer in your default browser (or the
RStudio Viewer pane).

## App layout

The app is divided into two panels:

### Left panel — Live preview

- The hex sticker updates in real time as you change any control.
- The **Export PNG** button downloads a 600 × 693 px transparent PNG.

### Right panel — Controls

The controls are organized into five sections:

#### 1. Text

| Control       | Description                          |
|---------------|--------------------------------------|
| Package Name  | The main text on the sticker         |
| Subtitle      | Optional smaller text below the name |
| URL           | Optional URL near the bottom         |
| Font Size     | Slider from 6–32 pt                  |
| Font          | Dropdown with 13 font options        |
| Bold / Italic | Checkboxes                           |

#### 2. Icon

| Control       | Description                                   |
|---------------|-----------------------------------------------|
| Built-in Icon | Dropdown of all 46 icons, grouped by category |
| Custom Image  | Upload a PNG or JPEG to use instead           |
| Icon Size     | Multiplier from 0.3 to 2.5                    |

#### 3. Theme

| Control | Description                 |
|---------|-----------------------------|
| Theme   | Dropdown with all 19 themes |
| Mode    | Dark or Light               |

#### 4. Custom Colors

Five color pickers let you override any individual theme color:
Background, Accent, Text, Border, and Subtitle.

#### 5. Border

| Control           | Description                            |
|-------------------|----------------------------------------|
| Border Width      | 0–8 mm                                 |
| Inner Accent Ring | Checkbox to show/hide the inner border |

## Workflow tips

1.  **Start with a theme** — pick a theme in the Theme section that
    matches your package’s domain.
2.  **Pick an icon** — use the Built-in Icon dropdown or upload a custom
    logo.
3.  **Adjust text** — set your package name; add a subtitle only if it
    fits at the chosen font size.
4.  **Fine-tune colors** — the Custom Colors section lets you tweak
    individual colors without switching themes.
5.  **Export** — click the Export PNG button. The file will be named
    after your package.

## After export

Place the downloaded PNG at `man/figures/logo.png` in your package
directory and add it to your README:

``` markdown
<img src="man/figures/logo.png" align="right" height="139" />
```

See
[`vignette("programmatic-usage")`](https://cttir.github.io/hexmakR/articles/programmatic-usage.md)
for details on integrating the sticker with usethis and pkgdown.
