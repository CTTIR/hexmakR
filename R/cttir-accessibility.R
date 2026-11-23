# Physiologically based simulation of colour vision deficiency (CVD), applied
# to linear sRGB at severity 1.0.
#
# Source: Machado GM, Oliveira MM, Fernandes LAF (2009). A physiologically-based
# model for simulation of color vision deficiency. IEEE Transactions on
# Visualization and Computer Graphics 15(6), 1291-1298.
# https://doi.org/10.1109/TVCG.2009.113
# The three matrices are the severity 1.0 rows (protanomaly, deuteranomaly,
# tritanomaly) of the authors' supplementary table of precomputed matrices,
# https://www.inf.ufrgs.br/~oliveira/pubs_files/CVD_Simulation/CVD_Simulation.html,
# as also carried by the colorspacious reference implementation
# (colorspacious/cvd.py). The values were compared with that table on
# 23 Nov 2026; the six-decimal values come from the supplementary table, so no
# printed page of the article is cited for them. Each row sums to one, which
# keeps achromatic colours unchanged (tested).
#
# The transfer function is the sRGB one (IEC 61966-2-1:1999) and the "gray"
# weights are the relative-luminance coefficients for sRGB primaries, as in
# the WCAG 2 definition (https://www.w3.org/TR/WCAG22/#dfn-relative-luminance).
#
# This transforms sRGB colours before drawing; it never edits a raster image.
# Simulations are screening aids, not proof of universal colour discrimination.
cttir_simulate_cvd <- function(colour, type = "deutan") {
  matrices <- list(
    protan = matrix(c(.152286,1.052583,-.204868, .114503,.786281,.099216,
                      -.003882,-.048116,1.051998),3,3,byrow=TRUE),
    deutan = matrix(c(.367322,.860646,-.227968, .280085,.672501,.047413,
                      -.011820,.042940,.968881),3,3,byrow=TRUE),
    tritan = matrix(c(1.255528,-.076749,-.178779, -.078411,.930809,.147602,
                      .004733,.691367,.303900),3,3,byrow=TRUE)
  )
  rgb <- grDevices::col2rgb(colour)/255
  linear <- base::ifelse(rgb <= .04045,rgb/12.92,((rgb+.055)/1.055)^2.4)
  if(type=="gray") {
    luminance <- c(.2126,.7152,.0722) %*% linear
    result <- matrix(base::rep(luminance,each=3),nrow=3)
  } else {
    base::stopifnot(type %in% base::names(matrices))
    result <- matrices[[type]] %*% linear
  }
  result[] <- base::pmin(1,base::pmax(0,result))
  srgb <- base::ifelse(result<=.0031308,12.92*result,1.055*result^(1/2.4)-.055)
  grDevices::rgb(srgb[1,],srgb[2,],srgb[3,])
}
