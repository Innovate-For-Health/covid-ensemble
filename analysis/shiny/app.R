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

## set working directory to source file location (covid-ensemble as pulled from git)
## if you're not Steph, this will need to change
setwd("/Users/seaneff/Documents/covid-ensemble/")

source("analysis/shiny/data_processing.R")
runApp("analysis/shiny")
