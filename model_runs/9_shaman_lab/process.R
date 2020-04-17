#################################################################
## Specify some initial details #################################
#################################################################

model_run_id_no_iv <- 12
model_run_id_20_red <- 13
model_run_id_30_red <- 14
model_run_id_40_red <- 17
file_name_beds_no_iv <- "model_runs/9_shaman_lab/model_export/12_bed_nointerv.csv"
file_name_cases_no_iv <- "model_runs/9_shaman_lab/model_export/12_Projection_nointerv.csv"
file_name_beds_40_red <- "model_runs/9_shaman_lab/model_export/17_bed_60contact.csv"
file_name_cases_40_red <- "model_runs/9_shaman_lab/model_export/17_Projection_60contact.csv"
file_name_beds_20_red <- "model_runs/9_shaman_lab/model_export/13_bed_80contact.csv"
file_name_cases_20_red <- "model_runs/9_shaman_lab/model_export/13_Projection_80contact.csv"
file_name_beds_30_red <- "model_runs/9_shaman_lab/model_export/14_bed_70contact.csv"
file_name_cases_30_red <- "model_runs/9_shaman_lab/model_export/14_Projection_70contact.csv"

#################################################################
## Load datasets and set fixed parameters #######################
#################################################################

## read in new dataset: assuming no intervention ("no iv")
no_iv_beds <- read.csv(file_name_beds_no_iv, stringsAsFactors = FALSE)
no_iv_cases <- read.csv(file_name_cases_no_iv, stringsAsFactors = FALSE)
red40_beds <- read.csv(file_name_beds_40_red, stringsAsFactors = FALSE)
red40_cases <-read.csv(file_name_cases_40_red, stringsAsFactors = FALSE)
red20_beds <- read.csv(file_name_beds_20_red, stringsAsFactors = FALSE)
red20_cases <-read.csv(file_name_cases_20_red, stringsAsFactors = FALSE)
red30_beds <- read.csv(file_name_beds_30_red, stringsAsFactors = FALSE)
red30_cases <-read.csv(file_name_cases_30_red, stringsAsFactors = FALSE)

## read in models (file that tracks all models)
models <- read.delim("data/models.txt", stringsAsFactors = FALSE)

## read in model_runs (file that tracks model runs)
model_runs <- read.delim("data/model_runs.txt", stringsAsFactors = FALSE)

## read in model_outputs (file that tracks model outputs)
model_outputs <- read.delim("data/model_outputs.txt", stringsAsFactors = FALSE)

## read in locations their their fips codes
locations <- read.delim("data/locations.txt", stringsAsFactors = FALSE)

