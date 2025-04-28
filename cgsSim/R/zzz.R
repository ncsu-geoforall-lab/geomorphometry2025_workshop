.onAttach <- function(libname, pkgname) {
    cgsSim <- read.dcf(file=system.file("DESCRIPTION", package=pkgname),
                      fields="Version")
    packageStartupMessage(paste(pkgname, cgsSim))
}