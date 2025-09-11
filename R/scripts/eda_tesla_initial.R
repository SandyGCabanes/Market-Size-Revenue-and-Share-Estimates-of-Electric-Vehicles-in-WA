# This is the initial EDA of the dataset -> dfcln.csv

# ````````````````````````````````````````````````````````````````````````
# Import libraries ----
# ........................................................................
library(ggplot2)
library(dplyr) # for %>%

# Collapse all: Alt + O
# Expand all: Shift + Alt + 0


# ````````````````````````````````````````````````````````````````````````
# Read in the dataset ----
# ........................................................................

df00 <- read.csv("Electric_Vehicle_Population_Data.csv")

# Remove duplicate rows distinct() ----
df00 <- distinct(df00)


# ``````````````````````````````
# Initial exploration ----
# .............................

# Displaying basic information about the dataset

## Shape, columns, structure, copy paste to md ----
cat("Dataset dimensions:", dim(df00), "\n")
cat("\nData structure:\n")
str(df00)
summary(df00)  #Copy-paste output as "eda_df00_etc.md"

# ````````````````````````````````````````````````````````````````````````
# Clean the dataset ----
# ........................................................................

## Filter only 9 cols ----
df0 <- df00 %>% select(c(VIN..1.10., State, Model.Year, Make, Model, Electric.Vehicle.Type, Electric.Range, Base.MSRP, Electric.Utility))

## Summary after filtering cols ----
sumry <- summary(df0)
writeLines(capture.output(summary(df0)), "eda_df0_summary.md")

## Check for blanks and spaces ----
colSums0 <- colSums(is.na(df0) | df0 == "" | df0 == " " | df0 == 0)
writeLines(capture.output(colSums0), "eda_df01_colSums.md")

## df of nas and blanks ----
dfnablank <- df0 %>% filter(is.na(Electric.Range) | Electric.Range == "" | Electric.Range == " " 
| is.na(Electric.Vehicle.Type) | Electric.Vehicle.Type == "" | Electric.Vehicle.Type == " " 
| is.na(Base.MSRP) | Base.MSRP == "" | Base.MSRP == " " 
| is.na(Electric.Utility) | Electric.Utility == "" | Electric.Utility == " "  )
write.csv(dfnablank, "dfnablank.csv", row.names = FALSE)

# ````````````````````````````````````````````````````````````````````````
# FINDING: only 39 nas or blanks ----
## Only 0.16% , use anti_join to drop 
# ........................................................................

df <- anti_join(df0, dfnablank)
# removed_rows <- nrow(df0) - nrow(df)
# removed_rows # 39

df <- df %>% filter (State == "WA")

## Check data quality again ----
## Only zeroes left, need to fill up later
colSums1 <- colSums(is.na(df) | df == "" | df == " " | df == 0)
writeLines(capture.output(colSums1), "eda_df_colSums.md")

## Count zeroes in Base.MSRP
msrp_zeroes <- group_by(df00, by = c(Base.MSRP)) %>% summarise (Count = n())
# 232403  / 235692 = 99%

## Count zeroes in Electric.Range 
range_zeroes <- group_by(df00, by = c(Electric.Range)) %>% summarise (Count = n())
# BEVs only: 139761 / 186642 = 75%



## Check data types for dates ----
sapply(df, class)

# Export df----
write.csv(df, "dfcln.csv")


# ````````````````````````````````````````````````````````````````````````
# POST RESEARCH ----
# msrp.csv created outside of R after external research
# dfbev_joined_for_boxplot.csv created outside of R after external research
# ........................................................................


