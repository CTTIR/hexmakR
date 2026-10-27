# Render colour-vision reviews directly in R and check documentation text roles.
args<-base::commandArgs(trailingOnly=FALSE)
script<-base::sub("^--file=","",args[base::grepl("^--file=",args)])
root<-if(base::length(script))base::dirname(base::normalizePath(script[1])) else "."
base::source(base::file.path(root,"R","cttir_hex.R"))
visions<-c("normal","protan","deutan","tritan","gray")
samples<-c("hyperspectR","phenoscapR","bambamR","molpathR","songR","dynasimR","scimapR","themakR","hyperloom","phenoloom")
registry<-utils::read.csv(base::file.path(root,"packages.csv"),stringsAsFactors=FALSE)
page<-function(names,mode="light") {
  grid::grid.newpage()
  grid::grid.text(base::paste("CTTIR / colour-vision review /",mode),.04,.97,just="left",
    gp=grid::gpar(fontfamily="Inter",fontface=2,fontsize=18,col="#212121"))
  for(j in base::seq_along(visions))grid::grid.text(visions[j],.23+(j-1)*.163,.917,
    gp=grid::gpar(fontfamily="Inter",fontsize=10,col="#444444"))
  ch<-.81/base::length(names)
  for(i in base::seq_along(names)) {
    grid::grid.text(names[i],.025,.872-ch*(i-.5),just="left",
      gp=grid::gpar(fontfamily="JetBrains Mono",fontsize=8,col="#212121"))
    f<-registry$family[registry$name==names[i]]
    for(j in base::seq_along(visions)) {
      base::options(cttir.vision=visions[j])
      grid::pushViewport(grid::viewport(.23+(j-1)*.163,.872-ch*(i-.5),
        width=grid::unit(1.50,"inches"),height=grid::unit(1.50/(base::sqrt(3)/2),"inches")))
      cttir_draw(names[i],f,mode,newpage=FALSE);grid::popViewport()
    }
  }
  base::options(cttir.vision="normal")
  grid::grid.text("Machado severity-100 simulations + luminance grayscale; shapes remain essential identity cues.",
    .04,.035,just="left",gp=grid::gpar(fontfamily="Inter",fontsize=9,col="#555555"))
}
cttir_device(function()grDevices::cairo_pdf(base::file.path(root,"CTTIR_CVD_Review.pdf"),
  width=13,height=11.5,onefile=TRUE,bg="transparent"),function()
    for(mode in c("light","dark"))for(batch in list(samples[1:5],samples[6:10]))page(batch,mode))
# Standard relative-luminance contrast, computed from unrounded channels.
luminance<-function(hex) {
  x<-grDevices::col2rgb(hex)/255
  x<-base::ifelse(x<=.04045,x/12.92,((x+.055)/1.055)^2.4)
  base::sum(x*c(.2126,.7152,.0722))
}
contrast<-function(a,b) {
  z<-base::sort(c(luminance(a),luminance(b)))
  (z[2]+.05)/(z[1]+.05)
}
checks<-base::expand.grid(mode=c("light","dark"),role=c("text","heading","link"),vision=visions,
  stringsAsFactors=FALSE)
checks$contrast<-base::vapply(base::seq_len(base::nrow(checks)),function(i) {
  x<-checks[i,];fg<-cttir_token(x$mode,x$role);bg<-cttir_token(x$mode,"page")
  if(x$vision!="normal") {fg<-cttir_simulate_cvd(fg,x$vision);bg<-cttir_simulate_cvd(bg,x$vision)}
  contrast(fg,bg)
},numeric(1))
base::dir.create(base::file.path(root,"validation"),showWarnings=FALSE)
utils::write.csv(checks,base::file.path(root,"validation","text_contrast.csv"),row.names=FALSE)
base::stopifnot(base::min(checks$contrast)>=4.5)
base::message("Minimum tested text contrast: ",base::round(base::min(checks$contrast),2),":1")

# Names now sit inside the tile, so check their actual group-tinted background.
named_checks <- base::expand.grid(family=base::names(cttir_accents),
  mode=c("light","dark","mono"),vision=visions,stringsAsFactors=FALSE)
named_checks$contrast <- base::vapply(base::seq_len(base::nrow(named_checks)),function(i) {
  x <- named_checks[i,];base::options(cttir.vision=x$vision)
  s <- cttir_style(x$family,x$mode);contrast(s$ink,s$face)
},numeric(1))
base::options(cttir.vision="normal")
utils::write.csv(named_checks,base::file.path(root,"validation","inside_name_contrast.csv"),row.names=FALSE)
base::stopifnot(base::min(named_checks$contrast)>=4.5)
base::message("Minimum inside-name contrast: ",base::round(base::min(named_checks$contrast),2),":1")
