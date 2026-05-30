library(ggplot2)
library(dplyr)
library(tidyverse)
library(paletteer)


my_palette <- paletteer_d("nationalparkcolors::BlueRidgePkwy")

# Global childhood vaccination coverage and World Bank income group data
data <- read.csv('data/global-vaccination-coverage.csv') 
income <- read.csv('data/world-bank-income-groups.csv')


# Remove observations without a country code and merge vaccination data with income classifciation
data_clean <- subset(data, Code != "")

data_merged <- merge(
  data_clean,
  income,
  by = c("Code", "Year")
)

data_merged <- data_merged %>%
  rename(income_class = World.Bank.s.income.classification)

colnames(data_merged) <- make.names(colnames(data_merged))

data_2024 <- subset(data_merged, Year == 2024)


# Selected routine childhood vaccine coverage indicators
vaccine_cols <- c(
  "Hepatitis.B..HepB3.",
  "H..influenza.type.b..Hib3.",
  "Inactivated.polio.vaccine..IPV1.",
  "Measles..first.dose..MCV1.",
  "Pneumococcal.vaccine..PCV3.",
  "Polio..Pol3.",
  "Rubella..RCV1.",
  "Rotavirus..RotaC.",
  "Diptheria.tetanus.pertussis..DTP3."
)

# Country-level average vaccination coverage
data_2024$mean_coverage <- rowMeans(data_2024[, vaccine_cols], na.rm = TRUE)

# for a clean order (from lowest to highest)
data_2024$income_class <- factor(
  data_2024$income_class,
  levels = c(
    "Low-income countries",
    "Lower-middle-income countries",
    "Upper-middle-income countries",
    "High-income countries"
  )
)

# Dichotomization --> used as it is the goal from WHO
data_2024$high_coverage <- ifelse(data_2024$mean_coverage >= 90, "Yes", "No")
data_2024$high_coverage <- factor(data_2024$high_coverage)




# Normality check
ggplot(data_2024, aes(sample = mean_coverage)) +
  stat_qq() +
  stat_qq_line() +
  facet_wrap(~ income_class)

shapiro_results <- data_2024 %>%
  group_by(income_class) %>%
  summarise(
    p_value = shapiro.test(mean_coverage)$p.value
  )

shapiro_results


# to see vaccination covergage by the income classed
ggplot(data_2024, aes(x = income_class, y = mean_coverage, fill = income_class)) +
  geom_boxplot() +
  geom_jitter(width = 0.2, alpha = 0.4) +
  scale_fill_manual(values = my_palette) +
  theme_gray() +
  theme(
    legend.position = "none"
  ) +
  labs(
    title = "Vaccination Coverage by Income Class",
    x = "Income Class",
    y = "Mean Coverage"
  )


############################
# QUESTION 1
#  Do vaccination coverage levels differ across income groups?
############################

# Main test: non-parametric
kruskal.test(mean_coverage ~ income_class, data = data_2024)

# Post-hoc comparisons
pairwise.wilcox.test(
  data_2024$mean_coverage,
  data_2024$income_class,
  p.adjust.method = "BH",
  exact = FALSE
)

# (robustness check)
anova_model <- aov(mean_coverage ~ income_class, data = data_2024)
summary(anova_model)
TukeyHSD(anova_model)


############################
#QUESTION 2
# Is achieving high vaccination coverage associated with income level?
############################

table_data <- table(data_2024$income_class, data_2024$high_coverage)

chi <- chisq.test(table_data)
chi
chi$expected

prop.table(table_data, 1)


ggplot(data_2024, aes(x = income_class, fill = high_coverage)) +
  geom_bar(position = "fill") +
  scale_fill_manual(values = my_palette) +
  theme_gray() +
  labs(
    title = "High Vaccination Coverage by Income Class",
    x = "Income Class",
    y = "Proportion",
    fill = "High Coverage"
  )


############################
# QUESTION 3
#Does income classification predict the likelihood of achieving high vaccination coverage?
############################

# Use low-income countries as the reference category
data_2024$income_class <- relevel(
  data_2024$income_class,
  ref = "Low-income countries"
)

log_model <- glm(
  high_coverage ~ income_class,
  data = data_2024,
  family = binomial
)

# Odds ratios + CI
exp(cbind(
  OddsRatio = coef(log_model),
  confint(log_model)
))


pred_data <- data.frame(
  income_class = factor(
    c(
      "Low-income countries",
      "Lower-middle-income countries",
      "Upper-middle-income countries",
      "High-income countries"
    ),
    levels = c(
      "Low-income countries",
      "Lower-middle-income countries",
      "Upper-middle-income countries",
      "High-income countries"
    )
  )
)

pred_data$predicted_prob <- predict(
  log_model,
  newdata = pred_data,
  type = "response"
)


ggplot(pred_data, aes(x = income_class, y = predicted_prob, fill = income_class)) +
  geom_col() +
  scale_fill_manual(values = my_palette) +
  ylim(0, 1) +
  theme_gray() +
  theme(legend.position = "none") +
  labs(
    title = "Predicted Probability of High Vaccination Coverage",
    x = "Income Class",
    y = "Predicted Probability"
  )



