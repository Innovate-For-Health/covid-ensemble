#################################################################
## Specify some initial details #################################
#################################################################

model_run_id <- 18
file_name_cases <- "model_runs/13_lanl/model_export/18_2020-04-15_confirmed_quantiles_us.csv"
file_name_deaths <- "model_runs/13_lanl/model_export/18_2020-04-15_deaths_quantiles_us.csv"

#################################################################
## Load datasets and set fixed parameters #######################
#################################################################

## read in lanl data
lanl_cases <- read.csv(file_name_cases, stringsAsFactors = FALSE)
lanl_deaths <- read.csv(file_name_deaths, stringsAsFactors = FALSE)

## read in models (file that tracks all models)
models <- read.delim("data/models.txt", stringsAsFactors = FALSE)

## read in model_runs (file that tracks model runs)
model_runs <- read.delim("data/model_runs.txt", stringsAsFactors = FALSE)

## read in model_outputs (file that tracks model outputs)
model_outputs <- read.delim("data/model_outputs.txt", stringsAsFactors = FALSE)

## read in outputs (file that uniquely identifies each distinct output tracked across models)
outputs <- read.delim("data/outputs.txt", stringsAsFactors = FALSE)

## read in dataset of locations
locations <- read.delim("data/locations.txt", stringsAsFactors = FALSE)

## LANL model ID is always 13, model name is always whatever model_id 13 is named in the file data/models.txt
model_id <- 13
model_name <- models$model_name[which(models$model_id == 13)]

#################################################################
## Check: any locations not in the locations file? ##############
#################################################################

all(lanl_cases$state %in% locations$location_name)

#################################################################
## Format data ##################################################
#################################################################

## set date as a date
lanl_cases$dates <- as.Date(lanl_cases$dates)
lanl_deaths$dates <- as.Date(lanl_deaths$dates)
model_outputs$date <- as.Date(model_outputs$date, format = "%m/%d/%y")

#################################################################
## Add data for output_id 3:  Fatalities per day ################
#################################################################

## only add these new data if you're not reading over model_outputs already stored
if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 3])){
  
  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 3,
                     "output_name" = "Fatalities per day",
                     "date" = lanl_deaths$dates,
                     "location" = lanl_deaths$state,
                     "value_type" = "percentile (50)",
                     "value" = lanl_deaths$q.50,
                     "notes" = "50th percentile produced across model runs")
  )
}

#################################################################
## Add data for output_id 4: Cumulative fatalities ##############
#################################################################

## todo: calculate cumulative fatalties per state

## only add these new data if you're not reading over model_outputs already stored
# if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 4])){
#   
#   model_outputs <- rbind.data.frame(
#     model_outputs,
#     cbind.data.frame("model_run_id" = model_run_id,
#                      "output_id" = 4,
#                      "output_name" = "Cumulative fatalities",
#                      "date" = lanl_deaths$dates,
#                      "location" = lanl_deaths$state,
#                      "value_type" = "percentile (50)",
#                      "value" = lanl_deaths$q.50,
#                      "notes" = "50th percentile produced across model runs")
#   )
# }

#################################################################
## Add data for output_id 11: New confirmed cases per day #######
#################################################################

## only add these new data if you're not reading over model_outputs already stored
if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 11])){
  
  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 11,
                     "output_name" = "New confirmed cases per day",
                     "date" = lanl_cases$dates,
                     "location" = lanl_cases$state,
                     "value_type" = "percentile (50)",
                     "value" = lanl_cases$q.50,
                     "notes" = "50th percentile produced across model runs")
  )
}

## TODO: calculate totals across states to generate national estimate

#################################################################
## Save model_outputs as .tsv file ##############################
#################################################################

write.table(model_outputs, file = 'data/model_outputs.txt', quote = FALSE, sep = '\t', row.names = FALSE)


