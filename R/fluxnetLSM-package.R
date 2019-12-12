#' @keywords internal
#' 
#' @importFrom graphics axis legend lines plot mtext par text title
#' @importFrom grDevices dev.off pdf png
#' @importFrom stats coef lm na.omit sd
#' @importFrom utils packageVersion read.csv write.csv tail
#' 
#' @importFrom lutz tz_lookup_coords
"_PACKAGE"

# The following block is used by usethis to automatically manage
# roxygen namespace tags. Modify with care!
## usethis namespace: start
## usethis namespace: end
NULL


.onLoad <- function (libname, pkgname){
    # load data
    # data("LaThuile_site_policy")
    # data("Output_variables_FLUXNET2015_FULLSET")
    # data("Output_variables_FLUXNET2015_SUBSET")
    # data("Output_variables_LaThuile")
    # data("Output_variables_OzFlux")
    # data("site_metadata")
}
