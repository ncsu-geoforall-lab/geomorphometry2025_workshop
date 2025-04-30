#!/usr/bin/env Rscript

# build.R
cat("🔧 Loading libraries...\n")
library(devtools)
library(usethis)
library(lintr)

# Optional: Tidy DESCRIPTION file before building
cat("🧹 Tidying DESCRIPTION...\n")
usethis::use_tidy_description()

# Lint the R code (optional, but good style check)
cat("🔍 Running lintr checks...\n")
lint_results <- lintr::lint_package()
print(lint_results)

# Load package environment
cat("🔄 Loading package...\n")
devtools::load_all()

# Build documentation
cat("📝 Building documentation...\n")
devtools::document()

# Build vignettes
cat("📚 Building vignettes...\n")
devtools::build_vignettes()

# Run unit tests
cat("🧪 Running tests...\n")
devtools::test()

# Run full package check
cat("🔍 Running R CMD check...\n")
devtools::check()

# Create build folder if missing
if (!dir.exists("build")) {
  dir.create("build", recursive = TRUE)
}

# Build tar.gz package
cat("📦 Building source package (.tar.gz)...\n")
devtools::build(path = "build")

cat("✅ Build complete! Package tar.gz is saved in 'build/' folder.\n")
