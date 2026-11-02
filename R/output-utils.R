# Complete an output beside its destination, then replace it in one rename.
# Keeping both paths in the same directory avoids cross-volume rename failures.
# A failed writer or rename leaves any previous destination untouched.
.write_output <- function(filename, writer) {
  if (!is.character(filename) || length(filename) != 1L || is.na(filename) ||
      !nzchar(filename)) stop("filename must be a path.", call. = FALSE)
  parent <- dirname(filename)
  if (!dir.exists(parent)) dir.create(parent, recursive = TRUE, showWarnings = FALSE)
  if (!dir.exists(parent)) stop("Could not create output directory: ", parent, call. = FALSE)
  if (dir.exists(filename)) stop("Output path is a directory: ", filename, call. = FALSE)
  staged <- tempfile(".hexmakR-stage-", tmpdir = parent,
                     fileext = paste0(".", tools::file_ext(filename)))
  on.exit(unlink(staged), add = TRUE)
  writer(staged)
  if (!file.exists(staged) || !file.rename(staged, filename))
    stop("Could not write ", filename, ". Any previous file was preserved.", call. = FALSE)
  invisible(filename)
}

# Closing an export device may select a different pre-existing device. Restore
# the caller's selection, but never select the null device (which opens one).
.close_output_device <- function(device, previous) {
  if (device %in% grDevices::dev.list()) grDevices::dev.off(device)
  if (previous > 1L && previous %in% grDevices::dev.list()) grDevices::dev.set(previous)
  invisible(NULL)
}
