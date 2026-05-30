# Vaccination Coverage and Income Classification

## Overview

This project was completed as part of the Biostatistics course (FS26). The assignment was to formulate research questions, perform appropriate statistical analyses on real-world public health data, and present the results.

## Research Question

How does childhood vaccination coverage differ across World Bank income groups?

Specifically, these three questions:

- Do vaccination coverage levels differ across income groups?
- Is achieving high vaccination coverage associated with income level?
- Does income classification predict the likelihood of achieving high vaccination coverage?

## Data

Data were obtained from Our World in Data:

- Global vaccination coverage (downloaded 6 April 2026)
- World Bank income groups (downloaded 29 March 2026)

The datasets were merged by country code and year, and the analysis focused on 2024 data.

## Methods

* Shapiro-Wilk test and Q-Q plots
* Kruskal-Wallis test with pairwise Wilcoxon post-hoc tests
* One-way ANOVA (robustness check)
* Chi-squared test of independence
* Logistic regression

## Key Findings

* Vaccination coverage differed significantly across income groups (Kruskal-Wallis, p < 0.001).
* High-income countries showed significantly higher coverage than lower-income countries.
* Income classification was significantly associated with achieving high vaccination coverage (Chi-squared test, p < 0.001).
* High-income countries had substantially greater odds of reaching the 90% vaccination coverage threshold than low-income countries.

## Tools

* R
* ggplot2
* dplyr
* tidyverse
* paletter