## if any locations have 4 digit FIPS codes, append the 0 needed to the front
if(any(nchar(locations$FIPS) == 4)){
  locations$FIPS[which(nchar(locations$FIPS) == 4)] <- paste("0",  locations$FIPS[which(nchar(locations$FIPS) == 4)], sep = "")
}
if(any(nchar(locations$FIPS) == 1)){
  locations$FIPS[which(nchar(locations$FIPS) == 1)] <- paste("0",  locations$FIPS[which(nchar(locations$FIPS) == 1)], sep = "")
}
## if any locations have 4 digit FIPS codes, append the 0 needed to the front
if(any(nchar(no_iv_beds$fips) == 4)){
  no_iv_beds$fips[which(nchar(no_iv_beds$fips) == 4)] <- paste("0",  no_iv_beds$fips[which(nchar(no_iv_beds$fips) == 4)], sep = "")
}
## if any locations have 4 digit FIPS codes, append the 0 needed to the front
if(any(nchar(no_iv_cases$fips) == 4)){
  no_iv_cases$fips[which(nchar(no_iv_cases$fips) == 4)] <- paste("0",  no_iv_cases$fips[which(nchar(no_iv_cases$fips) == 4)], sep = "")
}
if(any(nchar(red40_beds$fips) == 4)){
  red40_beds$fips[which(nchar(red40_beds$fips) == 4)] <- paste("0",  red40_beds$fips[which(nchar(red40_beds$fips) == 4)], sep = "")
}
## if any locations have 4 digit FIPS codes, append the 0 needed to the front
if(any(nchar(red40_cases$fips) == 4)){
  red40_cases$fips[which(nchar(red40_cases$fips) == 4)] <- paste("0",  red40_cases$fips[which(nchar(red40_cases$fips) == 4)], sep = "")
}
if(any(nchar(red20_beds$fips) == 4)){
  red20_beds$fips[which(nchar(red20_beds$fips) == 4)] <- paste("0",  red20_beds$fips[which(nchar(red20_beds$fips) == 4)], sep = "")
}
## if any locations have 4 digit FIPS codes, append the 0 needed to the front
if(any(nchar(red20_cases$fips) == 4)){
  red20_cases$fips[which(nchar(red20_cases$fips) == 4)] <- paste("0",  red20_cases$fips[which(nchar(red20_cases$fips) == 4)], sep = "")
}
if(any(nchar(red30_beds$fips) == 4)){
  red30_beds$fips[which(nchar(red30_beds$fips) == 4)] <- paste("0",  red30_beds$fips[which(nchar(red30_beds$fips) == 4)], sep = "")
}
## if any locations have 4 digit FIPS codes, append the 0 needed to the front
if(any(nchar(red30_cases$fips) == 4)){
  red30_cases$fips[which(nchar(red30_cases$fips) == 4)] <- paste("0",  red30_cases$fips[which(nchar(red30_cases$fips) == 4)], sep = "")
}

## read in outputs (file that uniquely identifies each distinct output tracked across models)
outputs <- read.delim("data/outputs.txt", stringsAsFactors = FALSE)

## Shaman lab model ID is always 9, model name is always whatever model_id 9 is named in the file data/models.txt
model_id <- 9
model_name <- models$model_name[which(models$model_id == 9)]

#################################################################
## Format data ##################################################
#################################################################

## set date as a date
no_iv_beds$Date <- as.Date(no_iv_beds$Date, format = "%m/%d/%y")
no_iv_cases$Date <- as.Date(no_iv_cases$Date, format = "%m/%d/%y")
red40_beds$Date <- as.Date(red40_beds$Date, format = "%m/%d/%y")
red40_cases$Date <- as.Date(red40_cases$Date, format = "%m/%d/%y")
red20_beds$Date <- as.Date(red20_beds$Date, format = "%m/%d/%y")
red20_cases$Date <- as.Date(red20_cases$Date, format = "%m/%d/%y")
red30_beds$Date <- as.Date(red30_beds$Date, format = "%m/%d/%y")
red30_cases$Date <- as.Date(red30_cases$Date, format = "%m/%d/%y")
model_outputs$date <- as.Date(model_outputs$date)

#################################################################
## Add data for output_id 1: New infections per day #############
#################################################################

new_model_outputs <- cbind.data.frame("model_run_id" = model_run_id_no_iv,
                     "output_id" = 1,
                     "output_name" = "New infections per day",
                     "date" = no_iv_cases$Date,
                     "location" = no_iv_cases$county,
                     "fips" = no_iv_cases$fips,
                     "value" = no_iv_cases$total_50,
                     "notes" = "use median new infections (model calculates percentiles across runs), assume no interventions")

new_model_outputs <- cbind.data.frame("model_run_id" = model_run_id_40_red,
                                      "output_id" = 1,
                                      "output_name" = "New infections per day",
                                      "date" = red40_cases$Date,
                                      "location" = red40_cases$county,
                                      "fips" = red40_cases$fips,
                                      "value" = red40_cases$total_50,
                                      "notes" = "use median new infections (model calculates percentiles across runs), assume 40% reduction in contact rate")

