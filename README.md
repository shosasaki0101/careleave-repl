# careleave-repl: Replication Package for Japan’s Carers’ Leave Reforms (2016–2017)

Author: Sho Sasaki (Email: shosasaki0101@gmail.com)

This repository contains code and materials to replicate the analyses reported in the working paper:
**_Income Replacement vs Flexibility: Evidence from Japan’s 2016–2017 Care-Leave Reforms on Gendered Patterns of Leave Uptake_**  

**Abstract:**
This paper examines how different policy instruments shape the uptake of family-care leave, a policy tool of growing importance in aging societies. While parental leave has been extensively studied, family-care leave remains under-researched despite substantial cross-national variation. Japan offers a useful case: two consecutive reforms in 2016 and 2017 altered the program’s core design. The 2016 reform raised the income replacement rate, while the 2017 reform introduced greater flexibility in leave-taking arrangements.

Using monthly prefecture-level administrative statistics from 2014 to 2019, I estimate event-study models and Poisson pseudo-maximum likelihood regressions with prefecture and month fixed effects. Results show that the 2016 reform reduced the male-to-female uptake ratio, indicating a relative increase in male participation, but had limited effects on the total number of recipients. In contrast, the 2017 reform produced sustained increases in both male and female uptake, while leaving the gender ratio unchanged. Robustness checks across alternative specifications and placebo tests confirm these patterns.

The findings demonstrate that income replacement and flexibility operate through distinct mechanisms. The former promotes gender equality, while the latter expands overall participation. Together, they underscore the complementary roles of generosity and flexibility in care-leave policy design and the need to analyze policy instruments as differentiated levers rather than interchangeable features.

---

## Purpose of Repository

It is designed to ensure **full reproducibility** of the analyses and to showcase **advanced quantitative research skills** (PPML, event study, robustness checks) relevant for my PhD application to the _Making Time_ project.  

The package contains:
- **Cleaned datasets** (`data/derived/`) sufficient to replicate the analyses
- **R scripts** (`code/`) for main analyses
- **Output tables and figures** (`out/`) generated directly from the scripts

---

## Data
- The raw data originate from official Japanese administrative statistics.  
- Due to redistribution restrictions, `data/raw/` is not included.  
- Instead, I provide:
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

**All outputs (tables and figures) are stored in the `out/` folder.**

---

## License
**For academic demonstration only.**  
This replication package is provided as part of a PhD application.  
All rights reserved. Reuse, redistribution, or modification in any form is prohibited.

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
