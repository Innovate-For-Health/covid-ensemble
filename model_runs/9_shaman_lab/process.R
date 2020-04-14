#################################################################
## Specify some initial details #################################
#################################################################

model_run_id_no_iv <- 31
file_name_beds_no_iv <- "model_runs/9_shaman_lab/model_export/31_bed_nointervention.csv"
file_name_cases_no_iv <- "model_runs/9_shaman_lab/model_export/31_Projection_nointervention.csv"

#################################################################
## Load datasets and set fixed parameters #######################
#################################################################

## read in new dataset: assuming no intervention ("no iv")
no_iv_beds <- read.csv(file_name_beds_no_iv, stringsAsFactors = FALSE)
no_iv_cases <- read.csv(file_name_cases_no_iv, stringsAsFactors = FALSE)

## read in models (file that tracks all models)
models <- read.delim("data/models.txt", stringsAsFactors = FALSE)

## read in model_runs (file that tracks model runs)
model_runs <- read.delim("data/model_runs.txt", stringsAsFactors = FALSE)

## read in model_outputs (file that tracks model outputs)
model_outputs <- read.delim("data/model_outputs.txt", stringsAsFactors = FALSE)

## read in outputs (file that uniquely identifies each distinct output tracked across models)
outputs <- read.delim("data/outputs.txt", stringsAsFactors = FALSE)

## Shaman lab model ID is always 9, model name is always whatever model_id 9 is named in the file data/models.txt
model_id <- 9
model_name <- models$model_name[which(models$model_id == 9)]

#################################################################
## Format data ##################################################
#################################################################

## set date as a date
no_iv_beds$Date <- as.Date(no_iv_beds$Date, format = "%m/%d/%y")
no_iv_cases$Date <- as.Date(no_iv_cases$Date, format = "%m/%d/%y")
model_outputs$date <- as.Date(model_outputs$date)
