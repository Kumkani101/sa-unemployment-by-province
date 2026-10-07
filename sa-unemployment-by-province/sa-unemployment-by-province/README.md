# Unemployment in South Africa by province, 2019–2026

An analysis in R of the official unemployment rate across South Africa's nine provinces, using Stats SA's Quarterly Labour Force Survey. It compares the second quarter of each year from 2019 (before the pandemic) to 2026.

**Question:** Has unemployment returned to pre-pandemic levels, and how far apart are the provinces?

![Unemployment rate by province against the national rate](charts/02_provinces_vs_national.png)

## Findings

1. **Unemployment has not returned to pre-pandemic levels.** The national rate was 29.0% in Q2 2019 and 33.6% in Q2 2026. In every second quarter since 2021 it has stayed between 32.6% and 34.4%.
2. **The 2020 drop was not a recovery.** The official rate fell to 23.3% in Q2 2020 because people who could not search for work during the lockdown were counted as outside the labour force, not as unemployed. The expanded rate that quarter was 42.0%.
3. **The Eastern Cape had the highest rate in six of the eight years.** At 47.5% in Q2 2026, close to half its labour force was unemployed, the highest provincial rate in this series.
4. **The gap between provinces is the widest in the series.** In Q2 2026 the Eastern Cape (47.5%) was 28.0 percentage points above the Western Cape (19.5%). In 2019 the gap between the highest and lowest province was 15.1 points.
5. **Only two provinces are below their 2019 level:** the Western Cape (−0.9 points) and the Northern Cape (−0.7 points). Limpopo, which had the lowest rate in 2019 (20.3%), rose 11.7 points to 32.0%.

![Change in unemployment rate since 2019](charts/04_change_since_2019.png)

## Limitations

- **Only the second quarter is compared.** Comparing the same quarter each year avoids seasonal effects, but it hides movement within each year.
- **These are survey estimates.** Provincial figures carry sampling error, so small year-to-year changes may not be meaningful.
- **The official definition excludes discouraged work-seekers,** people who want work but have stopped looking. The expanded unemployment rate is higher in every province.
- **Q2 2020 was surveyed by telephone only,** so it is not directly comparable with other years.
- **This analysis describes trends.** It does not show what caused them.

## What's in this repository

| File | What it is |
|---|---|
| `analysis.R` | The full analysis in R, with comments explaining each step |
| `data/unemployment_by_province_q2.csv` | The dataset: one row per province (and South Africa) per year |
| `data/SOURCES.md` | The Stats SA release and table each figure comes from |
| `charts/` | The four charts produced by the script |
| `output/` | Summary tables: highest and lowest province each year, and change since 2019 |

## How I did it

1. Collected the official provincial unemployment rates from four QLFS statistical releases, recording the release and table for every figure.
2. Loaded and checked the data in R with `readr` and `dplyr` (no missing values, all nine provinces for all eight years).
3. Compared each province with the national rate using small multiples (`facet_wrap` in `ggplot2`).
4. Reshaped the data with `tidyr::pivot_wider` to calculate each province's change from 2019 to 2026.
5. Calculated the highest and lowest province each year and the gap between them.
6. Marked the 2020 figure on the charts and explained it, so it is not misread as a fall in unemployment.

## Run it yourself

```r
install.packages(c("readr", "dplyr", "tidyr", "ggplot2"))
```

Then, from the project folder:

```
Rscript analysis.R
```

**Tools:** R, dplyr, tidyr, ggplot2
