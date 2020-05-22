#################################################################
## Specify some initial details #################################
#################################################################

## working directory should be covid-ensemble
model_run_id <- 70
file_location <- "https://gist.githubusercontent.com/ZeroWeight/9a0c53e56c9bf846485a19a324cf74bd/raw/us_all_pred.json"

#################################################################
## Load required libraries ######################################
#################################################################

library(rjson)
library(jsonlite)

#################################################################
## Load other datasets and set fixed parameters #################
#################################################################

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

## UCLA model ID is always 17, model name is always whatever model_id 17 is named in the file data/models.txt
model_id <- 17
model_name <- models$model_name[which(models$model_id == 17)]

#################################################################
## Hit API for states ###########################################
#################################################################

## as of May 22, URL: https://gist.githubusercontent.com/ZeroWeight/9a0c53e56c9bf846485a19a324cf74bd/raw/us_all_pred.json

raw_data <- rjson::fromJSON(file = file_location)
write(jsonlite::toJSON(raw_data), file = paste("model_runs/17_ucla/model_export/", Sys.Date(), "_raw_data.json", sep = ""))

## states that don't have data changed between updates
location_options <- locations[which(locations$location_type == "Province/State" & 
                                      locations$iso2 == "US"),]

location_options$api_id <- paste("US-", location_options$abbreviation, sep = "")

additional_outputs <- cbind.data.frame(
  "model_run_id" = NA,
  "output_id" = NA,
  "output_name" = NA,
  "date" =  NA,
  "location" =  NA,
  "value_type" = NA,
  "value" = NA,
  "notes" = NA)
    

for(i in 1:nrow(location_options)){
  
  print(location_options[i,]$location_name)
  
  predictions <- raw_data$deaths$pred[location_options[i,]$api_id]
  dates <- gsub(paste(location_options[i,]$api_id, ".", sep = ""), "", names(unlist(predictions)))
  deaths <- as.numeric(unlist(predictions))

    
    ## add cumulative fatality data
    additional_outputs <- rbind.data.frame(additional_outputs,
                                             cbind.data.frame(
                                               "model_run_id" = model_run_id,
                                               "output_id" = 4,
                                               "output_name" = "Cumulative fatalities",
                                               "date" = dates,
                                               "location" =  location_options[i,]$location_name,
                                               "value_type" = "point estimate",
                                               "value" = round(deaths),
                                               "notes" = "estimates rounded to nearest whole number, as displayed on UCLA site"))
    }


## remove first row that was just a placeholder
additional_outputs <- additional_outputs[-1,]

#################################################################
## Format data ##################################################
#################################################################

model_outputs$date <- as.Date(model_outputs$date)
additional_outputs$date <- as.Date(additional_outputs$date, format = "%m/%d/%y")

#################################################################
## Sanity check #################################################
#################################################################

## check data
ggplot(additional_outputs[which(additional_outputs$location == "District of Columbia"),],
       aes(x = date, y = value)) +
  geom_line(size = 1) +
  scale_y_continuous(label = comma) +
  xlab("") +
  theme_light() 

#################################################################
## Add new data to existing model_outputs file ##################
#################################################################

model_outputs <- rbind.data.frame(model_outputs, additional_outputs)

#################################################################
## Save model_outputs as .RDS file ##############################
#################################################################

saveRDS(model_outputs, file = 'data/model_outputs.RDS', compress = TRUE)

