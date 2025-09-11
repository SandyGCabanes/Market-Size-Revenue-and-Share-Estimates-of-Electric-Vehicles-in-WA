# Import libraries ----
library(dplyr)
library(tidyr)
library(ggplot2)
library(readr)
library(scales)

# Evolution of dfs ----
## dfcln              # Initial cleaning: dropped NAs, spaces, blanks
## dfwa               # Filtered for Washington state only; added Tesla.Vs.Others column
## tesladf            # Filtered TESLA rows from dfwa
## teslatop           # Grouped TESLA by Make, Model → count
## teslatopwprice     # Joined teslatop with msrp_csv (external MSRP research); added revenue columns
## df_tesla_sold_by_year  # Grouped TESLA by Model.Year for trend analysis
## df_donut           # Market share summary for donut chart (Tesla vs Others)
## df_stackedbar      # Grouped by Model.Year + Tesla.Vs.Others → share for stacked bar chart
## dfclnfil           # Joined dfwa with msrp_csv to fill Base.MSRP using AvgMSRP
## df_complete_prices # Final cleaned dataset with MSRP filled; used for multiple downstream charts
## msrp_csv           # External research: compiled MSRP ranges by Make/Model
## msrp_nonlux        # Filtered msrp_csv for AvgMSRP < 100k (non-luxury models)
## dfbev              # Imported separately: filtered BEVs only; joined with msrp_csv
## dfbev_ranges       # External research: Electric.Range values by Make/Model
## dfbev_completed_ranges # Joined dfbev with dfbev_ranges to fill missing Electric.Range
## df_evtrends        # Grouped df_complete_prices by Model.Year + EV type
## df_monthly_trends  # Imported size history file; reshaped for monthly line chart
## dftesla_utilities  # Grouped df_complete_prices by Electric.Utility
## dftesla_top5       # Filtered top 5 utilities for Tesla



# Load dfcln ----
# Dropped nas, spaces, blanks but not zeroes 
# For ranges and summaries, see dfcln_report.html 
dfcln <- read.csv("dfcln.csv")


# dfwa - filter WA ----
# 494 rows removed
dfwa <- dfcln %>% filter(State == "WA")


# New Tesla.Vs.Others column for comparison ----
dfwa <- dfwa %>% mutate(Tesla.Vs.Others = case_when(
  Make == "TESLA" ~ "TESLA",
  TRUE ~ "OTHERS")
)
#dfwa


# ``````````````````````````````````````````````````````````
# 1. Percent of recorded vehicles in WA that are Teslas ----
# ..........................................................

## New df WA only ----
# tesladf <- dfwa %>% filter(Make == "TESLA")
# tesla_market_share <- nrow(tesladf) / nrow(dfwa) * 100
# tesla_market_share <- round(tesla_market_share, digits = 1)
# tesla_market_share # 42.87847 percent
# cat("\nTesla share all years: ", tesla_market_share, "%")



##### Create new dfmarket for donut chart ----
holesize <- 2
dfmarket<- data.frame(
  Group = c("TESLA", "OTHERS"),
  Market_Share = c(tesla_market_share, 100-tesla_market_share)) %>%
  mutate(x = holesize)
dfmarket

#   Group Market_Share x
# 1 Tesla         42.9 2
# 2 Other         57.1 2


##### ggplot donut chart ----

donut_chart <- ggplot(dfmarket, aes(x = x, y = Market_Share, fill = Group)) +
  geom_col(width = 1, color = "white") +
  coord_polar(theta = "y") +
  xlim(c(0.2, holesize +0.5 )) +
  theme_void() +
  labs(title = "Electric Vehicles All Time Market Share in WA")+
  geom_text(aes(label = paste0(Market_Share, "%")), position = position_stack(vjust = 0.5)) +
  scale_fill_manual(values = c("TESLA" = "#E82127", "OTHERS" = "#999999"))

donut_chart
ggsave("1.donut_chart.png", plot = last_plot())




##### stacked bar plot of market share by year

# Create new df_shr_yrs, Tesla vs. Others
df_shr_yrs <- dfwa %>%
  group_by(Model.Year, Tesla.Vs.Others) %>%
  summarize(count=n(), 
  .groups = "drop") %>%
  arrange(Model.Year)
  
df_shr_yrs

