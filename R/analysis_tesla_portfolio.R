# Import libraries ----
library(dplyr)
library(tidyr)
library(ggplot2)
library(readr)
library(scales)
library(stringr)

# Inventory of dfs ----
## df - dropped nas, spaces, blanks, wa only, new Tesla.Vs.Others col
## df_donut - created for the donut chart
## df_stackedbar - created for the stacked bar chart
## teslatop - top Tesla models for the bar chart
## teslatopwprice - Tesla revenue table for the bar chart
## df_complete_prices - filled in MSRP from research
## dfbev - filtered BEVs only, prices filled in below
## dfbev_completed_ranges - filled in ranges from research 
## dftesla_top5 - utilities for Tesla 



# Load df ----
# Dropped nas, spaces, blanks but not zeroes
# Filtered WA only
# For ranges and summaries, see data_profiling_reports
df <- read.csv("C:/Users/sandy/zportfolio_projects_128gbsdcard/2025_grouped/electric_vehicles/data_csv_files/df.csv")

# New Tesla.Vs.Others column for comparison ----
df <- df %>% mutate(Tesla.Vs.Others = case_when(
  Make == "TESLA" ~ "TESLA",
  TRUE ~ "OTHERS")
)



# ``````````````````````````````````````````````````````````
# 1. Tesla Market Share by Count----
# ..........................................................

tesladf <- filter(df, Tesla.Vs.Others == "TESLA")
tesla_market_share <- nrow(tesladf) / nrow(df) * 100
tesla_market_share <- round(tesla_market_share, digits = 1)

# Tesla share all years: 42.9%


## New dfmarket for donut chart ----
holesize <- 2
df_donut <- data.frame(
  Group = c("TESLA", "OTHERS"),
  Market_Share = c(tesla_market_share, 100-tesla_market_share)) %>%
  mutate(x = holesize) %>%
  mutate(Market_Share = round(Market_Share, 1))
df_donut
#   Group Market_Share x
# 1 Tesla         42.9 2
# 2 Other         57.1 2


## Donut chart ----

donut_chart <- ggplot(df_donut, aes(x = x, y = Market_Share, fill = Group)) +
  geom_col(width = 1, color = "white") +
  coord_polar(theta = "y") +
  xlim(c(0.2, holesize +0.5 )) +
  theme_void() +
  labs(title = "Electric Vehicles All Time Market Share in WA")+
  geom_text(aes(label = paste0(Market_Share, "%")), position = position_stack(vjust = 0.5)) +
  scale_fill_manual(values = c("TESLA" = "#E82127", "OTHERS" = "#999999"))

donut_chart
ggsave("1.donut_chart.png", plot = last_plot())


## New df for stacked bar market share chart ----
df_stackedbar <- df %>% group_by(Model.Year, Tesla.Vs.Others) %>%
  summarise(Count = n(), .groups = "drop") 

df_total_per_year <- df %>% group_by(Model.Year) %>%
  summarise(YearTotal = n(), .groups = "drop")

df_stackedbar <- left_join(df_stackedbar, df_total_per_year, by = "Model.Year") %>%
  mutate(Share = Count / YearTotal *100) 

df_stackedbar$Share <- round(df_stackedbar$Share, digits = 0)
df_stackedbar <- df_stackedbar %>% filter(Model.Year >= 2015)

my_colors["TESLA"] <- "#E82127"
my_colors["OTHERS"] <-  "#999999"
 

## Stacked bar market share ----
stackedbar_plot <- ggplot(df_stackedbar, aes(x = Model.Year, y = Share, fill = Tesla.Vs.Others)) +   geom_bar(position = "stack", stat = "identity") + 
  labs(
  title = "Tesla vs. Others Yearly Share (Counts)",
  subtitle = "Past 10 Years",
  x = "Model Year",
  y = "Share of Counts",
  fill = "Tesla.Vs.Others")+
  scale_fill_manual(values = my_colors)

stackedbar_plot 
ggsave("1a.market_share_past10yrs.png", plot = last_plot())


# ``````````````````````````````````````````````
# 2a. Top Tesla Models Selling in the area ----
# Based on counts
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




# ````````````````````````````````````````````````
# 2b. Estimated AllTime Revenue for Tesla ----
# ................................................

## ```````````````````````````
## Research web for MSRPs ----
## ...........................

## Web research is done outside of R.

### msrp_csv import ----
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
write.csv(msrp_csv, "msrp_csv.csv")


