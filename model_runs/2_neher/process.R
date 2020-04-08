#################################################################
## Specify some initial details #################################
#################################################################

model_run_id <- 10
file_name <- "model_runs/2_neher/model_export/10_covid.results.deterministic.csv"
  
#################################################################
## Load datasets and set fixed parameters #######################
#################################################################

## read in new dataset of Neher exported data
neher <- read.delim(file_name, stringsAsFactors = FALSE)

## read in models (file that tracks all models)
models <- read.delim("data/models.txt", stringsAsFactors = FALSE)

## read in model_runs (file that tracks model runs)
model_runs <- read.delim("data/model_runs.txt", stringsAsFactors = FALSE)

## read in model_outputs (file that tracks model outputs)
model_outputs <- read.delim("data/model_outputs.txt", stringsAsFactors = FALSE)

## read in outputs (file that uniquely identifies each distinct output tracked across models)
outputs <- read.delim("data/outputs.txt", stringsAsFactors = FALSE)

## Neher model ID is always 2, model name is always whatever model_id 2 is named in the file data/models.txt
model_id <- 2
model_name <- models$model_name[which(models$model_id == 2)]

#################################################################
## Format data ##################################################
#################################################################

## set time as a date
neher$time <- as.Date(neher$time)
model_outputs$date <- as.Date(model_outputs$date)

## focus only on data starting in April 2020
neher <- neher[which(neher$time >= as.Date("2020-04-01")),]

## no data for output_id 1: new infections per day
## no data for output_id 2: cumulative infections

#################################################################
## Add data for output_id 3:  Fatalities per day ################
#################################################################

## only add these new data if you're not reading over model_outputs already stored
## note that Neher model export data format reports only cumulative fatalities, so backtracking
## from this value to calculate fatalities per day

if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 3])){
  
  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 3,
                     "output_name" = "Fatalities per day",
                     "date" = neher$time,
                     "location" = "United States of America",
                     "value" = c(NA, diff(neher$cumulative_fatality)),
                     "notes" = "calculated based on daily differences in cumulative fatalities")
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
                     "date" = neher$time,
                     "location" = "United States of America",
                     "value" = neher$cumulative_fatality,
                     "notes" = "")
  )
}


#################################################################
## Add data for output_id 6: ICU beds needed per day ############
#################################################################

## only add these new data if you're not reading over model_outputs already stored
## note that Neher model assumes a finite number of ICU beds and then puts patients
## beyond that finite number into an "overflow" bucket, so address that here

if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 6])){
  
  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 6,
                     "output_name" = "ICU beds needed per day",
                     "date" = neher$time,
                     "location" = "United States of America",
                     "value" = neher$ICU + neher$overflow,
                     "notes" = "calculated as the sum of ICU patients plus patient assumed to be diverted from the ICU due to overflow beyond ICU capacity")
  )
}

#################################################################
## Add data for output_id 8: Hospital admissions per day ########
#################################################################

## only add these new data if you're not reading over model_outputs already stored
## note that Neher model export data format reports only cumulative hospitalizations, so backtracking
## from this value to calculate hospitalizations per day

if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 8])){
  
  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 8,
                     "output_name" = "Hospital admissions per day",
                     "date" = neher$time,
                     "location" = "United States of America",
                     "value" = c(NA, diff(neher$cumulative_hospitalized)),
                     "notes" = "calculated based on daily differences in cumulative fatalities")
  )
}

#################################################################
## Save model_outputs as .tsv file ##############################
#################################################################

write.table(model_outputs, file = 'data/model_outputs.txt', quote = FALSE, sep='\t', row.names = FALSE)


