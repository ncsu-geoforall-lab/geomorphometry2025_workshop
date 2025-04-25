#!/usr/bin/env Rscript

# build.R
library(devtools)

devtools::load_all()
devtools::document()
devtools::test()
devtools::check()
if (!dir.exists("build")) {
  dir.create("build", recursive = TRUE)
}
devtools::build(path = "build/")  # save .tar.gz to 'build/' folder
