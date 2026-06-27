# run_all.R (robust version)

required_packages <- c(
  "here", "readxl", "dplyr", "tidyr", "ggplot2", "writexl",
  "ggrepel", "viridis", "gt", "webshot2", "flextable", "forcats", "readr"
)

missing <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]
if (length(missing) > 0) {
  stop(
    "Missing packages: ", paste(missing, collapse = ", "),
    "\nInstall first:\ninstall.packages(c(",
    paste0('"', missing, '"', collapse = ", "), "))"
  )
}

library(here)

cat("Working dir: ", getwd(), "\n", sep = "")
cat("here() root: ", here::here(), "\n", sep = "")

dir.create(here("outputs", "tables"), recursive = TRUE, showWarnings = FALSE)
dir.create(here("outputs", "figures"), recursive = TRUE, showWarnings = FALSE)
dir.create(here("outputs", "logs"), recursive = TRUE, showWarnings = FALSE)

main_data <- here("data", "raw", "Combined_field_class_data_2025.xlsx")

if (!file.exists(main_data) && !file.exists(main_data_alt)) {
  stop(
    "Could not find data file.\nLooked for:\n- ", main_data,
    "\n- ", main_data_alt
  )
}

scripts <- c(
  here("R", "01_raised_bog.R"),
  here("R", "02_grassland.R"),
  here("R", "03_limestone_pavement.R"),
  here("R", "04_freshwater.R"),
  here("R", "05_terrestrial_insects.R")
)

missing_scripts <- scripts[!file.exists(scripts)]
if (length(missing_scripts) > 0) {
  stop("Missing script file(s):\n", paste("-", missing_scripts, collapse = "\n"))
}

run_log <- file(here("outputs", "logs", "run_all_log.txt"), open = "wt")
sink(run_log, split = TRUE)
sink(run_log, type = "message")

cat("Run started:", as.character(Sys.time()), "\n\n")

for (s in scripts) {
  cat("Running:", s, "\n")
  source(s, echo = TRUE)
  cat("Completed:", s, "\n\n")
}

cat("Run finished:", as.character(Sys.time()), "\n")
sessionInfo()

sink(type = "message")
sink()
close(run_log)

message("All scripts completed. See outputs/logs/run_all_log.txt")
