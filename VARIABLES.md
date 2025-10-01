Variable Definitions (English + Japanese)

## A. Identifiers & Time

**pref_id**

- English: Prefecture ID (1–47)

- 日本語: 都道府県コード（1–47）

- Source: Common key, consistent across all sources.

**pref_name**

- English: Prefecture name

- 日本語: 都道府県名

- Source: From raw compilation (not used as a key in scripts).

**year_month**

- English: Year–month in YYYYMM

- 日本語: 年月（YYYYMM 形式）

- Constructed/Used for: Parsing monthly date.

**date**

- English: First day of month (YYYY-MM-01)

- 日本語: 月初日（YYYY-MM-01）

- Constructed as: Parsed from year_month.

**year**

- English: Calendar year

- 日本語: 年

**month**

- English: Calendar month (1–12)

- 日本語: 月（1–12）

**moy**

- English: Month-of-year factor ("01"–"12")

- 日本語: 月ダミー（因子）

- Constructed as: factor(strftime(date, "%m")).

**t_index**

- English: Time index (months since first observation)

- 日本語: 月次インデックス（観測開始からの月数）

- Constructed as: as.integer(as.yearmon(date) - as.yearmon(min(date))).

## B. Outcomes (Carers’ Leave Benefits)

**n_leave_m, n_leave_f**

- English: Carers’ Leave Benefit Recipients (male / female)

- 日本語（正式名）: 「雇用保険事業年報」第14表 都道府県労働局別雇用継続給付の状況［介護休業給付］

- English translation: Employment Insurance Annual Report, Table 14: Carers’ Leave Benefits by Prefecture Labour Bureau

- Source: MHLW — https://www.mhlw.go.jp/toukei/list/150-1a.html

**w_total**

- English: Total recipients (male + female)

- 日本語: 受給者総数（男性＋女性）

- Constructed as: pmax(n_leave_m,0) + pmax(n_leave_f,0).

**ln_ratio_mf**

- English: Log ratio of male/female recipients

- 日本語: 男性／女性受給者比の対数

- Constructed as: log((pmax(n_leave_m,0)+0.5)/(pmax(n_leave_f,0)+0.5))

## C. Controls (Levels) + Sources

**u_rate**

- English: Unemployment rate (model estimates by prefecture)

- 日本語（正式名）: 「労働力調査」第６表 都道府県別完全失業率（モデル推計値）

- English translation: Labour Force Survey, Table 6: Prefectural Unemployment Rate (Model Estimates)

- Source: e-Stat — https://www.e-stat.go.jp/stat-search/files?page=1&toukei=00200531

**n_ei**

- English: Employment Insurance insured persons

- 日本語（正式名）: 「雇用保険事業年報」第2表 都道府県労働局別適用状況［被保険者関係］

- English translation: Employment Insurance Annual Report, Table 2: Insured Persons

- Source: MHLW — https://www.mhlw.go.jp/toukei/list/150-1a.html

**ln_ei**

- English: Log of Employment Insurance insured persons

- 日本語: 被保険者数の対数

- Constructed as: log(pmax(n_ei,1)).

**n_need**

- English: Certified care-need persons (support/care levels)

- 日本語（正式名）: 第２－１表 都道府県別 要介護（要支援）認定者数－男女計－

- English translation: Table 2-1: Certified Support/Care-need Persons by Prefecture (Total)

- Source: MHLW — https://www.mhlw.go.jp/topics/0103/tp0329-1.html

**ln_need**

- English: Log of certified care-need persons

- 日本語: 要介護（要支援）認定者数の対数

- Constructed as: log(pmax(n_need,1)).

**facility_users**

- English: Facility service users

- 日本語（正式名）: 第５－１表 都道府県別 施設サービス受給者数

- English translation: Table 5-1: Facility Service Users by Prefecture

- Source: MHLW — https://www.mhlw.go.jp/topics/0103/tp0329-1.html

**ln_fac**

- English: Log of facility service users

- 日本語: 施設サービス受給者数の対数

- Constructed as: log(pmax(facility_users,1)).

**oldshare75**

- English: Share of population aged 75+ (75+ / total)

- 日本語: 人口に占める75歳以上人口の割合

- Constructed as: Provided or pop75 / pop.

**pop, pop75**

- English: Population (total) and population aged 75+

- 日本語（正式名）: 「人口推計」第2表 都道府県、男女別人口及び人口性比

- English translation: Population Estimates, Table 2: Population and Sex Ratio by Prefecture

- Source: Statistics Bureau of Japan — https://www.stat.go.jp/data/jinsui/index.html

## D. Standardized Controls (mean 0, sd 1)

**z_u_rate, z_ln_ei, z_ln_need, z_ln_fac, z_oldshare75**

- English: Standardized versions of the above controls

- 日本語: 上記コントロール変数の標準化版

- Constructed as: (x - mean(x)) / sd(x) within the full panel.

## E. Variables created only inside analysis scripts (not in bpm_clean.csv)

These appear when running the analysis (not stored in the cleaned CSV):

- Add-on spec dummies: d2016, d2017_add_eff

  - 2016 reform indicator; 2017 additional effect indicator (with lag k).

- Exclusive 3-bin dummies: p_2016only, p_2017plus

  - Mutually exclusive periods (pre is the reference).

- Long-format helpers: sexvar, sex, n

  - Created by to_long_*() for stacked (male/female) PPML.

## Notes

- All numeric fields were cleaned from raw inputs (full-width digits, commas) during preprocessing (code/00_prep.R).

- Time and seasonal controls are added in models via t_index and i(moy) respectively.
