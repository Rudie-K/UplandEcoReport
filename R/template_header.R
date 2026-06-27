library(here)
library(readxl)
library(dplyr)

# Optional by script:
# library(tidyr)
# library(ggplot2)
# library(writexl)

data_file <- here("data", "raw", "Combined_field_class_data_2025.xlsx")
dir.create(here("outputs", "tables"), recursive = TRUE, showWarnings = FALSE)
dir.create(here("outputs", "figures"), recursive = TRUE, showWarnings = FALSE)