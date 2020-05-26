#################################################################
## Specify some initial details #################################
#################################################################

model_run_id <- 87
file_name_cases_us <- "model_runs/13_lanl/model_export/87_2020-05-24_confirmed_quantiles_us_website.csv"
file_name_deaths_us <- "model_runs/13_lanl/model_export/87_2020-05-24_deaths_quantiles_us_website.csv"
file_name_cases_global <- "model_runs/13_lanl/model_export/87_2020-05-24_confirmed_quantiles_global_website.csv"
file_name_deaths_global <- "model_runs/13_lanl/model_export/87_2020-05-24_deaths_quantiles_global_website.csv"

#################################################################
## Load datasets and set fixed parameters #######################
#################################################################

## read in lanl data
lanl_cases <- read.csv(file_name_cases_us, stringsAsFactors = FALSE)
lanl_cases_global <- read.csv(file_name_cases_global, stringsAsFactors = FALSE)

lanl_deaths <- read.csv(file_name_deaths_us, stringsAsFactors = FALSE)
lanl_deaths_global <- read.csv(file_name_deaths_global, stringsAsFactors = FALSE)

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

## LANL model ID is always 13, model name is always whatever model_id 13 is named in the file data/models.txt
model_id <- 13
model_name <- models$model_name[which(models$model_id == 13)]

#################################################################
## Check: any locations not in the locations file? ##############
#################################################################

if(any(lanl_deaths_global$countries == "US")){
  lanl_deaths_global$countries[which(lanl_deaths_global$countries == "US")] <- "United States of America"
}

if(any(lanl_cases_global$countries == "US")){
  lanl_cases_global$countries[which(lanl_cases_global$countries == "US")] <- "United States of America"
}

all(lanl_cases$state %in% locations$location_name)
all(lanl_deaths$state %in% locations$location_name)
all(lanl_deaths_global$countries %in% locations$location_name)
all(lanl_cases_global$countries %in% locations$location_name)

#unique(lanl_deaths_global$countries[-which(lanl_deaths_global$countries %in% locations$location_name)])

#################################################################
## Format data ##################################################
#################################################################

## set date as a date
lanl_cases$dates <- as.Date(lanl_cases$dates)
lanl_deaths$dates <- as.Date(lanl_deaths$dates)
lanl_cases_global$dates <- as.Date(lanl_cases_global$dates)
lanl_deaths_global$dates <- as.Date(lanl_deaths_global$dates)
model_outputs$date <- as.Date(model_outputs$date)

## to minimize size of data file, now focus on dates after May 1, 2020 
## this change added as of May 26, 2020
lanl_cases <- lanl_cases[which(lanl_cases$dates >= as.Date("2020-05-01")),]
lanl_cases_global <- lanl_cases_global[which(lanl_cases_global$dates >= as.Date("2020-05-01")),]
lanl_deaths <- lanl_deaths[which(lanl_deaths$dates >= as.Date("2020-05-01")),]
lanl_deaths_global <- lanl_deaths_global[which(lanl_deaths_global$dates >= as.Date("2020-05-01")),]

##########################################################################
## Add data for output_id 3:  Cumulative fatalities: US data #############
##########################################################################

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

##########################################################################
## Add data for output_id 3:  Cumulative fatalities: Global data #########
##########################################################################

## only add these new data if you're not reading over model_outputs already stored
if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 3])){

  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 4,
                     "output_name" = "Cumulative fatalities",
                     "date" = lanl_deaths_global$dates,
                     "location" = lanl_deaths_global$countries,
                     "value_type" = "percentile (50)",
                     "value" = lanl_deaths_global$q.50,
                     "notes" = "50th percentile produced across model runs")
  )
}

# ##########################################################################
# ## Add data for output_id 3:  New confirmed cases per day: US Data #######
# ##########################################################################
# 
# undoCumSum <- function(x) {
#   c(NA, diff(x))
# }
# ## sanity check:
# #undoCumSum(cumsum(seq(1:10)))
# 
# lanl_cases <- lanl_cases[order(lanl_cases$dates, decreasing = FALSE),]
# 
# lanl_cases <- lanl_cases %>%
#   group_by(state) %>%
#   mutate(daily_new_cases =  undoCumSum(q.50))
# 
# ## only add these new data if you're not reading over model_outputs already stored
# if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 11])){
#   
#   model_outputs <- rbind.data.frame(
#     model_outputs,
#     cbind.data.frame("model_run_id" = model_run_id,
#                      "output_id" = 11,
#                      "output_name" = "New confirmed cases per day",
#                      "date" = lanl_cases$dates,
#                      "location" = lanl_cases$state,
#                      "value_type" = "percentile (50)",
#                      "value" = round(lanl_cases$daily_new_cases),
#                      "notes" = "50th percentile produced across model runs, rounded to nearest whole number")
#   )
# 
#   
# }
# 
# ##############################################################################
# ## Add data for output_id 3:  New confirmed cases per day: Global Data #######
# ##############################################################################
# 
# lanl_cases_global <- lanl_cases_global[order(lanl_cases_global$dates, decreasing = FALSE),]
# 
# lanl_cases_global <- lanl_cases_global %>%
#   group_by(countries) %>%
#   mutate(daily_new_cases =  undoCumSum(q.50))
# 
# ## only add these new data if you're not reading over model_outputs already stored
# if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 11])){
#   
#   model_outputs <- rbind.data.frame(
#     model_outputs,
#     cbind.data.frame("model_run_id" = model_run_id,
#                      "output_id" = 11,
#                      "output_name" = "New confirmed cases per day",
#                      "date" = lanl_cases_global$dates,
#                      "location" = lanl_cases_global$countries,
#                      "value_type" = "percentile (50)",
#                      "value" = round(lanl_cases_global$daily_new_cases),
#                      "notes" = "50th percentile produced across model runs, rounded to nearest whole number")
#   )
#   
#   
# }

#################################################################
## Save model_outputs as .RDS file ##############################
#################################################################

#saveRDS(model_outputs, file = 'data/model_outputs.RDS', compress = TRUE) 


