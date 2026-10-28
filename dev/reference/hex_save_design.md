# Save and load a v5 editing project

JSON projects store declarative settings, additional parts and layer
edits; loading never evaluates R code. Files larger than 20 MiB and
unknown fields are rejected.

## Usage

``` r
hex_save_design(design, path)

hex_read_design(path)
```

## Arguments

- design:

  A
  [`hex_design()`](https://cttir.github.io/hexmakR/dev/reference/hex_design.md)
  object.

- path:

  JSON project path.

## Value

`hex_save_design()` returns the path invisibly; `hex_read_design()`
returns a validated design.
