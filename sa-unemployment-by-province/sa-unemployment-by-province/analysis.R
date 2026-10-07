# Unemployment in South Africa by province, Q2 2019 to Q2 2026
# Data: Stats SA Quarterly Labour Force Survey (see data/SOURCES.md)
#
# Run from the project folder:  Rscript analysis.R
# Output: four charts in charts/ and a summary table in output/

suppressPackageStartupMessages({
  library(readr)    # reading CSV files
  library(dplyr)    # filtering, grouping, summarising
  library(tidyr)    # reshaping between long and wide format
  library(ggplot2)  # charts
})

dir.create("charts", showWarnings = FALSE)
dir.create("output", showWarnings = FALSE)

# Colour-blind-safe colours (Okabe-Ito palette)
blue   <- "#0072B2"
orange <- "#D55E00"
grey   <- "grey55"

theme_set(
  theme_minimal(base_size = 12) +
    theme(panel.grid.minor = element_blank(),
          plot.title = element_text(face = "bold"),
          plot.caption = element_text(colour = "grey40", hjust = 0))
)
source_note <- "Source: Stats SA, Quarterly Labour Force Survey (Q2 releases). Official definition of unemployment."


# 1. Load and check ------------------------------------------------------------

unemployment <- read_csv("data/unemployment_by_province_q2.csv", show_col_types = FALSE)

glimpse(unemployment)
cat("Missing values:", sum(is.na(unemployment)), "\n")
cat("Years:", paste(sort(unique(unemployment$year)), collapse = ", "), "\n")

# Split the national figure from the nine provinces
national  <- unemployment %>% filter(province == "South Africa")
provinces <- unemployment %>% filter(province != "South Africa")


# 2. National trend ------------------------------------------------------------
# Q2 2020 was collected by telephone during the hard lockdown. Many people
# could not look for work, so the survey counted them as "not economically
# active" rather than unemployed. The official rate fell, but jobs did not
# recover. That point is drawn differently so it is not misread.

chart1 <- ggplot(national, aes(year, unemployment_rate_pct)) +
  geom_line(colour = blue, linewidth = 1.2) +
  geom_point(data = filter(national, year != 2020), colour = blue, size = 3) +
  geom_point(data = filter(national, year == 2020), shape = 21, fill = "white",
             colour = blue, size = 3, stroke = 1.2) +
  geom_text(data = filter(national, year != 2020),
            aes(label = sprintf("%.1f%%", unemployment_rate_pct)), vjust = -1.1, size = 3.6) +
  geom_text(data = filter(national, year == 2020),
            aes(label = sprintf("%.1f%%", unemployment_rate_pct)), hjust = -0.35, size = 3.6) +
  annotate("text", x = 2020, y = 20.2, size = 3.3, colour = "grey30",
           label = "Lockdown: people unable to\nsearch for work were not\ncounted as unemployed") +
  scale_x_continuous(breaks = 2019:2026) +
  scale_y_continuous(limits = c(15, 38)) +
  labs(title = "National unemployment rate, second quarter of each year",
       x = NULL, y = "Unemployment rate (%)", caption = source_note)

ggsave("charts/01_national_trend.png", chart1, width = 8, height = 4.8, dpi = 150, bg = "white")


# 3. Every province against the national rate ----------------------------------
# facet_wrap() draws one small chart per province, all on the same scale,
# which is easier to compare than nine overlapping lines.

national_line <- national %>% select(year, national_rate = unemployment_rate_pct)

chart2 <- ggplot(provinces, aes(year, unemployment_rate_pct)) +
  geom_line(data = national_line, aes(year, national_rate),
            colour = grey, linetype = "dashed", inherit.aes = FALSE) +
  geom_line(colour = blue, linewidth = 1) +
  geom_point(colour = blue, size = 1.6) +
  facet_wrap(~ province, ncol = 3) +
  scale_x_continuous(breaks = c(2020, 2023, 2026)) +
  labs(title = "Unemployment rate by province (blue) against the national rate (dashed)",
       subtitle = "Second quarter of each year, 2019 to 2026",
       x = NULL, y = "Unemployment rate (%)", caption = source_note)

ggsave("charts/02_provinces_vs_national.png", chart2, width = 9, height = 7, dpi = 150, bg = "white")


# 4. Latest quarter ranking ----------------------------------------------------

latest_year <- max(provinces$year)
latest <- provinces %>% filter(year == latest_year)
latest_national <- national %>% filter(year == latest_year) %>% pull(unemployment_rate_pct)

chart3 <- ggplot(latest, aes(unemployment_rate_pct, reorder(province, unemployment_rate_pct))) +
  geom_col(fill = blue, width = 0.7) +
  geom_vline(xintercept = latest_national, linetype = "dashed", colour = grey) +
  annotate("text", x = latest_national + 0.5, y = 1, hjust = 0, size = 3.3,
           label = sprintf("National %.1f%%", latest_national)) +
  geom_text(aes(label = sprintf("%.1f", unemployment_rate_pct)), hjust = -0.2, size = 3.6) +
  scale_x_continuous(limits = c(0, 52)) +
  labs(title = sprintf("Unemployment rate by province, Q2 %d", latest_year),
       x = "Unemployment rate (%)", y = NULL, caption = source_note)

ggsave("charts/03_latest_ranking.png", chart3, width = 8, height = 4.8, dpi = 150, bg = "white")


# 5. Change since 2019 ---------------------------------------------------------
# pivot_wider() turns the long table (one row per province per year) into a
# wide one (one row per province, one column per year), so the two years can
# be subtracted.

change <- provinces %>%
  filter(year %in% c(2019, latest_year)) %>%
  select(province, year, unemployment_rate_pct) %>%
  pivot_wider(names_from = year, values_from = unemployment_rate_pct, names_prefix = "q2_") %>%
  mutate(change = round(.data[[paste0("q2_", latest_year)]] - q2_2019, 1),
         direction = if_else(change > 0, "Higher", "Lower"))

chart4 <- ggplot(change, aes(change, reorder(province, change), fill = direction)) +
  geom_col(width = 0.7) +
  geom_vline(xintercept = 0, colour = "grey30") +
  geom_text(aes(label = sprintf("%+.1f", change),
                hjust = if_else(change > 0, -0.2, 1.2)), size = 3.6) +
  scale_fill_manual(values = c(Higher = orange, Lower = blue)) +
  scale_x_continuous(limits = c(-4, 15)) +
  labs(title = sprintf("Change in unemployment rate, Q2 2019 to Q2 %d", latest_year),
       subtitle = "Percentage points. Orange means unemployment is higher than before the pandemic.",
       x = "Percentage points", y = NULL, fill = NULL, caption = source_note) +
  theme(legend.position = "none")

ggsave("charts/04_change_since_2019.png", chart4, width = 8, height = 4.8, dpi = 150, bg = "white")


# 6. Summary table -------------------------------------------------------------
# Highest and lowest province each year, and the gap between them.

gaps <- provinces %>%
  group_by(year) %>%
  summarise(highest_province = province[which.max(unemployment_rate_pct)],
            highest_rate     = max(unemployment_rate_pct),
            lowest_province  = province[which.min(unemployment_rate_pct)],
            lowest_rate      = min(unemployment_rate_pct),
            gap              = round(highest_rate - lowest_rate, 1))

print(gaps)
print(arrange(change, desc(change)))

write_csv(gaps, "output/highest_lowest_by_year.csv")
write_csv(arrange(change, desc(change)), "output/change_since_2019.csv")

cat("\nDone. Charts saved in charts/, tables in output/\n")
