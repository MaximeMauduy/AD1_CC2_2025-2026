install.packages(c(
  "shiny",
  "rmarkdown",
  "readxl",
  "psych",
  "rsq",
  "ggplot2"
))

# Installer pandoc si nécessaire
if (!rmarkdown::pandoc_available()) {
  rmarkdown::install_pandoc()
}