barchart_marketshares_year <- ggplot(
  df_shr_yrs %>% filter(Model.Year > 2010),
  aes(x = Model.Year, y = count, fill = Tesla.Vs.Others)) +
  geom_col() +
  scale_fill_manual(values = c("TESLA" = "#E82127", "OTHERS" = "#999999")) +
  labs(title = "Tesla Shares in Recent Years\nAs of July 2025", x = NULL, y = "Count of Registered Vehicles") +
  theme_minimal() +
  theme(
    panel.grid = element_blank()
  )
barchart_marketshares_year
ggsave("1. barchart_marketshares.png", plot = last_plot())

# ``````````````````````````````````````````````
# 2a. Top Tesla Models Selling in the area ----
# ..............................................

## New df teslatop ----
teslatop <- tesladf %>% group_by(Make, Model) %>% summarize(count = n(), .groups = "drop") %>% arrange(desc(count))
teslatop

## Bar chart of top models ----
barchart_topmodels <- ggplot(teslatop, aes(x=reorder(Model, count), y = count)) +
  geom_col(fill = "#E82127") +
  coord_flip() +
  labs(title = "Top Tesla Models Sold - All Time", x = NULL) +
  theme_minimal()
barchart_topmodels
ggsave("2.barchart_topmodels.png", plot = last_plot())
#rm(teslatop)



# ````````````````````````````````````````````````
# 2b. Estimated Cumulative Revenue for Tesla ----
# ................................................


# Average prices for Tesla from web into table
## New df of MSRP values ----
msrp_lookup <- data.frame(
  Make = c("TESLA", "TESLA", "TESLA", "TESLA", "TESLA", "TESLA"),
  Model    = c("MODEL Y", "MODEL 3", "MODEL S", "MODEL X", "CYBERTRUCK", "ROADSTER"),
  AvgMSRP = c(50810, 48740, 87490, 92490, 84990, 225000),
  MinMSRP  = c(46630, 42490, 79990, 84990, 69990, 200000),
  MaxMSRP  = c(54990, 54990, 94990, 99990, 99990, 250000),
  stringsAsFactors = FALSE
)
write.csv(msrp_lookup,"msrp_lookup.csv" )



## Join to add Avg_MSRP to teslatop ----
teslatopwprice <- teslatop %>%
  left_join(msrp_lookup, by = "Model")

## Create min max avg revenue columns ----
teslatopwprice <- teslatopwprice %>%
  mutate(
    AvgRevenue = count * AvgMSRP,
    MinRevenue = count * MinMSRP,
    MaxRevenue = count * MaxMSRP
  )

teslatopwprice

## Bar chart of top model revenues ----
# library(scales)
barchart_topmodels_avgrevenues <- ggplot(teslatopwprice, aes(x=reorder(Model, AvgRevenue), y = AvgRevenue)) +
  geom_col(fill = "#999999") +
  coord_flip() +
  labs(title = "Top Tesla Models Estimated Revenues - All Time", x = NULL, y = NULL) +
  scale_y_continuous(labels = label_comma()) +
  theme_minimal()
barchart_topmodels_avgrevenues
ggsave("3.barchart_topmodels_avgrevenues.png", plot = last_plot())


#rm(teslatop)



# `````````````````````````````````
# 2c. Tesla Cars Sold by Year ----
# .................................

## New df tesla_sold_by_year ----

df_tesla_sold_by_year <- dfwa %>%
  filter(Tesla.Vs.Others == "TESLA") %>%
  group_by(Model.Year) %>%
  summarise(Count = n()) %>%
  arrange(Model.Year)
# df_tesla_sold_by_year

## line chart tesla by year ----
linechart_tesla_by_year <- ggplot(df_tesla_sold_by_year, aes(x = Model.Year, y = Count)) +
  geom_line(color = "#999999", size = 1) +
  geom_point(color = "#E82127", size = 2) +
  labs(title = "Tesla Electric Vehicles Sold By Year\n As of mid July 2025", y = NULL) +
  theme_minimal()
linechart_tesla_by_year

ggsave("4.linechart_tesla_by_year.png", plot = last_plot())


# ```````````````````````````````````
# 3a. Tesla vs Competitors MSRP ----
# Average and Median 
# ...................................

## New Makes and Models df to research----
# dfmakes0 <- dfwa %>% group_by(Make, Model) %>% summarise(MinMSRP = min(Base.MSRP), .groups = "drop")
# dfmakes0  
# write.csv(dfmakes0, "dfmakes0.csv")




