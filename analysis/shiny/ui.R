##################################################################################
## User interface #################################################################
###################################################################################

ui <- navbarPage("COVID Model Inventory", id = "tabs",
                 
                 ###################################################################################
                 ## Welcome tab ####################################################################
                 ###################################################################################
                 
                 tabPanel("Overview",
                          mainPanel(
                            h2("COVID Model Inventory"),
                            
                            p("The COVID Model Inventory was developed support transparency 
                              in epidemiological modeling for COVID-19, including by highlighting
                              key differences between models and monitoring changes in models over time."),
                            
                            h3("Goals and Audience"),
                            
                            p("Public health researchers have developed models to forecast how the COVID-19 pandemic might 
                            unfold under various possible scenarios. However, it is often difficult to rapidly access, 
                            understand, and compare results from the numerous models currently 
                            being used to inform policy decisions and operational planning."),
                            
                            p("This project was developed to allow users to:"),
                            
                            tags$ul(
                              tags$li("compare results across models"), 
                              tags$li("monitor how models have changed over time"), 
                              tags$li("understand how key assumptions influence results")), 

                            h4("Disclaimer"),
                            
                            p("This site is not intended to act as a substitute for accessing each individual model’s visualizations and 
                              available documentation. If you are using these results to develop plans or prioritize response efforts, 
                              please also consult each model’s documentation. This site was developed to archive publicly available modeling 
                              results and is not intended to be used as an operational response tool."))),
                 
                 ###################################################################################
                 ## View Models: Sidebar selections  ###############################################
                 ###################################################################################
                 
                 tabPanel("Model results",
                          
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
                                                         choices = c("IHME COVID-19 Model", "LANL COVID-19 Model", "Shaman Lab Model")))
                            
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
                                                 
                                                 p("This plot shows the most recent estimates produced by each model that forecasts",
                                                   textOutput("model_output", inline = TRUE)),
                                                 
                                                 p("Models are developed for different intended uses and should be interpreted based on the context for which they were developed.
                                                    If you are using these model results to develop plans or prioritize response efforts, please also consult each model developer's original documentation.")),
                                        
                                        tabPanel(value = "monitor", title = "Monitor changes over time",
                                                 
                                                 h4("How have the results of a single model changed over time?"),
                                                 
                                                 plotOutput("compare_models_over_time"),
                                                 
                                                 h5("What does this plot show? How should it be interpreted?"),
                                                 
                                                 p("This plot shows outputs from multiple iterations of the", textOutput("model_name", inline = TRUE), 
                                                 "over time, as the input data and/or the model itself have been updated.
                                                  Older iterations are shown in lighter colors, with the most recent iteration of the model being shown as the darkest line.
                                                  Changes in results may reflect changes in model assumptions, input data, or modeling approaches."),
                                                 
                                                 p("Models are developed for different intended uses and should be interpreted based on the context for which they were developed.
                                                    If you are using these model results to develop plans or prioritize response efforts, please also consult each model developer's original documentation.")),
                                        
                                        tabPanel(value = "parameters", title = "Explore impact of assumptions",
                                                 
                                                 h4("How do the assumptions or inputs of a single model impact its results?"),
                                                 
                                                 plotOutput("compare_models_over_assumptions"),
                                                 
                                                 h5("What does this plot show? How should it be interpreted?"),
                                                 
                                                 p("This plot shows outputs from multiple iterations and/or versions of the",
                                                   "selected output, including across different assumptions and data inputs."),

                                                 
                                                 p("Models are developed for different intended uses and should be interpreted based on the context for which they were developed.
                                                    If you are using these model results to develop plans or prioritize response efforts, please also consult each model developer's original documentation."))
                            )
                            
                          )),
                 
                 
                 ###################################################################################
                 ## Model inventory ################################################################
                 ###################################################################################
                 
                 tabPanel("Model inventory",
                          mainPanel(
                            navlistPanel("Select model:",
                                         
                ###################################################################################
                ## Columbia Model Details #########################################################
                ###################################################################################
                                         
                                        tabPanel("Overview",  
                                        h3("Model inventory"),
                                        
                                        p("All models are developed with a specific purpose in mind. This intended purpose impacts how each model 
                                        is developed, how it should be used, and the context based on which its results should be interpreted."),
                                        
                                        p("Use the panel to the right to explore additional details 
                                          about each model included in this inventory.")),
                                        
                                        tabPanel("Columbia University Model",
                                                  
                                                  h3("Columbia University Model"),
                                                  hr(),
                                                  
                                                  p(tags$b("Intended use:"), "project daily hospital demand, at the county level, in the United States"),
                                                  hr(),
                                                  
                                                  p(tags$b("Developer:"), "Sen Pei and Jeffrey Shaman, Mailman School of Public Health, Columbia University"),
                                                  hr(),
                                                 
                                                  p(tags$b("Modeling approach:"), "metapopulation SEIR model"),
                                                 hr(),

                                                 p(tags$b("What is predicted:"),
                                                   tags$ul(
                                                     tags$li("new confirmed cases per day"),
                                                     tags$li("new reported infections per day"),
                                                     tags$li("new total infections per day (reported or unreported)"),
                                                     tags$li("demand for hospital beds per day")
                                                   )),
                                                 
                                                 hr(),
                                                  
                                                  p(tags$b("Key assumptions:") ,
                                                    tags$ul(
                                                      tags$li("assumes social distancing levels continue to increase with multiplicative effects over time for all counties with increasing weekly COVID-19 caseload"),
                                                      br(),
                                                      tags$li("assumes contact reductions are never relaxed over the course of the model run"),
                                                      br(),
                                                      tags$li("please consult available documentation below for additional information on key model assumptions.")),
                                                    
                                                    hr(),
                                                    
                                                    p(tags$b("Temporal and geographic resolution:"), "daily estimates, per US county"),
                                                    hr(),
                                                    
                                                    p(tags$b("Geographic coverage of estimates:"), "United States (no results for Virgin Islands or Puerto Rico)"),
                                                    hr(),
                                                    
                                                    
                                                    p(tags$b("Reference and source documentation:"),
                                                      tags$ul(
                                                        tags$li("preprint:", tags$a(href = "https://www.medrxiv.org/content/10.1101/2020.03.21.20040303v2", "https://www.medrxiv.org/content/10.1101/2020.03.21.20040303v2", target = "_blank")),
                                                        br(),
                                                        tags$li("model results and source code:", tags$a(href="https://github.com/shaman-lab/COVID-19Projection", "https://github.com/shaman-lab/COVID-19Projection", target="_blank"))
                                                      )),
                                                    hr(),
                                                    
                                                    p(tags$b("Most recent data update in Model Inventory:"), "April 26, 2020"),
                                                    # hr(),
                                                    # 
                                                    # p(tags$b("Data processing in Model Inventory:"),
                                                    #   tags$ul(
                                                    #     tags$li("state and national estimates calculated based on sum of relevant values reported at the county level"),
                                                    #     br(),
                                                    #     tags$li("point estimates taken as median produced value across model iterations, for any given location, date, and county"),
                                                    #     br(),
                                                    #     tags$li("when comparing Shaman model to other models in the Inventory, show model associated with initial 40% reduction in social contact"))),
                                                      
                                                      
                                                      
                                                      
                                                    hr()
                                                  )),       
                
                ###################################################################################
                ## COVID-Act Now Model Details ####################################################
                ###################################################################################
                
                tabPanel("COVID Act Now Model",
                         
                         h3("COVID Act Now Model"),
                         hr(),
                         
                         p(tags$b("Intended use:"), "provide disease intelligence and data analysis on COVID in the US"),
                         hr(),

                         p(tags$b("Developer:"), "COVIDActNow.org"),
                         hr(),

                         p(tags$b("What is predicted:"), "demand for hospital beds per day"),
                         
                         hr(),

                         p(tags$b("Key assumptions:"),"please consult available documentation below for additional information on key model assumptions."),

                           hr(),

                           p(tags$b("Temporal and geographic resolution:"), "daily estimates, per US state and for selected counties"),
                           hr(),

                           p(tags$b("Geographic coverage of estimates:"), "United States (no results for Virgin Islands or Puerto Rico)"),
                           hr(),


                           p(tags$b("Reference and source documentation:"),
                             tags$ul(
                               tags$li("visualizations and model results:", tags$a(href = "https://covidactnow.org/", "https://covidactnow.org/", target = "_blank")),
                               br(),
                               tags$li("source code:", tags$a(href="https://github.com/covid-projections/covid-projections", "https://github.com/covid-projections/covid-projections", target="_blank")),
                               br(),
                               tags$li("API documentation:", tags$a(href = "https://blog.covidactnow.org/covid-act-now-api-intervention-model/", "https://blog.covidactnow.org/covid-act-now-api-intervention-model/", target = "_blank")),
                               br(),
                               tags$li("additional documentation:", tags$a(href = "https://data.covidactnow.org/Covid_Act_Now_Model_References_and_Assumptions.pdf", "https://data.covidactnow.org/Covid_Act_Now_Model_References_and_Assumptions.pdf", target = "_blank")),
                               br()
                             )),
                           hr(),
                           
                           p(tags$b("Most recent data update in Model Inventory:"), "May 21, 2020"),
                         hr()
                         
                         ),       
                
                ###################################################################################
                ## GLEAM Details ##################################################################
                ###################################################################################
                
                tabPanel("GLEAM Model",
                         
                         h3("Global Epidemic and Mobility Model (GLEAM) Model"),
                         hr(),
                         
                         p(tags$b("Intended use:"), "forecast newly generated infections, times of disease arrival in different regions, and the number of traveling infection carriers"),
                         hr(),
                         
                         p(tags$b("Developer:"), "Global Epidemic and Mobility Model project team"),
                         hr(),
                         
                         p(tags$b("Key assumptions:") ,
                           tags$ul(
                             tags$li("assumes stay-at-home policies result in a '70% transmissibility reduction'"),
                             br(),
                             tags$li("assumes no pre-symptomatic transmission"),
                             br(),
                             tags$li("assumes sustained adherence to existing shelter-in-place orders"),
                             br(),
                             tags$li("please consult available documentation below for additional information on key model assumptions."))
                         ),
                         
                         hr(),
                         
                         p(tags$b("Reference and source documentation:"),
                           tags$ul(
                             tags$li("public documentation for COVID-19:", tags$a(href="https://uploads-ssl.webflow.com/58e6558acc00ee8e4536c1f5/5e8bab44f5baae4c1c2a75d2_GLEAM_web.pdf", "https://uploads-ssl.webflow.com/58e6558acc00ee8e4536c1f5/5e8bab44f5baae4c1c2a75d2_GLEAM_web.pdf", target="_blank")),
                             tags$li("GLEAM website:", tags$a(href="http://www.gleamviz.org/model/", "http://www.gleamviz.org/model/", target="_blank")),
                             tags$li("model results and visualizations:", tags$a(href = "https://covid19.gleamproject.org/", "https://covid19.gleamproject.org/", target = "_blank"))
                           )),
                         hr(),
                         
                         p(tags$b("Most recent data update in Model Inventory:"), "May 17, 2020"),
                         hr()
                ),                
                
                                         
                                         
                ###################################################################################
                ## IHME Model Details #############################################################
                ###################################################################################
                
                            tabPanel("IHME COVID-19 Model",
                                     
                                     h3("IHME COVID-19 Model"),
                                     hr(),
                                     
                                     p(tags$b("Intended use:"), "forecast the extent and timing of deaths and excess demand for hospital services due to COVID-19"),
                                     hr(),
                                     
                                     p(tags$b("Developer:"), "University of Washington Institute for Health Metrics and Evaluation"),
                                     hr(),
                                     
                                     p(tags$b("Key assumptions:") ,
                                       tags$ul(
                                         tags$li("please consult available documentation below for additional information on key model assumptions.")),
                                       hr(),
                                       
                                       p(tags$b("Reference and source documentation:"),
                                         tags$ul(
                                           tags$li("preprint:", tags$a(href = "https://www.medrxiv.org/content/10.1101/2020.03.27.20043752v1", "https://www.medrxiv.org/content/10.1101/2020.03.27.20043752v1", target = "_blank")),
                                           tags$li("model results and visualization:", tags$a(href="https://covid19.healthdata.org/united-states-of-america", "https://covid19.healthdata.org/united-states-of-america", target="_blank")),
                                           tags$li("history of model updates:", tags$a(href= "http://www.healthdata.org/covid/updates", "http://www.healthdata.org/covid/updates", target="_blank")))),
                                       hr(),
                                       
                                       p(tags$b("Media coverage, responses from other researchers:"),
                                         tags$ul(
                                           tags$li(tags$a(href = "https://annals.org/aim/fullarticle/2764774/caution-warranted-using-institute-health-metrics-evaluation-model-predicting-course",
                                                          "Jewell NP et al. 'Caution Warranted: Using the Institute for Health Metrics and Evaluation Model for Predicting the Course of the COVID-19 Pandemic'. Ann Intern Med. 2020.")),
                                           tags$li(tags$a(href = "https://annals.org/aim/fullarticle/2764774/caution-warranted-using-institute-health-metrics-evaluation-model-predicting-course",
                                                          "Jewell NP et al. 'Predictive Mathematical Models of the COVID-19 Pandemic: Underlying Principles and Value of Projections.' JAMA. 2020.")
                                           ))),
                                       hr(),
                                       
                                       p(tags$b("Most recent data update in Model Inventory:"), "May 20, 2020"),
                                       hr()
                                     )),
                

                ###################################################################################
                ## Los Alamos Model Details #######################################################
                ###################################################################################
                
                tabPanel("LANL COVID-19 Model",
                         
                         h3("Los Alamos National Lab (LANL) COVID-19 Model"),
                         hr(),
                         
                         p(tags$b("Intended use:"), "forecast the number of future confirmed cases and deaths as reported by the Johns Hopkins University (JHU) Coronavirus Resource Center dashboard"),
                         hr(),
                         
                         p(tags$b("Developer:"), "Los Alamos National Lab (LANL)"),
                         hr(),
                         
                         p(tags$b("Key assumptions:") ,
                           tags$ul(
                             tags$li("assumes that interventions will be implemented and will be upheld in the future"),
                             br(),
                             tags$li("assumes no more than approximately 60% of individuals could eventually become confirmed cases"),
                             br(),
                             tags$li("assumes no increase in case fatality rate, even if/as hospitals become overloaded"),
                             br(),
                             tags$li("assumes that, if a confirmed case dies, that death happens in synchrony with receiving positive test results"),
                             br(),
                             tags$li("please consult available documentation below for additional information on key model assumptions.")),
                           
                           hr(),
                           
                           p(tags$b("Temporal and geographic resolution:"), "daily estimates for selected US states"),
                           hr(),
                           
                           p(tags$b("Geographic coverage of estimates:"), "United States (no results for Virgin Islands, Puerto Rico, and selected US states including New Jersey)"),
                           hr(),
                           
                           p(tags$b("Reference and source documentation:"),
                             tags$ul(
                               tags$li("model results and visualizations:", tags$a(href="https://covid-19.bsvgateway.org/", "https://covid-19.bsvgateway.org/", target="_blank"))
                             )),
                           hr(),
                           
                           p(tags$b("Most recent data update in Model Inventory:"), "May 13, 2020"),
                           hr()
                         )),
                
                ###################################################################################
                ## MIT DELPHI Model Details #######################################################
                ###################################################################################
                
                tabPanel("MIT DELPHI Model",
                         
                         h3("MIT DELPHI Model"),
                         hr(),
                         
                         p(tags$b("Intended use:"), "forecasts infections, hospitalizations, and deaths due to COVID-19"),
                         hr(),
                         
                         p(tags$b("Developer:"), "MIT Operations Reseach Center"),
                         hr(),
                         
                         p(tags$b("Key assumptions:") ,
                           tags$ul(
                             tags$li("forecasts detected deaths, so counts may exclude deaths not detected by existing surveillance infrastructure"),
                             br(),
                             tags$li("please consult available documentation below for additional information on key model assumptions.")),
                           
                           hr(),
                           
                           p(tags$b("Temporal and geographic resolution:"), "daily estimates by country and for US states"),
                           hr(),
                           
                           p(tags$b("Geographic coverage of estimates:"), "Global"),
                           hr(),
                           
                           p(tags$b("Reference and source documentation:"),
                             tags$ul(
                               tags$li("results and visualizations", tags$a(href="https://www.covidanalytics.io/projections", "https://www.covidanalytics.io/projections", target="_blank")),
                               tags$li("source code:", tags$a(href="https://github.com/COVIDAnalytics/DELPHI", "https://github.com/COVIDAnalytics/DELPHI", target="_blank")),
                               tags$li("additional documentation:", tags$a(href = "https://www.covidanalytics.io/DELPHI_documentation_pdf", "https://www.covidanalytics.io/DELPHI_documentation_pdf", target = "_blank"))
                             )),
                           hr(),

                           p(tags$b("Most recent data update in Model Inventory:"), "May 19, 2020"),
                           hr()
                         )),
                ###################################################################################
                ## NotreDame-FRED Forecast Details ################################################
                ###################################################################################
                
                tabPanel("NotreDame-FRED Forecast",
                         
                         h3("NotreDame-FRED Forecast"),
                         hr(),
                         
                         p(tags$b("Intended use:"), "make short term forecasts of COVID-19, with a focus on incidence of cases and deaths and the impacts of NPIs"),
                         hr(),
                         
                         p(tags$b("Developer:"), "Perkins lab at the University of Notre Dame"),
                         hr(),
                         
                         p(tags$b("Key assumptions:") ,
                           tags$ul(
                             tags$li("please consult available documentation below for additional information on key model assumptions.")),
                           
                           hr(),
                           
                           p(tags$b("Temporal and geographic resolution:"), "daily estimates for selected US states"),
                           hr(),
                           
                           p(tags$b("Geographic coverage of estimates:"), "selected US states (IL, IN, KY, MI, MN, OH, WI)"),
                           hr(),
                           
                           p(tags$b("Reference and source documentation:"),
                             tags$ul(
                               tags$li("FRED model documentation", tags$a(href="https://fred.publichealth.pitt.edu/", "https://fred.publichealth.pitt.edu/", target="_blank")),
                               tags$li("model outputs:", tags$a(href="https://github.com/confunguido/covid19_ND_forecasting/tree/master/output", "https://github.com/confunguido/covid19_ND_forecasting/tree/master/output", target="_blank")),
                               tags$li("additional documentation:", tags$a(href = "https://github.com/confunguido/covid19_ND_forecasting/blob/master/output/metadata-NotreDame-FRED.txt", "https://github.com/confunguido/covid19_ND_forecasting/blob/master/output/metadata-NotreDame-FRED.txt", target = "_blank"))
                             )),
                           hr(),
                           
                           p(tags$b("Most recent data update in Model Inventory:"), "May 18, 2020"),
                           hr()
                         )),
                
                ###################################################################################
                ## UCLA Model Details #############################################################
                ###################################################################################
                
                tabPanel("UCLA COVID-19 Model",
                         
                         h3("UCLA COVID-19 Model"),
                         hr(),
                         
                         p(tags$b("Intended use:"), '"better understand the spread of COVID-19, to facilitate informed decisions by policy makers, and to better allocate the medical resources such as medical workers, personal protective equipment"'),
                         hr(),
                         
                         p(tags$b("Developer:"), "Statistical Machine Learning Lab at UCLA"),
                         hr(),
                         
                         p(tags$b("Key assumptions:") ,
                           tags$ul(
                             tags$li("please consult available documentation below for additional information on key model assumptions.")),
                           
                           hr(),
                           
                           p(tags$b("Temporal and geographic resolution:"), "daily estimates for US states"),
                           hr(),
                           
                           p(tags$b("Geographic coverage of estimates:"), "United States (including Virgin Islands and Puerto Rico)"),
                           hr(),
                           
                           p(tags$b("Reference and source documentation:"),
                             tags$ul(
                               tags$li("model outputs and visualizations:", tags$a(href="https://covid19.uclaml.org/index.html", "https://covid19.uclaml.org/index.html", target="_blank")),
                               tags$li("additional documentation:", tags$a(href = "https://github.com/confunguido/covid19_ND_forecasting/blob/master/output/metadata-NotreDame-FRED.txt", "https://github.com/confunguido/covid19_ND_forecasting/blob/master/output/metadata-NotreDame-FRED.txt", target = "_blank"))
                             )),
                           hr(),
                           
                           p(tags$b("Most recent data update in Model Inventory:"), "May 22, 2020"),
                           hr()
                         ))
                
                
                

                
                
                
                ))),
              

                 
                 ###################################################################################
                 ## Download Data Tab ##############################################################
                 ###################################################################################
                 
                 # tabPanel("Download data",
                 #          mainPanel(DT::dataTableOutput("output_table"))),
                 
                 ###################################################################################
                 ## Documentation Tab ##############################################################
                 ###################################################################################
                 
                 tabPanel("About",
                          mainPanel(
                            
                            
                            h3("Motivation"),
                            p("This project was developed to facilitate open-source, reproducible epidemiological modeling for COVID-19 response and recovery.
              As the COVID-19 outbreak continues to rapidly progress, policy-makers, public health responders, and researchers 
              rely, in part, on the results of epidemiological models to understand how the outbreak might progress."),
                            
                            p("However, different models are being produced and used by different groups, each with their own unique set of assumptions,
              underlying data inputs and methods, and intended uses. Moreover, these models often document their approaches and report
              or export their results in formats that make it difficult to compare results across models.
             This project was developed to fill that gap."),
                            
                            h3("Approach"),
                            
                            p("To monitor how different models have changed over time, compare the assumptions and results of these models, 
               and evaluate the best available evidence to inform policy decisions, it's first necessary to align modeling results to be able to compare 'apples to apples'.
               This requires an overarching data architecture that aligns results from different models into a common dataset."),
                
                            
                            p("The COVID model inventory relies on a common data structure, documented in the project's", 
                              tags$a(href = "https://github.com/Innovate-For-Health/covid-ensemble/blob/master/data/Data%20Dictionary.xlsx", "data dictionary.", target = "_black"),
             "As new model results become available, they are documented, archived,and processed via a series of routinely run R scripts 
             to add them to a relational data structure. This site will be updated every Thursday as new model results become available, though delays might occur."),
                            
                            h3("FAQ"),
                            
                            h4("Which  models are included in this inventory?"),
                            p('A current inventory of all included models can be found in the "Model Inventory" tab above. All of these models
                            have been documented as being used by policy-makers or public health responders during the 2019-2020 COVID-19 pandemic. 
                            However, this inventory of models is by no means comprehensive, and new models are currently being assessed and added in a rolling fashion.'),
                            
                          h4("How are models currently being used to inform COVID response and recovery?"),
                            
                            p("Public health responders, healthcare organizations, and policy-makers rely on 
                              epidemiological forecast models for COVID-19 to inform their policy decisions and to
                              develop operational plans based on how the outbreak may unfold."),
                            
                            p("For example, in California, Governor Gavin Newsom described how the state's early shelter-in-place orders
                              were informed by", tags$a(href="https://www.kqed.org/science/1959566/california-gov-gavin-newsom-orders-state-to-shelter-in-place", 
                              "statewide pandemic planning models", target = "_black"), "developed to forecast how the outbreak might spread.
                               Similarly, Muriel Bowser, the Mayor of Washington DC, cited results from both",
                              tags$a(href = "https://penn-chime.phl.io/", "University of Pennsylvania's CHIME model", target = "_black"), "and",
                              tags$a(href = "http://www.healthdata.org/", "University of Washington's IHME model", target = "_black"), 
                              "when outlining emergency legislative provisions for the District of Columbia.
                              Leaders within healthcare organizations also use the results of these models to",
                              tags$a(href = "https://www.nytimes.com/2020/04/01/us/coronavirus-california-new-york-testing.html", "inform their own planning efforts", target = "_black"),
                              "."),
                            
                            h3("Team and acknowledgements"),
                            
                            p("This site was designed, built, and developed by", 
                              tags$a(href="https://innovateforhealth.berkeley.edu/steph-eaneff-msp", 
                                     "Steph Eaneff"), ".", target = "_black"),
                            
                            p("This work was made possible by support from the",
                              tags$a(href = "https://innovateforhealth.berkeley.edu/",
                                     "Innovate for Health Data Science Health Innovation program,", target = "_blank"),
                              "including support from the UCSF Bakar Computational Health Sciences Institute, the UC Berkeley Institute for Data Science, 
                              and Johnson & Johnson.")
                          ))
)