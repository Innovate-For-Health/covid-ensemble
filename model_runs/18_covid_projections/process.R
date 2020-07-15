#################################################################
## Specify some initial details #################################
#################################################################

## working directory should be covid-ensemble
model_run_id <- 155
file_location_base <- "https://raw.githubusercontent.com/youyanggu/covid19_projections/master/projections/2020-07-14/"
file_location_base_international <- "https://raw.githubusercontent.com/youyanggu/covid19_projections/master/projections/2020-07-14/global/"

#################################################################
## Load required libraries ######################################
#################################################################

library(rjson)
library(jsonlite)
library(ggplot2)
library(scales)

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
locations <- read.csv("data/locations.csv", stringsAsFactors = FALSE, encoding = "UTF-8")

## This model ID is always 18, model name is always whatever model_id 18 is named in the file data/models.txt
model_id <- 18
model_name <- models$model_name[which(models$model_id == 18)]

undoCumSum <- function(x) {
  c(NA, diff(x))
}

#################################################################
## Access state-level data from github ###########################
#################################################################

## example URL: https://raw.githubusercontent.com/youyanggu/covid19_projections/master/projections/2020-05-21/US_AK.csv
additional_outputs <- cbind.data.frame(
  "model_run_id" = NA,
  "output_id" = NA,
  "output_name" = NA,
  "date" =  NA,
  "location" =  NA,
  "value_type" = NA,
  "value" = NA,
  "notes" = NA)


## states that don't have data changed between updates
location_options <- locations[which(locations$location_type == "Province/State" & 
                                      locations$iso2 == "US"),]

location_options$github_string <- paste("US_", location_options$abbreviation, ".csv", sep = "")

## for model_run_id 75 and 76 (data from 4/4 and 4/11, all of Wyoming's data is NULL, see: https://github.com/youyanggu/covid19_projections/blob/master/projections/2020-04-11/US_WY.csv)
if(model_run_id %in% c(75, 76)){location_options <- location_options[-which(location_options$location_name == "Wyoming"),]}

for(i in 1:nrow(location_options)){
  
  print(location_options[i,]$location_name)
  
  data <- read.csv(paste(file_location_base, location_options$github_string[i], sep = ""))

    additional_outputs <- rbind.data.frame(additional_outputs,
                                             cbind.data.frame(
                                               "model_run_id" = model_run_id,
                                               "output_id" = 1,
                                               "output_name" = "New infections per day",
                                               "date" = data$date,
                                               "location" =  location_options[i,]$location_name,
                                               "value_type" = "mean estimate",
                                               "value" = data$predicted_new_infected_mean,
                                               "notes" = ""))

    additional_outputs <- rbind.data.frame(additional_outputs,
                                           cbind.data.frame(
                                             "model_run_id" = model_run_id,
                                             "output_id" = 2,
                                             "output_name" = "Cumulative infections",
                                             "date" = data$date,
                                             "location" =  location_options[i,]$location_name,
                                             "value_type" = "mean estimate",
                                             "value" = data$predicted_total_infected_mean,
                                             "notes" = ""))
    
    additional_outputs <- rbind.data.frame(additional_outputs,
                                           cbind.data.frame(
                                             "model_run_id" = model_run_id,
                                             "output_id" = 4,
                                             "output_name" = "Cumulative fatalities",
                                             "date" = data$date,
                                             "location" =  location_options[i,]$location_name,
                                             "value_type" = "mean estimate",
                                             "value" = data$predicted_total_deaths_mean,
                                             "notes" = ""))
    
    if(sum(undoCumSum(data$predicted_total_deaths_mean), na.rm = TRUE) != max(data$predicted_total_deaths_mean, na.rm = TRUE) - min(data$predicted_total_deaths_mean, na.rm = TRUE)){
      stop("Something is wrong with calculations of daily fatalities. Please stop to inspect.")
    }
    
    additional_outputs <- rbind.data.frame(additional_outputs,
                                           cbind.data.frame(
                                             "model_run_id" = model_run_id,
                                             "output_id" = 3,
                                             "output_name" = "Fatalities per day",
                                             "date" = data$date,
                                             "location" =  location_options[i,]$location_name,
                                             "value_type" = "mean estimate, daily fatalities estimated based on daily differences in predicted total deaths",
                                             "value" = undoCumSum(data$predicted_total_deaths_mean),
                                             "notes" = ""))
    }


## remove first row that was just a placeholder
additional_outputs <- additional_outputs[-1,]

#################################################################
## Access country-level data from github ########################
#################################################################