new_model_outputs <- cbind.data.frame("model_run_id" = model_run_id_20_red,
                                      "output_id" = 1,
                                      "output_name" = "New infections per day",
                                      "date" = red20_cases$Date,
                                      "location" = red20_cases$county,
                                      "fips" = red20_cases$fips,
                                      "value" = red20_cases$total_50,
                                      "notes" = "use median new infections (model calculates percentiles across runs), assume 20% reduction in contact rate")

new_model_outputs <- cbind.data.frame("model_run_id" = model_run_id_30_red,
                                      "output_id" = 1,
                                      "output_name" = "New infections per day",
                                      "date" = red30_cases$Date,
                                      "location" = red30_cases$county,
                                      "fips" = red30_cases$fips,
                                      "value" = red30_cases$total_50,
                                      "notes" = "use median new infections (model calculates percentiles across runs), assume 30% reduction in contact rate")


#################################################################
## Add data for output_id 2: Cumulative infections ##############
#################################################################

## TODO: add cumulative infections here

#######################################################################
## Add data for output_id 11: New confirmed cases per day #############
#######################################################################

new_model_outputs <- rbind.data.frame(
    new_model_outputs,
    cbind.data.frame("model_run_id" = model_run_id_no_iv,
         "output_id" = 11,
          "output_name" = "New confirmed cases per day",
          "date" = no_iv_cases$Date,
          "location" = no_iv_cases$county,
          "fips" = no_iv_cases$fips,
           "value" = no_iv_cases$report_50,
          "notes" = "use median new confirmed cases (model calculates percentiles across runs), assume no interventions")
  )

new_model_outputs <- rbind.data.frame(
  new_model_outputs,
  cbind.data.frame("model_run_id" = model_run_id_40_red,
                   "output_id" = 11,
                   "output_name" = "New confirmed cases per day",
                   "date" = red40_cases$Date,
                   "location" = red40_cases$county,
                   "fips" = red40_cases$fips,
                   "value" = red40_cases$report_50,
                   "notes" = "use median new confirmed cases (model calculates percentiles across runs), assume 40% reduction in contact rate")
)

new_model_outputs <- rbind.data.frame(
  new_model_outputs,
  cbind.data.frame("model_run_id" = model_run_id_20_red,
                   "output_id" = 11,
                   "output_name" = "New confirmed cases per day",
                   "date" = red20_cases$Date,
                   "location" = red20_cases$county,
                   "fips" = red20_cases$fips,
                   "value" = red20_cases$report_50,
                   "notes" = "use median new confirmed cases (model calculates percentiles across runs), assume 20% reduction in contact rate"))

new_model_outputs <- rbind.data.frame(
  new_model_outputs,
  cbind.data.frame("model_run_id" = model_run_id_30_red,
                   "output_id" = 11,
                   "output_name" = "New confirmed cases per day",
                   "date" = red30_cases$Date,
                   "location" = red30_cases$county,
                   "fips" = red30_cases$fips,
                   "value" = red30_cases$report_50,
                   "notes" = "use median new confirmed cases (model calculates percentiles across runs), assume 30% reduction in contact rate"))

#################################################################
## Add data for output_id 5: Hospital beds needed per day #######
#################################################################

  new_model_outputs <- rbind.data.frame(
    new_model_outputs,
    cbind.data.frame("model_run_id" = model_run_id_no_iv,
           "output_id" = 5,
           "output_name" = "Hospital beds needed per day",
          "date" = no_iv_beds$Date,
          "location" = no_iv_beds$county,
          "fips" = no_iv_beds$fips,
          "value" = no_iv_beds$hosp_need_50,
          "notes" = "use median bed demand (model calculates percentiles across runs), assume no interventions"))

