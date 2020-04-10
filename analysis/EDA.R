#################################################################
## Load required packages #######################################
#################################################################

library(ggplot2)
library(scales)
library(lubridate)
library(dplyr)
library(RColorBrewer)

#################################################################
## Load datasets ################################################
#################################################################

model_outputs <- read.delim("data/model_outputs.txt", stringsAsFactors = FALSE)
models <- read.delim("data/models.txt", stringsAsFactors = FALSE)
model_runs <- read.delim("data/model_runs.txt", stringsAsFactors = FALSE)
US_states <- read.delim("data/USintermediateFIPS.txt", stringsAsFactors = FALSE)

#################################################################
## Format data ##################################################
#################################################################

model_outputs$date <- as.Date(model_outputs$date)

#################################################################
## Create master dataset: runs ##################################
#################################################################

## add descriptions of model runs and models themselves
outputs <- merge(model_outputs, model_runs[,-which(names(model_runs) == "notes"),], by = "model_run_id", all.x = TRUE, all.y = FALSE)
outputs <- merge(outputs, models[,-which(names(models) %in% c("source_documentation", "intended_use", "model_developer", "model_name")),], by = "model_id", all.x = TRUE, all.y = FALSE)

## format date as date
outputs$date <- as.Date(outputs$date)

################################################################################
## Which models have which data for US states?  ################################
################################################################################

table(outputs$model_name[outputs$geographic_resolution_US_state == TRUE], outputs$output_name[outputs$geographic_resolution_US_state == TRUE])

##################################################################################
## Fatalities per day, change in IHME model: US ##################################
##################################################################################

#pdf(paste("analysis/static_figures/IHME_daily_fatalities_", date(), ".pdf", sep = ""), height = 2.5, width = 5)
ggplot(outputs[which(outputs$model_name == "IHME COVID-19 Model" & outputs$output_name == "Fatalities per day" &
                     outputs$location == "United States of America" &
                     outputs$run_name != "IHME (4/5/2020)"),],
       aes(x = date, y = value, color = run_name)) +
  geom_line(size = 1) +
  scale_y_continuous(label = comma) +
  scale_color_manual(values = rev(c("#006d2c", "#a1d99b"))) +
  guides(color = guide_legend(title = "Model Run")) +
  ylab("Fatalities per day (US)") +
  xlab("") +
  theme_bw() +
  ggtitle("Fatalities per day in the US:\ntwo IHME model versions")
#dev.off()

##################################################################################
## Fatalities per day, change in IHME model: US ##################################
##################################################################################

#pdf(paste("analysis/static_figures/IHME_cumulative_fatalities_", date(), ".pdf", sep = ""), height = 2.5, width = 5)
ggplot(outputs[which(outputs$model_name == "IHME COVID-19 Model" & outputs$output_name == "Cumulative fatalities" &
                       outputs$location == "United States of America" &
                       outputs$run_name != "IHME (4/5/2020)"),],
       aes(x = date, y = value, color = run_name)) +
  geom_line(size = 1) +
  scale_y_continuous(label = comma) +
  scale_color_manual(values = rev(c("#006d2c", "#a1d99b"))) +
  guides(color = guide_legend(title = "Model Run")) +
  ylab("Cumulative fatalities (US)") +
  xlab("") +
  theme_bw() +
  ggtitle("Cumulative fatalities in the US:\ntwo IHME model versions")
#dev.off()

##################################################################################
## Hospital beds needed per day, by state ########################################
##################################################################################

##################################################################################
## Hospital beds needed per day, across models: California only ##################
##################################################################################

beds_california <- outputs[which(outputs$output_name == "Hospital beds needed per day" & outputs$location == "California" &
                                 outputs$date >= as.Date("2020-04-08") &
                                 outputs$date <= as.Date("2020-07-01") &
                                 outputs$run_name != "IHME (4/5/2020)" ## exclude this because it's identical to the run from 4/7/20 and so it's just getting directly plotted over
                                 ),]

beds_california$run_name <- factor(beds_california$run_name,
                                   levels = c("IHME (4/7/2020)", "IHME (4/1/2020)",
                                              "CHIME (4/8/2020, 50% reduction in social contact)", "CHIME (4/8/2020, 30% reduction in social contact)",
                                              "COVID Act Now (4/7/20, strict stay at home)", "COVID Act Now (4/10/20, strict stay at home)", "COVID Act Now (4/7/20, lax stay at home)", "COVID Act Now (4/10/20, lax stay at home)"))

beds_california$model_name <- factor(beds_california$model_name,
                                     levels = c("IHME COVID-19 Model","CHIME", "COVID Act Now"))

#pdf(paste("analysis/static_figures/CA_bed_demand_comparison_", date(), ".pdf", sep = ""), height = 2.5, width = 8.5)
ggplot(beds_california,
       aes(x = date, y = value, color = run_name)) +
  geom_line(size = 1) +
  scale_y_continuous(label = comma) +
  scale_color_manual(values = c("#006d2c", "#a1d99b", "#6a51a3", "#9e9ac8", "#7f2704", "#d94801", "#f16913", "#fd8d3c")) +
  guides(color = guide_legend(title = "Model Run")) +
  ylab("Hospital beds needed per day") +
  xlab("") +
  theme_bw() +
  facet_wrap(~model_name) +
  ggtitle("COVID-19 Hospital bed demand per day in California")

