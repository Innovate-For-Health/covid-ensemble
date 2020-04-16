######################################################################
## Load required libraries  ##########################################
######################################################################

library(dplyr) 
library(ggplot2)
library(scales)
library(DT)


server <- function(input, output, session) {
  
    
    ######################################################################
    ## Update UI filters based on other UI filters #######################
    ######################################################################
    
    ## if someone changes the location, only show potential outputs that are actually available for that location
    observe({
      x_loc <- input$location
    
      updateSelectInput(session, "output_name",
                      choices = outputs$output_name[which(outputs$location == x_loc)],
                      selected = "Hospital beds needed per day")
      })
    
  
    ## if someone changes the location, and the model outputs, only show potential models that are actually available for that location
    observe({
      x_loc <- input$location
      x_output <- input$output_name
      
      updateSelectInput(session, "model_name",
                        choices = outputs$model_name[which(outputs$location == x_loc & outputs$output_name == x_output)])
    })
    
  ######################################################################
  ## Filter data as needed #############################################
  ######################################################################
    
    ## filter data based on the location and mnodel output selected
    selectedOutputs <- reactive({
      outputs %>% 
         filter(location %in% input$location & 
                output_name %in% input$output_name) %>%
        arrange(desc(model_snapshot_date))
    })
    
    ## filter data based on the location, model output, and specific model selected
    selectedOutputsModel <- reactive({
      outputs %>% 
        filter(location %in% input$location & 
               output_name %in% input$output_name &
               model_name %in% input$model_name) %>%
        arrange(desc(model_snapshot_date))
    })
    
    ## debugging
    # selectedOutputsModel <- outputs %>% 
    #   filter(location %in% "United States of America" & 
    #            output_name %in% "Hospital beds needed per day" &
    #            model_name %in% "COVID Act Now (strict stay at home)") %>%
    #   arrange(desc(model_snapshot_date))
    
    ######################################################################
    ## Generate plot: most recent models #################################
    ######################################################################
    
    output$compare_most_recent_models <- renderPlot({
      ggplot(selectedOutputs()[which(selectedOutputs()$model_run_id %in% most_recent_model_runs$model_run_id &
                                       ## for now set focus to March through June
                                     selectedOutputs()$date >= as.Date("2020-03-01") &
                                     selectedOutputs()$date < as.Date("2020-07-01")),],
             aes(x = date, y = value, color = run_name)) +
        geom_line(size = 1) +
        scale_y_continuous(label = comma) +
        guides(color = guide_legend(title = "Model Run")) +
        ggtitle(paste("Projected ", input$output_name, ":\n", input$location, sep = "")) + 
        ylab(input$output_name) +
        xlab("") +
        theme_light() 
    })
    
    ######################################################################
    ## Generate plot: compare models over time ###########################
    ######################################################################
    
    output$compare_models_over_time <- renderPlot({
      
      ggplot(selectedOutputsModel()[which( ## for now set focus to March through June
                selectedOutputsModel()$date >= as.Date("2020-03-01") &
                  selectedOutputsModel()$date < as.Date("2020-07-01")),],
             aes(x = date, y = value, 
                 ## format model run name as a factor so ggplot2 doesn't hijack the ordering I want
                 color = factor(run_name, levels = rev(unique(selectedOutputsModel()$run_name))))) +
        geom_line(size = 1) +
        scale_y_continuous(label = comma) +
        guides(color = guide_legend(title = "Model Run")) +
        ggtitle(paste("Projected ", input$output_name, ":\n", input$location, "\n", input$model_name,  sep = "")) + 
        ylab(input$output_name) +
        scale_colour_brewer(palette = "Greens",
                            ## colors are sequential -- show a gradient here
                            type = "seq",
                            ## gradient should make the darket color the most recent
                            direction = 1) +
        xlab("") +
        theme_light() 
    })
    
    ######################################################################
    ## Let people view the data #########################################
    ######################################################################
    
    output$output_table = DT::renderDataTable({
      datatable(
        outputs[,c(10, 11, 9, 3, 4, 5, 6)],
        rownames = FALSE,
        extensions = "Buttons",
        options = list(pageLength = 25, 
                       autoWidth = TRUE,
                       buttons = c("copy", "csv", "excel"),
                       dom = "Bfrtip"),
        class = "display"
      )
    })
    

  
  }