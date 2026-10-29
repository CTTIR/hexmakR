# This versioned table drives both the R artwork and generated documentation CSS.
cttir_load_tokens <- function(path) {
  x <- utils::read.csv(path, stringsAsFactors = FALSE)
  base::stopifnot(!base::anyDuplicated(base::paste(x$group, x$token)))
  out <- x$value
  base::names(out) <- base::paste(x$group, x$token, sep = ".")
  out
}
# The installed table is read once per session.
cttir_tokens <- function() {
  if (base::is.null(.cttir_cache$tokens))
    .cttir_cache$tokens <- cttir_load_tokens(.cttir_path("design_tokens.csv"))
  .cttir_cache$tokens
}
cttir_token <- function(group, token) {
  key <- base::paste(group, token, sep = ".")
  tokens <- cttir_tokens()
  if (!key %in% base::names(tokens)) base::stop("Missing token: ", key)
  tokens[[key]]
}