## adding 1 just to avoid taking the log of zero, magnitudes are so large that it's impossible to discern from the plot
ggplot(beds_california,
       aes(x = date, y = value + 1, color = run_name)) +
  geom_line(size = 1) +
  scale_y_continuous(label = comma, trans = "log10") +
  scale_color_manual(values = c("#006d2c", "#a1d99b", "#6a51a3", "#9e9ac8", "#7f2704", "#d94801", "#f16913", "#fd8d3c")) +
  guides(color = guide_legend(title = "Model Run")) +
  ylab("Hospital beds needed per day (Log scale)") +
  xlab("") +
  theme_bw() +
  facet_wrap(~model_name) +
  ggtitle("COVID-19 Hospital bed demand per day in California")
#dev.off()

################################################################################
## Which models have which data the whole US?  #################################
################################################################################

table(outputs$model_name[outputs$location == "United States of America"], outputs$output_name[outputs$location == "United States of America"])

#################################################################
## Compare available models for whole US  #######################
#################################################################

## specify the week corresponding the the date
## weeks identified as "week ending" with weeks starting on Sunday and ending on Saturday, as is the way the Imperial College London are reported
## we want weeks that start on Sunday and end on Saturday, as defined in the data dictionary and reported in available Imperial College London results
## now all week endings are Saturdays here

outputs$week_ending <- ceiling_date(outputs$date, "week", week_start = getOption("lubridate.week.start", 6),
                                    change_on_boundary = FALSE)

## we have daily fatality data from IHME and Neher (if/when Neher is giving the types of outputs we need), convert that to weekly data so we can compare with the Imperial College London model results
weekly_fatalities_from_daily <- 
  outputs[which(outputs$model_name %in% c("IHME COVID-19 Model") & outputs$output_name == "Fatalities per day" &
                outputs$run_name != "IHME (4/5/2020)" ## exclude this because it's identical to the run from 4/7/20 and so it's just getting directly plotted over
          ),] %>% 
  group_by(week_ending, model_name, model_run_id, run_name, model_snapshot_date, output_name, location) %>% 
  summarize(weekly_fatalities = sum(value))

## just grab the weekly fatality data
weekly_fatalities_from_weekly <- outputs[which(outputs$model_name %in% c("Imperial College London COVID-19 Model") & outputs$output_name == "Fatalities per week"),]

## smush them together
weekly_fatalities <- rbind.data.frame(cbind.data.frame(model_name = weekly_fatalities_from_weekly$model_name,
                                                       run_name = weekly_fatalities_from_weekly$run_name,
                                                       model_snapshot_date = weekly_fatalities_from_weekly$model_snapshot_date,
                                                       output_name = weekly_fatalities_from_weekly$output_name,
                                                       location = weekly_fatalities_from_weekly$location,
                                                       week_ending = weekly_fatalities_from_weekly$week_ending,
                                                       value = weekly_fatalities_from_weekly$value),
                                      cbind.data.frame(model_name = weekly_fatalities_from_daily$model_name,
                                                       run_name = weekly_fatalities_from_daily$run_name,
                                                       model_snapshot_date = weekly_fatalities_from_daily$model_snapshot_date,
                                                       output_name = weekly_fatalities_from_daily$output_name,
                                                       location = weekly_fatalities_from_daily$location,
                                                       week_ending = weekly_fatalities_from_daily$week_ending,
                                                       value = weekly_fatalities_from_daily$weekly_fatalities))


weekly_fatalities$run_name <- factor(weekly_fatalities$run_name,
                                     levels = c("IHME (4/1/2020)",
                                                "IHME (4/7/2020)",
                                                "Imperial College (4/7/10, model 1)",
                                                "Imperial College (4/7/10, model 2)",
                                                "Imperial College (4/7/10, model 3)",
                                                "Imperial College (4/7/10, unweighted ensemble)"))

weekly_fatalities$model_name <- factor(weekly_fatalities$model_name,
                                     levels = c("IHME COVID-19 Model","Imperial College London COVID-19 Model"))

  

#pdf(paste("analysis/static_figures/US_weekly_fatality_comaprison_", date(), ".pdf", sep = ""), height = 2.5, width = 9)
ggplot(weekly_fatalities[which(weekly_fatalities$location == "United States of America" &
                               weekly_fatalities$week_ending >= "2020-03-17" &
                               weekly_fatalities$week_ending <= "2020-04-12"),],
       aes(x = week_ending, y = value, color = run_name)) +
  geom_line(size = 1) +
  scale_y_continuous(label = comma) +
  scale_color_manual(values = c("#006d2c", "#41ab5d", "#084594", "#2171b5", "#4292c6", "#6baed6")) +
  guides(color = guide_legend(title = "Model Run")) +
  ylab("COVID-19 Fatalities per week") +
  xlab("Week ending") +
  theme_bw() +
  facet_wrap(~model_name) +
  ggtitle("COVID-19 Fatalities per week in the United States")
#dev.off()

#################################################################
## Compare available models for Spain  ##########################
#################################################################

pdf(paste("analysis/static_figures/spain_weekly_fatality_comaprison_", date(), ".pdf", sep = ""), height = 2.5, width = 9)
ggplot(weekly_fatalities[which(weekly_fatalities$location == "Spain" &
                                 weekly_fatalities$week_ending >= "2020-03-17" &
                                 weekly_fatalities$week_ending <= "2020-04-12"),],
       aes(x = week_ending, y = value, color = run_name)) +
  geom_line(size = 1) +
  scale_y_continuous(label = comma) +
  scale_color_manual(values = c("#006d2c", "#084594", "#2171b5", "#4292c6", "#6baed6")) +
  guides(color = guide_legend(title = "Model Run")) +
  ylab("COVID-19 Fatalities per week") +
  xlab("Week ending") +
  theme_bw() +
  facet_wrap(~model_name) +
  ggtitle("COVID-19 Fatalities per week in Spain")
dev.off()

#dev.off()