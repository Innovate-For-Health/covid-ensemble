#################################################################
## Specify some initial details #################################
#################################################################

model_run_id <- 134

file_name <- "model_runs/14_delphi/model_export/134_covid_analytics_projections.csv"

#################################################################
## Load datasets and set fixed parameters #######################
#################################################################

## assume you're in the covid-ensemble directory
#setwd("~/Documents/covid-ensemble")

## read in data
delphi <- read.csv(file_name, stringsAsFactors = FALSE)

## immediately archive data
write.csv(delphi, file = paste("model_runs/14_delphi/model_export/", model_run_id, "_projections.csv", sep = ""))

## read in models (file that tracks all models)
models <- read.delim("srv/shiny-server/data/models.txt", stringsAsFactors = FALSE)

## read in model_runs (file that tracks model runs)
model_runs <- read.delim("srv/shiny-server/data/model_runs.txt", stringsAsFactors = FALSE)

## read in model_outputs (file that tracks model outputs)
model_outputs <- readRDS("srv/shiny-server/data/model_outputs.RDS")

## read in outputs (file that uniquely identifies each distinct output tracked across models)
outputs <- read.delim("srv/shiny-server/data/outputs.txt", stringsAsFactors = FALSE)

## read in dataset of locations
locations <- read.csv("srv/shiny-server/data/locations.csv", stringsAsFactors = FALSE, encoding = "UTF-8")

## DEPHI model ID is always 14, model name is always whatever model_id 14 is named in the file data/models.txt
model_id <- 14
model_name <- models$model_name[which(models$model_id == 14)]

#################################################################
## Check: any locations not in the locations file? ##############
#################################################################

delphi$Country[which(delphi$Country == "US")] <- "United States of America"
delphi$Country[which(delphi$Country == "Korea, South")] <- "South Korea"
delphi$Country[which(delphi$Country == "Congo (Brazzaville)")] <- "Brazzaville"
delphi$Country[which(delphi$Country == "Congo (Kinshasa)")] <- "Kinshasa"
delphi$Country[which(delphi$Country == "Georgia")] <- "Georgia (country)"

all(delphi$Country %in% locations$location_name)

## the "Nones" are continents
unique(delphi$Country[-which(delphi$Country %in% locations$location_name)])

## just look at locations already specified in locations.txt
delphi <- delphi[which(delphi$Country %in% locations$location_name),]

## for everywhere but the US, just look at country-level data
## within the US, also look at state-level data
delphi <- delphi[which(delphi$Province == "None" | delphi$Country == "United States of America"),]
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
  
  additional_outputs <- cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 7,
                     "output_name" = "Ventilators needed per day",
                     "date" = delphi$Day,
                     "location" = delphi$location,
                     "value_type" = "point estimate",
                     "value" = delphi$Active.Ventilated,
                     "notes" = "Active.Ventilated from DELPHI data export")
}

#################################################################
## Add data for output_id 5:  Hospital beds needed per day ######
#################################################################

## only add these new data if you're not reading over model_outputs already stored
if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 5])){
  
  additional_outputs <- rbind.data.frame(additional_outputs,
                     cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 5,
                     "output_name" = "Hospital beds needed per day",
                     "date" = delphi$Day,
                     "location" = delphi$location,
                     "value_type" = "point estimate",
                     "value" = delphi$Active.Hospitalized,
                     "notes" = "Active.Hospitalized from DELPHI data export"))
}

#################################################################
## Add data for output_id 4: Cululative Fatalities ##############
#################################################################

## only add these new data if you're not reading over model_outputs already stored
if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 4])){
  
  additional_outputs <- rbind.data.frame(additional_outputs,
    cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 4,
                     "output_name" = "Cumulative fatalities",
                     "date" = delphi$Day,
                     "location" = delphi$location,
                     "value_type" = "point estimate",
                     "value" = delphi$Total.Detected.Deaths,
                     "notes" = "defined as 'detected deaths'"))
}

#################################################################
## Add data for output_id 3: Fatalities per day #################
#################################################################

undoCumSum <- function(x) {
  c(NA, diff(x))
}

## sanity check:
#undoCumSum(cumsum(seq(1:10)))
delphi <- delphi[order(delphi$Day, decreasing = FALSE),]

daily_fatalities <- delphi %>%
  group_by(Country, Province) %>%
  mutate(daily_fatalities =  undoCumSum(Total.Detected.Deaths))

## only add these new data if you're not reading over model_outputs already stored
if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 3])){
  
  additional_outputs <- rbind.data.frame(additional_outputs,
                                         cbind.data.frame("model_run_id" = model_run_id,
                                                          "output_id" = 3,
                                                          "output_name" = "Fatalities per day",
                                                          "date" = daily_fatalities$Day,
                                                          "location" = daily_fatalities$location,
                                                          "value_type" = "point estimate",
                                                          "value" = daily_fatalities$daily_fatalities,
                                                          "notes" = "fatalities defined as 'detected deaths', daily fatalities calculated as daily difference between estimates of detected deaths"))
}

#################################################################
## Run some sanity checks #######################################
#################################################################

## max should be four
max(table(additional_outputs$location, additional_outputs$date))

## are any estimates of daily fatalities less than zero?
any(additional_outputs[which(additional_outputs$output_id == 3),]$value < 0, na.rm = TRUE)

ggplot(additional_outputs[which(additional_outputs$location == "California" & additional_outputs$output_name == "Ventilators needed per day"),],
       aes(x = date, y = value)) +
  geom_line(size = 1) +
  scale_y_continuous(label = comma) +
  xlab("") +
  theme_light() 

ggplot(additional_outputs[which(additional_outputs$location == "Brazil" & additional_outputs$output_name == "Fatalities per day"),],
       aes(x = date, y = value)) +
  geom_line(size = 1) +
  scale_y_continuous(label = comma) +
  xlab("") +
  theme_light() 

ggplot(additional_outputs[which(additional_outputs$location == "United States of America" & additional_outputs$output_name == "Fatalities per day"),],
       aes(x = date, y = value)) +
  geom_line(size = 1) +
  scale_y_continuous(label = comma) +
  xlab("") +
  theme_light() 

#################################################################
## Merge with full dataset #######################################
#################################################################

model_outputs <- rbind.data.frame(model_outputs, additional_outputs)

#################################################################
## Save output ##################################################
#################################################################

saveRDS(model_outputs, file = 'srv/shiny-server/data/model_outputs.RDS', compress = TRUE) 
