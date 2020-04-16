###################################################################################
## Load libraries and custom functions ############################################
###################################################################################

## if you haven't already installed these, run installation for each package by 
## running the code below, which is currently commented out
#install.packages(c("shiny"))
library(shiny)

###################################################################################
## Run the app ####################################################################
###################################################################################

source("/Users/seaneff/Documents/covid-ensemble/analysis/shiny/data_processing.R")
runApp("/Users/seaneff/Documents/covid-ensemble/analysis/shiny")
