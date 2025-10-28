# Market Size, Share and Revenue Estimates of Electric Vehicles in WA - Focus on Tesla
##  Uses Real World data  (235K+ rows of data)

## ![Excel dashboard](excel_dashboard.gif)

## Strategic Objectives  
This analysis addresses key business questions relevant to OEMs (Original Equipment Manufacturers), utilities, and policy stakeholders
using data from this [website](https://catalog.data.gov/datasets/lectroc-vehicle-population-data). 
- What is Tesla’s current market share in Washington’s EV landscape?
- Which Tesla models drive the most registrations and estimated revenue?
- How do Tesla’s vehicle ranges and prices compare to competitors?
- What are the adoption trends for BEVs vs. PHEVs?
- Which utilities are most frequently associated with Tesla registrations?
- What is Tesla’s projected 2025 sales outlook based on historical trends?


## Key challenge:  Since a lot of the price information and electric range information are missing, I researched the prices and electric ranges beyond the dataset provided.

## Excel workflow
For the msrp charts, I linked the original dataset with the researched price data using xlookup.
I filtered only battery electric vehicles for fair comparison and researched the electric ranges for these missing models and makes.
Using the added data, I then created this dashboard, using excel pivot tables and pivot charts.

## Findings as of July 2025:
- Tesla has almost half of market share in terms of counts, all years.
- Tesla maintained this share level as of report date.
- Tesla is in mid to upper range in terms of price among the USD <100K price segment.
- Tesla is also in mid to upper range in terms of electric range in miles within BEV.
- BEV continues to outpace hybrids. The spike in 2023 is due to the tax incentives.
- The partnership with Puget Sound utilties is evident in the associated utilities with Tesla cars.
- 2025 forecast for Tesla is around 20k compared to 17k in 2024. [exponential smoothing 'forecast.ets' function in excel](https://support.microsoft.com/en-us/office/forecast-ets-function-15389b8b-677e-4fbd-bd95-21d464333f41)  Since exponential smoothing gives rapidly decreasing attention to older data, the forecast is higher.

