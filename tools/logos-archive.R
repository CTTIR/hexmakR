# Rebuild inst/cttir/logos.tar.xz from the SVG and PDF masters in
# inst/cttir/logos, and inst/cttir/logos.sha256 from the hashes recorded for
# them in inst/cttir/SHA256.json.
#
# The folder is the source of truth and stays in the repository; the built
# package ships only the archive, which hex_asset() unpacks once per session,
# and the hash list, which the tests use to check the installed masters.
# Members are sorted and carry a fixed mode, owner and time, so rebuilding
# unchanged masters gives the same bytes. Every master must match the hash
# recorded when the library was imported. Needs R 4.5.0 or later for
# tools::sha256sum(). Run from the package root:
#
#   Rscript tools/logos-archive.R
write_logos_archive <- function() {
  masters <- file.path("inst", "cttir", "logos")
  archive <- file.path("inst", "cttir", "logos.tar.xz")
  hashes <- file.path("inst", "cttir", "logos.sha256")
  if (!dir.exists(masters)) stop("Run this script from the package root.", call. = FALSE)
  files <- sort(list.files(masters, pattern = "[.](svg|pdf)$", recursive = TRUE), method = "radix")
  if (!length(files)) stop("No SVG or PDF masters found in ", masters, call. = FALSE)

  recorded <- jsonlite::fromJSON(file.path("inst", "cttir", "SHA256.json"))
  key <- paste0("logos/", files)
  if (!all(key %in% names(recorded))) {
    stop("Not recorded in SHA256.json: ", paste(files[!key %in% names(recorded)], collapse = ", "),
         call. = FALSE)
  }
  sha <- unname(tools::sha256sum(file.path(masters, files)))
  changed <- sha != unlist(recorded[key], use.names = FALSE)
  if (any(changed)) {
    stop("Masters differ from SHA256.json: ", paste(files[changed], collapse = ", "), call. = FALSE)
  }
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

  write_atomic <- function(bytes, path) {
    temp <- tempfile("logos-", tmpdir = dirname(path))
    on.exit(unlink(temp))
    writeBin(bytes, temp)
    if (file.exists(path)) unlink(path)
    if (!file.rename(temp, path)) stop("Could not write ", path, call. = FALSE)
  }
  write_atomic(memCompress(tar, "xz"), archive)
  # The format of sha256sum, with LF line endings on every platform.
  write_atomic(charToRaw(paste0(sha, "  ", files, "\n", collapse = "")), hashes)
  message("Wrote ", archive, ": ", sum(endsWith(files, ".svg")), " SVG and ",
          sum(endsWith(files, ".pdf")), " PDF masters, ",
          format(file.size(archive), big.mark = ","), " bytes; and ", hashes, ".")
}

write_logos_archive()
