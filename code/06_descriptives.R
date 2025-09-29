# ==========================================
# 06_descriptives.R  (minimal descriptive statistics only)
# ==========================================
library(data.table)
library(zoo)

dir.create("out/tables", recursive = TRUE, showWarnings = FALSE)

bpm <- fread("out/bpm_clean.csv")

make_bins <- function(dt, k=4){
  d <- copy(dt)
  start16 <- as.Date("2016-12-01")
  start17 <- as.Date(as.yearmon("2017-01") + k/12, frac=0)  # k=4 -> 2017-05-01
  d[, period := fifelse(date < start16, "pre",
                 fifelse(date < start17, "2016-only", "2017+"))]
  d[, period := factor(period, levels=c("pre","2016-only","2017+"))]
  d[]
}

d <- make_bins(bpm, k=4)

# ---- Overall summary (key vars) ----
vars_key <- c("n_leave_m","n_leave_f","w_total","ln_ratio_mf",
              "u_rate","ln_ei","ln_need","ln_fac","oldshare75")

one_var_summary <- function(x){
  c(Mean=mean(x,na.rm=TRUE),
    SD=sd(x,na.rm=TRUE),
    Min=min(x,na.rm=TRUE),
    P25=as.numeric(quantile(x,.25,na.rm=TRUE)),
    Median=median(x,na.rm=TRUE),
    P75=as.numeric(quantile(x,.75,na.rm=TRUE)),
    Max=max(x,na.rm=TRUE))
}

overall <- rbindlist(lapply(vars_key, function(v){
  vals <- one_var_summary(d[[v]])
  data.table(Variable=v, Stat=names(vals), Value=as.numeric(vals))
}), fill=TRUE)
fwrite(overall, "out/tables/descriptives_overall_min.csv")

# ---- By period means (same key vars) ----
by_period <- d[, .(
  mean_m       = mean(n_leave_m, na.rm=TRUE),
  mean_f       = mean(n_leave_f, na.rm=TRUE),
  mean_total   = mean(w_total,    na.rm=TRUE),
  mean_lnratio = mean(ln_ratio_mf,na.rm=TRUE),
  mean_urate   = mean(u_rate,     na.rm=TRUE),
  mean_lnei    = mean(ln_ei,      na.rm=TRUE),
  mean_lnneed  = mean(ln_need,    na.rm=TRUE),
  mean_lnfac   = mean(ln_fac,     na.rm=TRUE),
  mean_old75   = mean(oldshare75, na.rm=TRUE)
), by = period]
fwrite(by_period, "out/tables/descriptives_by_period_min.csv")

# ---- Zero-count shares by period ----
zeros <- d[, .(
  zero_m = mean(n_leave_m <= 0, na.rm=TRUE),
  zero_f = mean(n_leave_f <= 0, na.rm=TRUE)
), by = period]
fwrite(zeros, "out/tables/zero_share_by_period_min.csv")

cat("Minimal descriptives saved to out/tables/ .\n")
