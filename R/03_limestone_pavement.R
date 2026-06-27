library(here)
library(readxl)
library(dplyr)
library(ggplot2)
library(forcats)
library(grid)

data_file <- here("data", "raw", "Combined_field_class_data_2025.xlsx")

# ---------- Area / volume analysis ----------
grike_data <- read_excel(data_file, sheet = "Limestone Pavement grikes")

grike_data$grike_area_m2 <- grike_data$Grike_width_m * grike_data$Grike_length_m
grike_data$grike_volume_m3 <- grike_data$grike_area_m2 * grike_data$Grike_depth_m

area_cor <- cor.test(grike_data$grike_area_m2, grike_data$SpeciesRichness, method = "spearman")
area_lm <- summary(lm(SpeciesRichness ~ log10(grike_area_m2), data = grike_data))

vol_cor <- cor.test(grike_data$grike_volume_m3, grike_data$SpeciesRichness, method = "spearman")
vol_lm <- summary(lm(SpeciesRichness ~ log10(grike_volume_m3), data = grike_data))

sink(here("outputs", "tables", "limestone_stats.txt"))
print(area_cor); print(area_lm)
print(vol_cor); print(vol_lm)
sink()

# Base plots saved as PNG
png(here("outputs", "figures", "richness_vs_area.png"), width = 1200, height = 900, res = 150)
plot(grike_data$grike_area_m2, grike_data$SpeciesRichness,
     log = "x",
     xlab = expression("Grike Surface Area (m"^2*") [log scale]"),
     ylab = "Number of Species",
     pch = 19, col = "darkblue")
abline(lm(SpeciesRichness ~ log10(grike_area_m2), data = grike_data), col = "red", lwd = 2)
dev.off()

png(here("outputs", "figures", "richness_vs_volume.png"), width = 1200, height = 900, res = 150)
plot(grike_data$grike_volume_m3, grike_data$SpeciesRichness,
     log = "x",
     xlab = expression("Grike Volume (m"^3*") [log scale]"),
     ylab = "Number of Species",
     pch = 19, col = "darkgreen")
abline(lm(SpeciesRichness ~ log10(grike_volume_m3), data = grike_data), col = "blue", lwd = 2)
dev.off()

# ---------- Histogram (report-style) ----------
rooting_depths <- read_excel(data_file, sheet = "Limestone Pavem. rooting depths")

species_list <- c(
  "Phyllitis scolopendrium",
  "Geranium robertianum",
  "Ctenidium molluscum",
  "Sesleria caerulea",
  "Mercurialis perennis"
)

depth_data <- rooting_depths %>%
  filter(`Scientific name` %in% species_list) %>%
  rename(species = `Scientific name`, depth = `rooting depth (cm)`) %>%
  filter(!is.na(depth)) %>%
  mutate(depth_bin = cut(depth, breaks = seq(0, 100, by = 10), right = FALSE, labels = seq(0, 90, by = 10))) %>%
  filter(!is.na(depth_bin))

depth_data$depth_bin <- fct_rev(depth_data$depth_bin)

species_counts <- depth_data %>%
  group_by(species) %>%
  summarise(n = n(), .groups = "drop") %>%
  mutate(facet_label = paste0(species, " (n = ", n, ")"))

depth_data <- left_join(depth_data, species_counts, by = "species")

species_palette <- c(
  "Phyllitis scolopendrium" = "blue",
  "Geranium robertianum" = "red",
  "Ctenidium molluscum" = "yellow",
  "Sesleria caerulea" = "pink",
  "Mercurialis perennis" = "orange"
)

p_hist <- ggplot(depth_data, aes(x = depth_bin, fill = species)) +
  geom_bar(aes(y = ..count..), width = 0.8, color = "black", show.legend = FALSE) +
  geom_text(stat = "count", aes(label = after_stat(count), y = ..count..), hjust = -0.2, size = 3.5) +
  coord_flip() +
  facet_wrap(~ facet_label, nrow = 2) +
  scale_x_discrete(name = "Rooting Depth from Pavement Surface (cm)") +
  scale_y_continuous(name = "Count of Individual Plants", expand = expansion(mult = c(0, 0.15))) +
  scale_fill_manual(values = species_palette) +
  theme_minimal(base_size = 12) +
  theme(
    strip.text = element_text(size = 12, face = "italic"),
    axis.text.x = element_text(size = 10),
    axis.text.y = element_text(size = 10),
    panel.spacing = unit(1, "lines"),
    plot.margin = margin(1, 1, 1.5, 1, "cm")
  )

ggsave(here("outputs", "figures", "Historgram.png"), p_hist, width = 12, height = 7, dpi = 300)
write.csv(depth_data, here("outputs", "tables", "limestone_rooting_depth_data.csv"), row.names = FALSE)