# Generate every export for tivis.r with the shared R vector renderer.
# Usage: Rscript scripts/draw_tivis.r.R
args <- base::commandArgs(trailingOnly = FALSE)
script <- base::sub("^--file=", "", args[base::grepl("^--file=", args)])
root <- if (base::length(script)) base::dirname(base::dirname(base::normalizePath(script[1]))) else "."
base::source(base::file.path(root, "R", "cttir_hex.R"))
cttir_render_package("tivis.r", root = root)
