# COVID-19 Model Inventory and Archive

## This work is still in progress.

This project was developed to facilitate open-source, reproducible epidemiological modeling for COVID-19 response and recovery. We are working to create an overarching data and modeling architecture to allow multiple validated models, developed by public health experts, to be compared via a consolidated platform both individually and as an ensemble. These efforts are similar to the approaches used to model hurricanes based on the consensus of separate models.

This effort will enable public health experts, policy-makers, and data scientists to make direct and meaningful comparisons between model results (e.g., projected caseload over time) under different sets of assumptions, input data, and modeling approaches.

## Current models supported

The data contained in data/model outputs/ currently contains data from three public models: 

- [University of Washington IHME's COVID-19 model](https://www.medrxiv.org/content/10.1101/2020.03.27.20043752v1.full.pdf)

- [Penn Medicine's COVID-19 Hospital Impact Model for Epidemics (CHIME) app](https://code-for-philly.gitbook.io/chime/)

- [Harvard Global Health Institute's Multiplier-Based Model](https://globalepidemics.org/our-data/hospital-capacity/#data) 

We are actively working to incorporate data from additional public models as they become available, and are first focusing on epidemiological forecast models that are currently able to ingest real-time or near-real-time caseload data as those data become available.

Each model is mapped to a common data structure of inputs and outputs to enable clear and rapid comparisons across dates, locations, and types of predictions (e.g., daily ICU admissions vs. cumulative fatalities). Additional information, including data structures, data dictionaries, and an ER diagram, are available in the data/ subdirectory. Below, we have included a brief summary table describing how outputs from each model are mapped to a common standard set of metrics.

![Model output mapping](https://raw.githubusercontent.com/Innovate-For-Health/covid-ensemble/master/data/model_output_mapping.png)

