library(here)
library(dplyr)
library(tidyr)
library(readxl)

data_file <- here("data", "raw", "Combined_field_class_data_2025.xlsx")

traits <- read_excel(data_file, sheet = "Beetle species and traits")
traps <- read_excel(data_file, sheet = "Beetle trapping data")

# Section A
data <- left_join(traps, traits, by = "species")

weighted_size_by_habitat <- data %>%
  group_by(Observed_Habitat) %>%
  summarise(
    mean_size = sum(`average size` * number) / sum(number),
    sd_size = sd(rep(`average size`, number)),
    n = sum(number),
    .groups = "drop"
  )

size_woodland <- rep(data$`average size`[data$Observed_Habitat == "woodland"],
                     data$number[data$Observed_Habitat == "woodland"])
size_grassland <- rep(data$`average size`[data$Observed_Habitat == "grassland"],
                      data$number[data$Observed_Habitat == "grassland"])

size_ttest <- t.test(size_woodland, size_grassland)

wing_counts <- data %>%
  group_by(Observed_Habitat, wings) %>%
  summarise(total = sum(number), .groups = "drop") %>%
  pivot_wider(names_from = wings, values_from = total, values_fill = 0)

wing_table <- wing_counts %>%
  select(dimorphic, unwinged, winged) %>%
  as.matrix()

wing_table[is.na(wing_table)] <- 0
wing_chisq <- chisq.test(wing_table)

print(weighted_size_by_habitat)
print(size_ttest)
print(wing_counts)
print(wing_chisq)

write.csv(weighted_size_by_habitat, here("outputs", "tables", "beetle_weighted_size_by_habitat.csv"), row.names = FALSE)
write.csv(wing_counts, here("outputs", "tables", "beetle_wing_counts_by_habitat.csv"), row.names = FALSE)

sink(here("outputs", "tables", "beetle_stats.txt"))
print(size_ttest)
print(wing_chisq)
sink()

# Section B
beetle_csv <- here("data", "derived", "beetle_data_species_richness_B.csv")
if (file.exists(beetle_csv)) {
  beetle <- read.csv(beetle_csv)

  beetle <- beetle %>%
    mutate(match = case_when(
      Typical_Habitat == "Woodland/Grassland" ~ "Generalist",
      Typical_Habitat == "Marsh/Fen" & Observed_Habitat == "grassland" ~ "Match",
      Typical_Habitat == "Woodland" & Observed_Habitat == "woodland" ~ "Match",
      Typical_Habitat == "Grassland" & Observed_Habitat == "grassland" ~ "Match",
      TRUE ~ "Mismatch"
    ))

  totals <- beetle %>% count(match)
  totals_by_habitat <- beetle %>% count(Observed_Habitat, match)

  print(totals)
  print(totals_by_habitat)

  write.csv(totals, here("outputs", "tables", "beetle_habitat_totals.csv"), row.names = FALSE)
  write.csv(totals_by_habitat, here("outputs", "tables", "beetle_habitat_by_habitat.csv"), row.names = FALSE)
} else {
  message("Optional file missing: data/derived/beetle_data_species_richness_B.csv")
}