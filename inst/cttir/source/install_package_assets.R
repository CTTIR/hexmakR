# Optional local installation helper. Does not publish or commit anything.
# Source this file and call cttir_install_assets("hyperspectR", "/path/to/package").
cttir_install_assets <- function(name,package_dir,kit_root=".",overwrite=FALSE) {
  registry<-utils::read.csv(base::file.path(kit_root,"packages.csv"),stringsAsFactors=FALSE)
  if(!name %in% registry$name)base::stop("Unknown identity: ",name)
  if(!base::file.exists(base::file.path(package_dir,"DESCRIPTION")))
    base::stop("package_dir must contain DESCRIPTION")
  target<-base::file.path(package_dir,"man","figures")
  base::dir.create(target,recursive=TRUE,showWarnings=FALSE)
  from<-c("hex.svg","hex.png","hex-dark.svg","hex-dark.png","lockup.svg","lockup.png")
  to<-c("logo.svg","logo.png","logo-dark.svg","logo-dark.png","logo-with-name.svg","logo-with-name.png")
  paths<-base::file.path(target,to)
  if(!overwrite && base::any(base::file.exists(paths)))
    base::stop("Some target assets exist. Review them, then use overwrite=TRUE if intended.")
  ok<-base::file.copy(base::file.path(kit_root,"logos",name,from),paths,overwrite=overwrite)
  if(!base::all(ok))base::stop("Some assets could not be copied")
  base::invisible(paths)
}
