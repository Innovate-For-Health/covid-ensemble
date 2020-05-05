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
                            
                            p("The COVID Model Inventory was developed to facilitate reproducible epidemiological modeling for COVID-19 response and recovery."),
                            
                            h3("Goals and Audience"),
                            
                            p("Public health researchers have rapidly responded to the COVID-19 
             outbreak by developing models to forecast how the outbreak might unfold under various possible scenarios. 
             In the absence of a central data repository or coordinating body for public health response modeling, 
             it is often difficult to rapidly access, understand, and compare results from different models currently 
                              being used to inform policy decisions and operational planning."),
                            
                            p("This project was developed to allow users to:"),
                            
                            tags$ul(
                              tags$li("monitor how different COVID-19 models have changed over time"), 
                              tags$li("compare the assumptions and results of these models"), 
                              tags$li("understand how differences in assumptions and methods may drive differences in results")),
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
                            navlistPanel("Select model",
                                         
                ###################################################################################
                ## Columbia Model Details #########################################################
                ###################################################################################
                                         
                                         tabPanel("Columbia University Model",
                                                  
                                                  h3("Columbia University Model"),
                                                  hr(),
                                                  
                                                  p(tags$b("Intended use:"), "project daily hospital demand, at the county level, in the United States"),
                                                  hr(),
                                                  
                                                  p(tags$b("Developer:"), "Sen Pei and Jeffrey Shaman, Mailman School of Public Health, Columbia University"),
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
                                                    hr(),
                                                    
                                                    p(tags$b("Data processing in Model Inventory:"),
                                                      tags$ul(
                                                        tags$li("state and national estimates calculated based on sum of relevant values reported at the county level"),
                                                        br(),
                                                        tags$li("point estimates taken as median produced value across model iterations, for any given location, date, and county"),
                                                        br(),
                                                        tags$li("when comparing Shaman model to other models in the Inventory, show model associated with initial 40% reduction in social contact")),
                                                      
                                                      
                                                      
                                                      
                                                    ),
                                                    hr()
                                                  )),       
                
                ###################################################################################
                ## COVID-Act Now Model Details ####################################################
                ###################################################################################
                
                tabPanel("COVID Act Now Model",
                         
                         h3("COVID Act Now Model"),
                         hr(),
                         h5("Additional details coming soon!")
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
                           )
                           
                         ),
                         hr(),
                         
                         p(tags$b("Most recent data update in Model Inventory:"), "April 15, 2020 (data accessed online May 4, 2020)"),
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
                                         tags$li("assumes continuation of social distancing in all US states and subsequent effective implementation of containment (e.g., testing, contact tracing, restrictions on public gatherings)",
                                                 tags$a(href = "http://www.healthdata.org/covid/updates", "(as of 4/17)", target = "_blank")),
                                         br(),
                                         tags$li("assumes effects from social distancing will be similar in locations around the world (e.g., Hubei, China vs. United States)"),
                                         br(),
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
                                       
                                       p(tags$b("Most recent data update in Model Inventory:"), "April 29, 2020"),
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
                           
                           p(tags$b("Most recent data update in Model Inventory:"), "April 29, 2020"),
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
                            
                            h3("FAQ"),
                            
                            h4("What types of models are included in this inventory?"),
                            p("All of the COVID-19 models identified below have been documented as being used by policy-makers or public health
           responders during the 2019-2020 COVID-19 pandemic. However, this inventory of models is by no means comprehensive, and 
           new models are currently being assessed and added in a rolling fashion."),
                            
                            h4("How are models currently being used to inform COVID response and recovery?"),
                            
                            p("Public health responders, healthcare organizations, and policy-makers rely on 
                              epidemiological forecast models for COVID-19 to inform their policy decisions and to
                              develop operational plans based on how the outbreak may unfold."),
                            
                            p("For example, in California, Governor Gavin Newsom described how the state's early shelter-in-place orders
                              were informed by", tags$a(href="https://www.kqed.org/science/1959566/california-gov-gavin-newsom-orders-state-to-shelter-in-place", 
                              "statewide pandemic planning models"), "developed to forecast how the outbreak might spread.
                               Similarly, Muriel Bowser, the Mayor of Washington DC, cited results from both",
                              tags$a(href = "https://penn-chime.phl.io/", "University of Pennsylvania's CHIME model"), "and",
                              tags$a(href = "http://www.healthdata.org/", "University of Washington's IHME model"), 
                              "when outlining emergency legislative provisions for the District of Columbia.
                              Leaders within healthcare organizations also use the results of these models to",
                              tags$a(href = "https://www.nytimes.com/2020/04/01/us/coronavirus-california-new-york-testing.html", "inform their own planning efforts"),
                              "."),
                            
                            h3("Team and acknowledgements"),
                            
                            p("This site was designed, built, and developed by", 
                              tags$a(href="https://bids.berkeley.edu/people/stephanie-eaneff", 
                                     "Steph Eaneff"), "."),
                            
                            p("This work was made possible by support from the Innovate for Health Data Science Health Innovation program, 
                              including support from the UCSF Bakar Computational Health Sciences Institute, the UC Berkeley Institute for Data Science, 
                              and Johnson & Johnson.")
                          ))
)