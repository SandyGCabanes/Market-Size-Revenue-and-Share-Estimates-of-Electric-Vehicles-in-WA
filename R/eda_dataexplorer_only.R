# Tesla Executive Briefing

# Import libraries ----
library(tidyverse)
library(dplyr)
#install.packages("DataExplorer")
library(DataExplorer)


# Read in the dataset ----
## distinct()
vehicles <- read.csv("Electric_Vehicle_Population_Data.csv")
vehicles <- distinct(vehicles)

## filter only 9 cols
dfde0 <- vehicles %>% select(c(VIN..1.10., State, Model.Year, Make, Model, Electric.Vehicle.Type, Electric.Range, Base.MSRP, Electric.Utility))

# sumry0 after filtering cols ----
sumry <- summary(dfde0)

# colSums0 for blanks and spaces ----
colSums <- colSums(is.na(dfde0) | dfde0 == "" | dfde0 == " " | dfde0 == 0)

# df of nas and blanks ----
dfde_nablank <- df0 %>% filter(is.na(Electric.Range) | Electric.Range == "" | Electric.Range == " " 
                            | is.na(Electric.Vehicle.Type) | Electric.Vehicle.Type == "" | Electric.Vehicle.Type == " " 
                            | is.na(Base.MSRP) | Base.MSRP == "" | Base.MSRP == " " 
                            | is.na(Electric.Utility) | Electric.Utility == "" | Electric.Utility == " "  )
write.csv(dfde_nablank, "dfde_nablank.csv")

# FINDING: only 39 nas or blanks ----
## only 0.16% > anti_join to drop 

dfde <- anti_join(dfde0, dfnablank)

# Export df----
write.csv(dfde, "dfde.csv")


# Cannot use averages for Electric.Range and Base.MSRP because
# these depend on the Make and Model
# We just drop NAs, spaces and blanks, but retain the zeroes.
# This dfde_cln is temporary.  A new df will be used after filling in missing items.

dfde_cln <- dfde %>% filter(!is.na(Electric.Range) & Electric.Range != "" & Electric.Range != " " &
                                 !is.na(Base.MSRP) & Base.MSRP != "" & Base.MSRP != " ")
removed_rows <- nrow(dfde) - nrow(dfde_cln)
removed_rows # 0 rows

retention_rate <- (nrow(dfde_cln)/ nrow(dfde)) *100
retention_rate  # 100 % 


# Create new hmtl report for dfde_cln ----
create_report(dfde_cln, output_file = "dfde_cln_report.html")

# Report shows a LOT of zeroes still for Base.MSRP and Electric.Range.
# Need to fix later for questions 2 and 3.

# Export dfde_cln----
# This is only to continue the tutorial.
# After tutorial, will create a REAL portfolio project.
# I will use best practices for cleaning and validation.

# write.csv(dfcln, "dfcln.csv")

# Electric ranges analysis will be done on BEV only.

dfde_bev <- dfde_cln %>% filter (Electric.Vehicle.Type == "Battery Electric Vehicle (BEV)") 
zero_counts <- dfde_bev %>% group_by(Electric.Range) %>% summarise(Count = n())
zero_counts # 139761

retention_if_drop_zeroes = (nrow(dfde_bev) - 139761)/(nrow(dfde_bev)) * 100
retention_if_drop_zeroes  # 25.2599%



# ------------------------------------------------------------------------
# Detach DataExplorer ----
# ........................................................................
detach("package:DataExplorer", unload = TRUE)






