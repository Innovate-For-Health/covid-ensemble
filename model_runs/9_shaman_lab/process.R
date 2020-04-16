#################################################################
## Specify some initial details #################################
#################################################################

model_run_id_no_iv <- 31
file_name_beds_no_iv <- "model_runs/9_shaman_lab/model_export/31_bed_nointervention.csv"
file_name_cases_no_iv <- "model_runs/9_shaman_lab/model_export/31_Projection_nointervention.csv"

#################################################################
## Load datasets and set fixed parameters #######################
#################################################################

## read in new dataset: assuming no intervention ("no iv")
no_iv_beds <- read.csv(file_name_beds_no_iv, stringsAsFactors = FALSE)
no_iv_cases <- read.csv(file_name_cases_no_iv, stringsAsFactors = FALSE)

## read in models (file that tracks all models)
models <- read.delim("data/models.txt", stringsAsFactors = FALSE)

## read in model_runs (file that tracks model runs)
model_runs <- read.delim("data/model_runs.txt", stringsAsFactors = FALSE)

## read in model_outputs (file that tracks model outputs)
model_outputs <- read.delim("data/model_outputs.txt", stringsAsFactors = FALSE)

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
model_outputs$date <- as.Date(model_outputs$date)

#################################################################
## Add data for output_id 1: New infections per day #############
#################################################################

## only add these new data if you're not reading over model_outputs already stored
if((!model_run_id_no_iv %in% model_outputs$model_run_id[model_outputs$output_id == 1])){
  
  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id_no_iv,
                     "output_id" = 1,
                     "output_name" = "New infections per day",
                     "date" = no_iv_cases$date,
                     "location" = no_iv_cases$location,
                     "value" = no_iv_cases$total_50,
                     "notes" = "use median new infections (model calculates percentiles across runs)")
  )
}

#################################################################
## Add data for output_id 2: Cumulative infections ##############
#################################################################

## TODO: add cumulative infections here

#######################################################################
## Add data for output_id 11: New confirmed cases per day #############
#######################################################################

## only add these new data if you're not reading over model_outputs already stored
if((!model_run_id_no_iv %in% model_outputs$model_run_id[model_outputs$output_id == 11])){
  
  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id_no_iv,
                     "output_id" = 11,
                     "output_name" = "New confirmed cases per day",
                     "date" = no_iv_cases$date,
                     "location" = no_iv_cases$location,
                     "value" = no_iv_cases$report_50,
                     "notes" = "use median new confirmed cases (model calculates percentiles across runs)")
  )
}

#################################################################
## Add data for output_id 5: Hospital beds needed per day #######
#################################################################

## only add these new data if you're not reading over model_outputs already stored
if((!model_run_id_no_iv %in% model_outputs$model_run_id[model_outputs$output_id == 5])){
  
  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id_no_iv,
                     "output_id" = 5,
                     "output_name" = "Hospital beds needed per day",
                     "date" = no_iv_beds$date,
                     "location" = no_iv_beds$location,
                     "value" = no_iv_beds$hosp_need_50,
                     "notes" = "use median bed demand (model calculates percentiles across runs)")
  )
}

#################################################################
## Add data for output_id 6: ICU beds needed per day ############
#################################################################

## only add these new data if you're not reading over model_outputs already stored
if((!model_run_id_no_iv %in% model_outputs$model_run_id[model_outputs$output_id == 6])){
  
  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id_no_iv,
                     "output_id" = 6,
                     "output_name" = "ICU beds needed per day",
                     "date" = no_iv_beds$date,
                     "location" = no_iv_beds$location,
                     "value" = no_iv_beds$ICU_need_50,
                     "notes" = "use median ICU bed demand (model calculates percentiles across runs)")
  )
}

#################################################################
## Add data for output_id 7: Ventilators needed per day #########
#################################################################

## only add these new data if you're not reading over model_outputs already stored
if((!model_run_id_no_iv %in% model_outputs$model_run_id[model_outputs$output_id == 7])){
  
  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id_no_iv,
                     "output_id" = 7,
                     "output_name" = "Ventilators needed per day",
                     "date" = no_iv_beds$date,
                     "location" = no_iv_beds$location,
                     "value" = no_iv_beds$vent_need_50,
                     "notes" = "use median vent demand (model calculates percentiles across runs)")
  )
}

#################################################################
## Add data for output_id 7: Cumulative fatalities ##############
#################################################################

## only add these new data if you're not reading over model_outputs already stored
if((!model_run_id_no_iv %in% model_outputs$model_run_id[model_outputs$output_id == 4])){
  
  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id_no_iv,
                     "output_id" = 4,
                     "output_name" = "Cumulative fatalities",
                     "date" = no_iv_beds$date,
                     "location" = no_iv_beds$location,
                     "value" = no_iv_beds$death_50,
                     "notes" = "use median fatalities (model calculates percentiles across runs)")
  )
}

#################################################################
## Add data for output_id 7: Cumulative fatalities ##############
#################################################################

## only add these new data if you're not reading over model_outputs already stored
if((!model_run_id_no_iv %in% model_outputs$model_run_id[model_outputs$output_id == 4])){
  
  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id_no_iv,
                     "output_id" = 4,
                     "output_name" = "Cumulative fatalities",
                     "date" = no_iv_beds$date,
                     "location" = no_iv_beds$location,
                     "value" = no_iv_beds$death_50,
                     "notes" = "use median fatalities (model calculates percentiles across runs)")
  )
}

#################################################################
## Save model_outputs as .tsv file ##############################
#################################################################

write.table(model_outputs, file='data/model_outputs.txt', quote = FALSE, sep='\t', row.names = FALSE)