new_model_outputs <- rbind.data.frame(
  new_model_outputs,
  cbind.data.frame("model_run_id" = model_run_id_40_red,
                   "output_id" = 5,
                   "output_name" = "Hospital beds needed per day",
                   "date" = red40_beds$Date,
                   "location" = red40_beds$county,
                   "fips" = red40_beds$fips,
                   "value" = red40_beds$hosp_need_50,
                   "notes" = "use median bed demand (model calculates percentiles across runs), assume 40% reduction in contact rate"))

new_model_outputs <- rbind.data.frame(
  new_model_outputs,
  cbind.data.frame("model_run_id" = model_run_id_20_red,
                   "output_id" = 5,
                   "output_name" = "Hospital beds needed per day",
                   "date" = red20_beds$Date,
                   "location" = red20_beds$county,
                   "fips" = red20_beds$fips,
                   "value" = red20_beds$hosp_need_50,
                   "notes" = "use median bed demand (model calculates percentiles across runs), assume 20% reduction in contact rate"))

new_model_outputs <- rbind.data.frame(
  new_model_outputs,
  cbind.data.frame("model_run_id" = model_run_id_30_red,
                   "output_id" = 5,
                   "output_name" = "Hospital beds needed per day",
                   "date" = red30_beds$Date,
                   "location" = red30_beds$county,
                   "fips" = red30_beds$fips,
                   "value" = red30_beds$hosp_need_50,
                   "notes" = "use median bed demand (model calculates percentiles across runs), assume 30% reduction in contact rate"))


#################################################################
## Add data for output_id 6: ICU beds needed per day ############
#################################################################

  new_model_outputs <- rbind.data.frame(
    new_model_outputs,
    cbind.data.frame("model_run_id" = model_run_id_no_iv,
          "output_id" = 6,
          "output_name" = "ICU beds needed per day",
          "date" = no_iv_beds$Date,
          "location" = no_iv_beds$county,
          "fips" = no_iv_beds$fips,
          "value" = no_iv_beds$ICU_need_50,
          "notes" = "use median ICU bed demand (model calculates percentiles across runs), assume no interventions"))

new_model_outputs <- rbind.data.frame(
  new_model_outputs,
  cbind.data.frame("model_run_id" = model_run_id_40_red,
                   "output_id" = 6,
                   "output_name" = "ICU beds needed per day",
                   "date" = red40_beds$Date,
                   "location" = red40_beds$county,
                   "fips" = red40_beds$fips,
                   "value" = red40_beds$ICU_need_50,
                   "notes" = "use median ICU bed demand (model calculates percentiles across runs), assume 40% reduction in contact rate"))

new_model_outputs <- rbind.data.frame(
  new_model_outputs,
  cbind.data.frame("model_run_id" = model_run_id_20_red,
                   "output_id" = 6,
                   "output_name" = "ICU beds needed per day",
                   "date" = red20_beds$Date,
                   "location" = red20_beds$county,
                   "fips" = red20_beds$fips,
                   "value" = red20_beds$ICU_need_50,
                   "notes" = "use median ICU bed demand (model calculates percentiles across runs), assume 20% reduction in contact rate"))

new_model_outputs <- rbind.data.frame(
  new_model_outputs,
  cbind.data.frame("model_run_id" = model_run_id_30_red,
                   "output_id" = 6,
                   "output_name" = "ICU beds needed per day",
                   "date" = red30_beds$Date,
                   "location" = red30_beds$county,
                   "fips" = red30_beds$fips,
                   "value" = red30_beds$ICU_need_50,
                   "notes" = "use median ICU bed demand (model calculates percentiles across runs), assume 30% reduction in contact rate"))


#################################################################
## Add data for output_id 7: Ventilators needed per day #########
#################################################################

  new_model_outputs <- rbind.data.frame(
    new_model_outputs,
    cbind.data.frame("model_run_id" = model_run_id_no_iv,
          "output_id" = 7,
          "output_name" = "Ventilators needed per day",
          "date" = no_iv_beds$Date,
          "location" = no_iv_beds$county,
          "fips" = no_iv_beds$fips,
          "value" = no_iv_beds$vent_need_50,
          "notes" = "use median vent demand (model calculates percentiles across runs), assume no interventions"))

