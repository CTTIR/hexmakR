# Create a project logo in three frame shapes

Start a fresh project with its name inside a hexagonal, pentagonal or
square frame. Add individual parts with
[`hex_add_part()`](https://cttir.github.io/hexmakR/dev/reference/hex_add_part.md),
optionally reuse archive artwork with
[`hex_reuse_part()`](https://cttir.github.io/hexmakR/dev/reference/hex_reuse_part.md),
or choose a generic icon. The same editing, project and export functions
work with every frame shape.

## Usage

``` r
logo_design(
  name,
  motif = NULL,
  shape = c("hex", "pentagon", "square"),
  icon = NULL,
  ...
)
```

## Arguments

- name:

  Project name shown inside the frame.

- motif:

  Optional CTTIR archive identity supplying a motif and palette. `NULL`
  starts a fresh composition without archive artwork.

- shape:

  `hex`, `pentagon` or `square`.

- icon:

  Optional generic icon key, replacing the CTTIR motif.

- ...:

  Other settings passed to
  [`hex_design()`](https://cttir.github.io/hexmakR/dev/reference/hex_design.md).

## Value

An editable `hex_design` object.

## Examples

``` r
project <- logo_design("New project", shape = "pentagon")
project <- hex_add_part(project, "circle")
project <- hex_reuse_part(project, "phenoscapR")
logo_design("Study", shape = "square", icon = "microscope")
```
