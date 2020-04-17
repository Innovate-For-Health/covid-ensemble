#################################################################
## Specify some initial details #################################
#################################################################

run_id_strict <- 11
run_id_lax <- 16

#################################################################
## Load required libraries ######################################
#################################################################

library(rjson)

#################################################################
## Load datasets other than Covid Act Now data ##################
#################################################################

## read in models (file that tracks all models)
models <- read.delim("data/models.txt", stringsAsFactors = FALSE)

## read in model_runs (file that tracks model runs)
model_runs <- read.delim("data/model_runs.txt", stringsAsFactors = FALSE)

## read in model_outputs (file that tracks model outputs)
model_outputs <- read.delim("data/model_outputs.txt", stringsAsFactors = FALSE)

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

#################################################################
## Read in Covid Act Now data: Strict model ####################
#################################################################

## note: as of April 10th, file .1 json corresponds to the strict model and file .3 json corresponds to the lax model
## this needs to be double checked every time the code is run, in case they change something (documentation not clear)

## as of April 10th:
## this is the 3 month strict stay at home model (strict): "https://covidactnow.org/data/CA.1.json"
## this is the 3 month stay at home model (lax): "https://covidactnow.org/data/CA.3.json")

## as of April 16th: projected based on current trends
## this is the 3 month strict stay at home model (strict): "https://covidactnow.org/data/CA.2.json"

additional_outputs <- cbind.data.frame(
  "model_run_id" = NA,
  "output_id" = NA,
  "output_name" = NA,
  "date" =  NA,
  "location" =  NA,
  "value" = NA,
  "notes" = NA)

for(state in 1:nrow(locations[which(complete.cases(locations$FIPS)),])){
  
  print(locations[which(complete.cases(locations$FIPS)),]$location_name[state])
  
  strict <- fromJSON(file = paste("https://covidactnow.org/data/", locations[which(complete.cases(locations$FIPS)),][state,]$abbreviation, ".2.json", sep = ""))
  
  date_strict <- c()
  hosp_strict <- c()
  
  for(i in 1:length(strict)){
    date_strict <- c(date_strict, unlist(strict[[i]][2]))
    hosp_strict <- c(hosp_strict, as.numeric(unlist(strict[[i]][10])))
  }
  
  
  additional_outputs <- rbind.data.frame(additional_outputs,
    cbind.data.frame(
    "model_run_id" = run_id_strict,
    "output_id" = 5,
    "output_name" = "Hospital beds needed per day",
    "date" = date_strict,
    "location" =  locations[which(complete.cases(locations$FIPS)),]$location_name[state],
    "value" = hosp_strict,
    "notes" = "model described on site as 'projected based on current trends'")
  )
  
}

#################################################################
## Read in Covid Act Now data: Lax model ########################
#################################################################

## note: as of April 10th, file .1 json corresponds to the strict model and file .3 json corresponds to the lax model
## this needs to be double checked every time the code is run, in case they change something (documentation not clear)

for(state in 1:nrow(locations[which(locations$iso3 == "USA" & locations$location_type == "Province/State"),])){
  
  print(locations[which(locations$iso3 == "USA" & locations$location_type == "Province/State"),]$location_name[state])
  
  lax <- fromJSON(file = paste("https://covidactnow.org/data/", locations[which(locations$iso3 == "USA" & locations$location_type == "Province/State"),][state,]$abbreviation, ".3.json", sep = ""))
  
  date_lax <- c()
  hosp_lax <- c()
  
  for(i in 1:length(lax)){
    date_lax <- c(date_lax, unlist(lax[[i]][2]))
    hosp_lax <- c(hosp_lax, as.numeric(unlist(lax[[i]][10])))
  }
  
  
  additional_outputs <- rbind.data.frame(additional_outputs,
                                         cbind.data.frame(
                                           "model_run_id" = run_id_lax,
                                           "output_id" = 5,
                                           "output_name" = "Hospital beds needed per day",
                                           "date" = date_lax,
                                           "location" =  locations[which(complete.cases(locations$FIPS)),]$location_name[state],
                                           "value" = hosp_lax,
                                           "notes" = "assumed lifted restrictions")
  )
  
}


#################################################################
## Save model_outputs as .tsv file ##############################
#################################################################

## remove the first row of this, just used for initialization and all it has are missing values
additional_outputs <- additional_outputs[-1,]
additional_outputs$date <- as.Date(additional_outputs$date, format = "%m/%d/%y")


## check data
ggplot(additional_outputs[which(additional_outputs$location == "California"),],
       aes(x = date, y = value)) +
  geom_line(size = 1) +
  scale_y_continuous(label = comma) +
  xlab("") +
  theme_light() 

## calculate totals for whole US as sum across states and DC
us_totals <- additional_outputs %>%
  group_by(model_run_id, output_id, output_name, date) %>%
  summarise(value = sum(value))

## check data
ggplot(us_totals,
       aes(x = date, y = value)) +
  geom_line(size = 1) +
  scale_y_continuous(label = comma) +
  xlab("") +
  theme_light()

#################################################################
## Save model_outputs as .tsv file ##############################
#################################################################

model_outputs <- rbind.data.frame(model_outputs,
                                  additional_outputs)


new_model_outputs <- rbind.data.frame(model_outputs,
                                  additional_outputs,
                                  cbind.data.frame(model_run_id = us_totals$model_run_id,
                                                   output_id = us_totals$output_id,
                                                   output_name = us_totals$output_name,
                                                   date = us_totals$date,
                                                   location = "United States of America",
                                                   value = us_totals$value,
                                                   notes = "US total bed count calculated as sum across states and DC"))

write.table(model_outputs, file = 'data/model_outputs.txt', quote = FALSE, sep='\t', row.names = FALSE)
