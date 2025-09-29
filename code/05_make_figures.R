# ==========================================
# 05_make_figures.R  (minimal figures)
# - National ln(M/F) time series with reform lines
# - Event-study figures are produced in 02_eventstudy.R
# ==========================================
library(data.table)
library(zoo)
library(ggplot2)

dir.create("out/figures", recursive = TRUE, showWarnings = FALSE)

bpm <- fread("out/bpm_clean.csv")

# national monthly totals + ln ratio
nat <- bpm[, .(
  ln_ratio = log((sum(pmax(n_leave_m,0)) + 0.5)/(sum(pmax(n_leave_f,0)) + 0.5))
), by = date][order(date)]

# reform lines (k=4 => 2017-05-01)
start16 <- as.Date("2016-12-01")
start17 <- as.Date(as.yearmon("2017-01") + 4/12, frac=0)

p <- ggplot(nat, aes(x = date, y = ln_ratio)) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_line() +
  geom_vline(xintercept = start16, linetype = "dotted") +
  geom_vline(xintercept = start17, linetype = "dotted") +
  labs(x = NULL, y = "ln(Male/Female)",
       title = "National ln(M/F) over time",
       subtitle = "Dotted lines: 2016-12 and 2017-05 (k=4)") +
  theme_minimal(base_size = 12)

ggsave("out/figures/TS_national_lnratio.png", p, width = 7, height = 4.5, dpi = 300)
ggsave("out/figures/TS_national_lnratio.pdf", p, width = 7, height = 4.5)

cat("Figure saved to out/figures/TS_national_lnratio.{png,pdf}\n")
