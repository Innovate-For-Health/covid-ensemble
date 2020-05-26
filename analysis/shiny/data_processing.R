######################################################################
## Read in data ######################################################
######################################################################

## read in full list  of model outputs, model runs, and locations
model_outputs <- readRDS(here("data", "model_outputs.RDS"))
models <- read.delim(here("data", "models.txt"), stringsAsFactors = FALSE)
model_runs <- read.delim(here("data", "model_runs.txt"), stringsAsFactors = FALSE)
locations <- read.delim(here("data", "locations.txt"), stringsAsFactors = FALSE)
output_options <- unique(model_outputs$output_name)

## locations for which you can view data, grouped separately by countries and US states/territories/intermediate areas
## note: intentionally not including county data at this time
locations_agg <- list("Countries" = sort(locations[which(locations$location_type == "Country" & locations$location_name %in% unique(model_outputs$location)),]$location_name),
                     "US states, territories, and DC" = sort(locations[which(locations$area_level == "Intermediate" & locations$iso2 == "US" &
                                                             ## unfortunately data from VI are not reliable now (as of 5/22), so manually exclude and hopefully add back later if and as data become available
                                                                             locations$location_name != "Virgin Islands" & 
                                                                             locations$location_name %in% unique(model_outputs$location)),]$location_name))

outputs_agg <- list("Healthcare demand" = c("Hospital beds needed per day",
                                           "ICU beds needed per day",
                                           "Ventilators needed per day"),
                    "Fatalities" = c("Fatalities per day",
                                    "Cumulative fatalities"))

####################################################################################
## Process cumulative fatality estimates to also estimate fatalities per day #######
####################################################################################
# 
# undoCumSum <- function(x) {
#   c(NA, diff(x))
# }
# ## sanity check:
# #undoCumSum(cumsum(seq(1:10)))
# 
# ## exclude IHME and GLEAM data because they report daily fatalities directly
# model_outputs_cumfatal <- model_outputs[which(model_outputs$output_name == "Cumulative fatalities" & !model_outputs$model_run_id %in% model_runs$model_run_id[which(model_runs$model_id %in% c(1, 10))]),]
# model_outputs_cumfatal <- model_outputs[which(model_outputs$output_name == "Cumulative fatalities" & !model_outputs$model_run_id %in% model_runs$model_run_id[which(model_runs$model_id %in% c(1, 10))]),]
# 
# model_outputs_cumfatal <- model_outputs_cumfatal[order(model_outputs_cumfatal$date, decreasing = FALSE),]
# 
# model_outputs_cumfatal <- model_outputs_cumfatal %>%
#   group_by(model_run_id, output_id, output_name, location, value_type) %>%
#   mutate(daily_fatalities =  undoCumSum(value))
# 
# ## pause here -- some models do weird things to estimate cumulative fatalities
# ## and intentionally don't report fatalities per day
# ## in some cases, cumulative fatalities aren't monotonically increasing, which is nonsensical with the exception
# ## of maybe assuming case definitions or reporting has changed, essentially, data/surveillance artificts
# ## to deal with this for now, don't calculate fatalities per day for any model_run_ids that ever shows such a decrease
# exclude <- model_outputs_cumfatal[which(model_outputs_cumfatal$daily_fatalities < 0),]$model_run_id
# model_outputs_cumfatal <- model_outputs_cumfatal[-which(model_outputs_cumfatal$model_run_id %in% exclude),]
# 
# model_outputs <- rbind.data.frame(model_outputs,
#                                   cbind.data.frame(
#                                     model_run_id = model_outputs_cumfatal$model_run_id,
#                                     output_id = model_outputs_cumfatal$output_id,
#                                     output_name = "Fatalities per day",
#                                     date = model_outputs_cumfatal$date,
#                                     location = model_outputs_cumfatal$location,
#                                     value_type = model_outputs_cumfatal$value_type,
#                                     value = model_outputs_cumfatal$daily_fatalities,
#                                     notes = "calculated based on reported estimates of cumulative fatalities"))

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



