#################################################################
## Specify some initial details #################################
#################################################################

model_run_id <- 21
file_name_cases <- "model_runs/13_lanl/model_export/21_2020-04-05_confirmed_quantiles_us.csv"
file_name_deaths <- "model_runs/13_lanl/model_export/21_2020-04-05_deaths_quantiles_us.csv"

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
all(lanl_deaths$state %in% locations$location_name)

#################################################################
## Format data ##################################################
#################################################################

## set date as a date
lanl_cases$dates <- as.Date(lanl_cases$dates)
lanl_deaths$dates <- as.Date(lanl_deaths$dates)
model_outputs$date <- as.Date(model_outputs$date)

#################################################################
## Add data for output_id 3:  Cumulative fatalities #############
#################################################################

## only add these new data if you're not reading over model_outputs already stored
if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 3])){
  
  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 4,
                     "output_name" = "Cumulative fatalities",
                     "date" = lanl_deaths$dates,
                     "location" = lanl_deaths$state,
                     "value_type" = "percentile (50)",
                     "value" = lanl_deaths$q.50,
                     "notes" = "50th percentile produced across model runs")
  )
}

#################################################################
## Add data for output_id 3:  New confirmed cases per day #######
#################################################################

undoCumSum <- function(x) {
  c(NA, diff(x))
}
## sanity check:
#undoCumSum(cumsum(seq(1:10)))

lanl_cases <- lanl_cases[order(lanl_cases$dates, decreasing = FALSE),]

lanl_cases <- lanl_cases %>%
  group_by(state) %>%
  mutate(daily_new_cases =  undoCumSum(q.50))

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
                     "value" = lanl_cases$daily_new_cases,
                     "notes" = "50th percentile produced across model runs")
  )
}

#################################################################
## Calculate data for the whole US###############################
#################################################################

## sum across states to get national
national_total_cases <- lanl_cases %>%
  group_by(dates) %>%
  summarise(value = sum(daily_new_cases))

national_total_deaths <- lanl_deaths %>%
  group_by(dates) %>%
  summarise(value = sum(q.50))

## sanity check
plot(national_total_deaths$dates, national_total_deaths$value)

model_outputs <- rbind.data.frame(
  model_outputs,
  cbind.data.frame("model_run_id" = model_run_id,
                   "output_id" = 4,
                   "output_name" = "Cumulative fatalities",
                   "date" = national_total_deaths$dates,
                   "location" = "United States of America",
                   "value_type" = "percentile (50)",
                   "value" = national_total_deaths$value,
                   "notes" = "50th percentile produced across model runs, US totals calculated as sum over US states, DC, Virgin Islands, and Puerto Rico"))

model_outputs <- rbind.data.frame(
  model_outputs,
  cbind.data.frame("model_run_id" = model_run_id,
                   "output_id" = 11,
                   "output_name" = "New confirmed cases per day",
                   "date" = national_total_cases$dates,
                   "location" = "United States of America",
                   "value_type" = "percentile (50)",
                   "value" = national_total_cases$value,
                   "notes" = "50th percentile produced across model runs, US totals calculated as sum over US states, DC, Virgin Islands, and Puerto Rico"))

#################################################################
## Save model_outputs as .tsv file ##############################
#################################################################

write.table(model_outputs, file = 'data/model_outputs.txt', quote = FALSE, sep = '\t', row.names = FALSE)


