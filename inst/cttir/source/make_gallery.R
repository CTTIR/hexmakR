# Review sheets use the same R vector functions as the individual exports.
cttir_groups <- function(registry) {
  specs <- list(
    list(title="Spectral imaging",families="spectral",kind="R package",cols=4),
    list(title="Spatial biology",families="spatial",kind="R package",cols=4),
    list(title="Molecular data & clinical science",families=c("omics","clinical"),kind="R package",cols=3),
    list(title="Learning, inference & simulation",families=c("methods","simulation"),kind="R package",cols=3),
    list(title="Evidence & research infrastructure",families=c("evidence","platform"),kind="R package",cols=5),
    list(title="Applications & the CTTIR identity",families=NULL,kind=c("Companion app","Organisation"),cols=3),
    list(title="Connected research suites",families=c("spectral","spatial"),kind="Suite",cols=2))
  base::lapply(specs,function(g) {
    g$rows <- registry[registry$kind %in% g$kind,,drop=FALSE]
    if(!base::is.null(g$families)) g$rows <- g$rows[g$rows$family %in% g$families,,drop=FALSE]
    g$rows <- g$rows[base::order(g$rows$family,g$rows$name),,drop=FALSE]
    g
  })
}
cttir_gallery_page <- function(g,page,mode="light",layout="lockup") {
  font <- cttir_token("type","body_font")
  grid::grid.newpage()
  # Transparent canvas. Gallery headings stay dark for viewing on a light page.
  grid::grid.text("CTTIR / CODE + CRAFT",.035,.956,just="left",
    gp=grid::gpar(fontfamily=font,fontface=2,fontsize=10,col="#555555"))
  grid::grid.text(g$title,.035,.907,just="left",
    gp=grid::gpar(fontfamily=font,fontface=2,fontsize=25,col="#212121"))
  label <- if(layout=="hex") "Artwork only / unnamed hex edition" else "Artwork + exact name inside / JetBrains Mono"
  grid::grid.text(label,.035,.863,just="left",gp=grid::gpar(fontfamily=font,fontsize=11,col="#555555"))
  nr <- base::ceiling(base::nrow(g$rows)/g$cols)
  for(i in base::seq_len(base::nrow(g$rows))) {
    cc<-(i-1)%%g$cols;rr<-(i-1)%/%g$cols;cw<-.94/g$cols;ch<-.76/nr
    d<-cttir_dimensions(layout);aspect<-d$width/d$height
    wi<-grid::convertWidth(grid::unit(cw*.90,"npc"),"inches",valueOnly=TRUE)
    hi<-grid::convertHeight(grid::unit(ch*.91,"npc"),"inches",valueOnly=TRUE)
    ww<-base::min(wi,hi*aspect)
    grid::pushViewport(grid::viewport(x=.03+cw*(cc+.5),y=.823-ch*(rr+.5),
      width=grid::unit(ww,"inches"),height=grid::unit(ww/aspect,"inches")))
    cttir_draw(g$rows$name[i],g$rows$family[i],mode,layout,newpage=FALSE)
    grid::popViewport()
  }
  grid::grid.text(base::sprintf("V5 / 45 identities / %s / %s",mode,layout),.035,.024,just="left",
    gp=grid::gpar(fontfamily=font,fontsize=9,col="#555555"))
  grid::grid.text(base::sprintf("%02d / 07",page),.965,.024,just="right",
    gp=grid::gpar(fontfamily=font,fontface=2,fontsize=9,col="#555555"))
}
cttir_make_galleries <- function(root=".") {
  r<-utils::read.csv(base::file.path(root,"packages.csv"),stringsAsFactors=FALSE)
  groups<-cttir_groups(r)
  base::dir.create(base::file.path(root,"gallery"),showWarnings=FALSE)
  for(mode in c("light","dark","mono")) for(layout in c("hex","lockup")) {
    # Dark-mode sheets need a dark host to show their white name lettering.
    # Every gallery PNG remains transparent, like the individual assets.
    for(i in base::seq_along(groups)) cttir_device(function()grDevices::png(
      base::file.path(root,"gallery",base::sprintf("%s-%s-%02d.png",mode,layout,i)),
      width=2520,height=1836,res=180,type="cairo",bg="transparent",antialias="gray"),
      function()cttir_gallery_page(groups[[i]],i,mode,layout))
  }
  # Main PDF has both compositions for every package, on a light review page.
  cttir_device(function()grDevices::cairo_pdf(base::file.path(root,"CTTIR_R_Hex_Gallery.pdf"),
    width=14,height=10.2,onefile=TRUE,bg="transparent"),function()
      for(layout in c("lockup","hex")) for(i in base::seq_along(groups))
        cttir_gallery_page(groups[[i]],i,"light",layout))
  # A compact transparent comparison of the two requested forms.
  draw_pair<-function() {
    grid::grid.newpage()
    grid::grid.text("ARTWORK ONLY",.265,.955,gp=grid::gpar(fontfamily="Inter",fontsize=12,fontface=2,col="#555555"))
    grid::grid.text("NAME INSIDE",.735,.955,gp=grid::gpar(fontfamily="Inter",fontsize=12,fontface=2,col="#555555"))
    for(i in 1:2) for(j in 1:2) {
      layout<-if(j==1)"hex" else "lockup";d<-cttir_dimensions(layout);w<-2.8
      grid::pushViewport(grid::viewport(x=if(j==1).265 else .735,y=if(i==1).695 else .245,
        width=grid::unit(w,"inches"),height=grid::unit(w*d$height/d$width,"inches")))
      cttir_draw(c("hyperloom","phenoloom")[i],c("spectral","spatial")[i],"light",layout,newpage=FALSE)
      grid::popViewport()
    }
  }
  cttir_device(function()grDevices::png(base::file.path(root,"gallery","two-versions.png"),
    width=1500,height=1740,res=180,bg="transparent",type="cairo",antialias="gray"),draw_pair)
  base::invisible(NULL)
}
