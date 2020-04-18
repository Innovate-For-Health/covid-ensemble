# Essential information: consolidating the models and assumptions that drive COVID-19 policy decisions

## This work is still in progress.

This project was developed to facilitate open-source, reproducible epidemiological modeling for COVID-19 response and recovery.
As the COVID-19 outbreak continues to rapidly progress, policy-makers, public health responders, and researchers rely, in part, on the results of epidemiological models to understand how the outbreak might progress over time and across geographies. This effort will enable public health experts, policy-makers, and data scientists to make direct and meaningful comparisons between model results (e.g., projected caseload over time) under different sets of assumptions, input data, and modeling approaches.

However, different models are being produced and used by different groups, each with their own unique set of assumptions, underlying data inputs and methods, and intended uses. Moreover, these models often document their approaches and report or export their results in formats that make it difficult to compare results across models. This project was developed to fill that gap by allowing users to:

- compare results across models

- explore the impact of certain model assumptions

- monitor how the projections of a given model have changed over time

## Models currently incorporated

The researchers that developed the models incorporated in this repository and dashboard are doing important work. They have made their results publicly accessible in a way that supports and promotes reproducible research. We have included their data use and reuse licenses (when available) and complete references in each model's model_runs subdirectories.

All of the COVID-19 models identified below have been documented as being used by policy-makers or public health responders during the 2019-2020 COVID-19 pandemic. Each model was developed for a different purpose, and relies on different data inputs, key assumptions, and underlying methods. The intended use of a model impacts how it is developed, how it should be used, and the context based on which its results should be interpreted. 

- [University of Washington IHME's COVID-19 model](https://www.medrxiv.org/content/10.1101/2020.03.27.20043752v1.full.pdf)

- [COVID Act Now US Intervention Model](https://covidactnow.org/) 

- [Shaman Lab COVID-19 Projections](https://github.com/shaman-lab/COVID-19Projection)

- [Los Alamos National Lab COVID-19 Model](https://covid-19.bsvgateway.org/)


We are actively working to incorporate data from additional public models as they become available, and are first focusing on epidemiological forecast models that are currently able to ingest real-time or near-real-time caseload data as those data become available. Only models that produce estimates at daily, weekly, or monthly temporal resolutions over time are currently included.

## Data architecture

Each model is mapped to a common data structure of inputs and outputs to enable clear and rapid comparisons across dates, locations, and types of predictions (e.g., daily ICU admissions vs. cumulative fatalities). Additional information, including a detailed data dictionary, an ER diagram, and access to the flat data files are available in the [data subdirectory](https://github.com/Innovate-For-Health/covid-ensemble/tree/master/data).

A brief overview of key tables and data elements is included below.

#### Models Table

- **Resolution:** one row per model

- **Contents:** details on each model (though not all mdoels have model outputs currently tracked)

- **Key data elements:**

    -  `model id:` a unique identifier for each model
    -  `model name:` the name of the model
    - `model developer:` the group that developed the model
    - `intended use:` a brief description of the model's intended use, as described by the model developer
    - `code publicly available:` whether or not the model's code is publicly available
    - `source documentation:` a link the the model's source documentation


#### Outputs Table

- **Resolution:** one row per type of data output (e.g., fatalities per day, hospital bed demand per day)

- **Contents:** details on each type of model output tracked across models

- **Key data elements:**

    - `output id:` a unique identifier for model output
    - `output name:` the name of the model output (e.g., fatalities per day)
    - `definition:` a definition of each model output
    - `temporal resolution:` the temporal resolution of the output (e.g., daily vs. weekly)
    - `is_cumulative:` whether or not the output is cumulative

#### Locations Table

- **Resolution:** one row per location

- **Contents:** details on the locations for which model outputs are currently available

- **Key data elements:**

    - `location_name:` the name of each location
    - `area_level:` the level of geopolitical organization of each location 
    - `iso2:` for countries, the unique ISO2 code of the country
    - `iso3:` for countries, the unique ISO3 code of the country
    - `FIPS:` for US states, territories, districts, and counties, the unique FIPS code 

#### Model Runs Table

- **Resolution:** one row per model run. A model run is defined as an iteration of a specified model (as of a specified snapshot_date used to version that model) with a specified set of inputs and assumptions. That multiple model_runs will exist for a given model on a given snapshot_date if that model was run under different sets of inputs or assumptions (e.g., assuming no social distancing vs. assuming implementation of social distancing measures)

- **Contents:** details on a given iteration of a model run (see definition of model run above)

- **Key data elements:**

    - `model run id:` a unique identifier for model run
    - `model id:` the name of model
    - `key assumptions:` a brief written description of any key assumptions of the model
    - `model_snapshot_date:` a date used to identify the 'version' of the model being run
    
  #### Model outputs Table

- **Resolution:** one row per location, per date, per output, per model run

- **Contents:** the outputs produced by a specified model run, over time

- **Key data elements:**

    - `model run id:` a unique identifier for model run
    - `output id:` a unique identifier for each output
    - `date:` the date associated with the model output value
    - `location:` the location associated with the model output value
    - `value:` the value produced by the model for the given output, date, and location
    - `value type:` whether the value specified is a single point estimate (e.g., single point estimate produced by the model) or a percentile-based estimate (e.g., 50th percentile of estimates produced across model runs)


    
