#################################################################
## Specify some initial details #################################
#################################################################

model_run_id <- 16
file_name <- "model_runs/3_chime/model_export/16_2020-04-08_projected_census.csv"
file_name2 <- "model_runs/3_chime/model_export/16_2020-04-08_sim_sir_w_date.csv"
file_name3 <- "model_runs/3_chime/model_export/16_2020-04-08_projected_admits.csv"

#################################################################
## Load datasets and set fixed parameters #######################
#################################################################

## read in new dataset of CHIME data
chime <- read.csv(file_name, stringsAsFactors = FALSE)

## read in second chime export dataset
chimesir  <- read.csv(file_name2, stringsAsFactors = FALSE)

## read in third chime export dataset
chimeadmits <- read.csv(file_name3, stringsAsFactors = FALSE)

## read in models (file that tracks all models)
models <- read.delim("data/models.txt", stringsAsFactors = FALSE)

## read in model_runs (file that tracks model runs)
model_runs <- read.delim("data/model_runs.txt", stringsAsFactors = FALSE)

## read in model_outputs (file that tracks model outputs)
model_outputs <- read.delim("data/model_outputs.txt", stringsAsFactors = FALSE)

## read in outputs (file that uniquely identifies each distinct output tracked across models)
outputs <- read.delim("data/outputs.txt", stringsAsFactors = FALSE)

## CHIME model ID is always 3, model name is always whatever model_id 3 is named in the file data/models.txt
model_id <- 3
model_name <- models$model_name[which(models$model_id == 3)]

#################################################################
## Format data ##################################################
#################################################################

## set date as a date
chime$date <- as.Date(chime$date)
model_outputs$date <- as.Date(model_outputs$date)

## exclude NA values
chime <- chime[-which(is.na(chime$hospitalized)),]
chimeadmits <- chimeadmits[-which(is.na(chimeadmits$hospitalized)),]

## No data for output_id 1: New infections per day
## No data for output_id 2: Cumulative infections
## No data for output_id 3: Fatalities per day
## No data for output_id 4: Hospital beds needed per day

############################################################################
## Add data for output_id 5: Hospital beds needed per day ##################
############################################################################

## only add these new data if you're not reading over model_outputs already stored
if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 5])){
  
  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 5,
                     "output_name" = "Hospital beds needed per day",
                     "date" = chime$date,
                     "location" = "California",
                     "value" = chime$hospitalized,
                     "notes" = "")
  )
}

############################################################################
## Add data for output_id 6: ICU beds needed per day #######################
############################################################################

## only add these new data if you're not reading over model_outputs already stored
if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 6])){
  
  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 6,
                     "output_name" = "ICU beds needed per day",
                     "date" = chime$date,
                     "location" = "California",
                     "value" = chime$icu,
                     "notes" = "")
  )
}

############################################################################
## Add data for output_id 7: Ventilators needed per day ####################
############################################################################

## only add these new data if you're not reading over model_outputs already stored
if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 7])){
  
  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 7,
                     "output_name" = "Ventilators needed per day",
                     "date" = chime$date,
                     "location" = "California",
                     "value" = chime$ventilated,
                     "notes" = "")
  )
}

############################################################################
## Add data for output_id 8: Hospital admissions per day ###################
############################################################################

## only add these new data if you're not reading over model_outputs already stored
if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 8])){
  
  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 8,
                     "output_name" = "Hospital admissions per day",
                     "date" = chimeadmits$date,
                     "location" = "California",
                     "value" = chimeadmits$hospitalized,
                     "notes" = "")
  )
}

############################################################################
## Add data for output_id 9: ICU admissions per day ########################
############################################################################

## only add these new data if you're not reading over model_outputs already stored
if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 9])){
  
  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 9,
                     "output_name" = "ICU admissions per day",
                     "date" = chimeadmits$date,
                     "location" = "California",
                     "value" = chimeadmits$icu,
                     "notes" = "")
  )
}

#################################################################
## Save model_outputs as .tsv file ##############################
#################################################################

write.table(model_outputs, file='data/model_outputs.txt', quote = FALSE, sep='\t', row.names = FALSE)

