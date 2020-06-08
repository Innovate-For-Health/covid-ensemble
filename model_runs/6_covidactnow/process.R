#################################################################
## Specify some initial details #################################
#################################################################

run_id_observed <- 101
run_id_strong <- 102
run_id_weak <- 103

#################################################################
## Load required libraries ######################################
#################################################################

library(rjson)

#################################################################
## Load datasets other than Covid Act Now data ##################
#################################################################

## expects working directory to be "covid-ensemble"

## read in models (file that tracks all models)
models <- read.delim("data/models.txt", stringsAsFactors = FALSE)

## read in model_runs (file that tracks model runs)
model_runs <- read.delim("data/model_runs.txt", stringsAsFactors = FALSE)

## read in model_outputs (file that tracks model outputs)
model_outputs <- readRDS("data/model_outputs.RDS")

## read in outputs (file that uniquely identifies each distinct output tracked across models)
outputs <- read.delim("data/outputs.txt", stringsAsFactors = FALSE)

## read in dataset of US states and their abbreviations
locations <- read.delim("data/locations.txt", stringsAsFactors = FALSE)
locations <- locations[which(locations$iso3 == "USA" & locations$area_level == "Intermediate"),]

## Covid Act Now model ID is always 6, model name is always whatever model_id 6 is named in the file data/models.txt
model_id <- 6
model_name <- models$model_name[which(models$model_id == 6)]

#################################################################
## Format data ##################################################
#################################################################

## treat dates as dates
model_outputs$date <- as.Date(model_outputs$date)

#########################################################################
## Function needed to calculate daily fatalities #########################
#########################################################################

undoCumSum <- function(x) {
  c(NA, diff(x))
}

#########################################################################
## Read in Covid Act Now data: Observed Intervention ####################
#########################################################################

location_options <- locations[which(locations$location_type == "Province/State" & locations$iso2 == "US"),]

additional_outputs <- cbind.data.frame(
    "model_run_id" = NA,
    "output_id" = NA,
    "output_name" =  NA,
    "date" =  NA,
    "location" =  NA,
    "value_type" = NA,
    "value" = NA,
    "notes" = NA)


for(state in 1:nrow(location_options)){
  
  print(location_options$location_name[state])
  
  data <- rjson::fromJSON(file = paste("https://data.covidactnow.org/latest/us/states/", location_options[state,]$abbreviation, ".OBSERVED_INTERVENTION.timeseries.json", sep = ""))
  
  date <- c()
  hosp_beds  <- c()
  cumu_deaths <- c()
  loc_counter <- c()
  daily_deaths <- c()
  
  for(i in 1:length(data$timeseries)){
    date <- c(date, data$timeseries[[i]]$date)
    hosp_beds <- c(hosp_beds, as.numeric(as.character(data$timeseries[[i]]$hospitalBedsRequired)))
    cumu_deaths <- c(cumu_deaths, as.numeric(as.character(data$timeseries[[i]]$cumulativeDeaths)))
    loc_counter <- c(loc_counter, location_options$location_name[state])
    
  }
  
  additional_outputs <- rbind.data.frame(
    
    additional_outputs,
    
    cbind.data.frame(
    "model_run_id" = run_id_observed,
    "output_id" = 5,
    "output_name" = "Hospital beds needed per day",
    "date" =  date,
    "location" =  loc_counter,
    "value_type" = "point estimate",
    "value" = hosp_beds,
    "notes" = '"estimates based on the observed effect of mitigations and other factors in a given state"'),
    
    cbind.data.frame(
      "model_run_id" = run_id_observed,
      "output_id" = 4,
      "output_name" = "Cumulative fatalities",
      "date" =  date,
      "location" =  loc_counter,
      "value_type" = "point estimate",
      "value" = cumu_deaths,
      "notes" = '"estimates based on the observed effect of mitigations and other factors in a given state"'),
    
    cbind.data.frame(
      "model_run_id" = run_id_observed,
      "output_id" = 3,
      "output_name" = "Fatalities per day",
      "date" =  date,
      "location" =  loc_counter,
      "value_type" = "point estimate",
      "value" = undoCumSum(cumu_deaths),
      "notes" = 'estimates based on "the observed effect of mitigations and other factors in a given state", daily fatalities calculated based on reported output of cumulative fatalities')
  
    )
  
}

#########################################################################
## Read in Covid Act Now data: Stay at home orders ######################
#########################################################################

