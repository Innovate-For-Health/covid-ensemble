#################################################################
## Specify some initial details #################################
#################################################################

model_run_id <- 3
file_name <- "model_runs/1_ihme/model_export/Hospitalization_all_locs_04_07.csv"

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

## IHME model ID is always 1, model name is always whatever model_id 1 is named in the file data/models.txt
model_id <- 1
model_name <- models$model_name[which(models$model_id == 1)]

#################################################################
## Format data ##################################################
#################################################################

## set date as a date
ihme$date <- as.Date(ihme$date)
model_outputs$date <- as.Date(model_outputs$date)

## for consistency across data sources, consistently code IHME data locations as "United States of America" vs. "US" 
## IHME changed how these data were reported as of 4/5/20 (using full name vs. partial name)
## todo: map to FIPS codes and country ISO codes for locations
if(any(ihme$location == "US")){
  ihme$location[which(ihme$location == "US")] <- "United States of America"
}

## exclude some specific elements of IHME data that are only tracked ih IHME export and won't be 
## comparable to results of other models
ihme <- ihme[-which(ihme$location %in% c("King and Snohomish Counties (excluding Life Care Center), WA",
                                         "Life Care Center, Kirkland, WA",
                                         "Other Counties, WA")),]

## no data for output_id 1: new infections per day
## no data for output_id 2: cumulative infections

#################################################################
## Add data for output_id 3:  Fatalities per day ################
#################################################################

## only add these new data if you're not reading over model_outputs already stored
if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 3])){
  
  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 3,
                     "output_name" = "Fatalities per day",
                     "date" = ihme$date,
                     "location" = ihme$location,
                     "value" = ihme$deaths_mean,
                     "notes" = "")
  )
}

#################################################################
## Add data for output_id 4: Cumulative fatalities ##############
#################################################################

## only add these new data if you're not reading over model_outputs already stored
if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 4])){
  
  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 4,
                     "output_name" = "Cumulative fatalities",
                     "date" = ihme$date,
                     "location" = ihme$location,
                     "value" = ihme$totdea_mean,
                     "notes" = "")
  )
}

########################################################################
## Add data for output_id 5: Hospital beds needed per day ##############
########################################################################

## only add these new data if you're not reading over model_outputs already stored
if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 5])){
  
  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 5,
                     "output_name" = "Hospital beds needed per day",
                     "date" = ihme$date,
                     "location" = ihme$location,
                     "value" = ihme$allbed_mean,
                     "notes" = "")
  )
}

########################################################################
## Add data for output_id 6: ICU beds needed per day ###################
########################################################################

## only add these new data if you're not reading over model_outputs already stored
if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 6])){
  
  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 6,
                     "output_name" = "ICU beds needed per day",
                     "date" = ihme$date,
                     "location" = ihme$location,
                     "value" = ihme$ICUbed_mean,
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
                     "date" = ihme$date,
                     "location" = ihme$location,
                     "value" = ihme$InvVen_mean ,
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
                     "date" = ihme$date,
                     "location" = ihme$location,
                     "value" = ihme$admis_mean ,
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
                     "date" = ihme$date,
                     "location" = ihme$location,
                     "value" = ihme$newICU_mean ,
                     "notes" = "")
  )
}

############################################################################
## Add data for output_id 10: Fatalities per week ##########################
############################################################################

## TODO: add this later once I figure out the weeks in the Imperial College London model, now their documentation doesn't match their data export

#################################################################
## Save model_outputs as .tsv file ##############################
#################################################################

write.table(model_outputs, file='data/model_outputs.txt', quote = FALSE, sep='\t', row.names = FALSE)

