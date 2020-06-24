# COVID-19 Model Archive

## IHME COVID-19 Model model

This subdirectory contains state and country-level data produced and made publicly available by the Institute for Health Metrics and Evaluation (IHME).

Additional details about this model and its underlying data and assumptions can be found on the [IHME website](https://covid19.healthdata.org/united-states-of-america). Data are updated regularly and shared via an export data functionality on the website, and will regularly be pulled and archived by this model inventory. Data were last pulled and updated in this repository on June 24, 2020, accessing data from June 13, 2020.

IHME reports data per US state and per country. When processing data for incorporation into the model archive, selected geographic locations are renamed to map to existing country names and ISO codes within the model inventory (e.g., renaming "Bolivia (Plurinational State of)" as "Bolivia"). Additional details of all data processing are contained in the process.R script included in this directory. Data from the following locations are excluded from the model archive:
- King and Snohomish Counties (excluding Life Care Center), WA
- Life Care Center, Kirkland, WA
- Other Counties, WA
- Mexico_two (not confident how to interpret these data as of June 9, 2020)