international_locations <- c("Algeria", "Argentina", 
                             "Austria",
                             "Bangladesh", 
                             "Belgium", "Brazil",
                             "Bulgaria", "Canada", 
                             "Chile", "China", "Colombia", 
                             "Croatia", "Cyprus", "Czechia",
                             "Denmark", 
                             "Dominican-Republic", "Ecuador", "Egypt", 
                             "Estonia", "Finland", "France", "Germany",
                             "Greece", "Hungary", "Iceland", 
                             "India", "Indonesia",
                             "Iran", "Ireland", "Israel", 
                             "Italy", "Japan",
                             "Latvia", "Lithuania", "Luxembourg", "Malaysia",
                             "Malta", "Mexico", "Moldova", "Morocco", 
                             "Netherlands",
                             "Nigeria", "Norway", "Pakistan", "Panama", "Peru",
                             "Philippines", "Poland", "Portugal", "Romania",
                             "Russia", "Saudi-Arabia", "Serbia", 
                             "Slovakia", "Slovenia",
                             "South-Africa", "South-Korea", 
                             "Spain", "Sweden",
                             "Switzerland", "Turkey", "Ukraine",
                             "United-Kingdom")

for(i in international_locations){

  print(i)

  data <- read.csv(paste(file_location_base_international, "/", i, "_ALL.csv", sep = ""))

  additional_outputs <- rbind.data.frame(additional_outputs,
                                         cbind.data.frame(
                                           "model_run_id" = model_run_id,
                                           "output_id" = 1,
                                           "output_name" = "New infections per day",
                                           "date" = data$date,
                                           "location" =  gsub("-", " ", i),
                                           "value_type" = "mean estimate",
                                           "value" = data$predicted_new_infected_mean,
                                           "notes" = ""))

  additional_outputs <- rbind.data.frame(additional_outputs,
                                         cbind.data.frame(
                                           "model_run_id" = model_run_id,
                                           "output_id" = 2,
                                           "output_name" = "Cumulative infections",
                                           "date" = data$date,
                                           "location" =  gsub("-", " ", i),
                                           "value_type" = "mean estimate",
                                           "value" = data$predicted_total_infected_mean,
                                           "notes" = ""))

  additional_outputs <- rbind.data.frame(additional_outputs,
                                         cbind.data.frame(
                                           "model_run_id" = model_run_id,
                                           "output_id" = 4,
                                           "output_name" = "Cumulative fatalities",
                                           "date" = data$date,
                                           "location" =  gsub("-", " ", i),
                                           "value_type" = "mean estimate",
                                           "value" = data$predicted_total_deaths_mean,
                                           "notes" = ""))
  
  if(sum(undoCumSum(data$predicted_total_deaths_mean), na.rm = TRUE) != max(data$predicted_total_deaths_mean, na.rm = TRUE) - min(data$predicted_total_deaths_mean, na.rm = TRUE)){
    stop("Something is wrong with calculations of daily fatalities. Please stop to inspect.")
  }
      
  additional_outputs <- rbind.data.frame(additional_outputs,
                                         cbind.data.frame(
                                           "model_run_id" = model_run_id,
                                           "output_id" = 3,
                                           "output_name" = "Fatalities per day",
                                           "date" = data$date,
                                           "location" =  gsub("-", " ", i),
                                           "value_type" = "mean estimate, daily fatalities estimated based on daily differences in predicted total deaths",
                                           "value" = undoCumSum(data$predicted_total_deaths_mean),
                                           "notes" = ""))
}


additional_outputs <- additional_outputs[-which(is.na(additional_outputs$value)),]

#################################################################
## Format data ##################################################
#################################################################

model_outputs$date <- as.Date(model_outputs$date)
additional_outputs$date <- as.Date(additional_outputs$date)

## focus just on forecasts of the future
additional_outputs <- additional_outputs[which(additional_outputs$date >= as.Date("2020-06-25")),]

#################################################################
## Sanity check #################################################
#################################################################

## check data
ggplot(additional_outputs[which(additional_outputs$location == "California" & additional_outputs$output_id == 4),],
       aes(x = date, y = value)) +
  geom_line(size = 1) +
  scale_y_continuous(label = comma) +
  xlab("") +
  theme_light() 

## check data
ggplot(additional_outputs[which(additional_outputs$location == "California" & additional_outputs$output_id == 3),],
       aes(x = date, y = value)) +
  geom_line(size = 1) +
  scale_y_continuous(label = comma) +
  xlab("") +
  theme_light() 

## check data
ggplot(additional_outputs[which(additional_outputs$location == "Iran" & additional_outputs$output_id == 3),],
       aes(x = date, y = value)) +
  geom_line(size = 1) +
  scale_y_continuous(label = comma) +
  xlab("") +
  theme_light() 

## check data
ggplot(additional_outputs[which(additional_outputs$location == "Iran" & additional_outputs$output_id == 4),],
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

