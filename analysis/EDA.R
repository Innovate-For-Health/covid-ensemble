#################################################################
## Load required packages #######################################
#################################################################

library(ggplot2)
library(scales)

#################################################################
## Load datasets #######################
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
## Hospital beds needed per day, across models: California only ##################
##################################################################################

beds_california <- outputs[which(outputs$output_name == "Hospital beds needed per day" & outputs$location == "California" &
                                 outputs$date >= as.Date("2020-04-08") &
                                 outputs$date <= as.Date("2020-07-01")),]

beds_california$run_name <- factor(beds_california$run_name,
                                   levels = c("IHME (4/7/2020)", "IHME (4/5/2020)", "IHME (4/1/2020)",
                                              "CHIME (4/8/2020, 50% reduction in social contact)", "CHIME (4/8/2020, 30% reduction in social contact)",
                                              "COVID Act Now (4/7/20, strict stay at home)", "COVID Act Now (4/7/20, lax stay at home)"))

pdf(paste("analysis/static_figures/CA_bed_demand_comparison", date(), ".pdf", sep = ""), height = 2.5, width = 8)
ggplot(beds_california,
       aes(x = date, y = value + 1, color = run_name)) +
  geom_line(size = 1) +
  scale_y_continuous(label = comma) +
  scale_color_manual(values = c("#006d2c", "#41ab5d", "#a1d99b", "#6a51a3", "#9e9ac8", "#f16913", "#fdae6b")) +
  guides(color = guide_legend(title = "Model Run")) +
  ylab("Hospital beds needed per day") +
  xlab("") +
  theme_bw() +
  facet_wrap(~model_name) +
  ggtitle("COVID-19 Hospital demand per day in California")

ggplot(beds_california,
       aes(x = date, y = value + 1, color = run_name)) +
  geom_line(size = 1) +
  scale_y_continuous(label = comma, trans = "log10") +
  scale_color_manual(values = c("#006d2c", "#41ab5d", "#a1d99b", "#6a51a3", "#9e9ac8", "#f16913", "#fdae6b")) +
  guides(color = guide_legend(title = "Model Run")) +
  ylab("Hospital beds needed per day (Log scale)") +
  xlab("") +
  theme_bw() +
  facet_wrap(~model_name) +
  ggtitle("COVID-19 Hospital demand per day in California")
dev.off()

################################################################################
## Which models have which data the whole US?  #################################
################################################################################

table(outputs$model_name[outputs$location == "United States of America"], outputs$output_name[outputs$location == "United States of America"])

#################################################################
## Compare available models for whole US  #######################
#################################################################
# 
# ## workaround until I figure out the Imperial College date thing -- mismatch between documentation and exportable data
# ## assuming that documentation is right and that the field called "end of week" is in reality the beginning of the week
# ## todo: figure this out and fix in a more robust/consistent way
# 
# outputs[which(outputs$model_name == "Imperial College London COVID-19 Model" &
#               outputs$output_name == "Fatalities per week"),]$date <-
#   outputs[which(outputs$model_name == "Imperial College London COVID-19 Model" &
#                   outputs$output_name == "Fatalities per week"),]$date + 6 ## see note above for why I did this weird thing, with more details in readme in Imperial College model_runs file
# 
# 
# week(x)
# week(x) <- value
# 
# isoweek(x)
# 
# epiweek(x)
# 
#  ggplot(model_outputs[which(model_outputs$location == "United States of America" & 
#                            model_outputs$output_name == "ICU beds per day" &
#                            model_outputs$model_snapshot_date == as.Date("4/7/20")),],
#              aes(x = date, y = value, color = model_name)) + 
#         geom_line(size = 1) +
#         scale_y_continuous(label = comma) +
#         guides(color = guide_legend(title = "Model (as of 4/7/20")) +  
#         ylab("ICU beds needed per day") +
#         xlab("") +
#         ggtitle("Estimated ICU beds needed per day\nin United States") +
#         theme_bw()
