#################################################################
## Specify some initial details #################################
#################################################################

## working directory should be covid-ensemble
#setwd("~/Documents/covid-ensemble")

model_run_id <- 147
file_location <- "https://raw.githubusercontent.com/reichlab/covid19-forecast-hub/master/data-processed/Auquan-SEIR/2020-06-28-Auquan-SEIR.csv"

#################################################################
## Load required libraries ######################################
#################################################################

library(ggplot2)
library(scales)
library(dplyr)

#################################################################
## Load other datasets and set fixed parameters #################
#################################################################

## read in models (file that tracks all models)
models <- read.delim("srv/shiny-server/data/models.txt", stringsAsFactors = FALSE)

## read in model_runs (file that tracks model runs)
model_runs <- read.delim("srv/shiny-server/data/model_runs.txt", stringsAsFactors = FALSE)

## read in model_outputs (saved as RDS due to large file size)
model_outputs <- readRDS("srv/shiny-server/data/model_outputs.RDS")

## read in outputs (file that uniquely identifies each distinct output tracked across models)
outputs <- read.delim("srv/shiny-server/data/outputs.txt", stringsAsFactors = FALSE)

## read in dataset of locations
locations <- read.csv("srv/shiny-server/data/locations.csv", stringsAsFactors = FALSE, encoding = "UTF-8")

aq <- read.csv(file_location)

## This model ID is always 19, model name is always whatever model_id 19 is named in the file data/models.txt
model_id <- 19
model_name <- models$model_name[which(models$model_id == 19)]

undoCumSum <- function(x) {
  c(NA, diff(x))
}

#################################################################
## Process data #################################################
#################################################################

# reminder from documentation that location is 
#"a two-digit number representing the US state, territory, or district fips numeric code"

## get rid of leading zeros before FIPS codes
## NAs introduced by coercion warning is fine here
if(any(aq$location == "US")){
  aq$location <- ifelse(aq$location == "US", "United States of America", as.numeric(as.character(aq$location)))
}

## for now only include rows of the data that have known locations in the locations.csv file
aqu <- merge(aq, locations[which(locations$area_level %in% c("Intermediate", "Country")),], 
             by.x = "location", by.y = "FIPS", 
             all.x = TRUE, all.y = FALSE)

aqu$location_name[which(aqu$location == "United States of America")] <- "United States of America"

## just look at point estimates
aqu <- aqu[which(aqu$type == "point"),]

additional_outputs <- cbind.data.frame(
  "model_run_id" = model_run_id,
  "output_id" = 4,
  "output_name" = "Cumulative fatalities",
  "date" = aqu$target_end_date,
  "location" =  aqu$location_name,
  "value_type" = "point estimate",
  "value" = aqu$value,
  "notes" = "")

aqu <- aqu[order(aqu$target_end_date, decreasing = FALSE),]

## sometimes two identical rows exist for the same target (e.g., 3 weeks vs 21 days)
## so deal with that now before it misses up daily fatality calculations
aqu <- aqu[,-which(names(aqu) == "target"),]
aqu <- unique(aqu)

aqu_daily <- aqu %>%
  group_by(location_name) %>%
  mutate(daily_fatalities =  undoCumSum(value))

aqu_daily <- aqu_daily[-which(is.na(aqu_daily$daily_fatalities)),]

## sanity check
plot(aqu_daily$daily_fatalities)

additional_outputs <- rbind.data.frame(additional_outputs,
  cbind.data.frame(
  "model_run_id" = model_run_id,
  "output_id" = 3,
  "output_name" = "Fatalities per day",
  "date" = aqu_daily$target_end_date,
  "location" =  aqu_daily$location_name,
  "value_type" = "point estimate",
  "value" = aqu_daily$daily_fatalities,
  "notes" = "daily fatalities calculated based on reported values for cumulative fatalities"))

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

table(additional_outputs$output_id, additional_outputs$output_name)

## check data
ggplot(additional_outputs[which(additional_outputs$location == "California" & additional_outputs$output_id == 3),],
       aes(x = date, y = value)) +
  geom_line(size = 1) +
  scale_y_continuous(label = comma) +
  xlab("") +
  theme_light() 

## check data
ggplot(additional_outputs[which(additional_outputs$location == "California" & additional_outputs$output_id == 4),],
       aes(x = date, y = value)) +
  geom_line(size = 1) +
  scale_y_continuous(label = comma) +
  xlab("") +
  theme_light() 

## check data
ggplot(additional_outputs[which(additional_outputs$location == "New Mexico" & additional_outputs$output_id == 4),],
       aes(x = date, y = value)) +
  geom_line(size = 1) +
  scale_y_continuous(label = comma) +
  xlab("") +
  theme_light() 

## check data
ggplot(additional_outputs[which(additional_outputs$location == "New Mexico" & additional_outputs$output_id == 3),],
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

