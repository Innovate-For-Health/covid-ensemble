######################################################################
## Read in data ######################################################
######################################################################

## read in full list  of model outputs, model runs, and locations
model_outputs <- read.delim("~/Documents/covid-ensemble/data/model_outputs.txt", stringsAsFactors = FALSE)
models <- read.delim("~/Documents/covid-ensemble/data/models.txt", stringsAsFactors = FALSE)
model_runs <- read.delim("~/Documents/covid-ensemble/data/model_runs.txt", stringsAsFactors = FALSE)
locations <- read.delim("~/Documents/covid-ensemble/data/locations.txt", stringsAsFactors = FALSE)
output_options <- unique(model_outputs$output_name)
## exclude GLEAM for now as there's only one set of results
model_options <- unique(model_outputs$output_name)[-which(unique(model_outputs$output_name) == "GLEAM")]

locations_agg <- list("Countries" = sort(locations[which(locations$location_type == "Country" & locations$location_name %in% unique(model_outputs$location)),]$location_name),
                     "US states, territories, and DC" = sort(locations[which(locations$area_level == "Intermediate" & locations$iso2 == "US" &
                                                             ## unfortunately data from VI are not reliable now, so manually exclude and hopefully add back later if and as data become available
                                                                             locations$location_name != "Virgin Islands" & 
                                                                             locations$location_name %in% unique(model_outputs$location)),]$location_name))

outputs_agg <- list("Caseload and fatalities" = c("New confirmed cases per day",
                                                 "Cumulative fatalities"),
                   "Healthcare demand" = c("Hospital beds needed per day",
                                           "ICU beds needed per day",
                                           "Ventilators needed per day"))


######################################################################
## Calculate derivative datasets, lists, etc  ########################
######################################################################

## format dates as dates
model_runs$model_snapshot_date <- as.Date(model_runs$model_snapshot_date, format = "%m/%d/%y")

## find the most recent model run for each specified model
most_recent_model_runs <- model_runs[which(model_runs$compare_across_models == TRUE),] %>%
  group_by(model_name) %>% 
  arrange(desc(model_snapshot_date)) %>% 
  slice(1)

## generate master dataset of outputs
outputs <- merge(model_outputs, model_runs[,-which(names(model_runs) == "notes"),], by = "model_run_id", all.x = TRUE, all.y = FALSE)

## format date as a date
outputs$date <- as.Date(outputs$date)

## always round to nearest whole value
outputs$value <- round(outputs$value)



