# Reuse editable archive parts in another logo

Reused parts retain a validated snapshot of their native source
settings, colour overrides and edits. They remain independently
editable. No code, external files or serialised grid objects are loaded
from a project.

## Usage

``` r
hex_reuse_part(design, source, layer = NULL)
```

## Arguments

- design:

  Destination [`hex_design()`](hex_design.md) object.

- source:

  A catalogue identity or a [`hex_design()`](hex_design.md) object.

- layer:

  Native layer ID to reuse. `NULL` reuses all motif layers, excluding
  the source frame and name.

## Value

An updated destination design; its frame, name and palette are retained.

## Examples

``` r
d <- hex_reuse_part(logo_design("New project"), "phenoscapR", "layer_0007")
```
