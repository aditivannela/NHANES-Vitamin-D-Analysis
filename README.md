# NHANES-Vitamin-D-Analysis
Calculates weighted prevalence of Vitamin D deficiency in adults using 2013–2014 and 2015–2016 NHANES data

## Tools
- R
- tidyverse
- haven

## What it does
- Downloads NHANES demographic and vitamin D datasets
- Filters adults (18+) and creates Age/Sex categories
- Flags Vitamin D deficiency (<30 ng/mL)
- Calculates weighted prevalence by Age and Sex

## Data
All datasets are publicly available from the CDC NHANES website:
- DEMO_H.XPT / DEMO_I.XPT
- VID_H.XPT / VID_I.XPT

## Visualization
The plot below summarizes the weighted prevalence of Vitamin D deficiency by age group and sex:

![Vitamin D Deficiency by Age and Sex](Downloads/VitaminD_Deficiency_by_AgeSex.png)

## How to run
1. Make sure all four `.XPT` files are in the same folder as the script.
2. Open R or RStudio.
3. Run `nhanes_vitd_analysis.R` to generate `results.csv`.
