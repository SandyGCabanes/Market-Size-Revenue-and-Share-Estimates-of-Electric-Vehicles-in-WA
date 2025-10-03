# EV Dashboard using Plotly Express
# Exports charts as PNG images for HTML embedding



# %%
# 0. Imports and Load Main Dataset
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
import pandas as pd
import numpy as np
import plotly.express as px
from plotly.express import pie, bar, line
from pathlib import Path

# Define path to CSV folder
csv_folder = Path("C:/Users/sandy/zportfolio_projects_128gbsdcard/2025_grouped/electric_vehicles/data_csv_files")

# Load main EV dataset
df = pd.read_csv(csv_folder / "df.csv")
print("Main EV dataset loaded.")




# %%
# 1. Tesla Market Share by Count
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
df["Tesla.Vs.Others"] = np.where(df["Make"] == "TESLA", "TESLA", "OTHERS")
tesladf = df[df["Tesla.Vs.Others"] == "TESLA"]
tesla_market_share = round(len(tesladf) / len(df) * 100, 1)

df_donut = pd.DataFrame({
    "Group": ["TESLA", "OTHERS"],
    "Market_Share": [tesla_market_share, 100 - tesla_market_share]
})


fig = pie(df_donut, names="Group", values="Market_Share", hole=0.6,
          title="Electric Vehicles All Time Market Share in WA",
          color="Group",  
          color_discrete_map={"TESLA": "#E82127", "OTHERS": "#999999"})

fig.show()
fig.write_html("1.donut_chart.html")




# %%
# 2. Stacked Bar by Year
# ~~~~~~~~~~~~~~~~~~~~~~
df_stackedbar = df.groupby(["Model.Year", "Tesla.Vs.Others"]).size().reset_index(name="Count")
df_total_per_year = df.groupby("Model.Year").size().reset_index(name="YearTotal")
df_stackedbar = df_stackedbar.merge(df_total_per_year, on="Model.Year")
df_stackedbar["Share"] = round(df_stackedbar["Count"] / df_stackedbar["YearTotal"] * 100, 0)
df_stackedbar = df_stackedbar[df_stackedbar["Model.Year"] >= 2015]

fig = bar(df_stackedbar, x="Model.Year", y="Share", color="Tesla.Vs.Others",
          title="Tesla vs. Others Yearly Share (Counts)",
          color_discrete_map={"TESLA": "#E82127", "OTHERS": "#999999"})

fig.show()
fig.write_html("2.market_share_past10yrs.html")




# %%
# 3. Top Tesla Models
# ~~~~~~~~~~~~~~~~~~~
teslatop = tesladf.groupby(["Make", "Model"]).size().reset_index(name="count").sort_values("count", ascending=True)

fig = bar(teslatop, x="count", y="Model", orientation="h",
          title="Top Tesla Models Sold - All Time",
          color_discrete_sequence=["#E82127"])

fig.show()
fig.write_html("3.barchart_topmodels.html")




# %%
# 4. Estimated Revenue
# ~~~~~~~~~~~~~~~~~~~~
# Load MSRP reference data
msrp_csv = pd.read_csv(csv_folder / "msrp_lookup.csv")
print("MSRP reference data loaded.")

msrp_csv["MinMSRP"] = pd.to_numeric(msrp_csv["MinMSRP"])
msrp_csv["MaxMSRP"] = pd.to_numeric(msrp_csv["MaxMSRP"])
msrp_csv["AvgMSRP"] = round((msrp_csv["MinMSRP"] + msrp_csv["MaxMSRP"]) / 2)

teslatopwprice = teslatop.merge(msrp_csv, on=["Make", "Model"])
teslatopwprice["AvgRevenue"] = teslatopwprice["count"] * teslatopwprice["AvgMSRP"]

fig = bar(teslatopwprice, x="AvgRevenue", y="Model", orientation="h",
          title="Top Tesla Models Estimated Revenues - All Time",
          color_discrete_sequence=["#999999"])

fig.show()
fig.write_html("4.barchart_topmodels_avgrevenues.html")





# %%
# 5. Tesla Sold by Year
# ~~~~~~~~~~~~~~~~~~~~~
df_tesla_sold_by_year = tesladf.groupby("Model.Year").size().reset_index(name="Count")

