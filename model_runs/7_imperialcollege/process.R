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

## Imperial College model ID is always 7, model name is always whatever model_id 7 is named in the file data/models.txt
model_id <- 7
model_name <- models$model_name[which(models$model_id == 7)]

#################################################################
## Format data ##################################################
#################################################################

## TODO: review this as things progress // a note on dates:
## In shiny app as of 11am PT 4/8/20, data labeled as "Week ending" with values of 29-03-2020 and 05-04-2020. However this does not match the documentation, which states 
# "In the analysis for week beginning 29-03-2020, 22 countries/regions were included in the analysis. For the week beginning 05-04-2020, the number of countries/regions included based on these thresholds is 42."
## sassume the documentation is correct, so add 6 days to each date to make it a true "week ending" on Saturday and beginning on Sunday

imperial1$date <- as.Date(imperial1$Week.Ending, format = "%d-%m-%Y")
imperial2$date <- as.Date(imperial2$Week.Ending, format = "%d-%m-%Y")
imperial3$date <- as.Date(imperial3$Week.Ending, format = "%d-%m-%Y")
imperial4$date <- as.Date(imperial4$Week.Ending, format = "%d-%m-%Y")

model_outputs$date <- as.Date(model_outputs$date)

## strip out predicted deaths 
imperial1$deaths <- as.numeric(gsub(",", "", gsub(" ", "", sub("\\(.*", "", imperial1$Predicted.Deaths))))
imperial2$deaths <- as.numeric(gsub(",", "", gsub(" ", "", sub("\\(.*", "", imperial2$Predicted.Deaths))))
imperial3$deaths <- as.numeric(gsub(",", "", gsub(" ", "", sub("\\(.*", "", imperial3$Predicted.Deaths))))
imperial4$deaths <- as.numeric(gsub(",", "", gsub(" ", "", sub("\\(.*", "", imperial4$Predicted.Deaths))))

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

