# BEV Filling Branch with Outside Research for Boxplots

# Import libraries ----
library(ggplot2)
library(dplyr) # for %>%

setwd(getwd())

# Read in the dataset ----
## distinct()
vehicles <- read.csv("Electric_Vehicle_Population_Data.csv")
vehicles <- distinct(vehicles)

## filter only 9 cols
df0 <- vehicles %>% select(c(VIN..1.10., State, Model.Year, Make, Model, Electric.Vehicle.Type, Electric.Range, Base.MSRP, Electric.Utility))

# sumry0 after filtering cols ----
sumry <- summary(df0)
writeLines(capture.output(summary(df0)), "df0_summary0.md")

# colSums0 for blanks and spaces ----
colSums0 <- colSums(is.na(df) | df0 == "" | df0 == " " | df0 == 0)
writeLines(capture.output(colSums0), "df0colSums0.md")

# df of nas and blanks ----
dfnablank <- df0 %>% filter(is.na(Electric.Range) | Electric.Range == "" | Electric.Range == " " 
| is.na(Electric.Vehicle.Type) | Electric.Vehicle.Type == "" | Electric.Vehicle.Type == " " 
| is.na(Base.MSRP) | Base.MSRP == "" | Base.MSRP == " " 
| is.na(Electric.Utility) | Electric.Utility == "" | Electric.Utility == " "  )
write.csv(dfnablank, "dfnablank.csv")

# FINDING: only 39 nas or blanks ----
## only 0.16% > anti_join to drop 

df <- anti_join(df0, dfnablank)


# removed_rows <- nrow(df0) - nrow(df)
# removed_rows # 39

# Export df----
write.csv(df, "dfcln.csv", row.names = FALSE)

# ````````````````
# BEV section ----
# ................

# Filter out battery electric vehicles only ----
dfbev <- df %>% filter (Electric.Vehicle.Type == "Battery Electric Vehicle (BEV)")
grp_dfbev <- dfbev %>% group_by(Model.Year, Make, Model, Electric.Range) %>% summarise(Count = n(), .groups = "drop") %>% arrange(Make)

# Group zero range and group nonzero range ----
# Comparison shows a lot of zeroes still
# Therefore, not used for the final ranges

df_zero_bev <- df %>% filter (Electric.Vehicle.Type == "Battery Electric Vehicle (BEV)" & Electric.Range == 0) %>% 
  arrange((Make))

grp_zero_bev <- df_zero_bev %>% group_by(Model.Year, Make, Model, Electric.Range) %>% summarise(Count = n(), .groups = "drop") %>% arrange(Make)

write.csv(grp_zero_bev, "grp_zero_bev.csv", row.names = FALSE)

df_nonzero_bev <- df %>% filter (Electric.Vehicle.Type == "Battery Electric Vehicle (BEV)" & Electric.Range != 0) %>% 
  arrange((Make))

grp_nonzero_bev <- df_nonzero_bev %>% group_by(Model.Year, Make, Model, Electric.Range) %>% summarise(Count = n(), .groups = "drop")  %>% arrange(Make)

write.csv(grp_nonzero_bev, "grp_nonzero_bev.csv")


# Impute zero values ----
## Left join
temp_df_bev_after_join <- grp_zero_bev %>%
  left_join(
    grp_nonzero_bev %>%
      select(Model.Year, Make, Model, NonZero.Electric.Range = Electric.Range),
    by = c("Model.Year", "Make", "Model")
  )


## Coalesce and fill in
temp_df_bev_partial_fill <- temp_df_bev_after_join %>%
  mutate(Electric.Range = coalesce(
    ifelse(Electric.Range == 0, NonZero.Electric.Range, Electric.Range),
    Electric.Range)
  ) %>%
  select(-NonZero.Electric.Range)

## Filter only the rows with nonzero Electric.Range
temp_df_bev_nonzero <- temp_df_bev_partial_fill %>%
  filter(Electric.Range != 0)

## Finding: very few rows with range information
write.csv(temp_df_bev_nonzero, "temp_df_bev_nonzero.csv")

## df bev still to fill Electric.Range zeroes ----
temp_df_bev_still_zero <- temp_df_bev_partial_fill %>%
  filter(Electric.Range == 0) %>%
  mutate(Min.E.Range = "NA", Max.E.Range = "NA")

## Finding:  still a lot of zero rows, major research required
## If you are trying to replicate this, you need to research on your own. :)
write.csv(temp_df_bev_still_zero, "temp_df_bev_still_zero.csv", row.names = FALSE)

## This temp csv file will be filled up as dfbev_ranges.csv below.






# ``````````````````  
# POST RESEARCH ----
# ..................

## Similar to msrps, dfbev_ranges.csv was filled outside of R
## Read in the bev_ranges_final externally filled up electric ranges ----

bev_ranges_final <- read.csv("dfbev_ranges.csv")


## Create dfbev grouped by Model.Year, Make and Model
dfbev_grpd <- dfbev %>% group_by(Model.Year, Make, Model) %>%
  summarise(Count = n(), .groups = "drop") %>% arrange(Make)


## Left_join with dfbev_grpd on Model.Year, Make and Model
dfbev_joined <- left_join(dfbev_grpd, bev_ranges_final, by = c("Model.Year","Make", "Model"))

## Export for box plotting ----
write.csv(dfbev_joined, "dfbev_joined_for_boxplot.csv", row.names = FALSE)




