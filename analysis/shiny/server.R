######################################################################
## Load required libraries  ##########################################
######################################################################

library(dplyr) 
library(ggplot2)
library(scales)
#library(DT)

server <- function(input, output, session) {
  
    
    ######################################################################
    ## Update UI filters based on other UI filters #######################
    ######################################################################
    
  ## if someone changes the location, only show potential outputs that are actually available for that location
    # observe({
    #   x_loc <- input$location
    # 
    #   updateSelectInput(session, "output_name",
    #                   choices = list("Healthcare demand" = outputs_agg$`Healthcare demand`[which(outputs_agg$`Healthcare demand` %in% outputs$output_name[which(outputs$location == x_loc)])],
    #                                  "Caseload and fatalities" = outputs_agg$`Caseload and fatalities`[which(outputs_agg$`Caseload and fatalities` %in% outputs$output_name[which(outputs$location == x_loc)])]))
    #   })

  
    ## update select model input
    #if someone changes the model outputs, only show potential models that are actually available for that location
    observe({
      x_output <- input$output_name

      updateSelectInput(session, "model_name",
                        choices = sort(unique(outputs[which(outputs$output_name == x_output & outputs$model_name != "Columbia University Model" & outputs$model_name != "UCLA COVID-19 Model"),]$model_name)))
    })

    ######################################################################
    ## Generate explanatory text blurbs ##################################
    ######################################################################
    
    ## add a period to this one because it will always come at the end of a sentence
    output$model_output <- renderText({ print(paste(tolower(input$output_name), ".", sep = "")) })
    
    ## remove the word "model" from this based on how it's used in a sentence in the UI
    output$model_name <- renderText({ print(input$model_name) }) 
    
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
     #     filter(location %in% "United States of America" &
     #              output_name %in%  "Hospital beds needed per day" ) %>%
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
    
    ## for debugging
    # selectedOutputsModelAssumption <-  outputs[which(outputs$compare_across_assumptions == TRUE),] %>%
    #     filter(location %in% "California" &
    #              output_name %in% "Hospital beds needed per day" &
    #              model_name %in% "Columbia University Model") %>%
    #     arrange(desc(model_snapshot_date))
    
    ######################################################################
    ## Pick primary color palette depending on model ######################
    ######################################################################

    ## LANL COVID-19 Model: #1f78b4
    ## IHME: #31a354
    ## Columbia University (previously Shaman): #756bb1
    ## GLEAM: #dd1c77
    ## COVID-Act Now: #fd8d3c

    color_function_cm <- function(model_name){
      temp <- c()
      #if("Columbia University Model" %in% model_name){temp <- c(temp, "#756bb1")}
      if("COVID Act Now US Intervention Model" %in% model_name){temp <- c(temp, "#fd8d3c")}
      if("COVID19-projections.com" %in% model_name){temp <- c(temp, "darkmagenta")}
      if("GLEAM" %in% model_name){temp <- c(temp, "#dd1c77")}
      if("IHME COVID-19 Model" %in% model_name){temp <- c(temp, "#31a354")}
      if("LANL COVID-19 Model" %in% model_name){temp <- c(temp, "#1f78b4")}
      if("MIT DELPHI Model" %in% model_name){temp <- c(temp, "#756bb1")} ## right now showing this instead of Columbia due to lack of documentation
      if("NotreDame-FRED Forecast" %in% model_name){temp <- c(temp, "#6f94c5")}
      if("UCLA COVID-19 Model" %in% model_name){temp <- c(temp, "firebrick3")}

      
      
      return(temp)
    }
    
    ## for compare models plot
    model_palette_cm <- reactive({
       color_function_cm(selectedOutputs()$model_name)
    })
    
    #fredfunc <- colorRampPalette(c( "#cbe2ff", "#6f94c5"))
    #barplot(1:8, col=fredfunc(8)); # https://encycolorpedia.com/a6bddb
             
    color_function_mt <- function(model_name){
      temp <- c()
      #if("Columbia University Model" %in% model_name){temp <- c(temp, "Purples")}
      if("COVID Act Now US Intervention Model" %in% model_name){temp <- c(temp, "Oranges")}
      if("COVID19-projections.com" %in% model_name){temp <- c(temp, "PuRd")}
      if("GLEAM" %in% model_name){temp <- c(temp, "RdPu")}
      if("IHME COVID-19 Model" %in% model_name){temp <- c(temp, "Greens")}
      if("LANL COVID-19 Model" %in% model_name){temp <- c(temp, "Blues")}
      if("MIT DELPHI Model" %in% model_name){temp <- c(temp, "Purples")}  ## right now showing this instead of Columbia due to lack of documentation
      if("NotreDame-FRED Forecast" %in% model_name){temp <- c(temp, "GnBu")} 
      if("UCLA COVID-19 Model" %in% model_name){temp <- c(temp, "Reds")} 
      
      
      return(temp)
    }

    ## for compare model over time plot
    model_palette_mt <- reactive({
      color_function_mt(selectedOutputsModelTime()$model_name)
    })  
    

    ## for compare model assumptions plot
    model_palette_ma <- reactive({
      color_function_mt(selectedOutputsModelAssumption()$model_name)
      
    })  
    
    ######################################################################
    ## Generate plot: most recent models #################################
    ######################################################################
    

    output$compare_most_recent_models <- renderPlot({
      
      ## if data exist to make this plot, make this plot!
      if(nrow(selectedOutputs()[which(selectedOutputs()$model_run_id %in% most_recent_model_runs$model_run_id &
                                      ## for now set focus to  May through June
                                      selectedOutputs()$date >= as.Date("2020-05-01") &
                                      selectedOutputs()$date < as.Date("2020-07-01")),]) > 0){
      print(ggplot(selectedOutputs()[which(selectedOutputs()$model_run_id %in% most_recent_model_runs$model_run_id &
                                       ## for now set focus to  May through June
                                     selectedOutputs()$date >= as.Date("2020-05-01") &
                                     selectedOutputs()$date < as.Date("2020-07-01")),],
             aes(x = date, y = value, color = run_name)) +
        geom_line(size = 1) +
        scale_y_continuous(label = comma) +
        guides(color = guide_legend(title = "Model Run")) +
        ggtitle(paste("Projected ", input$output_name, ":\n", input$location, sep = "")) + 
        ylab(input$output_name) +
        xlab("") +
        scale_color_manual(values = model_palette_cm()) +
        theme_light())}
      
      ## if data don't exist to make this plot, show some explanatory text saying we don't have the data
      if(any(selectedOutputs()$model_run_id %in% most_recent_model_runs$model_run_id &
             selectedOutputs()$date >= as.Date("2020-05-01") &
             selectedOutputs()$date < as.Date("2020-07-01")) == FALSE){

        print(plot(c(0, 1), c(0, 1), ann = F, bty = 'n', type = 'n', xaxt = 'n', yaxt = 'n'))
        print(text(x = 0.5, y = 0.5, paste("At this time, no results are available\nfor the selected location and model outputs.\nPlease explore other options from the drop-down menu."),
             cex = 1, col = "black"))
      }
      
      
    })
    
    ######################################################################
    ## Generate plot: compare model over time ############################
    ######################################################################
    
    output$compare_models_over_time <- renderPlot({
      
      ## if data exist to make this plot, make this plot!
      if(nrow(selectedOutputsModelTime()[which( 
        selectedOutputsModelTime()$date >= as.Date("2020-05-01") &
        selectedOutputsModelTime()$date < as.Date("2020-07-01")),]) > 0){
        
      print(ggplot(selectedOutputsModelTime()[which( ## for now set focus on May through June
                selectedOutputsModelTime()$date >= as.Date("2020-05-01") &
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
        theme_light())
      }
      
      ## if data don't exist to make this plot, show some explanatory text saying we don't have the data
      if(any(selectedOutputsModelTime()$date >= as.Date("2020-05-01") &
             selectedOutputsModelTime()$date < as.Date("2020-07-01")) == FALSE){
        
        print(plot(c(0, 1), c(0, 1), ann = F, bty = 'n', type = 'n', xaxt = 'n', yaxt = 'n'))
        print(text(x = 0.5, y = 0.5, paste("At this time, no results are available\nfor the selected location, model, and outputs selected.\nPlease explore other options from the drop-down menu."),
                   cex = 1, col = "black"))
        
      }
    })
    
    ######################################################################
    ## Generate plot: compare model assumptions ##########################
    ######################################################################
    
    output$compare_models_over_assumptions <- renderPlot({
      
      ## if data exist to make this plot, make this plot!
      if(nrow(selectedOutputsModelAssumption()[which( 
        selectedOutputsModelAssumption()$date >= as.Date("2020-05-01") &
        selectedOutputsModelAssumption()$date < as.Date("2020-07-01")),]) > 0){
      
      print(ggplot(selectedOutputsModelAssumption()[which( ## for now set focus on May through June
        selectedOutputsModelAssumption()$date >= as.Date("2020-05-01") &
          selectedOutputsModelAssumption()$date < as.Date("2020-07-01")),],
        aes(x = date, y = value, 
            ## format model run name as a factor so ggplot2 doesn't hijack the ordering I want
            color = factor(key_assumptions, levels = rev(unique(selectedOutputsModelAssumption()$key_assumptions))))) +
        geom_line(size = 1) +
        scale_y_continuous(label = comma) +
        guides(color = guide_legend(title = "Model Run")) +
        ggtitle(paste("Projected ", input$output_name, ":\n", input$location, "\n", input$model_name, sep = "")) + 
        ylab(input$output_name) +
        scale_colour_brewer(palette = model_palette_ma(),
                            ## colors are sequential -- show a gradient here
                            type = "seq",
                            ## gradient should make the darket color the most recent
                            direction = 1) +
        xlab("") +
        theme_light())
      }
      
      ## if data don't exist to make this plot, show some explanatory text saying we don't have the data
      if(any(selectedOutputsModelAssumption()$date >= as.Date("2020-05-01") &
             selectedOutputsModelAssumption()$date < as.Date("2020-07-01")) == FALSE){
        
        print(plot(c(0, 1), c(0, 1), ann = F, bty = 'n', type = 'n', xaxt = 'n', yaxt = 'n'))
        print(text(x = 0.5, y = 0.5, paste("At this time, no results are available\nfor the selected location, model, and outputs selected.\nPlease explore other options from the drop-down menu."),
                   cex = 1, col = "black"))
        
      }
      
      
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
