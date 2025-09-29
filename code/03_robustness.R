# ==========================================
# 03_robustness.R  Donuts × k(3/4/5) × controls (PPML, additive)
# Also: exclusive vs additive on same sample
# ==========================================
library(data.table)
library(fixest)
library(zoo)

bpm <- fread(file.path("out","bpm_clean.csv"))
month_add <- function(d, n) as.Date(as.yearmon(d) + n/12, frac=0)

# Additive + donuts
make_addon <- function(dt, k=4, donut16=0, donut17=0){
  d <- copy(dt)
  start16 <- as.Date("2016-12-01")
  start17 <- as.Date(as.yearmon("2017-01") + k/12, frac=0)
  d[, d2016 := as.integer(date >= start16)]
  d[, d2017_add_eff := as.integer(date >= start17)]
  if (donut16>0){ don16 <- d$date >= month_add(start16,-donut16) & d$date <= month_add(start16,donut16); d <- d[!don16] }
  if (donut17>0){ don17 <- d$date >= month_add(start17,-donut17) & d$date <= month_add(start17,donut17); d <- d[!don17] }
  d[]
}
to_long_addon <- function(d){
  melt(d,
    id.vars=c("pref_id","date","moy","t_index","d2016","d2017_add_eff",
              "z_u_rate","z_ln_ei","z_ln_need","z_ln_fac","z_oldshare75"),
    measure.vars=c("n_leave_m","n_leave_f"),
    variable.name="sexvar", value.name="n"
  )[, sex := fifelse(sexvar=="n_leave_m","male","female")][]
}
lincom_pct_ci <- function(m, terms, label){
  terms <- intersect(terms, names(coef(m))); if(!length(terms)) return(data.table())
  b <- coef(m)[terms]; V <- vcov(m)[terms,terms,drop=FALSE]
  est <- sum(b); se <- sqrt(as.numeric(t(rep(1,length(terms))) %*% V %*% rep(1,length(terms))))
  data.table(effect=label, pct=100*(exp(est)-1),
             lo=100*(exp(est-1.96*se)-1), hi=100*(exp(est+1.96*se)-1))
}

run_one <- function(k=4, donut16=0, donut17=0, controls=TRUE){
  d <- make_addon(bpm, k, donut16, donut17)
  L <- to_long_addon(d)
  rhs_ctrl <- if (controls)
    "t_index + i(moy) + z_u_rate + z_ln_ei + z_ln_need + z_ln_fac + z_oldshare75"
  else
    "t_index + i(moy)"
  fstr <- paste0(
    "n ~ d2016 + d2017_add_eff + ",
    "i(sex, d2016, ref='female') + i(sex, d2017_add_eff, ref='female') + ",
    rhs_ctrl, " | pref_id + sex"
  )
  m <- fepois(as.formula(fstr), data=L, cluster=~pref_id)
  rbindlist(list(
    lincom_pct_ci(m, c("d2016","d2017_add_eff"), "2017+ total (female baseline)"),
    lincom_pct_ci(m, c("sex::male:d2016","sex::male:d2017_add_eff"), "2017+ male add-on"),
    lincom_pct_ci(m, c("d2016","d2017_add_eff","sex::male:d2016","sex::male:d2017_add_eff"),
                  "2017+ total (male)")
  ))[, `:=`(k=k, donut16=donut16, donut17=donut17, controls=controls)][]
}

# ---- Grid: k ∈ {3,4,5} × donuts ----
ks <- c(3,4,5)
res <- rbindlist(lapply(ks, function(kk){
  rbindlist(list(
    run_one(k=kk, donut16=0, donut17=0, controls=TRUE),   # main per k
    run_one(k=kk, donut16=1, donut17=1, controls=TRUE),   # ±1, ±1
    run_one(k=kk, donut16=2, donut17=1, controls=TRUE),   # 2016±2, 2017±1
    run_one(k=kk, donut16=2, donut17=2, controls=TRUE),   # ±2, ±2
    run_one(k=kk, donut16=0, donut17=0, controls=FALSE)   # no controls
  ), fill=TRUE)
}), fill=TRUE)
fwrite(res, "out/Robust_PPML_addon_k345_donuts_variants_ctrl_vs_noctrl.csv")

# ---- Exclusive vs additive on same (no-donut) sample, by k ----
make_3bins <- function(dt, k=4){
  d <- copy(dt)
  start16 <- as.Date("2016-12-01"); start17 <- as.Date(as.yearmon("2017-01") + k/12, frac=0)
  d[, p_2016only := as.integer(date >= start16 & date < start17)]
  d[, p_2017plus := as.integer(date >= start17)]
  d[]
}
pct_ci <- function(m, vs){
  vs <- intersect(vs, names(coef(m))); if(!length(vs)) return(data.table())
  b <- coef(m)[vs]; V <- vcov(m)[vs,vs,drop=FALSE]; se <- sqrt(diag(V))
  data.table(term=vs, pct=100*(exp(b)-1), lo=100*(exp(b-1.96*se)-1), hi=100*(exp(b+1.96*se)-1))
}

res_excl_all <- rbindlist(lapply(ks, function(kk){
  d_eq   <- make_addon(bpm, k=kk, donut16=0, donut17=0)
  d_excl <- make_3bins(d_eq, k=kk)
  L_excl <- melt(d_excl,
    id.vars=c("pref_id","date","moy","t_index","p_2016only","p_2017plus",
              "z_u_rate","z_ln_ei","z_ln_need","z_ln_fac","z_oldshare75"),
    measure.vars=c("n_leave_m","n_leave_f"),
    variable.name="sexvar", value.name="n"
  )[, sex := fifelse(sexvar=="n_leave_m","male","female")][]
  m_excl <- fepois(
    n ~ p_2016only + p_2017plus +
        i(sex,p_2016only,ref="female") + i(sex,p_2017plus,ref="female") +
        t_index + i(moy) + z_u_rate + z_ln_ei + z_ln_need + z_ln_fac + z_oldshare75 | pref_id + sex,
    data=L_excl, cluster=~pref_id
  )
  rbind(
    data.table(k=kk, effect="2017+ total (female baseline)", pct_ci(m_excl, "p_2017plus")[,.(pct,lo,hi)]),
    data.table(k=kk, effect="2017+ male add-on",            pct_ci(m_excl, "sex::male:p_2017plus")[,.(pct,lo,hi)]),
    data.table(k=kk, effect="2017+ total (male)",           {
      b <- c("p_2017plus","sex::male:p_2017plus"); B <- coef(m_excl)[b]; V <- vcov(m_excl)[b,b]
      est <- sum(B); se <- sqrt(as.numeric(t(rep(1,2))%*%V%*%rep(1,2)))
      data.table(pct=100*(exp(est)-1), lo=100*(exp(est-1.96*se)-1), hi=100*(exp(est+1.96*se)-1))
    })
  )
}), fill=TRUE)
fwrite(res_excl_all, "out/Compare_exclusive_vs_addon_same_sample_k345.csv")
