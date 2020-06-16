#################################################################
## Specify some initial details #################################
#################################################################

## working directory should be covid-ensemble
model_run_id <- 110
file_location <- "https://raw.githubusercontent.com/confunguido/covid19_ND_forecasting/master/output/2020-06-08-NotreDame-FRED.csv"

#################################################################
## Load datasets and set fixed parameters #######################
#################################################################

## read in new dataset of IHME exported data
nd <- read.csv(file_location, stringsAsFactors = FALSE)

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

## ND  model ID is always 1, model name is always whatever model_id 16 is named in the file data/models.txt
model_id <- 16
model_name <- models$model_name[which(models$model_id == 16)]

model_runs[which(model_runs$model_run_id == model_run_id),]
model_outputs[which(model_outputs$model_run_id == model_run_id),]
model_outputs <- model_outputs[-which(model_outputs$model_run_id == model_run_id),]

#################################################################
## Check: any locations not in the locations file? ##############
#################################################################

all(nd$location_name %in% locations$location_name)

#################################################################
## Format data ##################################################
#################################################################

## for now we're just interested in cumulative deaths
## also limit to the median estimate
nd <- nd[grep("cum death", nd$target),]
nd <- nd[which(nd$quantile == 0.5),]

## set dates as dates
nd$forecast_date <- as.Date(nd$forecast_date)
nd$target_end_date <- as.Date(nd$target_end_date)
model_outputs$date <- as.Date(model_outputs$date)

#################################################################
## Calculate fatalities per day #################################
#################################################################

undoCumSum <- function(x) {
  c(NA, diff(x))
}

## sanity check:
#undoCumSum(cumsum(seq(1:10)))

nd <- nd[order(nd$target_end_date, decreasing = FALSE),]

## exclude the target field (e.g., "5 day ahead cum death")
## and then exclude any duplicate rows of ND
## sometimes forecast for a single location-value-date triplicate is listed with two different targets
nd <- nd[,-which(names(nd) == "target")]
nd <- unique(nd)

nd <- nd %>%
  group_by(location_name, type, quantile) %>%
  mutate(daily_fatalities =  undoCumSum(value))

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
                     "date" = nd$target_end_date,
                     "location" = nd$location_name,
                     "value_type" = "percentile (50)",
                     "value" = nd$value,
                     "notes" = "values reported as is, and not rounded to the nearest fatality")
  )
}

#################################################################
## Add data for output_id 3: Fatalities per day #################
#################################################################

## only add these new data if you're not reading over model_outputs already stored
if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 3])){
  
  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 3,
                     "output_name" = "Fatalities per day",
                     "date" = nd$target_end_date,
                     "location" = nd$location_name,
                     "value_type" = "percentile (50)",
                     "value" = nd$daily_fatalities,
                     "notes" = "values reported as is, and not rounded to the nearest fatality, daily fatalities calculated based on reported values for cumulative fatalities")
  )
}

## get rid of any missing values we might have introduced,
## for example, the first value of the available time series
if(any(is.na(model_outputs$value))){
  model_outputs <- model_outputs[-which(is.na(model_outputs$value)),]
}

#################################################################
## Sanity checks ################################################
#################################################################

## check data
ggplot(model_outputs[which(model_outputs$location == "Ohio" & model_outputs$model_run_id == model_run_id & model_outputs$output_name == "Cumulative fatalities"),],
       aes(x = date, y = value)) +
  geom_line(size = 1) +
  scale_y_continuous(label = comma) +
  xlab("") +
  theme_light() 

## check data
ggplot(model_outputs[which(model_outputs$location == "Ohio" & model_outputs$model_run_id == model_run_id & model_outputs$output_name == "Fatalities per day"),],
       aes(x = date, y = value)) +
  geom_line(size = 1) +
  scale_y_continuous(label = comma) +
  xlab("") +
  theme_light() 

#################################################################
## Save model_outputs as .RDS file ##############################
#################################################################

saveRDS(model_outputs, file = 'data/model_outputs.RDS', compress = TRUE)

