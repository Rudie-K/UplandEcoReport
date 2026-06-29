# Upland Ecology in Cumbria (2025): Reproducible Analysis

This repository contains the R code and generated outputs for the report:

**A broad assessment of Upland Ecology in Cumbria**  
Date: **02 June 2025**

---

## What this repo contains

Analyses are organized by report section:

1. **Raised bog plant communities** (`R/01_raised_bog.R`)
2. **Grassland analyses** (rank-abundance + Shannon/Pielou) (`R/02_grassland.R`)
3. **Limestone pavement analyses** (grike area/volume and rooting-depth histogram) (`R/03_limestone_pavement.R`)
4. **Freshwater invertebrate summaries** (`R/04_freshwater.R`)
5. **Terrestrial insect analyses** (`R/05_terrestrial_insects.R`)

A master script runs all sections:

- `R/run_all.R`

> Note: Bird analyses in the report were performed in Excel and are not included as R scripts.

---

## Repository structure

```text
.
├─ R/
│  ├─ R_run_all.R
│  ├─ 01_raised_bog.R
│  ├─ 02_grassland.R
│  ├─ 03_limestone_pavement.R
│  ├─ 04_freshwater.R
│  └─ 05_terrestrial_insects.R
├─ data/
│  ├─ raw/
│  │  └─ Combined_field_class_data_2025.xlsx
│  └─ derived/
│     └─ beetle_data_species_richness_B.csv   # optional (used in insects Section B)
├─ outputs/
│  ├─ tables/
│  ├─ figures/
│  └─ logs/
└─ README.md
```

---

## Requirements

- R (tested on R 4.4.0)
- Packages:
  - here
  - readxl
  - dplyr
  - tidyr
  - ggplot2
  - writexl
  - ggrepel
  - viridis
  - gt
  - webshot2
  - flextable
  - forcats
  - readr

Install once:

```r
install.packages(c(
  "here","readxl","dplyr","tidyr","ggplot2","writexl",
  "ggrepel","viridis","gt","webshot2","flextable","forcats","readr"
))
```

---

## How to run everything

From the repository root:

```r
source("R/run_all.R")
```

This will:
- verify packages,
- check required files,
- run all analysis scripts in order,
- write outputs to `outputs/tables` and `outputs/figures`,
- write a run log to `outputs/logs/run_all_log.txt`.

---

## Expected key outputs

Examples of generated files include:

- `outputs/tables/raised_bog_summary.xlsx`
- `outputs/tables/grassland_diversity_metrics.csv`
- `outputs/figures/rank_abundance_acidic_basic.png`
- `outputs/figures/rank_abundance_calcareous_basic.png`
- `outputs/figures/Historgram.png`
- `outputs/tables/Combined_Freshwater_Summary.csv`
- `outputs/tables/beetle_weighted_size_by_habitat.csv`

---

## Reproducibility notes

- Scripts use project-relative paths via `here::here()`.
- Keep raw data file name exactly:
  - `data/raw/Combined_field_class_data_2025.xlsx`
- Do not run scripts from outside the repo root.
- Optional insects Section B file:
  - `data/derived/beetle_data_species_richness_B.csv`

---

## Status

This repository is configured to reproduce the report analyses and figure styles from the final submission workflow.
