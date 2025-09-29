# ===============================
# 00_prep.R  Load, clean, derive
# ===============================
library(data.table)
library(zoo)

# ---- Paths ----
infile_rel <- "data/raw/japan.csv"              # expected location in repo
infile <- Sys.getenv("JAPAN_CSV", infile_rel)   # allow override by env var
dir.create("out", showWarnings = FALSE)

# ---- Read ----
bpm <- fread(infile)
setDT(bpm); setalloccol(bpm)

# Expected columns (exact)
need <- c("pref_id","year_month","n_leave_m","n_leave_f",
          "n_pop","n_pop75","oldshare75","n_need","n_facility_users",
          "u_rate","n_ei")
miss <- setdiff(need, names(bpm))
if (length(miss)) stop("Missing required columns: ", paste(miss, collapse=", "))

# Standardize names used downstream
setnames(bpm, c("n_pop","n_pop75","n_facility_users"),
              c("pop","pop75","facility_users"), skip_absent=TRUE)

# ---- Helpers ----
to_num <- function(x){
  x <- as.character(x)
  x <- chartr("０１２３４５６７８９，．－＋", "0123456789,. -+", x)
  x <- gsub("[,，\\s]", "", x)
  x <- gsub("[^0-9eE.+\\-]", "", x)
  suppressWarnings(as.numeric(x))
}

# ---- Cast numerics ----
num_cols <- c("pref_id","n_leave_m","n_leave_f","u_rate","n_ei",
              "n_need","facility_users","oldshare75","pop","pop75")
for (v in intersect(num_cols, names(bpm))) bpm[, (v) := to_num(get(v))]
bpm[, (intersect(num_cols, names(bpm))) := lapply(.SD, as.numeric),
    .SDcols = intersect(num_cols, names(bpm))]

# ---- Dates ----
ym <- gsub("[^0-9]", "", as.character(bpm$year_month))
if (any(nchar(ym) != 6)) stop("year_month must be YYYYMM")
yy <- as.integer(substr(ym,1,4)); mm <- as.integer(substr(ym,5,6))
if (any(mm < 1 | mm > 12, na.rm=TRUE)) stop("Invalid month in year_month")
bpm[, date := as.Date(sprintf("%04d-%02d-01", yy, mm))]
bpm[, moy  := factor(sprintf("%02d", mm))]

# ---- Derived ----
bpm[, `:=`(
  w_total     = pmax(n_leave_m,0) + pmax(n_leave_f,0),
  ln_ratio_mf = log((pmax(n_leave_m,0) + 0.5)/(pmax(n_leave_f,0) + 0.5)),
  t_index     = as.integer(as.yearmon(date) - as.yearmon(min(date))),
  ln_ei       = log(pmax(n_ei,1)),
  ln_need     = log(pmax(n_need,1)),
  ln_fac      = log(pmax(facility_users,1))
)]

# ---- Standardize controls (z_) ----
for (v in c("u_rate","ln_ei","ln_need","ln_fac","oldshare75")) {
  mu <- mean(bpm[[v]], na.rm=TRUE)
  sdv <- sd(bpm[[v]], na.rm=TRUE); if (!is.finite(sdv) || sdv==0) sdv <- 1
  bpm[[paste0("z_",v)]] <- (bpm[[v]] - mu)/sdv
}

# ---- Save ----
fwrite(bpm, file.path("out","bpm_clean.csv"))
cat("Saved: out/bpm_clean.csv  rows=", nrow(bpm), " cols=", ncol(bpm), "\n")
