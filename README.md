# Market Size, Revenue and Share Estimates of Electric Vehicles in WA (Real World Data)

## What This is About:
This analyzes Tesla’s performance in Washington State’s electric vehicle market using real-world registration data. 
It explores market share, model-level sales, estimated revenue, pricing comparisons, and utility partnerships. 
The project showcases data wrangling, proactive research of missing MSRP data, proactive research of missing Electric.Range data,
and business-focused visualization.  Each of these methods produced similar dashboards.
- R [See R codes and dashboard](/R)  - for those interested in transparent reproducible workflows 
- Python [See python codes and dashboard](/Python)  - to follow
- Excel [Excel dashboard](/Excel) - for those interested in familiar tools and quick shareable dashboards
- Tableau [See Tableau report](Tableau Public link) - to follow 
- Power BI [See Power BI report](/PowerBI)  - to follow 

## Key Challenge
The [source dataset](https://catalog.data.gov/dataset/electric-vehicle-population-data) lacked price data for 99% of the rows: a major challenge.
To solve this, I conducted manual and batch research to enrich the dataset with accurate MSRP values by make and model. 
The dataset also lacked important electric range data needed for answering a key business question below.   
These two research steps resulted in more realistic competitive pricing and range analysis.

## Key Business Questions Addressed:

- What is Tesla’s market share in WA compared to other EV brands?
- Which Tesla models are most popular, and what is their estimated revenue impact?
- How do Tesla’s vehicle ranges and prices compare to competitors?
- How are PHEV and BEV trending?
- Which utilities are most commonly associated with Tesla EV registrations?

This project showcases reproducible analysis and clear communication of business-relevant 
metrics—skills essential for data analyst roles.

### R dashboard using flexdashboard
![R dashboard](R/dashboard_charts/Tesla_presentation.gif)

### Excel dashboard using pivot charts
![Excel dashboard](Excel/excel_dashboard.gif)
