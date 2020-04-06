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

## set data as a date
ihme$date <- as.Date(ihme$date)
model_outputs$date <- as.Date(model_outputs$date)

## for consistency with other data sources for now, consistently code IHME data locations as "US" vs. "United States of America"
## IHME changed how these data were reported as of 4/5/20 (using full name vs. partial name)
## todo: map to FIPS codes and country ISO codes for locations
if(any(ihme$location == "United States of America")){
  ihme$location[which(ihme$location == "United States of America")] <- "US"
}

## exclude some specific elements of IHME data that are only tracked ih IHME export and won't be 
## comparable to results of other models
ihme <- ihme[-which(ihme$location %in% c("King and Snohomish Counties (excluding Life Care Center), WA",
                                         "Life Care Center, Kirkland, WA",
                                         "Other Counties, WA")),]

#################################################################
## Add data to model_outputs file: cumulative fatalities ########
#################################################################

## only add these new data if you're not reading over model_outputs already stored
## given a fixed model run_id (specified above) for a given output type 

if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 1])){
  
  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 1,
                     "output_name" = "cumulative fatalities",
                     "date" = ihme$date,
                     "location" = ihme$location,
                     "value" = ihme$totdea_mean,
                     "notes" = "based on data export from model as of 4/1/2020, note that not all death estimates are rounded to nearest whole number")
  )
}

## note IHME has no data on cumulative cases (which is output_id == 2)

#################################################################
## Add data to model_outputs file: fatalities per day ###########
#################################################################

## only add these new data if you're not reading over model_outputs already stored
## given a fixed model run_id (specified above) for a given output type 

if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 7])){
  
  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 7,
                     "output_name" = "fatalities per day",
                     "date" = ihme$date,
                     "location" = ihme$location,
                     "value" = ihme$deaths_mean,
                     "notes" = "based on data export from model as of 4/1/2020, note that not all death estimates are rounded to nearest whole number")
  )
}

#################################################################
## Add data to model_outputs file: ICU beds per day #############
#################################################################

## only add these new data if you're not reading over model_outputs already stored
## given a fixed model run_id (specified above) for a given output type 

if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 3])){
  
  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 3,
                     "output_name" = "ICU beds per day",
                     "date" = ihme$date,
                     "location" = ihme$location,
                     "value" = ihme$totdea_mean,
                     "notes" = "based on data export from model as of 4/1/2020, note that not all ICU bed demand estimates are rounded to nearest whole number")
  )
}

###################################################################
## Add data to model_outputs file: invasive ventilators per day ###
###################################################################

## only add these new data if you're not reading over model_outputs already stored
## given a fixed model run_id (specified above) for a given output type 

if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 4])){
  
  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 4,
                     "output_name" = "ventilators per day",
                     "date" = ihme$date,
                     "location" = ihme$location,
                     "value" = ihme$InvVen_mean,
                     "notes" = "based on data export from model as of 4/1/2020, note that ventilator demand is not rounded to the nearest number")
  )
}


###################################################################
## Add data to model_outputs file: hospital admissions per day ####
###################################################################

## only add these new data if you're not reading over model_outputs already stored
## given a fixed model run_id (specified above) for a given output type 

if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 5])){
  
  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 5,
                     "output_name" = "hospital admissions per day",
                     "date" = ihme$date,
                     "location" = ihme$location,
                     "value" = ihme$admis_mean,
                     "notes" = "based on data export from model as of 4/1/2020, note that hospital admission counts are not rounded to the nearest number")
  )
}



###################################################################
## Add data to model_outputs file: ICU admissions per day #########
###################################################################

## only add these new data if you're not reading over model_outputs already stored
## given a fixed model run_id (specified above) for a given output type 

if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 6])){
  
  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 6,
                     "output_name" = "ICU admissions per day",
                     "date" = ihme$date,
                     "location" = ihme$location,
                     "value" = ihme$newICU_mean,
                     "notes" = "based on data export from model as of 4/1/2020, note that ICU admission counts are not rounded to the nearest number")
  )
}

#################################################################
## Save model_outputs as .tsv file ##############################
#################################################################

write.table(model_outputs, file='data/model_outputs.txt', quote = FALSE, sep='\t', row.names = FALSE)
