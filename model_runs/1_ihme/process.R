#################################################################
## Specify some initial details #################################
#################################################################

## working directory should be covid-ensemble
model_run_id <- 67
file_name <- "model_runs/1_ihme/model_export/Hospitalization_all_locs_05_20.csv"

#################################################################
## Load datasets and set fixed parameters #######################
#################################################################

## read in new dataset of IHME exported data
ihme <- read.csv(file_name, stringsAsFactors = FALSE)

## read in models (file that tracks all models)
models <- read.delim("data/models.txt", stringsAsFactors = FALSE)

## read in model_runs (file that tracks model runs)
model_runs <- read.delim("data/model_runs.txt", stringsAsFactors = FALSE)

## read in model_outputs (saved as RDS due to large file size)
model_outputs <- readRDS("data/model_outputs.RDS")

## read in outputs (file that uniquely identifies each distinct output tracked across models)
outputs <- read.delim("data/outputs.txt", stringsAsFactors = FALSE)

## read in dataset of locations
locations <- read.delim("data/locations.txt", stringsAsFactors = FALSE)

## IHME model ID is always 1, model name is always whatever model_id 1 is named in the file data/models.txt
model_id <- 1
model_name <- models$model_name[which(models$model_id == 1)]

#################################################################
## Check: any locations not in the locations file? ##############
## then check: do we care? ######################################
#################################################################

if(any(ihme$location_name == "US")){
  ihme$location_name[which(ihme$location_name == "US")] <- "United States of America"
}

if(any(ihme$location_name == "Bolivia (Plurinational State of)")){
  ihme$location_name[which(ihme$location_name == "Bolivia (Plurinational State of)")] <- "Bolivia"
}

if(any(ihme$location_name == "Mexico_country")){
  ihme$location_name[which(ihme$location_name == "Mexico_country")] <- "Mexico"
}

if(any(ihme$location_name == "Republic of Korea")){
  ihme$location_name[which(ihme$location_name == "Republic of Korea")] <- "South Korea"
}

if(any(ihme$location_name == "Republic of Moldova")){
  ihme$location_name[which(ihme$location_name == "Republic of Moldova")] <- "Moldova"
}

all(ihme$location_name %in% locations$location_name)
unique(ihme[-which(ihme$location_name %in% locations$location_name),]$location_name)


## exclude some specific elements of IHME data that are only tracked ih IHME export and won't be 
## comparable to results of other models
## note that field location_name was once called location
# if(any(names(ihme) == "location_name")){
# ihme <- ihme[-which(ihme$location_name %in% c("King and Snohomish Counties (excluding Life Care Center), WA",
#                                          "Life Care Center, Kirkland, WA",
#                                          "Other Counties, WA")),]
# }

# if(any(names(ihme) == "location")){
#   ihme <- ihme[-which(ihme$location %in% c("King and Snohomish Counties (excluding Life Care Center), WA",
#                                                 "Life Care Center, Kirkland, WA",
#                                                 "Other Counties, WA")),]
# }

#################################################################
## Format data ##################################################
#################################################################

## set date as a date
ihme$date <- as.Date(ihme$date)
model_outputs$date <- as.Date(model_outputs$date)

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
                     "value_type" = "point estimate",
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
                     "value_type" = "point estimate",
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
                     "value_type" = "point estimate",
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
                     "value_type" = "point estimate",
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
                     "value_type" = "point estimate",
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
                     "value_type" = "point estimate",
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
                     "value_type" = "point estimate",
                     "value" = ihme$newICU_mean ,
                     "notes" = "")
  )
}

#################################################################
## Save model_outputs as .RDS file ##############################
#################################################################

saveRDS(model_outputs, file = 'data/model_outputs.RDS', compress = TRUE)

