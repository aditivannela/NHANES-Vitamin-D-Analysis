# NHANES Vitamin D Deficiency Analysis
# Author: Aditi Vannela
# Description: Calculates weighted prevalence of Vitamin D deficiency in adults using 2013–2014 and 2015–2016 NHANES data

# Load libraries

library(tidyverse)  # for data manipulation and plotting
library(haven)      # to read .XPT SAS transport files

# Check that data files exist

required_files <- c("DEMO_H.XPT.txt", "DEMO_I.XPT.txt", "VID_H.XPT.txt", "VID_I.XPT.txt")
missing_files <- required_files[!file.exists(required_files)]

if(length(missing_files) > 0) {
  stop(
    paste("Error: The following files are missing from your project folder:\n",
          paste(missing_files, collapse = "\n"),
          "\n\nPlease download them from the NHANES website and place them in this folder:\n",
          "https://wwwn.cdc.gov/nchs/nhanes/continuousnhanes.aspx")
  )
}

# Read local NHANES .XPT.txt files

demo_h <- read_xpt("DEMO_H.XPT.txt")
demo_i <- read_xpt("DEMO_I.XPT.txt")
vid_h  <- read_xpt("VID_H.XPT.txt")
vid_i  <- read_xpt("VID_I.XPT.txt")

# Select relevant columns

demo_h <- demo_h %>% select(SEQN, RIDAGEYR, RIAGENDR, WTMEC2YR)
demo_i <- demo_i %>% select(SEQN, RIDAGEYR, RIAGENDR, WTMEC2YR)
vid_h  <- vid_h  %>% select(SEQN, LBXVIDMS)
vid_i  <- vid_i  %>% select(SEQN, LBXVIDMS)

# Merge demographic and Vitamin D datasets

nhanes_h <- left_join(demo_h, vid_h, by = "SEQN")
nhanes_i <- left_join(demo_i, vid_i, by = "SEQN")

# Combine 2013–2014 and 2015–2016 data

nhanes_all <- bind_rows(nhanes_h, nhanes_i)

# Filter adults, create Age/Sex categories, flag deficiency, adjust weights

nhanes_all <- nhanes_all %>%
  filter(!is.na(LBXVIDMS), RIDAGEYR >= 18) %>%
  mutate(
    Age = case_when(
      RIDAGEYR >= 18 & RIDAGEYR <= 39 ~ "18-39",
      RIDAGEYR >= 40 & RIDAGEYR <= 59 ~ "40-59",
      RIDAGEYR >= 60                 ~ "60+"
    ),
    Sex = if_else(RIAGENDR == 1, "Male", "Female"),
    deficient = LBXVIDMS < 30,            # Vitamin D deficiency if <30 ng/mL
    weight_4yr = WTMEC2YR / 2             # combine 2-year weights for 4-year estimate
  ) %>%
  filter(!is.na(Age))

# Calculate weighted prevalence of deficiency by Age and Sex

results <- nhanes_all %>%
  group_by(Age, Sex) %>%
  summarise(
    Percent_Low_VitD = 100 * sum(weight_4yr * deficient) / sum(weight_4yr),
    .groups = "drop"
  ) %>%
  mutate(
    Age = factor(Age, levels = c("18-39", "40-59", "60+")),
    Sex = factor(Sex, levels = c("Male", "Female"))
  ) %>%
  arrange(Age, Sex) %>%
  select(Age, Sex, Percent_Low_VitD)

# Bar plot of percent deficiency by Age and Sex

vitd_plot <- ggplot(results, aes(x = Age, y = Percent_Low_VitD, fill = Sex)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.7)) +
  labs(
    title = "Weighted Prevalence of Vitamin D Deficiency in Adults",
    x = "Age Group",
    y = "Percent with Low Vitamin D (%)",
    fill = "Sex"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5)
  )

# Save the plot to file

print(vitd_plot)
ggsave("VitaminD_Deficiency_by_AgeSex.png", plot = vitd_plot, width = 8, height = 6, dpi = 300)

# Save results and print

write.csv(results, "results.csv", row.names = FALSE)
print(results)