fig = line(df_tesla_sold_by_year, x="Model.Year", y="Count",
           title="Tesla Electric Vehicles Sold By Year As of mid July 2025",
           subtitle= "Tesla saw accelerated growth starting 2018. Spike in 2023 due to tax incentives.",
           markers=True)
fig.update_traces(line_color="#999999", marker_color="#E82127")

fig.show()
fig.write_html("5.linechart_tesla_by_year.html")




# %%
# 6. Boxplots of MSRP – Non-Luxury Segment
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Load MSRP data filtered to non-luxury vehicles (under $100k)
msrp_nonlux = pd.read_csv(csv_folder / "msrp_nonlux.csv")

color_map = {make: "#999999" for make in msrp_nonlux["Make"].unique()}
color_map["TESLA"] = "#E82127"

fig = px.box(msrp_nonlux, x="Make", y="AvgMSRP",
             title="Range of Prices by Make (Under $100k)",
             subtitle = "Tesla spans the higher end of the prices in the under 100K segment",
             color="Make",
             color_discrete_map=color_map)

fig.show()
fig.write_html("6.boxplots_msrp_non_lux.html")




# %%
# 7. Boxplots of Ranges Among Battery Electric Vehicles
# ~~~~~~~~~~~~~~~~~~~~~~
dfbev_completed_ranges = pd.read_csv(csv_folder / "dfbev_completed_ranges.csv")

color_map = {make: "#999999" for make in dfbev_completed_ranges["Make"].unique()}
color_map["TESLA"] = "#E82127"

fig = px.box(dfbev_completed_ranges, x="Make", y="Electric.Range.y",
             title="Battery EV Ranges in Miles by Make", subtitle = "Tesla spans mid to higher range", 
             color="Make",
             color_discrete_map=color_map)

fig.show()
fig.write_html("7.boxplots_bev_ranges.html")



# %%
# 8. PHEV vs. BEV trends

df_type = df[["VIN..1.10.","Model.Year", "Electric.Vehicle.Type"]]

df_type = df_type.groupby(["Model.Year", "Electric.Vehicle.Type"]).size().reset_index(name="Count")

fig = px.line(df_type, x="Model.Year", y="Count", color="Electric.Vehicle.Type",
           title="PHEV (Hybrids) vs. BEV (Battery) Electric Vehicle Trends By Year As of Mid 2025",
           subtitle="Battery Electric Vehicles are Growing Far More Than Hybrids",
           color_discrete_sequence=["#E82127", "#999999"])

fig.show()
fig.write_html("8.linechart_yearly_trends.html")





# %%
# 9. Top 5 Utilities Associated with Tesla
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Load utility dataset
df_tesla_utilities = pd.read_csv(csv_folder / "tesla_utilities.csv")

top5tesla_utilities = df_tesla_utilities.head(5).sort_values("Count", ascending=True)

fig = px.bar(top5tesla_utilities, x="Count", y="Electric.Utility", orientation="h",
          title="Top 5 Utilities Supporting Tesla EV Infrastructure",
          subtitle="Tesla's Partnership with Puget Sound Energy Very Evident",
          color_discrete_sequence=["#E82127"])

fig.show()
fig.write_html("9.barchart_top5_utilities.html")


# %%
# 7. Combine all figures into one HTML using plotly.io
import plotly.io as pio

list_html_files = [
"1.donut_chart.html",
"2.market_share_past10yrs.html",
"3.barchart_topmodels.html",
"4.barchart_topmodels_avgrevenues.html",
"5.linechart_tesla_by_year.html",
"6.boxplots_msrp_non_lux.html",
"7.boxplots_bev_ranges.html",
"8.linechart_yearly_trends.html",
"9.barchart_top5_utilities.html"]


# Read each HTML file as string
html_fragments = []
for file in list_html_files:
    with open(file, "r", encoding="utf-8") as f:
        html_fragments.append(f.read())

footer = '<h5 style="color:gray; font-weight:300;">Sandy G. Cabanes</h5>'
html_fragments_with_footer = [frag + footer for frag in html_fragments]

# Combine into one HTML document
combined_html = f"""
<html>
<head>
  <meta charset="utf-8" />
  <script src="https://cdn.plot.ly/plotly-2.27.1.min.js"></script>

</head>
<body>
  {'<hr style="margin:40px 0;">'.join(html_fragments_with_footer) }

</body>
</html>
"""

# Write to final dashboard file
with open("python_dashboard.html", "w", encoding="utf-8") as f:
    f.write(combined_html)
# %%
