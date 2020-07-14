# COVID-19 Model Inventory and Archive

## COVID Act Now (covidactnow.org) model

This subdirectory contains state-level data produced and made publicly available by the COVIDactnow.org website and accessed via a public API.

Additional details about this model and its underlying data and assumptions can be found on the [COVID Act Now website](https://covidactnow.org/). Data are updated daily via the COVID Act Now website and will regularly be pulled and archived by this model inventory. Data were last pulled and updated in this repository on July 14, 2020. COVID Act Now reports hospital bed requirements for each US state and DC. Total bed requirements for the US are estimated by summing available estimates as reported across states and DC. Estimates of daily fatalities were calculated based on reported cumulative fatalities per day, assuming that all measurements reported on a given day were as of the end of that day. 

Estimates of daily and cumulative fatalities from COVID Act Now are currently excluded from visualizations in the model inventory, as these results are only accessible via the COVID Act Now API (e.g., they are not displayed on the COVID Act Now website), and differ from similar modeling results available from other data sources.

Model outputs from COVID Act Now are not currently compared to other models included in this model inventory, as shown in the "Compare multiple models" tab. The model produces substantially different estimates of daily and cumulative fatalities as compared to other models in key states, including California. Given that the COVID Act Now site does not include any visualizations showing daily estimates of fatalities, I left this value out from the visualizations associated with this tool.