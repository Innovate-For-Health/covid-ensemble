# COVID-19 Model Archive

## IHME COVID-19 Model model

This subdirectory contains state and country-level data produced and made publicly available by the Institute for Health Metrics and Evaluation (IHME).

Additional details about this model and its underlying data and assumptions can be found on the [IHME website](https://covid19.healthdata.org/united-states-of-america). Data are updated regularly and shared via an export data functionality on the website, and will regularly be pulled and archived by this model inventory. Data were last pulled and updated in this repository on July 15, 2020, accessing data from July 11, 2020.

IHME reports data per country and per intermediate areas (e.g., states/provinces) for selected countries. When processing data for incorporation into the model archive, selected geographic locations are renamed to map to existing location names and ISO codes within the model inventory (e.g., renaming "Bolivia (Plurinational State of)" as "Bolivia").

As of June 29, 2020, IHME results are available under three different scenarios. Additional details regarding these scenarios can be accessed via the IHME website (see link above). Each scenario is captured in the inventory as a separate model run. A separate data ingest script (process_after_6-29-20.R) has been created to incorporate these new data. The script must be run three times, once per scenario. Of note, not all data are available for each scenario (e.g., estimates of the number of hospital beds, ICU beds, and invasive ventilators needed are reported for only one of the three available scenarios).

The scenario indicated as "reference" by the IHME team is the model that is compared to other models, and to itself over time, in the user interface by default. Per IHME's documentation available via the download data page, this run of the model "assumes social distancing mandates are re-imposed for 6 weeks whenever daily deaths reach 8 per million (0.8 per 100k)" but does not assume 95% compliance with masking orders.

Additional details of all data processing are contained in the process.R script included in this directory. Data from the following locations are excluded from the model archive:
- King and Snohomish Counties (excluding Life Care Center), WA
- Life Care Center, Kirkland, WA
- Other Counties, WA
- Mexico_two (not confident how to interpret these data as of June 9, 2020)
