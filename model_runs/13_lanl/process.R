#################################################################
## Specify some initial details #################################
#################################################################

#model_run_id <- 7
#file_name <- "model_runs/1_ihme/model_export/Hospitalization_all_locs_04_13.csv"

#################################################################
## Load datasets and set fixed parameters #######################
#################################################################

## read in new dataset of IHME exported data
ihme <- read.csv(file_name, stringsAsFactors = FALSE)

## read in models (file that tracks all models)
models <- read.delim("data/models.txt", stringsAsFactors = FALSE)

## read in model_runs (file that tracks model runs)
model_runs <- read.delim("data/model_runs.txt", stringsAsFactors = FALSE)

## read in model_outputs (file that tracks model outputs)
model_outputs <- read.delim("data/model_outputs.txt", stringsAsFactors = FALSE)

## read in outputs (file that uniquely identifies each distinct output tracked across models)
outputs <- read.delim("data/outputs.txt", stringsAsFactors = FALSE)

## read in dataset of locations
locations <- read.delim("data/locations.txt", stringsAsFactors = FALSE)

## IHME model ID is always 1, model name is always whatever model_id 1 is named in the file data/models.txt
model_id <- 1
model_name <- models$model_name[which(models$model_id == 1)]

lanl <- read.csv("https://raw.githubusercontent.com/reichlab/covid19-forecast-hub/master/data-raw/LANL/2020-04-12_deaths_quantiles_us.csv")
