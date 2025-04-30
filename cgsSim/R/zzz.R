.onAttach <- function(libname, pkgname) {
    cgs_sim <- read.dcf(
        file = system.file("DESCRIPTION", package = pkgname),
        fields = "Version"
    )
    packageStartupMessage(paste(pkgname, cgs_sim))
}
