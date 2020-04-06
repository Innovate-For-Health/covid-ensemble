#################################################################
## Specify some initial details #################################
#################################################################

model_run_id <- 3
file_name <- "model_runs/2_neher/model_export/3_covid.results.deterministic.csv"
  
#################################################################
## Load required packages #######################################
#################################################################

#################################################################
## Load datasets and set fixed parameters #######################
#################################################################

## read in new dataset of Neher exported data
neher <- read.delim(file_name, stringsAsFactors = FALSE)

## read in models (file that tracks all models)
models <- read.delim("data/models.txt", stringsAsFactors = FALSE)

## read in model_runs (file that tracks model runs)
model_runs <- read.delim("data/model_runs.txt", stringsAsFactors = FALSE)

## read in model_outputs (file that tracks model outputs)
model_outputs <- read.delim("data/model_outputs.txt", stringsAsFactors = FALSE)

## read in outputs (file that uniquely identifies each distinct output tracked across models)
outputs <- read.delim("data/outputs.txt", stringsAsFactors = FALSE)

## Neher model ID is always 2, model name is always whatever model_id 2 is named in the file data/models.txt
model_id <- 2
model_name <- models$model_name[which(models$model_id == 2)]

#################################################################
## Format data ##################################################
#################################################################

## set time as a date
neher$time <- as.Date(neher$time)
model_outputs$date <- as.Date(model_outputs$date)

## note: we "told" Neher model as an input to start the scenario on 4/6/2020 ("today" as of writing this code)
## as a result, current fatality counts are zero
## to address this, adding the cumulative COVID-19 fatality count reported by CDC as of 4/6/20 (8,910 fatalities) to cumulative_fatalities
neher$cumulative_fatality <- neher$cumulative_fatality + 8910

## note: we "told" Neher model as an input to start the scenario on 4/6/2020 ("today" as of writing this code)
## as a result, current hospitalization counts are zero
## to address this, adding hospitalization data reported by CDC as of 4/6/20 (8,910 fatalities) to cumulative_hospitalized
## overall cumulative hospitalization rate is 4.6 per 100,000 population (week ending March 28, 2020 accessed
## via https://gis.cdc.gov/grasp/COVIDNet/COVID19_3.html at 11:56AM PT on April 6, 2020)
## 4.6/100000*327167439 (assuming US population of 327,167,439 based on data from US Census) == 15,050 hospitalizations
neher$cumulative_hospitalized <- neher$cumulative_hospitalized + 15050

#################################################################
## Add data to model_outputs file: cumulative fatalities ########
#################################################################

## only add these new data if you're not reading over model_outputs already stored
## given a fixed model run_id (specified above) for a given output type 

## see notes above (in format data section) on calculation of cumulative fatalities by adding prior CDC data 

if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 1])){

  model_outputs <- rbind.data.frame(
              model_outputs,
              cbind.data.frame("model_run_id" = model_run_id,
                 "output_id" = 1,
                 "output_name" = "cumulative fatalities",
                 "date" = as.Date(neher$time),
                 "location" = "US", ## all data from this model are from the full US
                 "value" = neher$cumulative_fatality,
                 "notes" = "Model run using default parameters from Neher lab tool, plus US population data from US Census (total population = 327,167,439), and US COVID-19 caseload data from US CDC accessed morning of 4/6/2020 (cumulative cases = 330,891), which is almost certainly an understimate as it suggests a CFR of over 2.6% in the US. Model run assumed to begin on 4/6/20 so prior fatality data from CDC reported as cumulative prior to 4/6/2020.")
              )
}


#################################################################
## Add data to model_outputs file: fatalities per day ###########
#################################################################

## only add these new data if you're not reading over model_outputs already stored
## given a fixed model run_id (specified above) for a given output type 
## note that Neher model export data format (as of 4/6/20) reports only cumulative fatalities, so backtracking
## from this value to calculate fatalities per day

## see notes above (in format data section) on calculation of cumulative fatalities by adding prior CDC data 

if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 7])){
  
  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 7,
                     "output_name" = "fatalities per day",
                     "date" = neher$time,
                     "location" = "US",
                     "value" = c(NA, diff(neher$cumulative_fatality)),
                     "notes" = "Model run using default parameters from Neher lab tool, plus US population data from US Census (total population = 327,167,439), and US COVID-19 caseload data from US CDC accessed morning of 4/6/2020 (cumulative cases = 330,891), which is almost certainly an understimate as it suggests a CFR of over 2.6% in the US. Model run assumed to begin on 4/6/20 so prior fatality data from CDC reported as cumulative prior to 4/6/2020.")
  )
}

#################################################################
## Add data to model_outputs file: hospitalizations per day #####
#################################################################

## only add these new data if you're not reading over model_outputs already stored
## given a fixed model run_id (specified above) for a given output type 
## note that Neher model export data format (as of 4/6/20) reports only cumulative hospitalizations, so backtracking
## from this value to calculate hospitalizations per day

## see notes above (in format data section) on calculation of cumulative hospitalizations by adding prior CDC data 

if((!model_run_id %in% model_outputs$model_run_id[model_outputs$output_id == 5])){
  
  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 5,
                     "output_name" = "hospital admissions per day",
                     "date" = neher$time,
                     "location" = "US",
                     "value" = c(NA, diff(neher$cumulative_hospitalized)),
                     "notes" = "Model run using default parameters from Neher lab tool, plus US population data from US Census (total population = 327,167,439), and US COVID-19 caseload data from US CDC accessed morning of 4/6/2020 (cumulative cases = 330,891), which is almost certainly an understimate as it suggests a CFR of over 2.6% in the US. Model run assumed to begin on 4/6/20 so prior hospitalization data from CDC reported as cumulative prior to 4/6/2020.")
  )
}


#################################################################
## Save model_outputs as .tsv file ##############################
#################################################################

write.table(model_outputs, file = 'data/model_outputs.txt', quote = FALSE, sep='\t', row.names = FALSE)


