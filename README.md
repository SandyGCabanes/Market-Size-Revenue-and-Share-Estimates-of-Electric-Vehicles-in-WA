# Market Share, Revenue Estimates, and Sales Forecasting for Electric Vehicles in Washington State  
## Multi-Tool Business Intelligence Workflow (Python, R, Excel, Power BI, Tableau)

### Overview  
This project delivers a comprehensive business analysis of Tesla’s performance in Washington State’s electric vehicle (EV) market using real-world registration data. It supports strategic decision-making through market share diagnostics, model-level revenue estimates, competitive benchmarking, and sales forecasting.  

The workflow is implemented across five platforms—Python, R, Excel, Power BI, and Tableau—to accommodate diverse stakeholder preferences and deployment environments. Each version produces consistent dashboards and insights, enabling cross-functional adoption.
- R [See R codes and dashboard](/R)  Transparent, reproducible workflows using flexdashboar
- Python [See python codes and dashboard](/Python) Interactive visualizations with Plotly 
- Excel [Excel dashboard](/Excel) Familiar pivot-based interface for quick sharing
- Tableau [See Tableau report](Tableau Public link) - Under construction 
- Power BI [See Power BI report](/PowerBI)  - Under construction

## Key Advantages of This Analysis
The [source dataset](https://catalog.data.gov/dataset/electric-vehicle-population-data) **lacked price data for 99% of the rows:** a major challenge.
To solve this, **I conducted web research to enrich the dataset with accurate MSRP values by make and model.** 
The dataset also lacked important electric range data needed for comparing ranges. This required extra research beyond what is given in the dataset so that I get a more realistic comparison of Tesla vs. others. 

---

### Strategic Objectives  
This analysis addresses key business questions relevant to OEMs (Original Equipment Manufacturers), utilities, and policy stakeholders:

- What is Tesla’s current market share in Washington’s EV landscape?
- Which Tesla models drive the most registrations and estimated revenue?
- How do Tesla’s vehicle ranges and prices compare to competitors?
- What are the adoption trends for BEVs vs. PHEVs?
- Which utilities are most frequently associated with Tesla registrations?
- What is Tesla’s projected 2025 sales outlook based on historical trends?

---

### Data Enrichment and Methodology  
The source dataset ([Electric Vehicle Population Data](https://catalog.data.gov/dataset/electric-vehicle-population-data)) lacked MSRP and electric range data for the majority of entries. To address this:

- **MSRP values** were manually researched and mapped by make and model to enable revenue estimation.
- **Electric range data** was supplemented using external sources to support realistic range comparisons.

Sales projections were generated using ARIMA modeling, with adjustments to temper the 2023 spike and avoid overfitting to anomalous events.

---

### Visual Outputs  


---

### R dashboard using flexdashboard
![R dashboard](R/dashboard_charts/Tesla_presentation.gif)

---
### Excel dashboard using pivot charts
#### The excel forecast used native forecast.ets function, resulting in slightly higher figures.
![Excel dashboard](Excel/excel_dashboard.gif)

---
### Python dashboard using plotly
![Python dashboard](Python/output_5000ms.gif)
