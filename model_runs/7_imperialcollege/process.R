#################################################################
## Specify some initial details #################################
#################################################################

file_name1 <- "model_runs/7_imperialcollege/model_export/11_model1.txt"
file_name2 <- "model_runs/7_imperialcollege/model_export/12_model2.txt"
file_name3 <- "model_runs/7_imperialcollege/model_export/13_model3.txt"
file_name4 <- "model_runs/7_imperialcollege/model_export/14_ensemble123.txt"

#################################################################
## Load datasets and set fixed parameters #######################
#################################################################

## read in new dataset of Imperial College model exports: for model 1
imperial1 <- read.delim(file_name1, stringsAsFactors = FALSE)
imperial2 <- read.delim(file_name2, stringsAsFactors = FALSE)
imperial3 <- read.delim(file_name3, stringsAsFactors = FALSE)
imperial4 <- read.delim(file_name4, stringsAsFactors = FALSE)

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

## check locations
all(imperial1$Country %in% locations$location_name)
unique(imperial1$Country[-which(imperial1$Country %in% locations$location_name)])

#################################################################
## Format data ##################################################
#################################################################

## Imperial College London short-term forecasts reports weeks as starting on Sunday and ending on Saturday
## encode date as the end date of the time inverval, as specified in documentation and data dictionary
## you can do this by simply adding 6 days to the date

imperial1$date <- as.Date(imperial1$Week.Starting, format = "%d-%m-%Y") + 6
imperial2$date <- as.Date(imperial2$Week.Starting, format = "%d-%m-%Y") + 6
imperial3$date <- as.Date(imperial3$Week.Starting, format = "%d-%m-%Y") + 6
imperial4$date <- as.Date(imperial4$Week.Starting, format = "%d-%m-%Y") + 6

model_outputs$date <- as.Date(model_outputs$date)

## strip out predicted deaths 
imperial1$deaths <- as.numeric(gsub(",", "", gsub(" ", "", sub("\\(.*", "", imperial1$Predicted.Deaths))))
imperial2$deaths <- as.numeric(gsub(",", "", gsub(" ", "", sub("\\(.*", "", imperial2$Predicted.Deaths))))
imperial3$deaths <- as.numeric(gsub(",", "", gsub(" ", "", sub("\\(.*", "", imperial3$Predicted.Deaths))))
imperial4$deaths <- as.numeric(gsub(",", "", gsub(" ", "", sub("\\(.*", "", imperial4$Predicted.Deaths))))

## for consistency across data sources
if(any(imperial1$Country == "Czech Republic")){
  imperial1$Country[which(imperial1$Country == "Czech Republic")] <- "Czechia"
  imperial2$Country[which(imperial2$Country == "Czech Republic")] <- "Czechia"
  imperial3$Country[which(imperial3$Country == "Czech Republic")] <- "Czechia"
  imperial4$Country[which(imperial4$Country == "Czech Republic")] <- "Czechia"
}


## only available data are for output_id 10: Fatalities per week

#################################################################
## Add data for output_id 10:  Fatalities per week ##############
## Imperial College model 1 #####################################
#################################################################

  model_outputs <- rbind.data.frame(
    model_outputs,
    cbind.data.frame("model_run_id" = 11,
                     "output_id" = 10,
                     "output_name" = "Fatalities per week",
                     "date" = imperial1$date,
                     "location" = imperial1$Country,
                     "value" = imperial1$deaths,
                     "notes" = "Based on Imperial College London model 1 as of 4/7/2020")
  )

#################################################################
## Add data for output_id 10:  Fatalities per week ##############
## Imperial College model 2 #####################################
#################################################################

model_outputs <- rbind.data.frame(
  model_outputs,
  cbind.data.frame("model_run_id" = 12,
                   "output_id" = 10,
                   "output_name" = "Fatalities per week",
                   "date" = imperial2$date,
                   "location" = imperial2$Country,
                   "value" = imperial2$deaths,
                   "notes" = "Based on Imperial College London model 2 as of 4/7/2020")
)

#################################################################
## Add data for output_id 10:  Fatalities per week ##############
## Imperial College model 3 #####################################
#################################################################

model_outputs <- rbind.data.frame(
  model_outputs,
  cbind.data.frame("model_run_id" = 13,
                   "output_id" = 10,
                   "output_name" = "Fatalities per week",
                   "date" = imperial3$date,
                   "location" = imperial3$Country,
                   "value" = imperial3$deaths,
                   "notes" = "Based on Imperial College London model 3 as of 4/7/2020")
)

#################################################################
## Add data for output_id 10:  Fatalities per week ##############
## Imperial College ensemble model ##############################
#################################################################

model_outputs <- rbind.data.frame(
  model_outputs,
  cbind.data.frame("model_run_id" = 14,
                   "output_id" = 10,
                   "output_name" = "Fatalities per week",
                   "date" = imperial4$date,
                   "location" = imperial4$Country,
                   "value" = imperial4$deaths,
                   "notes" = "Based on Imperial College London ensemble model (unweighted combo of models 1, 2, and 3) as of 4/7/2020")
)



#################################################################
## Save model_outputs as .tsv file ##############################
#################################################################

write.table(model_outputs, file='data/model_outputs.txt', quote = FALSE, sep='\t', row.names = FALSE)

