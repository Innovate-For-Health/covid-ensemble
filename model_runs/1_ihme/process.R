#################################################################
## Specify some initial details #################################
#################################################################

model_run_id <- 1
file_name <- "model_runs/1_ihme/model_export/Hospitalization_all_locs_04_01.csv"
  
#################################################################
## Load required packages #######################################
#################################################################

#################################################################
## Load datasets and set fixed parameters #######################
#################################################################

## read in new dataset of IHME exported data
ihme <- read.csv(file_name)

## read in models (file that tracks all models)
models <- read.delim("data/models.txt", stringsAsFactors = FALSE)

## read in model_runs (file that tracks model runs)
model_runs <- read.delim("data/model_runs.txt")

## read in model_outputs (file that tracks model outputs)
model_outputs <- read.delim("data/model_outputs.txt")

## read in outputs (file that uniquely identifies each distinct output tracked across models)
outputs <- read.delim("data/outputs.txt")

## IHME model ID is always 1, model name is always whatever model_id 1 is named in the file data/models.txt
model_id <- 1
model_name <- models$model_name[which(models$model_id == 1)]

#################################################################
## Load datasets ################################################
#################################################################

cbind.data.frame("run_id" = model_run_id,
                 "output_id" = 1,
                 "output_name")
ihme$allbed_mean
