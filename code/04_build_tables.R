# ==========================================
# 04_build_tables.R  (minimal tables for k=3/4/5 + main k=4)
# ==========================================
library(data.table)
library(stringr)
library(modelsummary)  # datasummary_df()

dir.create("out/tables", recursive = TRUE, showWarnings = FALSE)

# ---- helpers ----
find_files <- function(pattern, roots = c("out/results", "out")) {
  roots <- roots[dir.exists(roots)]
  unlist(lapply(roots, function(p) list.files(p, pattern = pattern, full.names = TRUE)))
}

stack_by_pattern <- function(pattern, add_k_from = "k(\\d+)"){
  fs <- find_files(pattern)
  if (!length(fs)) return(NULL)
  rbindlist(lapply(fs, function(f){
    dt <- fread(f)
    k  <- suppressWarnings(as.integer(str_match(basename(f), add_k_from)[,2]))
    if (!"k" %in% names(dt) && !is.na(k)) dt[, k := k]
    dt[, file := basename(f)]
    dt[]
  }), fill = TRUE)
}

mk_num_table <- function(dt, effect_col = "effect"){
  stopifnot(all(c("pct","lo","hi") %in% names(dt)))
  if (!"k" %in% names(dt)) dt[, k := NA_integer_]  # ← kが無いCSVにも対応
  setnames(dt, effect_col, "Effect", skip_absent = TRUE)
  dt[, .(
    k        = as.integer(k),
    Effect   = as.character(Effect),
    Estimate = as.numeric(pct),
    CI_lo    = as.numeric(lo),
    CI_hi    = as.numeric(hi)
  )][]
}

safe_datasummary <- function(df, file){
  # 文字列列はそのまま、数値列のみ丸める
  suppressWarnings(datasummary_df(df, output = file, fmt = 1))
}

# ---------- 1) ln(M/F) additional effect across k ----------
lnratio_add <- stack_by_pattern("^LNratio_3bin_k\\d+_additional2017\\.csv$")
if (!is.null(lnratio_add)) {
  fwrite(lnratio_add, "out/tables/summary_LNratio_additional2017_allk.csv")
  if (!"effect" %in% names(lnratio_add)) lnratio_add[, effect := "2017 add-on vs 2016-only (ln ratio)"]
  lnratio_num <- mk_num_table(copy(lnratio_add), effect_col = "effect")
  safe_datasummary(as.data.frame(lnratio_num), "out/tables/summary_LNratio_additional2017.html")
  safe_datasummary(as.data.frame(lnratio_num), "out/tables/summary_LNratio_additional2017.tex")
  fwrite(dcast(lnratio_num, Effect ~ k, value.var = "Estimate"),
         "out/tables/summary_LNratio_additional2017_wide_estimate.csv")
  fwrite(dcast(lnratio_num, Effect ~ k, value.var = c("CI_lo","CI_hi")),
         "out/tables/summary_LNratio_additional2017_wide_ci.csv")
} else {
  message("No LN ratio additional-effect files found. Skipping.")
}

# ---------- 2) PPML (exclusive) additional effect across k ----------
ppml_add <- stack_by_pattern("^PPML_exclusive_k\\d+_additional2017\\.csv$")
if (!is.null(ppml_add)) {
  fwrite(ppml_add, "out/tables/summary_PPML_exclusive_additional2017_allk.csv")
  if ("effect" %in% names(ppml_add)) {
    level_order <- c("2017 add-on (female baseline)",
                     "2017 add-on (male add-on)",
                     "2017 add-on (male total)")
    ppml_add[, effect := factor(effect, levels = level_order)]
    setorder(ppml_add, effect, k)
    ppml_add[, effect := as.character(effect)]
  }
  ppml_num <- mk_num_table(copy(ppml_add), effect_col = "effect")
  safe_datasummary(as.data.frame(ppml_num), "out/tables/summary_PPML_exclusive_additional2017.html")
  safe_datasummary(as.data.frame(ppml_num), "out/tables/summary_PPML_exclusive_additional2017.tex")
  fwrite(dcast(ppml_num, Effect ~ k, value.var = "Estimate"),
         "out/tables/summary_PPML_exclusive_additional2017_wide_estimate.csv")
  fwrite(dcast(ppml_num, Effect ~ k, value.var = c("CI_lo","CI_hi")),
         "out/tables/summary_PPML_exclusive_additional2017_wide_ci.csv")
} else {
  message("No PPML exclusive additional-effect files found. Skipping.")
}

# ---------- 3) Main PPML add-on effects (k=4, no donuts) ----------
main_k4 <- find_files("^PPML_addon_main_effects_k4_donut16_0_donut17_0\\.csv$")
if (length(main_k4)) {
  dt <- fread(main_k4[1])
  order_lv <- c("2017+ total (female baseline)",
                "2017+ male add-on",
                "2017+ total (male)")
  if ("effect" %in% names(dt)) {
    dt[, effect := factor(effect, levels = order_lv)]
    setorder(dt, effect)
  }
  if (!"effect" %in% names(dt)) setnames(dt, "term", "effect", skip_absent = TRUE)
  dt[, k := 4L]  # ← 先に付ける
  dt_num <- mk_num_table(copy(dt), effect_col = "effect")
  fwrite(dt_num, "out/tables/summary_PPML_addon_main_k4.csv")
  safe_datasummary(as.data.frame(dt_num), "out/tables/summary_PPML_addon_main_k4.html")
  safe_datasummary(as.data.frame(dt_num), "out/tables/summary_PPML_addon_main_k4.tex")
} else {
  message("Main k=4 PPML add-on file not found. Skipping.")
}

cat("Tables written to out/tables/ .\n")
