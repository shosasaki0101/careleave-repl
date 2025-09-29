# careleave-repl: Replication Package for Japan’s Carers’ Leave Reforms (2016–2017)

Author: Sho Sasaki (Email: shosasaki0101@gmail.com)

This repository provides the replication package for my working paper on Japan’s carers’ leave reforms.  
It is designed to ensure reproducibility and to demonstrate advanced quantitative research skills (PPML, event study, robustness checks) as part of my PhD application to the *Making Time* project.  

The package contains:
- Cleaned datasets (`data/derived/`)
- R scripts for main analyses (`code/`)
- Output tables and figures (`out/`)

---

## Data
- The raw data originate from official Japanese administrative statistics.  
- Due to redistribution restrictions, `data/raw/` is not included.  
- Instead, we provide:
  - Instructions to obtain the raw data (see `data/raw/README_raw.md`)  
  - Cleaned derived dataset (`data/derived/bpm_clean.csv`) sufficient for replication.  

---

## Variables
Full details of all variables (definitions, sources, and constructed fields) are provided in [`VARIABLES.md`](VARIABLES.md).

---

## Outputs

- **Results (`out/results/`)**: CSV outputs from regression models.  
- **Tables (`out/tables/`)**: Summaries (HTML, TeX, CSV).  
- **Figures (`out/figures/`)**: PNG/PDF figures for national time series.  

---

## Reproducibility
Run the scripts in the following order:
1. `code/00_prep.R` – Data preparation (creates `bpm_clean.csv`)  
2. `code/01_main_lnratio_PPML.R` – Main analysis (PPML, additive and exclusive models)  
3. `code/02_eventstudy.R` – Event study analysis  
4. `code/03_robustness.R` – Robustness checks (donut exclusion, alternative k values)
5. `code/04_build_tables.R` – Build compact summary tables for results
6. `code/05_make_figures.R` – Create minimal national ln(M/F) time series figure
7. `code/06_descriptives.R` – Produce minimal descriptive statistics

All outputs (tables and figures) are stored in the `out/` folder.

---

## License
**For academic demonstration only.**  
This replication package is provided as part of a PhD application.  
All rights reserved. Redistribution of raw data is not included.

---

## Repository Structure

careleave-repl/
- code/ # R scripts for data cleaning and analysis
  - 00_prep.R # Data cleaning and construction of derived variables
  - 01_main_lnratio_PPML.R # Main PPML and log-ratio analyses
  - 02_eventstudy.R # Event study models
  - 03_robustness.R # Robustness checks (donut windows, k=3/4/5)
  - 04_build_tables.R # Build compact summary tables
  - 05_make_figures.R # Minimal figure (national ln(M/F) time series)
  - 06_descriptives.R # Minimal descriptive statistics
- data/
  - raw/ # Instructions only (no redistribution of raw data)
    - README_raw.md
  - derived/
    - bpm_clean.csv # Cleaned dataset sufficient for replication
- out/ # Outputs (tables, figures, CSV results)
- README.md # Project documentation
- VARIABLES.md # Full description of all variables (English + 日本語)
