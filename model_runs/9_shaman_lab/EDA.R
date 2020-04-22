data_15 <- read.csv("~/Documents/covid-ensemble/model_runs/9_shaman_lab/model_export/15_bed_60contact.csv", header = TRUE)
data_31 <- read.csv("~/Documents/covid-ensemble/model_runs/9_shaman_lab/model_export/31_bed_60contact.csv", header = TRUE)

length(unique(data_15$fips))
length(unique(data_31$fips))
