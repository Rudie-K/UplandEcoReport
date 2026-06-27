library(here)
library(dplyr)
library(tidyr)
library(readxl)
library(gt)
library(webshot2)
library(flextable)

data_file <- here("data", "raw", "Combined_field_class_data_2025.xlsx")

lake <- read_excel(data_file, sheet = "Lake 2025", skip = 5)
group_cols <- c("Group1", "Group2", "Group3", "Group4", "Group5", "Group6")
lake[group_cols] <- lapply(lake[group_cols], function(x) ifelse(is.na(x), 0, x))

lake <- lake %>% mutate(Total = rowSums(across(all_of(group_cols)), na.rm = TRUE))
lake_summary <- lake %>% filter(Total > 0)

lake_summary <- lake_summary %>%
  mutate(
    Family = ifelse(grepl("^\\s*Family", ...1), trimws(gsub("^Family ", "", ...1)), NA),
    Order = ifelse(grepl("^Order", ...1), trimws(gsub("^Order ", "", ...1)), NA),
    Class = ifelse(grepl("^CLASS", ...1), trimws(gsub("^CLASS ", "", ...1)), NA),
    Phylum = ifelse(grepl("^PHYLUM", ...1), trimws(gsub("^PHYLUM ", "", ...1)), NA)
  ) %>%
  fill(Phylum, .direction = "down") %>%
  fill(Class, .direction = "down") %>%
  fill(Order, .direction = "down") %>%
  mutate(
    TaxonGroup = case_when(
      !is.na(Family) ~ Family,
      !is.na(Order) ~ Order,
      !is.na(Class) ~ Class,
      !is.na(Phylum) ~ Phylum,
      TRUE ~ ...1
    )
  )

final_lake_summary <- lake_summary %>%
  group_by(TaxonGroup) %>%
  summarise(Lake_Total = sum(Total), .groups = "drop") %>%
  mutate(Lake_Percent = round(100 * Lake_Total / sum(Lake_Total), 1)) %>%
  arrange(desc(Lake_Total))

stream <- read_excel(data_file, sheet = "Stream 2025", skip = 5)
stream[group_cols] <- lapply(stream[group_cols], function(x) ifelse(is.na(x), 0, x))
stream <- stream %>% mutate(Total = rowSums(across(all_of(group_cols)), na.rm = TRUE))
stream_summary <- stream %>% filter(Total > 0)

stream_summary <- stream_summary %>%
  mutate(
    Family = ifelse(grepl("^\\s*Family", ...1), trimws(gsub("^Family ", "", ...1)), NA),
    Order = ifelse(grepl("^Order", ...1), trimws(gsub("^Order ", "", ...1)), NA),
    Class = ifelse(grepl("^CLASS", ...1), trimws(gsub("^CLASS ", "", ...1)), NA),
    Phylum = ifelse(grepl("^PHYLUM", ...1), trimws(gsub("^PHYLUM ", "", ...1)), NA)
  ) %>%
  fill(Phylum, .direction = "down") %>%
  fill(Class, .direction = "down") %>%
  fill(Order, .direction = "down") %>%
  mutate(
    TaxonGroup = case_when(
      !is.na(Family) ~ Family,
      !is.na(Order) ~ Order,
      !is.na(Class) ~ Class,
      !is.na(Phylum) ~ Phylum,
      TRUE ~ ...1
    )
  )

final_stream_summary <- stream_summary %>%
  group_by(TaxonGroup) %>%
  summarise(Stream_Total = sum(Total), .groups = "drop") %>%
  mutate(Stream_Percent = round(100 * Stream_Total / sum(Stream_Total), 1)) %>%
  arrange(desc(Stream_Total))

combined_summary <- full_join(final_lake_summary, final_stream_summary, by = "TaxonGroup") %>%
  replace(is.na(.), 0) %>%
  arrange(desc(Lake_Total + Stream_Total))

print(combined_summary, n = 50)

write.csv(combined_summary, here("outputs", "tables", "Combined_Freshwater_Summary.csv"), row.names = FALSE)

# gt export
gt_table <- gt(combined_summary) %>%
  tab_options(
    table.border.top.color = "black",
    table.border.bottom.color = "black",
    table.border.left.color = "black",
    table.border.right.color = "black",
    table.border.top.width = px(2),
    table.border.bottom.width = px(2),
    table.border.left.width = px(2),
    table.border.right.width = px(2)
  )

gtsave(gt_table, here("outputs", "figures", "summary_table_gt.png"))

# flextable export
ft <- flextable(combined_summary)
ft <- border_outer(ft, border = officer::fp_border(color = "black", width = 2))
save_as_image(ft, path = here("outputs", "figures", "summary_table_flextable.png"))