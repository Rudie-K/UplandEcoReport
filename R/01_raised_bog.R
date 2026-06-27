library(here)
library(readxl)
library(dplyr)
library(writexl)

data_file <- here("data", "raw", "Combined_field_class_data_2025.xlsx")

bog_data <- read_excel(data_file, sheet = "Peat bog data")

# Clean column names
names(bog_data) <- tolower(gsub(" ", "_", names(bog_data)))

# Ensure microhabitat and species names are consistent
bog_data <- bog_data %>%
  mutate(
    type = tolower(trimws(type)),
    scientific_name = tolower(trimws(scientific_name))
  )

summary_table <- bog_data %>%
  filter(!is.na(domin_value)) %>%
  group_by(scientific_name, type) %>%
  summarise(
    frequency = n(),
    median_domin = median(domin_value),
    .groups = "drop"
  ) %>%
  arrange(type, scientific_name)

print(summary_table, n = Inf)

write_xlsx(summary_table, here("outputs", "tables", "raised_bog_summary.xlsx"))
write.csv(summary_table, here("outputs", "tables", "raised_bog_summary.csv"), row.names = FALSE)