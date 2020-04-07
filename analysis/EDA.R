#################################################################
## Load required packages #######################################
#################################################################

library(ggplot2)
library(scales)

#################################################################
## Load datasets and set fixed parameters #######################
#################################################################

model_outputs <- read.delim("data/model_outputs.txt", stringsAsFactors = FALSE)
model_runs <- read.delim("data/model_runs.txt", stringsAsFactors = FALSE)

#################################################################
## Format data ##################################################
#################################################################

model_outputs$date <- as.Date(model_outputs$date)

#################################################################
## Create master dataset: runs ##################################
#################################################################

model_outputs <- merge(model_outputs, model_runs, by = "model_run_id", all.x = TRUE, all.y = FALSE)
model_outputs$model_run_description <- paste(model_outputs$model_name, " (version ", model_outputs$model_snapshot_date, ")", sep = "")
model_outputs$date <- as.Date(model_outputs$date)

#################################################################
## Compare IHME model progression over time #####################
#################################################################

ihme_hospital_admissions <- model_outputs[which(model_outputs$output_name == "hospital admissions per day" &
                      model_outputs$model_name == "IHME COVID-19 Model" &
                      model_outputs$date >= "2020-03-01" &
                      model_outputs$date <= "2020-07-01"),]

ihme_cumulative_fatalities <- model_outputs[which(model_outputs$output_name == "cumulative fatalities" &
                                                  model_outputs$model_name == "IHME COVID-19 Model" &
                                                  model_outputs$date >= "2020-03-01" &
                                                  model_outputs$date <= "2020-07-01"),]



for(loc in unique(ihme_hospital_admissions$location)){
  filename <- paste("analysis/static_figures/IHME_comparison_", loc, ".pdf", sep = "")
  pdf(file = filename, height = 3.5, width = 5.5)
  
  print(ggplot(ihme_hospital_admissions[which(ihme_hospital_admissions$location == loc),], 
       aes(x = date, y = value, color = model_snapshot_date)) + 
  geom_line(size = 1) +
  scale_y_continuous(label = comma) +
  scale_color_manual(values = rev(c("#08519c",  "#3182bd", "#6baed6"))) +
  guides(color = guide_legend(title = "Model Snapshot date")) +  
  ylab(paste("Daily hospital admissions (", loc, ")", sep = "")) +
  xlab("") + 
  ggtitle(paste("Projected daily hospital admissions\nIHME Model (", loc, ")", sep = "" )) +
  theme_bw())
  
  print(ggplot(ihme_cumulative_fatalities[which(ihme_cumulative_fatalities$location == loc),], 
               aes(x = date, y = value, color = model_snapshot_date)) + 
          geom_line(size = 1) +
          scale_y_continuous(label = comma) +
          scale_color_manual(values = rev(c("#08519c",  "#3182bd", "#6baed6"))) +
          guides(color = guide_legend(title = "Model Snapshot date")) +  
          ylab(paste("Cumulative fatalities (", loc, ")", sep = "")) +
          xlab("") + 
          ggtitle(paste("Projected cumulative fatalities\nIHME Model (", loc, ")", sep = "" )) +
          theme_bw())
  
  dev.off()
}