## ```````````````````````````
## Research web for MSRPs ----
## ...........................

## This is done outside of R
## If you are trying to replicate this, you need to research this on your own. :)

## Read in the msrps ----
msrp_csv <- read_delim(
  "msrp_compiled.csv",
  delim = "|",
  escape_double = FALSE,
  trim_ws = TRUE
)

msrp_csv <- msrp_csv %>%
  slice(-1) %>%
  select(Make, Model, MinMSRP, MaxMSRP, `Price Year`) %>%
  mutate(
    MinMSRP = as.numeric(MinMSRP),
    MaxMSRP = as.numeric(MaxMSRP),
    AvgMSRP = round((MinMSRP + MaxMSRP) / 2, 0)
  )

msrp_csv

## Join the msrps with dfwa ----

dfclnfil <- inner_join(dfwa, msrp_csv, by = c("Make", "Model"))
dfclnfil

## New grouped df of MSRP for Tesla vs. Others ----
dfteslavothers <- dfclnfil %>% group_by(Tesla.Vs.Others) %>%
  summarise(AvgMSRP = mean(AvgMSRP), MedianMSRP = median(AvgMSRP))
dfteslavothers

## Write to new csv ----
write.csv(dfteslavothers, "tesla_others_msrps.csv")

## Bar charts of MSRPS ----
barchart_msrps <- ggplot(dfteslavothers, aes(x = Tesla.Vs.Others, y = AvgMSRP, fill = Tesla.Vs.Others)) +
  geom_col() +
  scale_fill_manual(values = c("TESLA" = "#E82127", "OTHERS" = "#999999")) +
  labs(title = "Average Prices for Battery Electric Vehicles", x = NULL, y = "Average Prices USD") +
  theme_minimal()
barchart_msrps
ggsave("5. barchart_msrps.png", plot = last_plot())


# Competitive Prices analysis within non luxury segment
msrp_csv <- read.csv("C:/Users/sandy/zportfolio_projects_128gbsdcard/2025_grouped/electric_vehicles/data_csv_files/msrp_csv.csv")

msrp_nonlux <- msrp_csv %>% filter(AvgMSRP < 100000)
write.csv(msrp_nonlux, "msrp_nonlux.csv")


# Get all unique makes from the data
all_makes <- unique(msrp_nonlux$Make)
# Create a named vector for the colors. Default to grey.
my_colors <- ifelse(all_makes == "TESLA", "#E82127", "#999999")
names(my_colors) <- all_makes





# ``````````````````````````````````````````
# Boxplots of prices non-luxury segment ----
# ..........................................

boxplot_msrp_nonlux <- ggplot(msrp_nonlux, aes(x = reorder(Make, AvgMSRP, FUN = median), y = AvgMSRP)) +
  geom_boxplot(aes(fill = Make), outlier.shape = 20) + 
  coord_flip() + 
  scale_fill_manual(values = my_colors) + 
  scale_y_continuous(labels = scales::dollar_format()) + 
  labs(
    title = "Average Price Ranges (Under $100k)",
    subtitle = "Tesla priced higher within the non-luxury segment",
    y = "Average MSRP (USD)",
    x = "Car Make"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 20, face = "bold"),
    plot.subtitle = element_text(size = 12),
    axis.title = element_text(size = 14),
    axis.text.y = element_text(size = 9),
    axis.text.x = element_text(size = 9),
    legend.position = "none"
  )

boxplot_msrp_nonlux
ggsave("6. boxplot_msrp_nonluxury.png", plot = last_plot())






# ``````````````````````````````````````````````````````
# 3b. Tesla vs Competitors Electric.Range BEV only ----
# Average and Median 
# ......................................................

## Ranges: Filter only EVs ----

dfevs <- dfclnfil %>% filter(Electric.Vehicle.Type == "Battery Electric Vehicle (BEV)" & Electric.Range != 0)
dfevsranges <- dfevs %>% group_by(Tesla.Vs.Others) %>%
  summarise(AvgRange = mean(Electric.Range), MedianRange= median(Electric.Range))
dfevsranges

## Write to new csv ----
write.csv(dfevsranges, "tesla_others_ranges.csv")

