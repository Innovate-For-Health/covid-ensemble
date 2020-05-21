#################################################################
## Specify some initial details #################################
#################################################################

model_run_id <- 61
file_name_cases <- "model_runs/14_delphi/model_export/61_covid_analytics_projections.csv"

#################################################################
## Load datasets and set fixed parameters #######################
#################################################################

## read in data
delphi <- read.csv(file_name_cases, stringsAsFactors = FALSE)

## read in models (file that tracks all models)
models <- read.delim("data/models.txt", stringsAsFactors = FALSE)

## read in model_runs (file that tracks model runs)
model_runs <- read.delim("data/model_runs.txt", stringsAsFactors = FALSE)

## read in model_outputs (file that tracks model outputs)
model_outputs <- readRDS("data/model_outputs.RDS")

## read in outputs (file that uniquely identifies each distinct output tracked across models)
outputs <- read.delim("data/outputs.txt", stringsAsFactors = FALSE)

## read in dataset of locations
locations <- read.delim("data/locations.txt", stringsAsFactors = FALSE)

## DEPHI model ID is always 14, model name is always whatever model_id 14 is named in the file data/models.txt
model_id <- 14
model_name <- models$model_name[which(models$model_id == 14)]

#################################################################
## Check: any locations not in the locations file? ##############
#################################################################

all(delphi$Country %in% locations$location_name)
delphi$Country[which(delphi$Country == "US")] <- "United States of America"
delphi$Country[which(delphi$Country == "Korea, South")] <- "South Korea"
delphi$Country[which(delphi$Country == "Congo (Brazzaville)")] <- "Brazzaville"
delphi$Country[which(delphi$Country == "Congo (Kinshasa)")] <- "Kinshasa"
delphi$Country[which(delphi$Country == "Georgia")] <- "Georgia (country)"

## the "Nones" are continents
unique(delphi$Country[-which(delphi$Country %in% locations$location_name)])

## just look at locations already specified in locations.txt
delphi <- delphi[which(delphi$Country %in% locations$location_name),]

## for everywhere but the US, just look at country-level data
## within the US, also look at state-level data
dephi <- delphi[which(delphi$Province == "None" | delphi$Country == "United States of America"),]
delphi$location <- ifelse((delphi$Country == "United States of America" & delphi$Province != "None"), 
                          delphi$Province,
                          delphi$Country)
                          
#################################################################
## Format data ##################################################
#################################################################

## set date as a date
delphi$Day <- as.Date(delphi$Day)
model_outputs$date <- as.Date(model_outputs$date)

#################################################################
## Add data for output_id 7:  Ventilators needed per day ########
#################################################################

## only add these new data if you're not reading over model_outputs already stored
if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 7])){
  
  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 7,
                     "output_name" = "Ventilators needed per day",
                     "date" = delphi$Day,
                     "location" = delphi$location,
                     "value_type" = "point estimate",
                     "value" = delphi$Active.Ventilated,
                     "notes" = "Active.Ventilated from DELPHI data export")
  )
}

#################################################################
## Add data for output_id 5:  Hospital beds needed per day ######
#################################################################

## only add these new data if you're not reading over model_outputs already stored
if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 5])){
  
  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 5,
                     "output_name" = "Hospital beds needed per day",
                     "date" = delphi$Day,
                     "location" = delphi$location,
                     "value_type" = "point estimate",
                     "value" = delphi$Active.Hospitalized,
                     "notes" = "Active.Hospitalized from DELPHI data export")
  )
}

#################################################################
## Add data for output_id 5:  Hospital beds needed per day ######
#################################################################


## only add these new data if you're not reading over model_outputs already stored
if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 4])){
  
  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 4,
                     "output_name" = "Cumulative fatalities",
                     "date" = delphi$Day,
                     "location" = delphi$location,
                     "value_type" = "point estimate",
                     "value" = delphi$Total.Detected.Deaths,
                     "notes" = "defined as 'detected deaths'")
  )
}


#################################################################
## Run some sanity checks #######################################
#################################################################


ggplot(model_outputs[which(model_outputs$model_run_id == 62 & model_outputs$location == "Georgia" & model_outputs$output_name == "Ventilators needed per day"),],
       aes(x = date, y = value)) +
  geom_line(size = 1) +
  scale_y_continuous(label = comma) +
  xlab("") +
  theme_light() 

ggplot(model_outputs[which(model_outputs$model_run_id == 62 & model_outputs$location == "Georgia" & model_outputs$output_name == "Hospital beds needed per day"),],
               aes(x = date, y = value)) +
     geom_line(size = 1) +
     scale_y_continuous(label = comma) +
     xlab("") +
     theme_light() 

saveRDS(model_outputs, file = 'data/model_outputs.RDS', compress = TRUE) 