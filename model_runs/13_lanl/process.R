#################################################################
## Specify some initial details #################################
#################################################################
 
model_run_id <- 107
file_name_cases_us <- "model_runs/13_lanl/model_export/107_2020-06-03_confirmed_quantiles_us_website.csv"
file_name_deaths_us <- "model_runs/13_lanl/model_export/107_2020-06-03_deaths_quantiles_us_website.csv"
file_name_cases_global <- "model_runs/13_lanl/model_export/107_2020-06-03_confirmed_quantiles_global_website.csv"
file_name_deaths_global <- "model_runs/13_lanl/model_export/107_2020-06-03_deaths_quantiles_global_website.csv"

#################################################################
## Load datasets and set fixed parameters #######################
#################################################################

## assume working directory is covid-ensemble
#setwd("/Users/seaneff/Documents/covid-ensemble/")

## read in lanl data
lanl_cases <- read.csv(file_name_cases_us, stringsAsFactors = FALSE)
lanl_cases_global <- read.csv(file_name_cases_global, stringsAsFactors = FALSE)

lanl_deaths <- read.csv(file_name_deaths_us, stringsAsFactors = FALSE)
lanl_deaths_global <- read.csv(file_name_deaths_global, stringsAsFactors = FALSE)

## read in models (file that tracks all models)
models <- read.delim("srv/shiny-server/data/models.txt", stringsAsFactors = FALSE)

## read in model_runs (file that tracks model runs)
model_runs <- read.delim("srv/shiny-server/data/model_runs.txt", stringsAsFactors = FALSE)

## read in model_outputs (file that tracks model outputs)
model_outputs <- readRDS("srv/shiny-server/data/model_outputs.RDS")

## read in outputs (file that uniquely identifies each distinct output tracked across models)
outputs <- read.delim("srv/shiny-server/data/outputs.txt", stringsAsFactors = FALSE)

## read in dataset of locations
locations <- read.delim("srv/shiny-server/data/locations.txt", stringsAsFactors = FALSE)

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

unique(lanl_deaths_global$countries[-which(lanl_deaths_global$countries %in% locations$location_name)])

#################################################################
## Format data ##################################################
#################################################################

## set date as a date
lanl_cases$dates <- as.Date(lanl_cases$dates)
lanl_deaths$dates <- as.Date(lanl_deaths$dates)
lanl_cases_global$dates <- as.Date(lanl_cases_global$dates)
lanl_deaths_global$dates <- as.Date(lanl_deaths_global$dates)
model_outputs$date <- as.Date(model_outputs$date)

## to minimize size of data file, now focus on dates after May 15, 2020 
lanl_cases <- lanl_cases[which(lanl_cases$dates >= as.Date("2020-05-15")),]
lanl_cases_global <- lanl_cases_global[which(lanl_cases_global$dates >= as.Date("2020-05-15")),]
lanl_deaths <- lanl_deaths[which(lanl_deaths$dates >= as.Date("2020-05-15")),]
lanl_deaths_global <- lanl_deaths_global[which(lanl_deaths_global$dates >= as.Date("2020-05-15")),]

##########################################################################
## Add data for output_id 3:  Cumulative fatalities: US data #############
##########################################################################

  additional_outputs <- cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 4,
                     "output_name" = "Cumulative fatalities",
                     "date" = lanl_deaths$dates,
                     "location" = lanl_deaths$state,
                     "value_type" = "percentile (50)",
                     "value" = lanl_deaths$q.50,
                     "notes" = "50th percentile produced across model runs")

##########################################################################
## Add data for output_id 4:  Cumulative fatalities: Global data #########
##########################################################################

  additional_outputs <- rbind.data.frame(
    additional_outputs,
    cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 4,
                     "output_name" = "Cumulative fatalities",
                     "date" = lanl_deaths_global$dates,
                     "location" = lanl_deaths_global$countries,
                     "value_type" = "percentile (50)",
                     "value" = lanl_deaths_global$q.50,
                     "notes" = "50th percentile produced across model runs")
  )

