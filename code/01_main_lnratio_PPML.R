# =======================================
# 01_main_lnratio_PPML.R  Main analysis
# Main spec: Additive PPML, k=4, no donuts, with controls
# Also: exclusive 3-bin additional effect for k=3/4/5 (ratio & PPML)
# =======================================
library(data.table)
library(fixest)
library(zoo)
library(modelsummary)

bpm <- fread(file.path("out","bpm_clean.csv"))

# ---- Helpers ----
month_add <- function(d, n) as.Date(as.yearmon(d) + n/12, frac=0)

# Additive dummies + asymmetric donuts
make_addon <- function(dt, k=4, donut16=0, donut17=0){
  d <- copy(dt)
  start16 <- as.Date("2016-12-01")
  start17 <- as.Date(as.yearmon("2017-01") + k/12, frac=0)   # e.g., k=4 -> 2017-05-01
  d[, d2016 := as.integer(date >= start16)]
  d[, d2017_add_eff := as.integer(date >= start17)]
  if (donut16>0){
    don16 <- d$date >= month_add(start16,-donut16) & d$date <= month_add(start16,donut16)
    d <- d[!don16]
  }
  if (donut17>0){
    don17 <- d$date >= month_add(start17,-donut17) & d$date <= month_add(start17,donut17)
    d <- d[!don17]
  }
  d[]
}

# Long format (keep controls)
to_long_addon <- function(d){
  melt(d,
    id.vars=c("pref_id","date","moy","t_index","d2016","d2017_add_eff",
              "z_u_rate","z_ln_ei","z_ln_need","z_ln_fac","z_oldshare75"),
    measure.vars=c("n_leave_m","n_leave_f"),
    variable.name="sexvar", value.name="n"
  )[, sex := fifelse(sexvar=="n_leave_m","male","female")][]
}

# % and CI for coefficients; and linear combination
pct_ci <- function(m, vs){
  vs <- intersect(vs, names(coef(m))); if(!length(vs)) return(data.table())
  b <- coef(m)[vs]; V <- vcov(m)[vs,vs,drop=FALSE]; se <- sqrt(diag(V))
  data.table(term=vs, pct=100*(exp(b)-1), lo=100*(exp(b-1.96*se)-1), hi=100*(exp(b+1.96*se)-1))
}
lincom_pct_ci <- function(m, terms, label){
  terms <- intersect(terms, names(coef(m))); if(!length(terms)) return(data.table())
  b <- coef(m)[terms]; V <- vcov(m)[terms,terms,drop=FALSE]
  est <- sum(b); se <- sqrt(as.numeric(t(rep(1,length(terms))) %*% V %*% rep(1,length(terms))))
  data.table(effect=label, pct=100*(exp(est)-1),
             lo=100*(exp(est-1.96*se)-1), hi=100*(exp(est+1.96*se)-1))
}

# ---- MAIN: PPML additive, k=4, no donuts, with controls ----
L_main <- to_long_addon(make_addon(bpm, k=4, donut16=0, donut17=0))
fml_main <- n ~ d2016 + d2017_add_eff +
              i(sex,d2016,ref="female") + i(sex,d2017_add_eff,ref="female") +
              t_index + i(moy) + z_u_rate + z_ln_ei + z_ln_need + z_ln_fac + z_oldshare75 | pref_id + sex
m_addon_main <- fepois(fml_main, data=L_main, cluster=~pref_id)

# Summaries
res_main <- rbindlist(list(
  lincom_pct_ci(m_addon_main, c("d2016","d2017_add_eff"), "2017+ total (female baseline)"),
  lincom_pct_ci(m_addon_main, c("sex::male:d2016","sex::male:d2017_add_eff"), "2017+ male add-on"),
  lincom_pct_ci(m_addon_main, c("d2016","d2017_add_eff","sex::male:d2016","sex::male:d2017_add_eff"),
                "2017+ total (male)")
), fill=TRUE)
fwrite(res_main, "out/PPML_addon_main_effects_k4_donut16_0_donut17_0.csv")
fwrite(pct_ci(m_addon_main, c("d2016","d2017_add_eff","sex::male:d2016","sex::male:d2017_add_eff")),
       "out/PPML_addon_components_k4_donut16_0_donut17_0.csv")

