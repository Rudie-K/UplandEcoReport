library(here)
library(readxl)
library(dplyr)
library(ggplot2)
library(ggrepel)
library(viridis)
library(writexl)

data_file <- here("data", "raw", "Combined_field_class_data_2025.xlsx")

# ---------- Section 1: Rank-abundance ----------
data <- read_excel(data_file, sheet = "Grasslands point quadrat data")

names(data) <- tolower(gsub(" ", "_", names(data)))
data$`%pin` <- as.numeric(data$`%pin`)

cover_summary <- data %>%
  group_by(site, scientific_name) %>%
  summarise(total_cover = sum(`%pin`, na.rm = TRUE), .groups = "drop")

prepare_rank_data <- function(df, site_name) {
  df %>%
    filter(grepl(site_name, site, ignore.case = TRUE)) %>%
    arrange(desc(total_cover)) %>%
    mutate(rank = row_number())
}

calcareous_rank <- prepare_rank_data(cover_summary, "calcareous")
acidic_rank <- prepare_rank_data(cover_summary, "acidic")

acidic_rank <- acidic_rank %>%
  mutate(percent_cover = (total_cover / sum(total_cover)) * 100)

calcareous_rank <- calcareous_rank %>%
  mutate(percent_cover = (total_cover / sum(total_cover)) * 100)

plot_rank_abundance <- function(df, title, color) {
  ggplot(df, aes(x = rank, y = percent_cover)) +
    geom_line(group = 1, color = color) +
    geom_point(color = color) +
    geom_text(aes(label = ifelse(rank <= 5, scientific_name, "")), hjust = 1.1, size = 3) +
    scale_x_continuous(breaks = df$rank) +
    scale_y_continuous(breaks = seq(0, 100, by = 10)) +
    labs(
      title = title,
      x = "Plant Species Ranked by Highest to Lowest Frequency",
      y = "Abundance (% of Total Sample)"
    ) +
    theme_minimal(base_size = 14) +
    theme(panel.border = element_rect(colour = "black", fill = NA, linewidth = 1))
}

p1 <- plot_rank_abundance(calcareous_rank, "Rank Abundance Plot: Calcareous Grassland", "darkgreen")
p2 <- plot_rank_abundance(acidic_rank, "Rank Abundance Plot: Acidic Grassland", "steelblue")

ggsave(here("outputs", "figures", "rank_abundance_calcareous_basic.png"), p1, width = 10, height = 6, dpi = 300)
ggsave(here("outputs", "figures", "rank_abundance_acidic_basic.png"), p2, width = 10, height = 6, dpi = 300)

write.csv(calcareous_rank, here("outputs", "tables", "calcareous_rank_abundance.csv"), row.names = FALSE)
write.csv(acidic_rank, here("outputs", "tables", "acidic_rank_abundance.csv"), row.names = FALSE)

# ---------- Section 2: Vibrant plot from CSV ----------
acidic_rank2 <- read.csv(here("outputs", "tables", "acidic_rank_abundance.csv"))
calcareous_rank2 <- read.csv(here("outputs", "tables", "calcareous_rank_abundance.csv"))

acidic_rank2 <- acidic_rank2 %>%
  filter(tolower(scientific_name) != "bare ground") %>%
  arrange(desc(percent_cover)) %>%
  mutate(scientific_name = factor(scientific_name, levels = scientific_name))

calcareous_rank2 <- calcareous_rank2 %>%
  filter(tolower(scientific_name) != "bare ground") %>%
  arrange(desc(percent_cover)) %>%
  mutate(scientific_name = factor(scientific_name, levels = scientific_name))

plot_rank_abundance_vibrant <- function(df, title) {
  ggplot(df, aes(x = scientific_name, y = percent_cover, color = percent_cover)) +
    geom_segment(aes(x = scientific_name, xend = scientific_name, y = 0, yend = -2), color = "grey40", size = 0.5) +
    geom_point(size = 3) +
    geom_line(aes(group = 1), color = "black") +
    scale_color_viridis_c(option = "plasma", direction = -1) +
    geom_text_repel(
      aes(label = round(percent_cover, 1)),
      box.padding = 0.3,
      max.overlaps = 20,
      size = 4,
      fontface = "bold",
      nudge_y = 1
    ) +
    labs(
      title = title,
      x = "Plant Species Ranked Highest to Lowest Frequency",
      y = "Abundance (% of Total Sample)"
    ) +
    theme_minimal(base_size = 14) +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
      panel.border = element_rect(colour = "black", fill = NA, linewidth = 1),
      legend.position = "none"
    ) +
    coord_cartesian(ylim = c(-2, max(df$percent_cover) + 2))
}

pv1 <- plot_rank_abundance_vibrant(acidic_rank2, "")
pv2 <- plot_rank_abundance_vibrant(calcareous_rank2, "")

ggsave(here("outputs", "figures", "rank_abundance_acidic_vibrant.png"), pv1, width = 12, height = 7, dpi = 300)
ggsave(here("outputs", "figures", "rank_abundance_calcareous_vibrant.png"), pv2, width = 12, height = 7, dpi = 300)

# ---------- Section 3: Shannon ----------
data2 <- read_excel(data_file, sheet = "Grasslands point quadrat data")
names(data2) <- tolower(gsub(" ", "_", names(data2)))

cover_summary2 <- data2 %>%
  group_by(site, scientific_name) %>%
  summarise(percentage_cover = sum(`%pin`, na.rm = TRUE), .groups = "drop") %>%
  filter(tolower(scientific_name) != "bare ground")

compute_shannon_table <- function(df) {
  total_cover <- sum(df$percentage_cover)
  df %>%
    mutate(
      pi = percentage_cover / total_cover,
      ln_pi = log(pi),
      pi_ln_pi = pi * ln_pi
    )
}

calcareous <- cover_summary2 %>% filter(grepl("calcareous", site, ignore.case = TRUE))
acidic <- cover_summary2 %>% filter(grepl("acidic", site, ignore.case = TRUE))

calcareous_table <- compute_shannon_table(calcareous)
acidic_table <- compute_shannon_table(acidic)

calculate_metrics <- function(df) {
  H <- -sum(df$pi_ln_pi)
  S <- nrow(df)
  E <- H / log(S)
  list(H = H, S = S, E = E)
}

metrics_calcareous <- calculate_metrics(calcareous_table)
metrics_acidic <- calculate_metrics(acidic_table)

print(metrics_acidic)
print(metrics_calcareous)

write_xlsx(acidic_table, here("outputs", "tables", "acidic_table.xlsx"))
write_xlsx(calcareous_table, here("outputs", "tables", "calcareous_table.xlsx"))