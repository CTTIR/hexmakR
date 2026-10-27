# Run Rscript render_all.R, or source from the extracted project folder.
args<-base::commandArgs(trailingOnly=FALSE)
script<-base::sub("^--file=","",args[base::grepl("^--file=",args)])
root<-if(base::length(script))base::dirname(base::normalizePath(script[1])) else "."
base::source(base::file.path(root,"R","cttir_hex.R"))
registry<-utils::read.csv(base::file.path(root,"packages.csv"),stringsAsFactors=FALSE)
base::stopifnot(!base::anyDuplicated(registry$name),base::capabilities("cairo"))
for(i in base::seq_len(base::nrow(registry))) {
  base::message(i," / ",base::nrow(registry),"  ",registry$name[i])
  cttir_render_package(registry$name[i],root)
}
base::source(base::file.path(root,"make_gallery.R"));cttir_make_galleries(root)
base::source(base::file.path(root,"write_integration.R"));cttir_write_integration(root)
base::source(base::file.path(root,"make_index.R"));cttir_make_index(root)
roles<-base::do.call(base::rbind,base::lapply(c("light","dark","mono"),function(mode)
  base::do.call(base::rbind,base::lapply(base::names(cttir_accents),function(family) {
    s<-cttir_style(family,mode);n<-base::setdiff(base::names(s),"mode")
    base::data.frame(family=family,mode=mode,role=n,hex=base::unlist(s[n],use.names=FALSE))
  }))))
utils::write.csv(roles,base::file.path(root,"colour_roles.csv"),row.names=FALSE)
base::writeLines(utils::capture.output(utils::sessionInfo()),base::file.path(root,"SESSION_INFO.txt"))