## Bar charts of ranges ----
barchart_ranges <- ggplot(dfevsranges, aes(x = Tesla.Vs.Others, y = AvgRange, fill = Tesla.Vs.Others)) +
  geom_col() +
  scale_fill_manual(values = c("TESLA" = "#E82127", "OTHERS" = "#999999")) +
  labs(title = "Average Ranges for Battery Electric Vehicles", x = NULL, y = "Average Range (miles)") +
  theme_minimal()
barchart_ranges
ggsave("7. barchart_ranges.png", plot = last_plot())







# ~~~~~~~~~~~~~~~~~~~~~
# Boxplot of Ranges----
# ~~~~~~~~~~~~~~~~~~~~~

## If you want to replicate this, you need to research the ranges on your own. :)

dfbev_joined_for_boxplot<- read.csv("C:/Users/sandy/zportfolio_projects_128gbsdcard/2025_grouped/electric_vehicles/data_csv_files/dfbev_joined_for_boxplot.csv", strip.white = TRUE)

# Get all unique makes from the data
all_makes <- unique(dfbev_completed_ranges$Make)
# Create a named vector for the colors. Default to grey.
my_colors <- ifelse(all_makes == "TESLA", "#E82127", "#999999")
names(my_colors) <- all_makes

boxplot_ranges <- ggplot(dfbev_completed_ranges, aes(x = reorder(Make, Electric.Range, FUN = median), y = Electric.Range)) +
  geom_boxplot(aes(fill = Make), outlier.colour = "red", outlier.shape = 20, colour = NA) +
  coord_flip() + 
  scale_fill_manual(values = my_colors) + # Apply the custom color vector
  labs(
    title = "Distribution of Average Electric Range by Make",
    subtitle = "Highlighting Tesla. Across all models and years.",
    y = "Average Electric Range (Miles)",
    x = "Car Make"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 20, face = "bold"),
    plot.subtitle = element_text(size = 12),
    axis.title = element_text(size = 14),
    axis.text.y = element_text(size = 9),
    axis.text.x = element_text(size = 9),
    legend.position = "none" 
  )
boxplot_ranges
ggsave("8. boxplot_ranges.png", plot = last_plot())



# ``````````````````````````
# 4. PHEV vs BEV trends ----
# ..........................

df_evtrends <- dfclnfil %>%
  group_by(Model.Year, Electric.Vehicle.Type)  %>%
  summarise(Count = n(), .groups = "drop")
# df_evtrends
write.csv(df_evtrends, "trends_ev.csv")

## line chart PHEV and BEV yearly ----

linechart_evtrends <- ggplot(df_evtrends, aes(x = Model.Year, y = Count, color = Electric.Vehicle.Type)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  labs(title = "PHEV vs. BEV Trends By Year") +
  scale_color_manual(values = c("Battery Electric Vehicle (BEV)" = "#E82127", "Plug-in Hybrid Electric Vehicle (PHEV)" = "#999999")) +
  theme_minimal()
linechart_evtrends

ggsave("9.linechart_evtrends.png", plot = last_plot())



# ``````````````````````````````````````````````````````
# 5. Top Electric Utilities in Washington for Tesla ----
# ......................................................

dftesla_utilities <- dfclnfil %>%
  filter(Tesla.Vs.Others == "TESLA") %>%
  group_by(Electric.Utility) %>%
  summarise(Count = n(), .groups = "drop") %>%
  arrange(desc(Count))

# dftesla_utilities

write.csv(dftesla_utilities, "tesla_utilities.csv")

## Top 5 utilities for Tesla ----
dftesla_top5 <- head(dftesla_utilities, 5)
dftesla_top5


## Bar chart for top 5 utilities ----

###  Wrap long utility names
library(stringr)
dftesla_top5$Electric.Utility <- str_wrap(dftesla_top5$Electric.Utility, width = 25)


barchart_utilities <- ggplot(dftesla_top5, aes(x = reorder(Electric.Utility, Count), y = Count)) + 
  geom_col(fill = "#af2529") +
  coord_flip() +
  labs(title = "Top 5 Utilities for Tesla", x = NULL, y = "Tesla Count")+
  theme_minimal() +
  theme(
    axis.text.y = element_text(size = 10),
    axis.text.x = element_text(size = 10),
    plot.title = element_text(size = 14, face = "bold")
  )
barchart_utilities
ggsave("8. barchart_top5_utilities.png", plot = last_plot())