### Join to add Avg_MSRP to teslatop ----
teslatopwprice <- teslatop %>%
  left_join(msrp_csv, by = c("Make", "Model"))

## Create revenue cols min max avg ----
teslatopwprice <- teslatopwprice %>%
  mutate(
    AvgRevenue = count * AvgMSRP,
    MinRevenue = count * MinMSRP,
    MaxRevenue = count * MaxMSRP
  )


## Bar chart of top model revenues ----
# Using library(scales) for label

barchart_topmodels_avgrevenues <- ggplot(teslatopwprice, aes(x=reorder(Model, AvgRevenue), y = AvgRevenue)) +
  geom_col(fill = "#999999") +
  coord_flip() +
  labs(title = "Top Tesla Models Estimated Revenues - All Time", x = NULL, y = NULL) +
  scale_y_continuous(labels = label_comma()) +
  theme_minimal()
barchart_topmodels_avgrevenues
ggsave("3.barchart_topmodels_avgrevenues.png", plot = last_plot())




# `````````````````````````````````
# 2c. Tesla Cars Sold by Year ----
# .................................

## New df tesla_sold_by_year ----

df_tesla_sold_by_year <- df %>%
  filter(Tesla.Vs.Others == "TESLA") %>%
  group_by(Model.Year) %>%
  summarise(Count = n()) %>%
  arrange(Model.Year)


linechart_tesla_by_year <- ggplot(df_tesla_sold_by_year, aes(x = Model.Year, y = Count)) +
  geom_line(color = "#999999", size = 1) +
  geom_point(color = "#E82127", size = 2) +
  labs(title = "Tesla Electric Vehicles Sold By Year\n As of mid July 2025", y = NULL) +
  theme_minimal()
linechart_tesla_by_year

ggsave("4.linechart_tesla_by_year.png", plot = last_plot())


# ```````````````````````````````````
# 3. Tesla vs Competitors MSRP ----
# ...................................

## Fill in prices from msrp_csv 
## Convert zeroes to NA, fill in with AvgMSRP, drop joined cols
## select(-AvgMSRP, -MinMSRP, -MaxMSRP, -"Price Year")

df <- df %>% mutate(na_if(Base.MSRP, 0))
df_complete_prices <- left_join(df, msrp_csv, by = c("Make", "Model")) %>%
  mutate(Base.MSRP = ifelse(is.na(Base.MSRP), AvgMSRP, Base.MSRP))
df_complete_prices <- df_complete_prices %>%
  select(-AvgMSRP, -MinMSRP, -MaxMSRP, -"Price Year")


# ``````````````````````````````````````````````````````
# 3a. Competitive prices analysis ----
# ......................................................
msrp_nonlux <- msrp_csv %>% filter(AvgMSRP < 100000)
write.csv(msrp_nonlux, "msrp_nonlux.csv")


# Get all unique makes from the data
all_makes <- unique(msrp_nonlux$Make)
# Create a named vector for the colors. Default to grey.
my_colors <- ifelse(all_makes == "TESLA", "#E82127", "#999999")
names(my_colors) <- all_makes


