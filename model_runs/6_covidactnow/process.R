#################################################################
## Specify some initial details #################################
#################################################################

## model run 8: 3 months strict say at home orders, manually extracted data for California only
## model run 9: 3 months lax say at home orders, manually extracted data for California only

## todo: figure out a smarter solution that is more scalable and sustainable than pulling data manually
## should be able to figure out something using hicharts? not sure from git documentation which model is actually being used,
## so should pull data directly from site where possible

#################################################################
## Load required libraries ######################################
#################################################################

library(readxl)

#################################################################
## Load datasets and set fixed parameters #######################
#################################################################

## read in dataset (manually extracted on 4/7/20, just for California, and double checked)
## this is my last manual data pull, see todo note above about doing this in a smarter way
cah_manual_strict_sah <- read_excel("model_runs/6_covidactnow/CAH manual california.xlsx", sheet = "strict_sah")
cah_manual_lax_sah <- read_excel("model_runs/6_covidactnow/CAH manual california.xlsx", sheet = "lax_sah")

## read in models (file that tracks all models)
models <- read.delim("data/models.txt", stringsAsFactors = FALSE)

## read in model_runs (file that tracks model runs)
model_runs <- read.delim("data/model_runs.txt", stringsAsFactors = FALSE)

## read in model_outputs (file that tracks model outputs)
model_outputs <- read.delim("data/model_outputs.txt", stringsAsFactors = FALSE)

## read in outputs (file that uniquely identifies each distinct output tracked across models)
outputs <- read.delim("data/outputs.txt", stringsAsFactors = FALSE)

## Covid Act Now model ID is always 6, model name is always whatever model_id 6 is named in the file data/models.txt
model_id <- 6
model_name <- models$model_name[which(models$model_id == 6)]

############################################################################
## Format data #############################################################
############################################################################

model_outputs$date <- as.Date(model_outputs$date)
cah_manual_lax_sah$date <- as.Date(cah_manual_lax_sah$date)
cah_manual_strict_sah$date <- as.Date(cah_manual_strict_sah$date)

############################################################################
## Add data for output_id 2: Cumulative infections #########################
############################################################################

model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = 8,
                     "output_id" = 5,
                     "output_name" = "Hospital beds needed per day",
                     "date" = as.Date(cah_manual_strict_sah$date),
                     "location" =  "California", ## for now, just have data from California
                     "value" = cah_manual_strict_sah$hospitalizations_strict_sah,
                     "notes" = "Data manually extracted from covidactnow.org site on 4/7/20, just for the state of California (strict stay at home orders)"))

model_outputs <- rbind.data.frame(
  model_outputs,
  cbind.data.frame("model_run_id" = 9,
                   "output_id" = 5,
                   "output_name" = "Hospital beds needed per day",
                   "date" = cah_manual_lax_sah$date,
                   "location" =  "California", ## for now, just have data from California
                   "value" = cah_manual_lax_sah$hospitalizations_lax_sah,
                   "notes" = "Data manually extracted from covidactnow.org site on 4/7/20, just for the state of California (lax stay at home orders)"))

#################################################################
## Save model_outputs as .tsv file ##############################
#################################################################

write.table(model_outputs, file='data/model_outputs.txt', quote = FALSE, sep='\t', row.names = FALSE)

