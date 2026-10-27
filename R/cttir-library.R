# Installed v5 source is isolated from the user's global environment.
.cttir_cache <- new.env(parent = emptyenv())

.cttir_path <- function(...) {
  path <- system.file("cttir", ..., package = "hexmakR")
  if (!nzchar(path)) stop("The installed CTTIR library is missing.", call. = FALSE)
  path
}

.cttir_engine <- function() {
  if (!is.null(.cttir_cache$engine)) return(.cttir_cache$engine)
  env <- new.env(parent = baseenv())
  root <- .cttir_path("source")
  sys.source(file.path(root, "R", "tokens.R"), env)
  env$cttir_tokens <- env$cttir_load_tokens(file.path(root, "design_tokens.csv"))
  for (file in c("accessibility.R", "palette.R", "primitives.R", "motifs.R")) {
    sys.source(file.path(root, "R", file), env)
  }
  .cttir_cache$engine <- env
  env
}

#' Browse the CTTIR v5 identities
#'
#' The registry includes 37 R packages, five companion apps, two suites and
#' the CTTIR organisation identity. Exact spelling and case are preserved.
#' @param family Optional family key used to filter the registry.
#' @return A data frame with identity, repository, family, symbol, kind and source.
#' @export
#' @examples
#' hex_catalog()
#' hex_catalog("spectral")
hex_catalog <- function(family = NULL) {
  x <- utils::read.csv(.cttir_path("packages.csv"), stringsAsFactors = FALSE)
  if (!is.null(family)) x <- x[x$family %in% family, , drop = FALSE]
  x$asset_dir <- ifelse(x$name == "CTTIR", "CTTIR-brand", x$name)
  rownames(x) <- NULL
  x
}

.identity_row <- function(package) {
  .scalar_text(package, "package")
  row <- hex_catalog()
  row <- row[row$name == package, , drop = FALSE]
  if (nrow(row) != 1L) stop("Unknown CTTIR identity: ", package, call. = FALSE)
  row
}

#' Locate an original approved v5 asset
#'
#' These files are the unchanged supplied masters. Use [hex_export()] to
#' regenerate artwork or export an edited design.
#' @param package Exact identity from [hex_catalog()].
#' @param mode One of `dark`, `light`, `mono`.
#' @param layout `lockup` (name inside), `hex` (artwork only), or `icon`.
#' @param format File format: `svg`, `png`, or `pdf`.
#' @param size Icon width, one of 32, 48, 64, 128, 256. Icons use dark mode.
#' @return An absolute file path.
#' @export
#' @examples
#' hex_asset("phenoscapR")
hex_asset <- function(package, mode = c("dark", "light", "mono"),
                      layout = c("lockup", "hex", "icon"),
                      format = c("svg", "png", "pdf"), size = 128L) {
  .identity_row(package)
  mode <- match.arg(mode); layout <- match.arg(layout); format <- match.arg(format)
  if (layout == "icon") {
    if (format != "png" || mode != "dark" || length(size) != 1L ||
        !size %in% c(32, 48, 64, 128, 256)) {
      stop("Original icons are dark PNGs in sizes 32, 48, 64, 128 or 256.", call. = FALSE)
    }
    stem <- paste0("icon-", size)
  } else stem <- paste0(layout, if (mode == "light") "" else paste0("-", mode))
  .cttir_path("logos", .identity_row(package)$asset_dir, paste0(stem, ".", format))
}

.scalar_text <- function(x, name, empty = FALSE) {
  if (!is.character(x) || length(x) != 1L || is.na(x) ||
      (!empty && !nzchar(x)) || nchar(x, type = "bytes") > 200L) {
    stop(name, " must be a single short string.", call. = FALSE)
  }
  invisible(x)
}
.scalar_number <- function(x, name, low, high) {
  if (!is.numeric(x) || length(x) != 1L || !is.finite(x) || x < low || x > high) {
    stop(name, " must be a finite number between ", low, " and ", high, ".", call. = FALSE)
  }
  invisible(x)
}
.named_fields <- function(x, allowed, what) {
  if (!is.list(x) || (length(x) && (is.null(names(x)) || anyDuplicated(names(x)) ||
      any(!nzchar(names(x))) || any(!names(x) %in% allowed)))) {
    stop("Invalid ", what, " fields.", call. = FALSE)
  }
}
.color_value <- function(x) {
  .scalar_text(x, "colour")
  tryCatch(grDevices::col2rgb(x), error = function(e) stop("Invalid colour: ", x, call. = FALSE))
  invisible(x)
}
