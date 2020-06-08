#################################################################
## Specify some initial details #################################
#################################################################

model_run_id_mitigated <- 105

#################################################################
## Load required libraries ######################################
#################################################################

library(rjson)
library(jsonlite)

#################################################################
## Load other datasets ##########################################
#################################################################

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

## GLEAM model ID is always 10, model name is always whatever model_id 10 is named in the file data/models.txt
model_id <- 10
model_name <- models$model_name[which(models$model_id == 10)]

#################################################################
## Format data ##################################################
#################################################################

## treat dates as dates
model_outputs$date <- as.Date(model_outputs$date)

#################################################################
## Hit API for states ###########################################
#################################################################

## as of April 18th:
## example URL: https://data-tracking-api-dot-mobs-2019-ncov-web.appspot.com/data?state=Maine

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
location_options <- gsub(" ", "%20", c(locations[which(locations$location_type == "Province/State" & 
                                                         locations$iso2 == "US" &
                                                         locations$location_name != "District of Columbia" &
                                                         locations$location_name != "Washington" &
                                                         locations$location_name != "New York"
                                                       ),]$location_name,
                                       "Washington State", "New York State"))


for(state in location_options){
  
  print(state)
  
  raw_data <- rjson::fromJSON(file = paste("https://data-tracking-api-dot-mobs-2019-ncov-web.appspot.com/data?state=", state, sep = ""))
  
  date <- c()
  new_deaths_mitigated_scenario <- c()
  total_infections_mitigated_scenario <- c()
  icu_beds <- c()
  hospital_beds <- c()
  
  for(i in 1:length(raw_data)){
    
    ## add new deaths data
    if(!is.null(raw_data[[i]]$`amt_New Deaths|Mitigated`)){
    additional_outputs <- rbind.data.frame(additional_outputs,
                                           cbind.data.frame(
                                             "model_run_id" = model_run_id_mitigated,
                                             "output_id" = 3,
                                             "output_name" = "Fatalities per day",
                                             "date" = raw_data[[i]]$date,
                                             "location" =  state,
                                             "value_type" = "point estimate",
                                             "value" = round(raw_data[[i]]$`amt_New Deaths|Mitigated`),
                                             "notes" = "estimates rounded to nearest whole number, as displayed on GLEAM site"))
    }
    
    ## add ICU bed requirement data
    if(!is.null(raw_data[[i]]$`amt_ICU beds needed|Mitigated`)){
    additional_outputs <- rbind.data.frame(additional_outputs,
                                           cbind.data.frame(
                                             "model_run_id" = model_run_id_mitigated,
                                             "output_id" = 6,
                                             "output_name" = "ICU beds needed per day",
                                             "date" = raw_data[[i]]$date,
                                             "location" =  state,
                                             "value_type" = "point estimate",
                                             "value" = round(raw_data[[i]]$`amt_ICU beds needed|Mitigated`),
                                             "notes" = "estimates rounded to nearest whole number, as displayed on GLEAM site"))
    }
    
    ## add hospital bed requirement data
    if(!is.null(raw_data[[i]]$`amt_Hospital beds needed|Mitigated`)){
    additional_outputs <- rbind.data.frame(additional_outputs,
                                           cbind.data.frame(
                                             "model_run_id" = model_run_id_mitigated,
                                             "output_id" = 5,
                                             "output_name" = "Hospital beds needed per day",
                                             "date" = raw_data[[i]]$date,
                                             "location" =  state,
                                             "value_type" = "point estimate",
                                             "value" = round(raw_data[[i]]$`amt_Hospital beds needed|Mitigated`),
                                             "notes" = "estimates rounded to nearest whole number, as displayed on GLEAM site"))
    }
                                           
    #total_infections_mitigated_scenario <- c(total_infections_mitigated_scenario, round(raw_data[[i]]$`amt_Total Infectious|Mitigated`))
  }}

#################################################################
## Clean up data ################################################
#################################################################

write.table(additional_outputs, 
            file = paste("/Users/seaneff/Documents/covid-ensemble/model_runs/10_gleam/model_export/", model_run_id_mitigated, "_backup_data.txt", sep = ""),
            quote = FALSE, sep ='\t', row.names = FALSE)

#additional_outputs <- read.delim("model_runs/10_gleam/model_export/46_backup_data.txt", stringsAsFactors = FALSE)

## remove the first row of this, just used for initialization and all it has are missing values
additional_outputs <- additional_outputs[-1,]

## for now focus on data from May 15th and later
additional_outputs$date <- as.Date(additional_outputs$date)
additional_outputs <- additional_outputs[which(additional_outputs$date >= as.Date("2020-05-15")), ]

## add back spaces in state names
additional_outputs$location <- gsub(" State", "", gsub("%20", " ", additional_outputs$location))

## just work with unique data
additional_outputs <- unique(additional_outputs)

#################################################################
## Save model_outputs as .tsv file ##############################
#################################################################

## check data
ggplot(additional_outputs[which(additional_outputs$location == "Oregon" & additional_outputs$output_name == "Hospital beds needed per day"),],
       aes(x = date, y = value)) +
  geom_line(size = 1) +
  scale_y_continuous(label = comma) +
  xlab("") +
  theme_light() 

#################################################################
## Save model_outputs as .tsv file ##############################
#################################################################

new_model_outputs <- rbind.data.frame(model_outputs, additional_outputs)

saveRDS(new_model_outputs, file = 'data/model_outputs.RDS', compress = TRUE)