new_model_outputs <- rbind.data.frame(
  new_model_outputs,
  cbind.data.frame("model_run_id" = model_run_id_40_red,
                   "output_id" = 7,
                   "output_name" = "Ventilators needed per day",
                   "date" = red40_beds$Date,
                   "location" = red40_beds$county,
                   "fips" = red40_beds$fips,
                   "value" = red40_beds$vent_need_50,
                   "notes" = "use median vent demand (model calculates percentiles across runs), assume 40% reduction in contact rate"))

new_model_outputs <- rbind.data.frame(
  new_model_outputs,
  cbind.data.frame("model_run_id" = model_run_id_20_red,
                   "output_id" = 7,
                   "output_name" = "Ventilators needed per day",
                   "date" = red20_beds$Date,
                   "location" = red20_beds$county,
                   "fips" = red20_beds$fips,
                   "value" = red20_beds$vent_need_50,
                   "notes" = "use median vent demand (model calculates percentiles across runs), assume 20% reduction in contact rate"))

new_model_outputs <- rbind.data.frame(
  new_model_outputs,
  cbind.data.frame("model_run_id" = model_run_id_30_red,
                   "output_id" = 7,
                   "output_name" = "Ventilators needed per day",
                   "date" = red30_beds$Date,
                   "location" = red30_beds$county,
                   "fips" = red30_beds$fips,
                   "value" = red30_beds$vent_need_50,
                   "notes" = "use median vent demand (model calculates percentiles across runs), assume 30% reduction in contact rate"))

#################################################################
## Aggregate to state level (for now) ###########################
#################################################################

all(locations$FIPS[which(locations$location_type == "County")] %in% new_model_outputs$fips)

## which FIPS codes are we missing data for? American Samoa, Puerto Rico, Virgin Islands, Northern Mariana Islands
locations[which(locations$location_type == "County"),][-which(locations$FIPS[which(locations$location_type == "County")] %in% new_model_outputs$fips),]

## first two digits of FIPS codes corresponds to state
new_model_outputs$state <- substr(new_model_outputs$fips, start = 1, stop = 2)

## merge by FIPS codes to get state names
state_listing <- merge(new_model_outputs, locations,
                                      by.x = "state", by.y = "FIPS",
                                      all.x = TRUE, all.y = FALSE)

## reformat value so it's an number
state_listing$value <- as.numeric(as.character(state_listing$value))

## sum across counties to get totals by state
state_totals <- state_listing %>%
  group_by(model_run_id, output_id, output_name, date, location_name) %>%
  summarise(value = sum(value))

## sum across states to get national
national_total <- state_totals %>%
  group_by(model_run_id, output_id, output_name, date) %>%
  summarise(value = sum(value))


model_outputs <- rbind.data.frame(cbind.data.frame(
                                        model_run_id = state_totals$model_run_id,
                                        output_id = state_totals$output_id,
                                        output_name = state_totals$output_name,
                                        date = state_totals$date,
                                        location = state_totals$location_name,
                                        value = state_totals$value,
                                        notes = "state totals calculated as the sum across all county-level projections in state, using median forecasted value across ensemble model runs"),
                                    cbind.data.frame(
                                          model_run_id = national_total$model_run_id,
                                          output_id = national_total$output_id,
                                          output_name = national_total$output_name,
                                          date = national_total$date,
                                          location = "United States of America",
                                          value = national_total$value,
                                          notes = "national totals calculated as the sum across all county-level projections in state, using median forecasted value across ensemble model runs"),
                                  model_outputs)

#################################################################
## Save model_outputs as .tsv file ##############################
#################################################################

write.table(model_outputs, file = 'data/model_outputs.txt', quote = FALSE, sep = '\t', row.names = FALSE)