# ``````````````````````````````````````````````````````
# Boxplots of prices non-luxury segment ----
# ......................................................  
boxplot_msrp_nonlux <- ggplot(msrp_nonlux, aes(x = reorder(Make, AvgMSRP, FUN = median), y = AvgMSRP)) +
  geom_boxplot(aes(fill = Make), outlier.shape = 20) + 
  coord_flip() + 
  scale_fill_manual(values = my_colors) + 
  scale_y_continuous(labels = scales::dollar_format()) + 
  labs(
    title = "Distribution of Average MSRP by Make (Under $100k)",
    subtitle = "Highlighting Tesla within the non-luxury market.",
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
ggsave("5. boxplot_msrp_nonluxury.png", plot = last_plot())



# ``````````````````````````````````````````````````````
# 3b. Competitive ranges analysis ----
# ......................................................

## Research ranges outside of R

## Update dfbev zeroes with Electric.Range values in dfbev_ranges ---
dfbev <- read.csv("dfbev.csv", strip.white = TRUE)

dfbev <- dfbev %>% 
  mutate(Base.MSRP = na_if(Base.MSRP, 0)) 

dfbev <- dfbev %>%
  left_join(msrp_csv, by = c("Make", "Model")) %>%
  mutate(Base.MSRP = ifelse(is.na(Base.MSRP), AvgMSRP, Base.MSRP)) %>%
  select(-AvgMSRP, MinMSRP, MaxMSRP, "Price Year")

dfbev <- dfbev %>% 
  mutate(Electric.Range = na_if(Electric.Range, 0))

dfbev_ranges <- read.csv("dfbev_ranges.csv", strip.white = TRUE)

dfbev_completed_ranges <- dfbev %>%
  left_join(dfbev_ranges, by = c("Model.Year", "Make", "Model")) %>%
  mutate(Electric.Range = ifelse(is.na(Electric.Range), New.Range, Electric.Range)) %>%
  select(-New.Range)

dfbev_completed_ranges
write.csv(dfbev_completed_ranges, "dfbev_completed_ranges.csv")

# ``````````````````````````````````````````````````````
# Boxplots of ranges by Make ---- ----
# ......................................................  

# Get all unique makes from the data
all_makes <- unique(dfbev_completed_ranges$Make)
# Create a named vector for the colors. Default to grey.
my_colors <- ifelse(all_makes == "TESLA", "#E82127", "#999999")
names(my_colors) <- all_makes

boxplot_ranges <- ggplot(dfbev_ranges, aes(x = reorder(Make, Electric.Range, FUN = median), y = Electric.Range)) +
  geom_boxplot(aes(fill = Make), outlier.colour = "red", outlier.shape = 20) +
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
ggsave("6. boxplot_ranges.png", plot = last_plot())




# ``````````````````````````````````````````````````````````````````````
# 4a. PHEV vs BEV trends ----
# ......................................................................

df_evtrends <- df_complete_prices%>%
  group_by(Model.Year, Electric.Vehicle.Type)  %>%
  summarise(Count = n(), .groups = "drop")

write.csv(df_evtrends, "trends_ev.csv")

# Yearly line chart PHEV and BEV yearly ----

linechart_evtrends <- ggplot(df_evtrends, aes(x = Model.Year, y = Count, color = Electric.Vehicle.Type)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  labs(title = "PHEV vs. BEV Trends By Year") +
  scale_color_manual(values = c("Battery Electric Vehicle (BEV)" = "#E82127", "Plug-in Hybrid Electric Vehicle (PHEV)" = "#999999")) +
  theme_minimal()
linechart_evtrends

ggsave("7.linechart_yearly_trends.png", plot = last_plot())

# ``````````````````````````````````````````````````````````````````````
# 4b. PHEV vs BEV monthly trends ----
# ......................................................................
# Using size history file from site ----
df_monthly_trends <- read.csv("Electric_Vehicle_population_Size_history.csv", strip.white = TRUE)


# Prep for multi-line viz ----
df_monthly_trends <- df_monthly_trends %>%
  rename(
    PHEV_Count = Plug.In.Hybrid.Electric.Vehicle..PHEV..Count,
    BEV_Count = Battery.Electric.Vehicle..BEV..Count,
    EV_Total = Electric.Vehicle..EV..Total)

df_monthly_trends <- df_monthly_trends %>%
  mutate(Date = as.Date(Date, format = "%B %d %Y"))

# Reshape data from 'wide' to 'long' format for ggplot
df_monthly_trends <- df_monthly_trends %>%
  pivot_longer(
    cols = c(PHEV_Count, BEV_Count, EV_Total),
    names_to = "Vehicle_Type",
    values_to = "Count"
  ) %>%
  # Make the legend labels cleaner
  mutate(
    Vehicle_Type = recode(Vehicle_Type,
                          "PHEV_Count" = "PHEV",
                          "BEV_Count" = "BEV",
                          "EV_Total" = "Total"
    )
  )


# Line chart using monthly df ----
linechart_monthly <- ggplot(df_monthly_trends, aes(x = Date, y = Count, color = Vehicle_Type)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  labs(title = "PHEV vs. BEV Monthly Market Trends") +
  scale_color_manual(values = c("BEV" = "#E82127", "PHEV" = "#999999", "Total" = "black")) +
  theme_minimal()
linechart_monthly
ggsave("8. linechart_monthly.png", plot = last_plot())

# ``````````````````````````````````````````````````````
# 5. Top Electric Utilities in Washington for Tesla ----
# ......................................................

dftesla_utilities <- df_complete_prices %>%
  filter(Tesla.Vs.Others == "TESLA") %>%
  group_by(Electric.Utility) %>%
  summarise(Count = n(), .groups = "drop") %>%
  arrange(desc(Count))

dftesla_utilities

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
ggsave("9. barchart_top5_utilities.png", plot = last_plot())

