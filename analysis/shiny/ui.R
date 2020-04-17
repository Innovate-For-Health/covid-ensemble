
###################################################################################
## User interface #################################################################
###################################################################################

ui <- navbarPage("COVID Model Inventory", id = "tabs",

###################################################################################
## Welcome tab ####################################################################
###################################################################################

tabPanel("Overview",
         mainPanel(
           h2("COVID Model Inventory"),
           
           p("Welcome! This project was developed to facilitate reproducible epidemiological modeling for COVID-19 response and recovery."),
           
           h3("Goals and Audience"),
           
           p("Public health researchers and responders have rapidly responded to the COVID-19 
             outbreak by developing models to forecast how the outbreak might unfold under various possible scenarios. 
             In the absence of a central data repository or coordinating body for public health response modeling, 
             it is often difficult to rapidly access, understand, and compare results from different models currently being used to inform policy decisions."),
           
             p("To monitor how different models have changed over time, 
               compare the assumptions and results of these models, 
               and evaluate evidence to inform policy decisions, 
               it's first necessary to align modeling results to be able to compare 'apples to apples'.
               This project aims to fill that gap and to enable researchers, 
               public health experts, and policy-makers to understand how models have changed over time and how they differ 
               in their underlying assumptions, approaches, and results."),
           
           # h3("How to use this site"),
           # p("Click on the", tags$b("View models"), "tab to view available modeling results
           #   for a given location. Compare results across different models,
           #   see how a single model has changed over time, or explore multiple iterations
           #   of a single model run under a series of different future scenarios (e.g., with and without social distancing)."),
           # 
           # p("Access key assumptions and links to additional information and documentation about each model in the",
           #   tags$b("Model inventory"), "tab. Use the", tags$b("Download data"), "to access available results across models."),
           
           h4("Disclaimer"),
           
           p("This site is not intended to act as a substitute for accessing each individual model developer's data visualizations and available documentation.
           If you are using these model results to develop plans or prioritize response efforts, please also consult each model developer's original documentation and 
           most recently available results. This site was developed specifically to archive publicly available modeling results and to highlight changes and differences 
           assumptions and approaches between models, but is not indended to be used as an operational response tool."))),

###################################################################################
## View Models: Sidebar selections  ###############################################
###################################################################################

tabPanel("View models",

           sidebarPanel(
             
             selectInput(inputId = "location",
                         label = "Select location:",
                         choices = locations_agg,
                         selected = "California"),
             
             selectInput(inputId = "output_name",
                     label = "Select model outputs:",
                     choices = outputs_agg,
                     selected = "Hospital beds needed per day"),
             
             ## if you want to look at changes in a model over time, you need to pick one model to look at
             conditionalPanel(condition = "input.model_tab == 'monitor' || input.model_tab == 'parameters'" ,
                       selectInput(inputId = "model_name", 
                                   label = "Select model:", 
                                   choices = c("IHME COVID-19 Model", "COVID Act Now US Intervention Model", "Shaman Lab Model")))
             
           ),
         
            mainPanel(
              tabsetPanel(type = "tab", id = "model_tab",

###################################################################################
## View Models: Plots  ############################################################
###################################################################################
                          
                          tabPanel(value = "compare", title = "Compare multiple models",
                                   h4("How do the results of different models compare?"),
                                   plotOutput("compare_most_recent_models"),
                                   h5("What does this plot show? How should it be interpreted?"),
                                  p("This plot shows the most recent available model estimates, over time, for each model that estimates the number of",
                                  textOutput("model_output", inline = TRUE), "."),
                                  p("Models are developed for different intended uses and should be interpreted based on the context for which they were developed.
                                    This plot is intended to illustrate how different models may produce different results over time, based on differences in underlying data inputs, parameters, or assumptions.
                                    If you are using these model results to develop plans or prioritize response efforts, please also consult each model developer's original documentation and 
                                    most recently available results.")
                                  
                                   ),
                          tabPanel(value = "monitor", title = "Monitor changes over time", 
                                   h4("How have the results of a single model changed over time?"),
                                   plotOutput("compare_models_over_time"),
                                   h5("What does this plot show? How should it be interpreted?"),
                                 #  p("This plot shows the most recent available model estimates, over time, for each model that estimates the number of",
                                  #   textOutput("model_output", inline = TRUE), "."),
                                   p("Models are developed for different intended uses and should be interpreted based on the context for which they were developed.
                                    This plot is intended to illustrate how different models may produce different results over time, based on differences in underlying data inputs, parameters, or assumptions.
                                    If you are using these model results to develop plans or prioritize response efforts, please also consult each model developer's original documentation and 
                                    most recently available results.")
                                   
                                   ),
                          tabPanel(value = "parameters", title = "Explore impact of assumptions",
                                   h4("How do the assumptions or inputs of a single model impact its results?"),
                                   plotOutput("compare_models_over_assumptions"),
                                   h5("What does this plot show? How should it be interpreted?"),
                                   #  p("This plot shows the most recent available model estimates, over time, for each model that estimates the number of",
                                   #   textOutput("model_output", inline = TRUE), "."),
                                   p("Models are developed for different intended uses and should be interpreted based on the context for which they were developed.
                                    This plot is intended to illustrate how different models may produce different results over time, based on differences in underlying data inputs, parameters, or assumptions.
                                    If you are using these model results to develop plans or prioritize response efforts, please also consult each model developer's original documentation and 
                                    most recently available results."))
                          )

         )),


###################################################################################
## Model inventory ################################################################
###################################################################################

tabPanel("Model inventory",
         mainPanel(
           h3("What is a model?"),
           h3("How are models being used in COVID-response?"),
           h3("Model inventory"),
           h4("IHME COVID-19 Model"),
           h4("COVID Act Now"),
           h4("Shaman Lab Model")
         )),

###################################################################################
## Download Data Tab ##############################################################
###################################################################################

tabPanel("Download data",
         mainPanel(DT::dataTableOutput("output_table"))),

###################################################################################
## Documentation Tab ##############################################################
###################################################################################

tabPanel("Documentation",
         mainPanel(
           h3("Motivation"),
           p("This project was developed to facilitate open-source, reproducible epidemiological modeling for COVID-19 response and recovery.
              As the COVID-19 outbreak continues to rapidly progress, policy-makers, public health responders, and researchers 
              rely, in part, on the results of epidemiological models to understand how the outbreak might progress over time and
              across geographies."),
            
              p("However, different models are being produced and used by different groups, each with their own unique set of assumptions,
              underlying data inputs and methods, and intended uses. Moreover, these models often document their approaches and report
              or export their results in formats that make it difficult to compare results across models.
             This project was developed to fill that gap."),
           
           h3("Approach"),
            
           p("To monitor how different models have changed over time, compare the assumptions and results of these models, 
               and evaluate the best available evidence to inform policy decisions, it's first necessary to align modeling results to be able to compare 'apples to apples'.
               This requires an overarching data architecture that aligns results from different models into a common dataset.
               The results of different models are reported over:"),
           
           tags$ul(
             tags$li("different time spans (e.g., January through August vs. for the 'next two weeks'"), 
             tags$li("different geographic resolutions (e.g., county vs. state vs. national)"), 
             tags$li("different temporal resolutions (e.g., daily vs. weekly)"),
             tags$li("different model outputs (e.g., new fatalities per day vs. cumulative fatalities"),
             tags$li("different data formats (e.g., embedded in a PDF table vs. .json vs. .csv")),
           
             p("To enable comparisons, these model results are mapped to a common data structure, with corresponding
             documentation in a data dictionary. As new model results become available, they are documented, archived,
             and processed via a series of routinely run R scripts to add them to a relational data structure
               (currently managed as a series of flat tab-delimited files stored in git)."),
           
           p("This is a work in progress! New models are currently being assessed and added in a rolling fashion. 
             This site itself is also being updated regularly, including improvements to its design, underlying
             data visualizations, and documentation.")))
)

