#################################################################
## Specify some initial details #################################
#################################################################

## working directory should be covid-ensemble
model_run_id <- 109
file_location <- "https://gist.githubusercontent.com/ZeroWeight/9a0c53e56c9bf846485a19a324cf74bd/raw/us_all_pred.json"
file_location_world <- "https://gist.githubusercontent.com/ZeroWeight/9a0c53e56c9bf846485a19a324cf74bd/raw/51bdcf5fa57428c07a40c1184f7fff1b5f1c02e3/world_all_pred.json"

#################################################################
## Load required libraries ######################################
#################################################################

library(rjson)
library(jsonlite)

#################################################################
## Load other datasets and set fixed parameters #################
#################################################################

## assume working directory is covid-ensemble
#setwd("~/Documents/covid-ensemble")

## read in models (file that tracks all models)
models <- read.delim("srv/shiny-server/data/models.txt", stringsAsFactors = FALSE)

## read in model_runs (file that tracks model runs)
model_runs <- read.delim("srv/shiny-server/data/model_runs.txt", stringsAsFactors = FALSE)

## read in model_outputs (saved as RDS due to large file size)
model_outputs <- readRDS("srv/shiny-server/data/model_outputs.RDS")

## read in outputs (file that uniquely identifies each distinct output tracked across models)
outputs <- read.delim("srv/shiny-server/data/outputs.txt", stringsAsFactors = FALSE)

## read in dataset of locations
locations <- read.delim("srv/shiny-server/data/locations.txt", stringsAsFactors = FALSE)

## UCLA model ID is always 17, model name is always whatever model_id 17 is named in the file data/models.txt
model_id <- 17
model_name <- models$model_name[which(models$model_id == 17)]

#################################################################
## Get data for states ##########################################
#################################################################

## as of May 22, URL: https://gist.githubusercontent.com/ZeroWeight/9a0c53e56c9bf846485a19a324cf74bd/raw/us_all_pred.json

raw_data <- rjson::fromJSON(file = file_location)
raw_data_global <- rjson::fromJSON(file = file_location_world)
write(jsonlite::toJSON(raw_data), file = paste("model_runs/17_ucla/model_export/", Sys.Date(), "_raw_data_US_states.json", sep = ""))
write(jsonlite::toJSON(raw_data_global), file = paste("model_runs/17_ucla/model_export/", Sys.Date(), "_raw_data_global.json", sep = ""))

## function to calculate daily fatalities
undoCumSum <- function(x) {
  c(NA, diff(x))
}

#################################################################
## Process data from US States ##################################
#################################################################

## list of US states to loop over
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
  daily_deaths <- undoCumSum(deaths)
  
  if(max(deaths) - min(deaths) != sum(daily_deaths, na.rm = TRUE)){stop("Something is wrong with the calculation of daily fatalities. Please check.")}

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
    
    ## add daily fatality data
    additional_outputs <- rbind.data.frame(additional_outputs,
                                           cbind.data.frame(
                                             "model_run_id" = model_run_id,
                                             "output_id" = 3,
                                             "output_name" = "Fatalities per day",
                                             "date" = dates,
                                             "location" =  location_options[i,]$location_name,
                                             "value_type" = "point estimate",
                                             "value" = round(daily_deaths),
                                             "notes" = "estimates rounded to nearest whole number, as displayed on UCLA site, daily fatalities calculated as daily difference between estimates of cumulative deaths"))
    
    
    }

#################################################################
## Process global data ##########################################
#################################################################

## just to be safe, remove some old stored variables
rm(location_options); rm(raw_data); rm(predictions); rm(dates); rm(deaths); rm(daily_deaths)

## check that all countries are included in the locations.txt file
all(names(raw_data_global$deaths$pred) %in% locations$iso2)
#names(raw_data_global$deaths$pred)[-which(names(raw_data_global$deaths$pred) %in% locations$iso2)]

global_location_options <- locations[which(locations$iso2 %in% names(raw_data_global$deaths$pred) & 
                                             locations$location_type == "Country"),]

## for model_run_id 91, estimates of cumulative fatalities in Gemrany are not monotonically increasing,
## so don't calculate daily fatalities for Germany for this model run

for(i in 1:nrow(global_location_options)){
  
  print(global_location_options[i,]$location_name)
  
  predictions <- raw_data_global$deaths$pred[global_location_options[i,]$iso2]
  dates <- gsub(paste(global_location_options[i,]$iso2, ".", sep = ""), "", names(unlist(predictions)))
  deaths <- as.numeric(unlist(predictions))
  daily_deaths <- undoCumSum(deaths)

  ## add cumulative fatality data
  additional_outputs <- rbind.data.frame(additional_outputs,
                                         cbind.data.frame(
                                           "model_run_id" = model_run_id,
                                           "output_id" = 4,
                                           "output_name" = "Cumulative fatalities",
                                           "date" = dates,
                                           "location" =  global_location_options[i,]$location_name,
                                           "value_type" = "point estimate",
                                           "value" = round(deaths),
                                           "notes" = "estimates rounded to nearest whole number, as displayed on UCLA site"))
  
  ## add daily fatality data
  if(!(model_run_id %in% c(92, 109) & global_location_options[i,]$location_name == "Germany")){
    if((max(deaths) - min(deaths)) != sum(daily_deaths, na.rm = TRUE)){stop("Something is wrong with the calculation of daily fatalities. Please check.")}
    
  additional_outputs <- rbind.data.frame(additional_outputs,
                                         cbind.data.frame(
                                           "model_run_id" = model_run_id,
                                           "output_id" = 3,
                                           "output_name" = "Fatalities per day",
                                           "date" = dates,
                                           "location" =  global_location_options[i,]$location_name,
                                           "value_type" = "point estimate",
                                           "value" = round(daily_deaths),
                                           "notes" = "estimates rounded to nearest whole number, as displayed on UCLA site"))
  }
}



## remove first row that was just a placeholder
additional_outputs <- additional_outputs[-1,]

#################################################################
## Format data ##################################################
#################################################################

model_outputs$date <- as.Date(model_outputs$date)
additional_outputs$date <- as.Date(additional_outputs$date, format = "%m/%d/%y")

additional_outputs <- additional_outputs[-which(is.na(additional_outputs$value)),]

#################################################################
## Sanity check #################################################
#################################################################

table(additional_outputs$output_name)

## check data
ggplot(additional_outputs[which(additional_outputs$location == "California" & additional_outputs$output_name == "Fatalities per day"),],
       aes(x = date, y = value)) +
  geom_line(size = 1) +
  scale_y_continuous(label = comma) +
  xlab("") +
  theme_light() 

## check data
ggplot(additional_outputs[which(additional_outputs$location == "United Kingdom" & additional_outputs$output_name == "Fatalities per day"),],
       aes(x = date, y = value)) +
  geom_line(size = 1) +
  scale_y_continuous(label = comma) +
  xlab("") +
  theme_light() 

ggplot(additional_outputs[which(additional_outputs$location == "United Kingdom" & additional_outputs$output_name == "Cumulative fatalities"),],
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

saveRDS(model_outputs, file = 'srv/shiny-server/data/model_outputs.RDS', compress = TRUE)

