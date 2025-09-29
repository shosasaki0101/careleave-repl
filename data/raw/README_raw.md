**How to Obtain the Raw Data (English & 日本語)**

Important: Raw files are not redistributed due to licensing/redistribution restrictions. Follow the steps below to download the original tables and reconstruct japan.csv (the compiled raw) and out/bpm_clean.csv (the cleaned panel).

**1) Population (total & 75+)** — pop, pop75

English title: Population Estimates, Table 2: Population and Sex Ratio by Prefecture

日本語（正式名）: 「人口推計」第2表 都道府県、男女別人口及び人口性比

URL: https://www.stat.go.jp/data/jinsui/index.html

What to extract: Prefecture-level monthly (or annual interpolated to month if needed) totals for population and population aged 75+.

Tips: Align prefecture IDs (1–47). If the table is annual, document the interpolation method you use (not required by our scripts if monthly is available).

**2) Carers’ Leave Benefit Recipients** — n_leave_m, n_leave_f

English title: Employment Insurance Annual Report, Table 14: Carers’ Leave Benefits by Prefecture Labour Bureau

日本語（正式名）: 「雇用保険事業年報」第14表 都道府県労働局別雇用継続給付の状況［介護休業給付］

URL: https://www.mhlw.go.jp/toukei/list/150-1a.html

What to extract: Monthly counts by prefecture, split by male/female.

**3) Certified Care-need Persons** — n_need

English title: Table 2-1: Certified Support/Care-need Persons by Prefecture (Total)

日本語（正式名）: 第２－１表 都道府県別 要介護（要支援）認定者数－男女計－

URL: https://www.mhlw.go.jp/topics/0103/tp0329-1.html

What to extract: Total number by prefecture (monthly where available; if not, match to your time frequency and document the method).

**4) Facility Service Users** — facility_users

English title: Table 5-1: Facility Service Users by Prefecture

日本語（正式名）: 第５－１表 都道府県別 施設サービス受給者数

URL: https://www.mhlw.go.jp/topics/0103/tp0329-1.html

What to extract: Prefecture-level counts (align timing with other series).

**5) Unemployment Rate** — u_rate

English title: Labour Force Survey, Table 6: Prefectural Unemployment Rate (Model Estimates)

日本語（正式名）: 「労働力調査」第６表 都道府県別完全失業率（モデル推計値）

URL: https://www.e-stat.go.jp/stat-search/files?page=1&toukei=00200531

What to extract: Prefecture-level rates. Ensure month alignment with your panel.

**6) Employment Insurance Insured Persons** — n_ei

English title: Employment Insurance Annual Report, Table 2: Insured Persons

日本語（正式名）: 「雇用保険事業年報」第2表 都道府県労働局別適用状況［被保険者関係］

URL: https://www.mhlw.go.jp/toukei/list/150-1a.html

What to extract: Prefecture-level insured counts (prefer monthly; if not, document alignment).

**File Naming & Merge Keys**

Your raw CSV: Place the compiled file at
data/raw/japan.csv
with the exact column names required by the prep script:

pref_id, year_month, n_leave_m, n_leave_f,
n_pop, n_pop75, oldshare75, n_need, n_facility_users,
u_rate, n_ei

The prep script (code/00_prep.R) will:

Rename n_pop→pop, n_pop75→pop75, n_facility_users→facility_users

Clean numeric fields (full-width digits, commas)

Create date, moy, t_index, logs, standardized controls

Output out/bpm_clean.csv

Key for merges: pref_id × year_month (YYYYMM).

**Reproducing the Clean Panel**

From the project root:
source("code/00_prep.R") 

**Citation Guidance**

When using the data, please cite each source explicitly with:

Official Japanese title (日本語の正式名)

English descriptive title (意訳)

URL (landing page, not deep files where possible)

Access date (optional but recommended)

Redistribution Policy

Raw tables may have redistribution restrictions. We do not include them in this repository.

The cleaned, derived panel out/bpm_clean.csv is generated locally via the script above.

If you plan to share a derived dataset publicly, ensure it complies with each source’s terms and your journal/program’s policies.
