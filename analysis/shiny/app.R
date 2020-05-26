###################################################################################
## Load libraries and custom functions ############################################
###################################################################################

## if you haven't already installed these, run installation for each package by 
## running the "install.packages" code below, which is currently commented out
#install.packages(c("shiny"))
#install.packages(c("dplyr"))
#install.packages(c("here"))
#install.packages(c("scales"))

library(shiny)
library(dplyr)
library(here)
library(scales)

###################################################################################
## Run the app ####################################################################
###################################################################################

source(here("analysis", "shiny", "data_processing.R"))
runApp(here("analysis", "shiny"))

