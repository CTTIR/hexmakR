# Create a project logo in three frame shapes

Reuse a CTTIR scientific motif or a generic icon for a project, with its
name inside a hexagonal, pentagonal or square frame. The same editing,
project and export functions work with all shapes.

## Usage

``` r
logo_design(
  name,
  motif = "hexmakR",
  shape = c("hex", "pentagon", "square"),
  icon = NULL,
  ...
)
```

## Arguments

- name:

  Project name shown inside the frame.

- motif:

  CTTIR identity supplying the motif and default palette.

- shape:

  `hex`, `pentagon` or `square`.

- icon:

  Optional generic icon key, replacing the CTTIR motif.

- ...:

  Other settings passed to [`hex_design()`](hex_design.md).

## Value

An editable `hex_design` object.

## Examples

``` r
logo_design("My project", motif = "phenoscapR", shape = "pentagon")

logo_design("Study", shape = "square", icon = "microscope")
```
