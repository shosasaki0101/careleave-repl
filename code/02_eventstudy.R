# =================================
# 02_eventstudy.R  Event studies (ratio)
# =================================
library(data.table)
library(fixest)
library(zoo)

bpm <- fread(file.path("out","bpm_clean.csv"))

bpm_es <- copy(bpm)

# Around 2016-08
bpm_es[, ev2016 := as.integer(round(12*(as.yearmon(date) - as.yearmon("2016-08"))))]
bpm_es[ev2016 < -18, ev2016 := -18]
bpm_es[ev2016 >  24, ev2016 :=  24]
es2016 <- feols(ln_ratio_mf ~ i(ev2016, ref=-1) | pref_id,
                data=bpm_es, weights=~w_total, cluster=~pref_id)
png("out/Figure_ES_2016_ratio.png", 1200, 800, res=150)
iplot(es2016, xlab="Months since 2016-08 (ref=-1)",
      ylab="Effect on ln(M/F)", main="Event study around 2016 reform", ref.line=0)
dev.off()

# Around 2017-01
bpm_es[, ev2017 := as.integer(round(12*(as.yearmon(date) - as.yearmon("2017-01"))))]
bpm_es[ev2017 < -18, ev2017 := -18]
bpm_es[ev2017 >  24, ev2017 :=  24]
es2017 <- feols(ln_ratio_mf ~ i(ev2017, ref=-1) | pref_id,
                data=bpm_es, weights=~w_total, cluster=~pref_id)
png("out/Figure_ES_2017_ratio.png", 1200, 800, res=150)
iplot(es2017, xlab="Months since 2017-01 (ref=-1)",
      ylab="Effect on ln(M/F)", main="Event study around 2017 reform", ref.line=0)
dev.off()
