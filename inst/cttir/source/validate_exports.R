# Structural validation requiring only R's bundled packages.
# The delivery was also pixel-decoded and PDF/XML-parsed before packaging.
args<-base::commandArgs(trailingOnly=FALSE)
script<-base::sub("^--file=","",args[base::grepl("^--file=",args)])
root<-if(base::length(script))base::dirname(base::normalizePath(script[1])) else "."
r<-utils::read.csv(base::file.path(root,"packages.csv"),stringsAsFactors=FALSE)
stems<-c("hex","hex-dark","hex-mono","lockup","lockup-dark","lockup-mono")
expected<-c(base::as.vector(base::outer(stems,c("svg","png","pdf"),base::paste,sep=".")),
  base::paste0("icon-",c(32,48,64,128,256),".png"))
files<-base::unlist(base::lapply(r$name,function(n)base::file.path(root,"logos",n,expected)))
base::stopifnot(base::all(base::file.exists(files)),base::all(base::file.info(files)$size>100))
for(p in files[base::grepl("[.]svg$",files)]) {
  txt<-base::paste(base::readLines(p,warn=FALSE),collapse="\n")
  if(base::grepl("<image|<script|data:image|https?://[^\" ]+[.]png",txt))base::stop("Unexpected embedded content: ",p)
  if(base::grepl("/hex[^/]*[.]svg$",p) && base::grepl("<text|<symbol",txt))
    base::stop("Text or glyph symbols in an artwork-only hex: ",p)
}
for(p in files[base::grepl("[.]png$",files)]) {
  con<-base::file(p,"rb");header<-base::readBin(con,"raw",n=26);base::close(con)
  base::stopifnot(base::identical(header[1:8],base::as.raw(c(137,80,78,71,13,10,26,10))),
    base::as.integer(header[26]) %in% c(3L,4L,6L))
  # Cairo may optimise small alpha PNGs into indexed colour (type 3).
  if(base::as.integer(header[26])==3L) {
    con<-base::file(p,"rb");raw<-base::readBin(con,"raw",n=base::file.info(p)$size);base::close(con)
    base::stopifnot(base::grepl("74524e53",base::paste(base::format(raw),collapse="")))
  }
}
base::dir.create(base::file.path(root,"validation"),showWarnings=FALSE)
out<-base::data.frame(path=base::substring(files,base::nchar(root)+2L),bytes=base::file.info(files)$size,
  md5=base::unname(tools::md5sum(files)))
utils::write.csv(out,base::file.path(root,"validation","exports.csv"),row.names=FALSE)
base::message(base::nrow(r)," identities / ",base::length(files)," exports passed structural checks.")
