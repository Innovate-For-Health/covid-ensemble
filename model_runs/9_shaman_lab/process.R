#################################################################
## Specify some initial details #################################
#################################################################

model_run_id_8010p <- 94
model_run_id_805p <- 95
model_run_id_80w10p <- 96
model_run_id_80w5p <- 97

file_name_80w10p <- "https://raw.githubusercontent.com/shaman-lab/COVID-19Projection/master/Projection_May31/cdc_hosp/state_cdchosp_80contactw10p.csv"
file_name_80w5p <- "https://raw.githubusercontent.com/shaman-lab/COVID-19Projection/master/Projection_May31/cdc_hosp/state_cdchosp_80contactw5p.csv"
file_name_8010p <- "https://raw.githubusercontent.com/shaman-lab/COVID-19Projection/master/Projection_May31/cdc_hosp/state_cdchosp_80contact1x10p.csv"
file_name_805p <- "https://raw.githubusercontent.com/shaman-lab/COVID-19Projection/master/Projection_May31/cdc_hosp/state_cdchosp_80contact1x5p.csv"

#################################################################
## Load datasets and set fixed parameters #######################
#################################################################

## read in new datasets from github
dat_80w10p  <- read.csv(file_name_80w10p, stringsAsFactors = FALSE)
dat_80w5p <- read.csv(file_name_80w5p, stringsAsFactors = FALSE)
dat_8010p <- read.csv(file_name_8010p, stringsAsFactors = FALSE)
dat_805p <- read.csv(file_name_805p, stringsAsFactors = FALSE)

## read in models (file that tracks all models)
models <- read.delim("data/models.txt", stringsAsFactors = FALSE)

## read in model_runs (file that tracks model runs)
model_runs <- read.delim("data/model_runs.txt", stringsAsFactors = FALSE)

## read in model_outputs (file that tracks model outputs)
model_outputs <- readRDS("data/model_outputs.RDS")

## read in locations their their fips codes
locations <- read.delim("data/locations.txt", stringsAsFactors = FALSE)

## read in outputs (file that uniquely identifies each distinct output tracked across models)
outputs <- read.delim("data/outputs.txt", stringsAsFactors = FALSE)

## Shaman lab model ID is always 9, model name is always whatever model_id 9 is named in the file data/models.txt
model_id <- 9
model_name <- models$model_name[which(models$model_id == 9)]

#################################################################
## Format data ##################################################
#################################################################

## set date as a date
dat_80w10p$Date <- as.Date(dat_80w10p$Date, format = "%m/%d/%y")
dat_80w5p$Date <- as.Date(dat_80w5p$Date, format = "%m/%d/%y")
dat_8010p$Date <- as.Date(dat_8010p$Date, format = "%m/%d/%y")
dat_805p$Date <- as.Date(dat_805p$Date, format = "%m/%d/%y")

model_outputs$date <- as.Date(model_outputs$date)

#################################################################
## Add data for each scenario ###################################
#################################################################

additional_outputs <- cbind.data.frame(
  "model_run_id" = model_run_id_80w10p,
  "output_id" = 3,
  "output_name" = "Fatalities per day",
  "date" = dat_80w10p$Date,
  "location" =  dat_80w10p$location,
  "value_type" = "percentile (50)",
  "value" = dat_80w10p$death_50,
  "notes" = "")

additional_outputs <- rbind.data.frame(additional_outputs,
  cbind.data.frame(
  "model_run_id" = model_run_id_80w10p,
  "output_id" = 4,
  "output_name" = "Cumulative fatalities",
  "date" = dat_80w10p$Date,
  "location" =  dat_80w10p$location,
  "value_type" = "percentile (50)",
  "value" = dat_80w10p$cdeath_50,
  "notes" = ""))

#################################################################
## Add data for each scenario ###################################
#################################################################

additional_outputs <- rbind.data.frame(additional_outputs,
  cbind.data.frame(
  "model_run_id" = model_run_id_80w5p,
  "output_id" = 3,
  "output_name" = "Fatalities per day",
  "date" = dat_80w5p$Date,
  "location" =  dat_80w5p$location,
  "value_type" = "percentile (50)",
  "value" = dat_80w5p$death_50,
  "notes" = ""))

additional_outputs <- rbind.data.frame(additional_outputs,
  cbind.data.frame(
  "model_run_id" = model_run_id_80w5p,
  "output_id" = 4,
  "output_name" = "Cumulative fatalities",
  "date" = dat_80w5p$Date,
  "location" =  dat_80w5p$location,
  "value_type" = "percentile (50)",
  "value" = dat_80w5p$cdeath_50,
  "notes" = ""))

#################################################################
## Add data for each scenario ###################################
#################################################################

additional_outputs <- rbind.data.frame(additional_outputs,
  cbind.data.frame(
  "model_run_id" = model_run_id_8010p,
  "output_id" = 3,
  "output_name" = "Fatalities per day",
  "date" = dat_8010p$Date,
  "location" =  dat_8010p$location,
  "value_type" = "percentile (50)",
  "value" = dat_8010p$death_50,
  "notes" = ""))

additional_outputs <- rbind.data.frame(additional_outputs,
  cbind.data.frame(
  "model_run_id" = model_run_id_8010p,
  "output_id" = 4,
  "output_name" = "Cumulative fatalities",
  "date" = dat_8010p$Date,
  "location" =  dat_8010p$location,
  "value_type" = "percentile (50)",
  "value" = dat_8010p$cdeath_50,
  "notes" = ""))

#################################################################
## Add data for each scenario ###################################
#################################################################

additional_outputs <- rbind.data.frame(additional_outputs,
  cbind.data.frame(
  "model_run_id" = model_run_id_805p,
  "output_id" = 3,
  "output_name" = "Fatalities per day",
  "date" = dat_805p$Date,
  "location" =  dat_805p$location,
  "value_type" = "percentile (50)",
  "value" = dat_805p$death_50,
  "notes" = ""))

additional_outputs <- rbind.data.frame(additional_outputs,
   cbind.data.frame(
  "model_run_id" = model_run_id_805p,
  "output_id" = 4,
  "output_name" = "Cumulative fatalities",
  "date" = dat_805p$Date,
  "location" =  dat_805p$location,
  "value_type" = "percentile (50)",
  "value" = dat_805p$cdeath_50,
  "notes" = ""))

#################################################################
## Sanity check #################################################
#################################################################

## check data
ggplot(additional_outputs[which(additional_outputs$location == "California" & additional_outputs$output_id == 4),],
       aes(x = date, y = value, col = as.factor(model_run_id))) +
  geom_line(size = 1) +
  scale_y_continuous(label = comma) +
  xlab("") +
  theme_light() 

#################################################################
## Merge data ###################################################
#################################################################

model_outputs <- rbind.data.frame(model_outputs, additional_outputs)

#################################################################
## Save model_outputs as .RDS file ##############################
#################################################################

saveRDS(model_outputs, file = 'data/model_outputs.RDS', compress = TRUE)