# ##########################################################################
# ## Add data for output_id 3: Fatalities per day: US Data #################
# ##########################################################################

undoCumSum <- function(x) {
  c(NA, diff(x))
}
## sanity check:
#undoCumSum(cumsum(seq(1:10)))

lanl_deaths <- lanl_deaths[order(lanl_deaths$dates, decreasing = FALSE),]

lanl_deaths <- lanl_deaths %>%
  group_by(state) %>%
  mutate(daily_fatalities =  undoCumSum(q.50))

lanl_deaths$daily_fatalities[which(lanl_deaths$daily_fatalities < 0)] <- 0

  additional_outputs <- rbind.data.frame(
    additional_outputs,
    cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 3,
                     "output_name" = "Fatalities per day",
                     "date" = lanl_deaths$dates,
                     "location" = lanl_deaths$state,
                     "value_type" = "percentile (50)",
                     "value" = round(lanl_deaths$daily_fatalities),
                     "notes" = "50th percentile produced across model runs, daily fatalities calculated as difference between daily cumulative fatalities. If daily fatalities is every less than zero due to data anomaly, value is set to zero.")
  )


# ##############################################################################
# ## Add data for output_id 3: Fatalities per day: Global Data #################
# ##############################################################################

lanl_deaths_global <- lanl_deaths_global[order(lanl_deaths_global$dates, decreasing = FALSE),]

lanl_deaths_global <- lanl_deaths_global %>%
  group_by(countries) %>%
  mutate(daily_fatalities =  undoCumSum(q.50))

lanl_deaths_global$daily_fatalities[which(lanl_deaths_global$daily_fatalities < 0)] <- 0

  additional_outputs <- rbind.data.frame(
    additional_outputs,
    cbind.data.frame("model_run_id" = model_run_id,
                     "output_id" = 3,
                     "output_name" = "Fatalities per day",
                     "date" = lanl_deaths_global$dates,
                     "location" = lanl_deaths_global$countries,
                     "value_type" = "percentile (50)",
                     "value" = round(lanl_deaths_global$daily_fatalities),
                     "notes" = "50th percentile produced across model runs, daily fatalities calculated as difference between daily cumulative fatalities. If daily fatalities is every less than zero due to data anomaly, value is set to zero.")
  )
  

################################################################
## Run some sanity checks #######################################
#################################################################

if(any(is.na(additional_outputs$value))){
  additional_outputs <- additional_outputs[-which(is.na(additional_outputs$value)),]
}

table(additional_outputs$output_name)

## max should be two
max(table(additional_outputs$location, additional_outputs$date))

## are any estimates less than zero?
any(additional_outputs$value < 0, na.rm = TRUE)

ggplot(additional_outputs[which(additional_outputs$location == "California" & additional_outputs$output_name == "Fatalities per day"),],
       aes(x = date, y = value)) +
  geom_line(size = 1) +
  scale_y_continuous(label = comma) +
  xlab("") +
  theme_light() 

ggplot(additional_outputs[which(additional_outputs$location == "Brazil" & additional_outputs$output_name == "Fatalities per day"),],
       aes(x = date, y = value)) +
  geom_line(size = 1) +
  scale_y_continuous(label = comma) +
  xlab("") +
  theme_light() 

ggplot(additional_outputs[which(additional_outputs$location == "United States of America" & additional_outputs$output_name == "Fatalities per day"),],
       aes(x = date, y = value)) +
  geom_line(size = 1) +
  scale_y_continuous(label = comma) +
  xlab("") +
  theme_light() 

#################################################################
## Merge with full dataset #######################################
#################################################################

model_outputs <- rbind.data.frame(model_outputs, additional_outputs)

#################################################################
## Save output ##################################################
#################################################################

saveRDS(model_outputs, file = 'srv/shiny-server/data/model_outputs.RDS', compress = TRUE) 

