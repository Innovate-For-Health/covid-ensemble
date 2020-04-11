######################################################################
## Load required libraries  ##########################################
######################################################################

library(dplyr) 
library(ggplot2)
library(scales)

server <- function(input, output) {
  
  ######################################################################
  ## Read in data ######################################################
  ######################################################################
    
    ## read in full list  of model outputs
    outputs <- read.delim("~/Documents/covid-ensemble/data/model_outputs.txt", stringsAsFactors = FALSE)
    model_runs <- read.delim("~/Documents/covid-ensemble/data/model_runs.txt", stringsAsFactors = FALSE)
    
    ## find the most recent model run for each specified model
    most_recent_model_runs <- model_runs %>%
      group_by(model_name, assumed_mitigation) %>% 
      arrange(desc(model_snapshot_date)) %>% 
      slice(1)
    
    outputs <- merge(outputs, model_runs[,-which(names(model_runs) == "notes"),], by = "model_run_id", all.x = TRUE, all.y = FALSE)
  
    
    ## format date as a date
    outputs$date <- as.Date(outputs$date)
    
  ######################################################################
  ## Filter data as needed #############################################
  ######################################################################
    
    ## filter data based on the location and input selected
    selectedOutputs <- reactive({
      outputs %>% 
        dplyr::filter(location %in% input$location & 
                      output_name %in% input$output_name
        )
    })
    
    ######################################################################
    ## Generate plot: most recent models #################################
    ######################################################################
    
    output$compare_most_recent_models <- renderPlot({
      ggplot(selectedOutputs()[which(selectedOutputs()$model_run_id %in% most_recent_model_runs$model_run_id),],
             aes(x = date, y = value, color = run_name)) +
        geom_line(size = 1) +
        scale_y_continuous(label = comma) +
        guides(color = guide_legend(title = "Model Run")) +
        ylab(input$output_name) +
        xlab("Date") +
        theme_bw() +
        facet_wrap(~model_name) 
        #ggtitle("COVID-19 Hospital bed demand per day in California")
    })
    
    ######################################################################
    ## Generate plot: compare models over time ###########################
    ######################################################################
    
    output$compare_models_over_time <- renderPlot({
      ggplot(selectedOutputs(),
             aes(x = date, y = value, color = run_name)) +
        geom_line(size = 1) +
        scale_y_continuous(label = comma) +
        guides(color = guide_legend(title = "Model Run")) +
        ylab(input$output_name) +
        xlab("Date") +
        theme_bw() +
        facet_wrap(~model_name) 
      #ggtitle("COVID-19 Hospital bed demand per day in California")
    })
    
    
  }