# ---- Reference: ratio model (exclusive 3-bin) ----
make_3bins <- function(dt, k=4){
  d <- copy(dt)
  start16 <- as.Date("2016-12-01")
  start17 <- as.Date(as.yearmon("2017-01") + k/12, frac=0)
  d[, p_2016only := as.integer(date >= start16 & date < start17)]
  d[, p_2017plus := as.integer(date >= start17)]
  d[]
}
bpm3 <- make_3bins(bpm, k=4)
m_ratio_3bin <- feols(ln_ratio_mf ~ p_2016only + p_2017plus + t_index + i(moy) | pref_id,
                      data=bpm3, weights=~w_total, cluster=~pref_id)
fwrite(pct_ci(m_ratio_3bin, c("p_2016only","p_2017plus")), "out/LNratio_3bin_k4.csv")

# ---- Additional effect (exclusive 3-bin): k = 3/4/5, ratio & PPML ----
lincom_diff_pct <- function(m, t_plus, t_base, label){
  nm <- names(coef(m))
  if (!all(c(t_plus, t_base) %in% nm)) return(data.table())
  b <- coef(m)[c(t_plus, t_base)]
  V <- vcov(m)[c(t_plus, t_base), c(t_plus, t_base), drop=FALSE]
  cvec <- c(1, -1)
  est <- sum(b * cvec)
  se  <- sqrt(as.numeric(t(cvec) %*% V %*% cvec))
  data.table(effect = label,
             pct = 100*(exp(est)-1),
             lo  = 100*(exp(est-1.96*se)-1),
             hi  = 100*(exp(est+1.96*se)-1))
}
to_long_excl <- function(d){
  melt(d,
    id.vars = c("pref_id","date","moy","t_index","p_2016only","p_2017plus",
                "z_u_rate","z_ln_ei","z_ln_need","z_ln_fac","z_oldshare75"),
    measure.vars = c("n_leave_m","n_leave_f"),
    variable.name = "sexvar", value.name = "n"
  )[, sex := fifelse(sexvar=="n_leave_m","male","female")][]
}

for (kk in c(3,4,5)) {
  bpm3_k <- make_3bins(bpm, k=kk)
  # Ratio
  m_ratio_k <- feols(ln_ratio_mf ~ p_2016only + p_2017plus + t_index + i(moy) | pref_id,
                     data=bpm3_k, weights=~w_total, cluster=~pref_id)
  res_ratio_k <- lincom_diff_pct(m_ratio_k, "p_2017plus", "p_2016only",
                                 sprintf("2017 add-on vs 2016-only (ln ratio), k=%d", kk))
  fwrite(res_ratio_k, sprintf("out/LNratio_3bin_k%d_additional2017.csv", kk))

  # PPML
  L_excl_k <- to_long_excl(bpm3_k)
  m_ppml_k <- fepois(
    n ~ p_2016only + p_2017plus +
        i(sex, p_2016only, ref="female") + i(sex, p_2017plus,  ref="female") +
        t_index + i(moy) + z_u_rate + z_ln_ei + z_ln_need + z_ln_fac + z_oldshare75 |
        pref_id + sex,
    data=L_excl_k, cluster=~pref_id
  )
  res_ppml_k <- rbindlist(list(
    lincom_diff_pct(m_ppml_k, "p_2017plus", "p_2016only",
                    sprintf("2017 add-on (female baseline), k=%d", kk)),
    lincom_diff_pct(m_ppml_k, "sex::male:p_2017plus", "sex::male:p_2016only",
                    sprintf("2017 add-on (male add-on), k=%d", kk)),
    {
      terms <- c("p_2017plus","p_2016only","sex::male:p_2017plus","sex::male:p_2016only")
      nm <- names(coef(m_ppml_k)); terms <- intersect(terms, nm)
      if (length(terms) < 4) data.table()
      else {
        b <- coef(m_ppml_k)[terms]; V <- vcov(m_ppml_k)[terms,terms,drop=FALSE]
        cvec <- c(1,-1, 1,-1)
        est <- sum(b * cvec)
        se  <- sqrt(as.numeric(t(cvec) %*% V %*% cvec))
        data.table(effect=sprintf("2017 add-on (male total), k=%d", kk),
                   pct=100*(exp(est)-1),
                   lo =100*(exp(est-1.96*se)-1),
                   hi =100*(exp(est+1.96*se)-1))
      }
    }
  ), fill=TRUE)
  fwrite(res_ppml_k, sprintf("out/PPML_exclusive_k%d_additional2017.csv", kk))
}
