# Regenerate both suite identities, with and without the name inside.
args<-base::commandArgs(trailingOnly=FALSE)
script<-base::sub("^--file=","",args[base::grepl("^--file=",args)])
root<-if(base::length(script))base::dirname(base::normalizePath(script[1])) else "."
base::source(base::file.path(root,"R","cttir_hex.R"))
for(name in c("hyperloom","phenoloom"))cttir_render_package(name,root)
