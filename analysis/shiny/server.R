######################################################################
## Load required libraries  ##########################################
######################################################################

library(dplyr) 
library(ggplot2)
library(scales)
library(DT)

## TODO: make plots not appear when there aren't data to power them

server <- function(input, output, session) {
  
    
    ######################################################################
    ## Update UI filters based on other UI filters #######################
    ######################################################################
    
  ## update select model outputs tab
  ## if someone changes the location, only show potential outputs that are actually available for that location
    observe({
      x_loc <- input$location

      updateSelectInput(session, "output_name",
                      choices = list("Caseload and fatalities" = outputs_agg$`Caseload and fatalities`[which(outputs_agg$`Caseload and fatalities` %in% outputs$output_name[which(outputs$location == x_loc)])],
                                     "Healthcare demand" = outputs_agg$`Healthcare demand`[which(outputs_agg$`Healthcare demand` %in% outputs$output_name[which(outputs$location == x_loc)])]),
                      selected = "Hospital beds needed per day")
      })

  
    ## update select model input
    ## if someone changes the location, and the model outputs, only show potential models that are actually available for that location
    observe({
      x_loc <- input$location
      x_output <- input$output_name

      updateSelectInput(session, "model_name",
                        choices = unique(outputs[which(outputs$location == x_loc & outputs$output_name == x_output),]$model_name))
    })
    
    ######################################################################
    ## Generate explanatory text blurbs ##################################
    ######################################################################
    
    output$model_output <- renderText({ print(tolower(input$output_name)) })
    output$model_name <- renderText({ print(tolower(input$model_name)) }) 
    
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
    
    ## for debugging
    # selectedOutputs <- outputs %>%
    #     filter(location %in% "Alaska" &
    #              output_name %in%  "Hospital beds needed per day") %>%
    #     arrange(desc(model_snapshot_date))

    
    ## filter data based on the location, model output, and specific model selected
    ## this is used for the "monitor changes over time" plot
    selectedOutputsModelTime <- reactive({
      outputs[which(outputs$compare_over_time == TRUE),] %>% 
        filter(location %in% input$location & 
               output_name %in% input$output_name &
               model_name %in% input$model_name) %>%
        arrange(desc(model_snapshot_date))
    })
    
    ## for debugging
    # selectedOutputsModelTime <- 
    #   outputs[which(outputs$compare_over_time == TRUE),] %>% 
    #     filter(location %in% "Alabama" & 
    #              output_name %in% "Fatalities per day" &
    #              model_name %in% c("IHME COVID-19 Model")) %>%
    #     arrange(desc(model_snapshot_date))
    
    ## filter data based on the location, model output, and specific model selected
    ## this is used for the "compare assumptions" plot
    selectedOutputsModelAssumption <- reactive({
      outputs[which(outputs$compare_across_assumptions == TRUE),] %>% 
        filter(location %in% input$location & 
                 output_name %in% input$output_name &
                 model_name %in% input$model_name) %>%
        arrange(desc(model_snapshot_date))
    })
    
    ######################################################################
    ## Pick primary color palette depending on model ######################
    ######################################################################

    ## for compare models plot
    ## TODO: get this working again
    # model_palette_cm <- reactive({
    #   if(all(c("COVID Act Now US Intervention Model", "IHME COVID-19 Model", "Shaman Lab Model") %in% unique(selectedOutputs()$model_name)))
    #     c("#fd8d3c", "#31a354", "#756bb1") else 
    #   if(all(c("COVID Act Now US Intervention Model", "Shaman Lab Model") %in% unique(selectedOutputs()$model_name)))
    #     c("#fd8d3c", "#756bb1") else 
    #       c("#006d2c", "#3182bd", "#e6550d")
    # })  
    # 
    
    ## for compare model over time plot
    model_palette_mt <- reactive({
      unique(ifelse(selectedOutputsModelTime()$model_name == "IHME COVID-19 Model", "Greens",
                       ifelse(selectedOutputsModelTime()$model_name == "Shaman Lab Model", "Purples",
                       ifelse(selectedOutputsModelTime()$model_name == "COVID Act Now US Intervention Model", "Oranges",   
                       "Reds"))))
    })  
    
    ## for compare model assumptions plot
    model_palette_ma <- reactive({
      unique(ifelse(selectedOutputsModelTime()$model_name == "IHME COVID-19 Model", "Greens",
             ifelse(selectedOutputsModelTime()$model_name == "Shaman Lab Model", "Purples",
             ifelse(selectedOutputsModelTime()$model_name == "COVID Act Now US Intervention Model", "Oranges",   
             "Reds"))))
    })  
    
    ######################################################################
    ## Generate plot: most recent models #################################
    ######################################################################
    
    output$compare_most_recent_models <- renderPlot({
      ggplot(selectedOutputs()[which(selectedOutputs()$model_run_id %in% most_recent_model_runs$model_run_id &
                                       ## for now set focus to April through June
                                     selectedOutputs()$date >= as.Date("2020-04-01") &
                                     selectedOutputs()$date < as.Date("2020-07-01")),],
             aes(x = date, y = value, color = run_name)) +
        geom_line(size = 1) +
        scale_y_continuous(label = comma) +
        guides(color = guide_legend(title = "Model Run")) +
        ggtitle(paste("Projected ", input$output_name, ":\n", input$location, sep = "")) + 
        ylab(input$output_name) +
        xlab("") +
        ## TODO: get this working again
        #scale_color_manual(values = model_palette_cm()) +
        theme_light() 
    })
    
    ######################################################################
    ## Generate plot: compare model over time ############################
    ######################################################################
    
    output$compare_models_over_time <- renderPlot({
      ggplot(selectedOutputsModelTime()[which( ## for now set focus to April through June
                selectedOutputsModelTime()$date >= as.Date("2020-04-01") &
                  selectedOutputsModelTime()$date < as.Date("2020-07-01")),],
             aes(x = date, y = value, 
                 ## format model run name as a factor so ggplot2 doesn't hijack the ordering I want
                 color = factor(run_name, levels = rev(unique(selectedOutputsModelTime()$run_name))))) +
        geom_line(size = 1) +
        scale_y_continuous(label = comma) +
        guides(color = guide_legend(title = "Model Run")) +
        ggtitle(paste("Projected ", input$output_name, ":\n", input$location, "\n", input$model_name,  sep = "")) + 
        ylab(input$output_name) +
        scale_colour_brewer(palette = model_palette_mt(),
                            ## colors are sequential -- show a gradient here
                            type = "seq",
                            ## gradient should make the darket color the most recent
                            direction = 1) +
        xlab("") +
        theme_light() 
    })
    
    ######################################################################
    ## Generate plot: compare model assumptions ##########################
    ######################################################################
    
    output$compare_models_over_assumptions <- renderPlot({
      
      ggplot(selectedOutputsModelAssumption()[which( ## for now set focus to April through June
        selectedOutputsModelAssumption()$date >= as.Date("2020-04-01") &
          selectedOutputsModelAssumption()$date < as.Date("2020-07-01")),],
        aes(x = date, y = value, 
            ## format model run name as a factor so ggplot2 doesn't hijack the ordering I want
            color = factor(key_assumptions, levels = rev(unique(selectedOutputsModelAssumption()$key_assumptions))))) +
        geom_line(size = 1) +
        scale_y_continuous(label = comma) +
        guides(color = guide_legend(title = "Model Run")) +
        ggtitle(paste("Projected ", input$output_name, ":\n", input$location, "\n", input$model_name,  sep = "")) + 
        ylab(input$output_name) +
        scale_colour_brewer(palette = model_palette_ma(),
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
