# Rebuild inst/cttir/logos.tar.xz from the SVG masters in inst/cttir/logos.
#
# The folder is the source of truth and stays in the repository; the built
# package ships only the archive, which hex_asset() unpacks once per session.
# Members are sorted and carry a fixed mode, owner and time, so rebuilding
# unchanged masters gives the same bytes. Run from the package root:
#
#   Rscript tools/logos-archive.R
write_logos_archive <- function() {
  masters <- file.path("inst", "cttir", "logos")
  archive <- file.path("inst", "cttir", "logos.tar.xz")
  if (!dir.exists(masters)) stop("Run this script from the package root.", call. = FALSE)
  files <- sort(list.files(masters, pattern = "[.]svg$", recursive = TRUE), method = "radix")
  if (!length(files)) stop("No SVG masters found in ", masters, call. = FALSE)
  # 25 October 2026, when the v5 library was supplied.
  mtime <- as.integer(as.POSIXct("2026-10-25", tz = "UTC"))

  field <- function(x, width) {
    x <- charToRaw(x)
    if (length(x) >= width) stop("Name too long for a tar header: ", rawToChar(x), call. = FALSE)
    c(x, raw(width - length(x)))
  }
  # POSIX ustar header for a regular file owned by uid and gid 0.
  header <- function(name, size) {
    h <- c(field(name, 100L), field("0000644", 8L), field("0000000", 8L),
           field("0000000", 8L), field(sprintf("%011o", size), 12L),
           field(sprintf("%011o", mtime), 12L), charToRaw("        "),
           charToRaw("0"), raw(100L), field("ustar", 6L), charToRaw("00"),
           raw(32L), raw(32L), raw(8L), raw(8L), raw(155L), raw(12L))
    h[149:156] <- c(charToRaw(sprintf("%06o", sum(as.integer(h)))), as.raw(c(0L, 32L)))
    h
  }
  pad <- function(n, block) raw((block - n %% block) %% block)

  members <- lapply(files, function(f) {
    bytes <- readBin(file.path(masters, f), "raw", file.size(file.path(masters, f)))
    c(header(f, length(bytes)), bytes, pad(length(bytes), 512L))
  })
  tar <- c(unlist(members, use.names = FALSE), raw(1024L))
  tar <- c(tar, pad(length(tar), 10240L))

  temp <- tempfile("logos-", tmpdir = dirname(archive), fileext = ".tar.xz")
  on.exit(unlink(temp), add = TRUE)
  writeBin(memCompress(tar, "xz"), temp)
  if (file.exists(archive)) unlink(archive)
  if (!file.rename(temp, archive)) stop("Could not write ", archive, call. = FALSE)
  message("Wrote ", archive, ": ", length(files), " SVG masters, ",
          format(file.size(archive), big.mark = ","), " bytes.")
}

write_logos_archive()
