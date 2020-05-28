# ###########################################################################################
# ## Pre-process outputs (prior to loading shiny) ###########################################
# ###########################################################################################
# 
# ######################################################################
# ## Load required libraries ###########################################
# ######################################################################
# 
# library(dplyr)
# 
# ######################################################################
# ## Read in data ######################################################
# ######################################################################
# 
# ## read in full list  of model outputs, model runs, and locations
# model_outputs <- readRDS("data/model_outputs.RDS")
# models <- read.delim("data/models.txt", stringsAsFactors = FALSE)
# model_runs <- read.delim("data/model_runs.txt", stringsAsFactors = FALSE)
# locations <- read.delim("data/locations.txt", stringsAsFactors = FALSE)
# output_options <- unique(model_outputs$output_name)
# 
# ## locations for which you can view data, grouped separately by countries and US states/territories/intermediate areas
# ## note: intentionally not including county data at this time
# locations_agg <- list("Countries" = sort(locations[which(locations$location_type == "Country" & locations$location_name %in% unique(model_outputs$location)),]$location_name),
#                      "US states, territories, and DC" = sort(locations[which(locations$area_level == "Intermediate" & locations$iso2 == "US" &
#                                                              ## unfortunately data from VI are not reliable now (as of 5/22), so manually exclude and hopefully add back later if and as data become available
#                                                                              locations$location_name != "Virgin Islands" & 
#                                                                              locations$location_name %in% unique(model_outputs$location)),]$location_name))
# 
# outputs_agg <- list("Healthcare demand" = c("Hospital beds needed per day",
#                                            "ICU beds needed per day",
#                                            "Ventilators needed per day"),
#                     "Fatalities" = c("Cumulative fatalities",
#                                      "Fatalities per day"))
# 
# ######################################################################
# ## Calculate derivative datasets, lists, etc  ########################
# ######################################################################
# 
# ## format dates as dates
# model_runs$model_snapshot_date <- as.Date(model_runs$model_snapshot_date, format = "%m/%d/%y")
# 
# ## find the most recent model run for each specified model
# most_recent_model_runs <- model_runs[which(model_runs$compare_across_models == TRUE),] %>%
#   group_by(model_name) %>% 
#   arrange(desc(model_snapshot_date)) %>% 
#   slice(1)
# 
# ## generate master dataset of outputs
# outputs <- merge(model_outputs, model_runs[,-which(names(model_runs) == "notes"),], by = "model_run_id", all.x = TRUE, all.y = FALSE)
# 
# ## format date as a date
# outputs$date <- as.Date(outputs$date)
# 
# ## always round to nearest whole value
# outputs$value <- round(outputs$value)
# 
# ######################################################################
# ## Remove things not required to run the shiny app ###################
# ######################################################################
# 
# rm(model_outputs)
# rm(locations)
# 
# ######################################################################
# ## Save R environment ################################################
# ######################################################################
# 
# save.image(file = "data/preprocessed_data.RData",ascii = FALSE, compress = TRUE, safe = TRUE)

###########################################################################################
## Load pre-processed data (each time shiny is run) #######################################
###########################################################################################

load("data/preprocessed_data.RData")
