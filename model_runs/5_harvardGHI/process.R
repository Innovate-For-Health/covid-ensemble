#################################################################
## Specify some initial details #################################
#################################################################

## model run 5: 20% infected
## model run 6: 40% infected
## model run 7: 60% infected

#################################################################
## Load required libraries ######################################
#################################################################

library(readxl)

#################################################################
## Load datasets and set fixed parameters #######################
#################################################################

## read in dataset from GHI assuming 20% infection
ghi20 <- read_excel("model_runs/5_harvardGHI/model_export/Hospital Capacity by State ( 20% _ 40% _ 60% ).xlsx", sheet = "20%")
ghi40 <- read_excel("model_runs/5_harvardGHI/model_export/Hospital Capacity by State ( 20% _ 40% _ 60% ).xlsx", sheet = "40%")
ghi60 <- read_excel("model_runs/5_harvardGHI/model_export/Hospital Capacity by State ( 20% _ 40% _ 60% ).xlsx", sheet = "60%")

## read in dataset of state abbreviations to get FIPS codes
states <- read.delim("data/USintermediateFIPS.txt", stringsAsFactors = FALSE)

## read in models (file that tracks all models)
models <- read.delim("data/models.txt", stringsAsFactors = FALSE)

## read in model_runs (file that tracks model runs)
model_runs <- read.delim("data/model_runs.txt", stringsAsFactors = FALSE)

## read in model_outputs (file that tracks model outputs)
model_outputs <- read.delim("data/model_outputs.txt", stringsAsFactors = FALSE)

## read in outputs (file that uniquely identifies each distinct output tracked across models)
outputs <- read.delim("data/outputs.txt", stringsAsFactors = FALSE)

## GHI model ID is always 5, model name is always whatever model_id 5 is named in the file data/models.txt
model_id <- 5
model_name <- models$model_name[which(models$model_id == 5)]

#################################################################
## Format data ##################################################
#################################################################

## add full state names
ghi20 <- merge(ghi20, states, by.x = "State", by.y = "abbreviation")
ghi40 <- merge(ghi40, states, by.x = "State", by.y = "abbreviation")
ghi60 <- merge(ghi60, states, by.x = "State", by.y = "abbreviation")

## format dates as dates
model_outputs$date <- as.Date(model_outputs$date)

## Only available data are for output_id 2: Cumulative infections

############################################################################
## Add data for output_id 2: Cumulative infections #########################
############################################################################

model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = 5,
                     "output_id" = 2,
                     "output_name" = "Cumulative infections",
                     "date" = as.Date(as.Date("2020-04-07") + 18*30), ## assume infections occur over 18 months
                     "location" =  ghi20$Location, ## use full state names
                     "value" = ghi20$`Projected Infected Individuals`,
                     "notes" = "Model assumes that 20% of the population is infected over 18 months, using estimate as of 18 months"))

model_outputs <- rbind.data.frame(
  model_outputs,
  cbind.data.frame("model_run_id" = 6,
                   "output_id" = 2,
                   "output_name" = "Cumulative infections",
                   "date" = as.Date(as.Date("2020-04-07") + 18*30), ## assume infections occur over 18 months
                   "location" =  ghi40$Location, ## use full state names
                   "value" = ghi40$`Projected Infected Individuals`,
                   "notes" = "Model assumes that 20% of the population is infected over 18 months, using estimate as of 18 months"))

model_outputs <- rbind.data.frame(
  model_outputs,
  cbind.data.frame("model_run_id" = 7,
                   "output_id" = 2,
                   "output_name" = "Cumulative infections",
                   "date" = as.Date(as.Date("2020-04-07") + 18*30), ## assume infections occur over 18 months
                   "location" =  ghi60$Location, ## use full state names
                   "value" = ghi60$`Projected Infected Individuals`,
                   "notes" = "Model assumes that 60% of the population is infected over 18 months, using estimate as of 18 months"))

#################################################################
## Save model_outputs as .tsv file ##############################
#################################################################

write.table(model_outputs, file='data/model_outputs.txt', quote = FALSE, sep='\t', row.names = FALSE)