for(state in 1:nrow(location_options)){
  
  print(location_options$location_name[state])
  
  data <- rjson::fromJSON(file = paste("https://data.covidactnow.org/latest/us/states/", location_options[state,]$abbreviation, ".STRONG_INTERVENTION.timeseries.json", sep = ""))
  
  date <- c()
  hosp_beds  <- c()
  cumu_deaths <- c()
  loc_counter <- c()
  
  for(i in 1:length(data$timeseries)){
    date <- c(date, data$timeseries[[i]]$date)
    hosp_beds <- c(hosp_beds, as.numeric(as.character(data$timeseries[[i]]$hospitalBedsRequired)))
    cumu_deaths <- c(cumu_deaths, as.numeric(as.character(data$timeseries[[i]]$cumulativeDeaths)))
    loc_counter <- c(loc_counter, location_options$location_name[state])
    
  }
  
  additional_outputs <- rbind.data.frame(
    
    additional_outputs,
    
    cbind.data.frame(
      "model_run_id" = run_id_strong,
      "output_id" = 5,
      "output_name" = "Hospital beds needed per day",
      "date" =  date,
      "location" =  loc_counter,
      "value_type" = "point estimate",
      "value" = hosp_beds,
      "notes" = 'assuming "strong intervention" (stay at home orders)'),
    
    cbind.data.frame(
      "model_run_id" = run_id_strong,
      "output_id" = 4,
      "output_name" = "Cumulative fatalities",
      "date" =  date,
      "location" =  loc_counter,
      "value_type" = "point estimate",
      "value" = cumu_deaths,
      "notes" = 'assuming "strong intervention" (stay at home orders)'),
    
    cbind.data.frame(
      "model_run_id" = run_id_strong,
      "output_id" = 3,
      "output_name" = "Fatalities per day",
      "date" =  date,
      "location" =  loc_counter,
      "value_type" = "point estimate",
      "value" = undoCumSum(cumu_deaths),
      "notes" = 'assuming "strong intervention" (stay at home orders), daily fatalities calculated based on reported output of cumulative fatalities')
    
    
  )
  
}

#########################################################################
## Read in Covid Act Now data: Social distancing ########################
#########################################################################

for(state in 1:nrow(location_options)){
  
  print(location_options$location_name[state])
  
  data <- rjson::fromJSON(file = paste("https://data.covidactnow.org/latest/us/states/", location_options[state,]$abbreviation, ".WEAK_INTERVENTION.timeseries.json", sep = ""))
  
  date <- c()
  hosp_beds  <- c()
  cumu_deaths <- c()
  loc_counter <- c()
  
  for(i in 1:length(data$timeseries)){
    date <- c(date, data$timeseries[[i]]$date)
    hosp_beds <- c(hosp_beds, as.numeric(as.character(data$timeseries[[i]]$hospitalBedsRequired)))
    cumu_deaths <- c(cumu_deaths, as.numeric(as.character(data$timeseries[[i]]$cumulativeDeaths)))
    loc_counter <- c(loc_counter, location_options$location_name[state])
    
  }
  
  additional_outputs <- rbind.data.frame(
    
    additional_outputs,
    
    cbind.data.frame(
      "model_run_id" = run_id_weak,
      "output_id" = 5,
      "output_name" = "Hospital beds needed per day",
      "date" =  date,
      "location" =  loc_counter,
      "value_type" = "point estimate",
      "value" = hosp_beds,
      "notes" = 'assuming "weak intervention" (social distancing, no stay at home orders)'),
    
    cbind.data.frame(
      "model_run_id" = run_id_weak,
      "output_id" = 4,
      "output_name" = "Cumulative fatalities",
      "date" =  date,
      "location" =  loc_counter,
      "value_type" = "point estimate",
      "value" = cumu_deaths,
      "notes" = 'assuming "weak intervention" (social distancing, no stay at home orders)'),
    
    cbind.data.frame(
      "model_run_id" = run_id_weak,
      "output_id" = 3,
      "output_name" = "Fatalities per day",
      "date" =  date,
      "location" =  loc_counter,
      "value_type" = "point estimate",
      "value" = undoCumSum(cumu_deaths),
      "notes" = 'assuming "weak intervention" (social distancing, no stay at home orders), daily fatalities calculated based on reported output of cumulative fatalities"')
    
    
  )
  
}

#################################################################
## Do some processing ###########################################
#################################################################

## drop first row with nulls
additional_outputs <- additional_outputs[-1,]

## save data as backup
write.csv(additional_outputs, file = paste("/Users/seaneff/Documents/covid-ensemble/model_runs/6_covidactnow/model_export/", run_id_observed, "_projections.csv", sep = ""))

## format dates as dates
additional_outputs$date <- as.Date(additional_outputs$date)

## drop all dates before May 25th (as of June 1st)
additional_outputs <- additional_outputs[which(additional_outputs$date >= as.Date("2020-05-25")),]

#################################################################
## Run some sanity checks #######################################
#################################################################

## sanity checks
table(additional_outputs$model_run_id, additional_outputs$output_name)

ggplot(additional_outputs[which(additional_outputs$location == "Ohio" & additional_outputs$output_name == "Hospital beds needed per day"),],
               aes(x = date, y = value, group = model_run_id)) +
     geom_line(size = 1) +
     scale_y_continuous(label = comma) +
     xlab("") +
     theme_light()

ggplot(additional_outputs[which(additional_outputs$location == "Georgia" & additional_outputs$output_name == "Fatalities per day"),],
       aes(x = date, y = value, group = model_run_id)) +
  geom_line(size = 1) +
  scale_y_continuous(label = comma) +
  xlab("") +
  theme_light()

ggplot(additional_outputs[which(additional_outputs$location == "California" & additional_outputs$output_name == "Fatalities per day"),],
       aes(x = date, y = value, color = factor(model_run_id))) +
  geom_line(size = 1) +
  scale_y_continuous(label = comma) +
  xlab("") +
  theme_light()

#################################################################
## Save model_outputs as .RDS file ##############################
#################################################################

model_outputs <- rbind.data.frame(model_outputs, additional_outputs)

saveRDS(model_outputs, file = 'data/model_outputs.RDS', compress = TRUE)
