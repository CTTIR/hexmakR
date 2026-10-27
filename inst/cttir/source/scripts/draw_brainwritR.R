# Generate every export for brainwritR with the shared R vector renderer.
# Usage: Rscript scripts/draw_brainwritR.R
args <- base::commandArgs(trailingOnly = FALSE)
script <- base::sub("^--file=", "", args[base::grepl("^--file=", args)])
root <- if (base::length(script)) base::dirname(base::dirname(base::normalizePath(script[1]))) else "."
base::source(base::file.path(root, "R", "cttir_hex.R"))
cttir_render_package("brainwritR", root = root)
