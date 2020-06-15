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
                            
                            p("The COVID Model Inventory highlights key differences between models that forecast 
                               hospital demand, caseload, and fatalities due to COVID-19,
                               and monitors changes in model outputs over time."),
                            
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

                            
                            p(strong("This site is updated monthly (last update on June 15, 2020), and likely does not display the most recent results available for any given model.")))),

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
                                        selected = "Fatalities per day"),
                            
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
                                         
                                         
                                        tabPanel("Overview",  
                                        h3("Model inventory"),
                                        
                                        p("All models are developed with a specific purpose in mind. This intended purpose impacts how each model 
                                        is developed, how it should be used, and the context based on which its results should be interpreted."),
                                        
                                        p("Use the panel to the right to explore additional details 
                                          about each model included in this inventory.")),
                                        
                                        ###################################################################################
                                        ## Columbia Model Details #########################################################
                                        ###################################################################################
                                        
                                        #tabPanel("Columbia University Model",
                                                 #  
                                                 #  h3("Columbia University Model"),
                                                 #  hr(),
                                                 #  
                                                 #  p(tags$b("Intended use:"), "project daily hospital demand, at the county level, in the United States"),
                                                 #  hr(),
                                                 #  
                                                 #  p(tags$b("Developer:"), "Sen Pei and Jeffrey Shaman, Mailman School of Public Health, Columbia University"),
                                                 #  hr(),
                                                 # 
                                                 #  p(tags$b("Modeling approach:"), "metapopulation SEIR model"),
                                                 # hr(),
                                                 # 
                                                 # p(tags$b("What is predicted:"),
                                                 #   tags$ul(
                                                 #     tags$li("new confirmed cases per day"),
                                                 #     tags$li("new reported infections per day"),
                                                 #     tags$li("new total infections per day (reported or unreported)"),
                                                 #     tags$li("demand for hospital beds per day")
                                                 #   )),
                                                 # hr(),
                                                 # 
                                                 # p(tags$b("Selected data inputs:"),
                                                 #   tags$ul(
                                                 #     tags$li("caseload data:", tags$a(href = "https://usafacts.org/visualizations/coronavirus-covid-19-spread-map/", "usafacts.org", target = "_blank")),
                                                 #     tags$li("commute data:", tags$a(href = "https://www.census.gov/topics/employment/commuting.html", "US Census commute data", target = "_blank"))
                                                 #   )),
                                                 # 
                                                 # hr(),
                                                 #  
                                                 #  p(tags$b("Key assumptions:"),
                                                 #    tags$ul(
                                                 #      tags$li("assumes social distancing levels continue to increase with multiplicative effects over time for all counties with increasing weekly COVID-19 caseload"),
                                                 #      br(),
                                                 #      tags$li("Once a state has re-opened, contact rates are assumed to increase by 5% each week"),
                                                 #      br(),
                                                 #      tags$li("please consult available documentation below for additional information on key model assumptions.")),
                                                 #    hr(),
                                                 #    
                                                 #    p(tags$b("Temporal and geographic resolution:"), "daily estimates, per US county"),
                                                 #    hr(),
                                                 #    
                                                 #    p(tags$b("Geographic coverage of estimates:"), "United States (no results for Virgin Islands or Puerto Rico)"),
                                                 #    hr(),
                                                 #    
                                                 #    p(tags$b("Reference and source documentation:"),
                                                 #      tags$ul(
                                                 #        tags$li(tags$a(href = "https://covidprojections.azurewebsites.net/", "visualizations of forecast results", target = "_blank")),
                                                 #        tags$li(tags$a(href = "https://www.medrxiv.org/content/10.1101/2020.03.21.20040303v2", "preprint", target = "_blank")),
                                                 #        tags$li(tags$a(href="https://github.com/shaman-lab/COVID-19Projection", "model results and source code", target="_blank")),
                                                 #        tags$li(tags$a(href = "https://blogs.cuit.columbia.edu/jls106/publications/covid-19-findings-simulations/", "blog post", target = "_blank"))
                                                 #        
                                                 #      )),
                                                 #    hr(),
                                                 #    
                                                 #    p(tags$b("Media coverage, responses from other researchers:"),
                                                 #      tags$ul(
                                                 #        tags$li(tags$a(href = "https://www.cdc.gov/coronavirus/2019-ncov/covid-data/forecasting-us.html",
                                                 #                       "CDC Forecast Website", target = "_blank"))
                                                 #      )),
                                                 #    hr(),
                                                 #  
                                                 #    p(tags$b("Update frequency:"), "approximately twice per week"),
                                                 #    hr(),
                                                 #    
                                                 #    p(tags$b("Most recent data update in Model Inventory:"), "April 26, 2020"),
                                                 # 
                                                 #    hr()
                                                 #  )),       
                                                 # 
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

                         p(tags$b("Modeling approach:"), "fitted SEIR model"),
                         hr(),

                         p(tags$b("What is predicted:"), "demand for hospital beds per day"),
                         hr(),
                         
                         p(tags$b("Selected data inputs:"),
                           tags$ul(
                             tags$li("caseload data:", tags$a(href = "https://coronavirus.jhu.edu/map.html", "Johns Hopkins COVID-19 dashboard", target = "_blank")),
                             tags$li("hospitalization data:", tags$a(href = "https://covidtracking.com/", "COVID Tracking Project", target = "_blank")),
                             tags$li("hospitalization data:", tags$a(href = "https://coronadatascraper.com/#home", "Corona Data Scraper", target = "_blank")),
                             tags$li("population size data:", tags$a(href = "https://en.wikipedia.org/wiki/List_of_states_and_territories_of_the_United_States_by_population", "Wikipedia", target = "_blank"))
                           )),
                         hr(),

                         p(tags$b("Key assumptions:"),"please consult available documentation below for additional information on key model assumptions"),
                           hr(),

                           p(tags$b("Temporal and geographic resolution:"), "daily estimates, per US state and for selected counties"),
                           hr(),

                           p(tags$b("Geographic coverage of estimates:"), "United States (no results for Virgin Islands or Puerto Rico)"),
                           hr(),

                           p(tags$b("Reference and source documentation:"),
                             tags$ul(
                               tags$li(tags$a(href = "https://covidactnow.org/", "visualizations and model results", target = "_blank")),
                               tags$li(tags$a(href="https://github.com/covid-projections/covid-projections", "source code", target="_blank")),
                               tags$li(tags$a(href = "https://blog.covidactnow.org/covid-act-now-api-intervention-model/", "API documentation", target = "_blank")),
                               tags$li(tags$a(href = "https://docs.google.com/document/d/1cd_cEpNiIl1TzUJBvw9sHLbrbUZ2qCxgN32IqVLa3Do/edit", "references and assumptions", target = "_blank"))
                             )),
                           hr(),
                         
                         p(tags$b("Media coverage, responses from other researchers:"),
                           tags$ul(
                             tags$li(tags$a(href = "https://www.cdc.gov/coronavirus/2019-ncov/covid-data/forecasting-us.html",
                                            "CDC Forecast Website", target = "_blank"))
                             )),
                         hr(),
                         
                         p(tags$b("Update frequency:"), "every three days"),
                         hr(),
                           
                           p(tags$b("Most recent data update in Model Inventory:"), "June 14, 2020"),
                         hr()
                         
                         ),       
                
                ###################################################################################
                ## COVID-19 Projections.com #######################################################
                ###################################################################################
                
                tabPanel("COVID19-projections.com",
                         
                         h3("COVID19-projections.com"),
                         hr(),
                         
                         p(tags$b("Intended use:"), '""make COVID-19 infections and deaths projections for the US, all 50 US states, and more than 60 countries"'),
                         hr(),
                         
                         p(tags$b("Developer:"), "Youyang Gu"),
                         hr(),
                         
                         p(tags$b("Modeling approach:"), "SEIS mechanistic model"),
                         hr(),
                         
                         p(tags$b("What is predicted:"), "cumulative fatalities, fatalities per day, new and current infections"),
                         hr(),
                         
                         p(tags$b("Selected data inputs:"),
                           tags$ul(
                             tags$li("death data:", tags$a(href = "https://coronavirus.jhu.edu/map.html", "Johns Hopkins COVID-19 dashboard", target = "_blank")),
                             tags$li("US state re-opening data:", tags$a(href = "https://www.nytimes.com/interactive/2020/us/states-reopen-map-coronavirus.html", "New York Times", target = "_blank"))
                           )),
                         hr(),
                         
                         p(tags$b("Key assumptions:"),
                           tags$ul(
                             tags$li("all US state re-openings are assumed to be gradual"),
                             br(),
                             tags$li('assume infection fatality rate decreases over time "to reflect improving treatments and the lower proportion of care home deaths"'),
                             br(),
                             tags$li("please consult available documentation below for additional information on key model assumptions"))),
                           hr(),

                         p(tags$b("Temporal and geographic resolution:"), "daily estimates, per US state and for selected counties"),
                         hr(),
                         
                         p(tags$b("Geographic coverage of estimates:"), "Global"),
                         hr(),

                         p(tags$b("Reference and source documentation:"),
                           tags$ul(
                             tags$li("visualizations and model results:", tags$a(href = "https://covid19-projections.com/", "https://covid19-projections.com/", target = "_blank")),
                             br(),
                             tags$li("archive of historical data:", tags$a(href="https://github.com/youyanggu/covid19_projections/tree/master/projections", "https://github.com/youyanggu/covid19_projections/tree/master/projections", target="_blank")),
                             br(),
                             tags$li("key assumptions:", tags$a(href="https://covid19-projections.com/about/#assumptions", "https://covid19-projections.com/about/#assumptions", target="_blank")),
                             br(),
                             tags$li("model documentation:", tags$a(href = "https://covid19-projections.com/about/#about-the-model", "https://covid19-projections.com/about/#about-the-model", target = "_blank")),
                             br()
                           )),
                         hr(),
                         
                         p(tags$b("Media coverage, responses from other researchers:"),
                           tags$ul(
                             tags$li(tags$a(href = "https://www.cdc.gov/coronavirus/2019-ncov/covid-data/forecasting-us.html",
                                            "CDC Forecast Website", target = "_blank")),
                             tags$li(tags$a(href = "https://projects.fivethirtyeight.com/covid-forecasts/",
                                            "fivethirtyeight", target = "_blank")),
                             tags$li(tags$a(href = "https://twitter.com/CT_Bergstrom/status/1255343846445195266",
                                            "twitter (@CT_Bergstrom)", target = "_blank"))
                           )),
                         hr(),
                         
                         p(tags$b("Update frequency:"), "daily"),
                         hr(),
                         
                         p(tags$b("Most recent data update in Model Inventory:"), "June 14, 2020"),
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
                         
                         p(tags$b("Modeling approach:"), '"individual-based, stochastic, and spatial epidemic model"'),
                         hr(),
                         
                         p(tags$b("What is predicted:"), "cumulative fatalities, hospital beds needed per day (overall and ICU)"),
                         hr(),
                         
                         p(tags$b("Selected data inputs:"),
                           tags$ul(
                             tags$li('mobility data: "databases collected from 30 countries on five continents"',
                             tags$li("death data:", tags$a(href = "https://coronavirus.jhu.edu/map.html", "Johns Hopkins COVID-19 dashboard", target = "_blank"))
                           ))),
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
                         
                         p(tags$b("Update frequency:"), "approximately weekly"),
                         hr(),
                         
                         p(tags$b("Most recent data update in Model Inventory:"), "June 7, 2020"),
                         hr()
                ),                
                
                                         
                                         
                ###################################################################################
                ## IHME Model Details #############################################################
                ###################################################################################
                
                            tabPanel("IHME COVID-19 Model",
                                     
                                     h3("IHME COVID-19 Model"),
                                     hr(),
                                     
                                     p(tags$b("Intended use:"), '"forecast the extent and timing of deaths and excess demand for hospital services due to COVID-19"'),
                                     hr(),
                                     
                                     p(tags$b("Developer:"), "University of Washington Institute for Health Metrics and Evaluation"),
                                     hr(),
                                     
                                     p(tags$b("Modeling approach:"), '"combination of a mechanistic disease transmission model and a curve-fitting approach" (per CDC)'),
                                     hr(),
                                     
                                     p(tags$b("What is predicted:"), "infections, fatalities, and tests performed"),
                                     hr(),
                                     
                                     p(tags$b("Selected data inputs:"),
                                       tags$ul(
                                         tags$li("death data:", tags$a(href = "https://coronavirus.jhu.edu/map.html", "Johns Hopkins COVID-19 dashboard", target = "_blank")),
                                         br(),
                                         tags$li('mobility data: "anonymous cellphone data" from Descartes Labs, SafeGraph, and Google COVID-19 Community Mobility Reports'),
                                         br(),
                                        tags$li("additional death data: French governmental dashboard, Colorado Department of Public Health and Environment website,  Illinois’s Department of Health website, New York City Department of Health and Mental Hygiene, and NYT data for NY")
                                         )),
                                     hr(),
                                     
                                     p(tags$b("Key assumptions:") ,
                                       tags$ul(
                                         tags$li("please consult available documentation below for additional information on key model assumptions.")),
                                       hr(),
                                       
                                       p(tags$b("Reference and source documentation:"),
                                         tags$ul(
                                           tags$li(tags$a(href = "https://www.medrxiv.org/content/10.1101/2020.03.27.20043752v1", "preprint", target = "_blank")),
                                           tags$li(tags$a(href = "https://www.medrxiv.org/content/medrxiv/suppl/2020/04/25/2020.04.21.20074732.DC1/2020.04.21.20074732-2.pdf", "preprint (Appendix B)", target = "_blank")),
                                           tags$li(tags$a(href="https://covid19.healthdata.org/united-states-of-america", "model results and visualizations", target="_blank")),
                                           tags$li(tags$a(href= "http://www.healthdata.org/covid/updates", "history of model updates", target="_blank")))),
                                       hr(),
                                       
                                       p(tags$b("Media coverage, responses from other researchers:"),
                                         tags$ul(
                                           tags$li(tags$a(href = "https://annals.org/aim/fullarticle/2764774/caution-warranted-using-institute-health-metrics-evaluation-model-predicting-course",
                                                          "Jewell NP et al. 'Caution Warranted: Using the Institute for Health Metrics and Evaluation Model for Predicting the Course of the COVID-19 Pandemic'. Ann Intern Med. 2020.")),
                                           tags$li(tags$a(href = "https://annals.org/aim/fullarticle/2764774/caution-warranted-using-institute-health-metrics-evaluation-model-predicting-course",
                                                          "Jewell NP et al. 'Predictive Mathematical Models of the COVID-19 Pandemic: Underlying Principles and Value of Projections.' JAMA. 2020.")
                                           ))),
                                       hr(),
                                       
                                       p(tags$b("Update frequency:"), "multiple times per week"),
                                       hr(),
                                       
                                       p(tags$b("Most recent data update in Model Inventory:"), "June 6, 2020"),
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
                         
                         p(tags$b("Modeling approach:"), '"statistical dynamical growth model accounting for population susceptibility" (per CDC)'),
                         hr(),
                         
                         p(tags$b("What is predicted:"), "infections, fatalities, and tests performed"),
                         hr(),
                         
                         p(tags$b("Selected data inputs:"),
                           tags$ul(
                             tags$li("death data:", tags$a(href = "https://coronavirus.jhu.edu/map.html", "Johns Hopkins COVID-19 dashboard", target = "_blank"))
                           )),
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
                           
                           p(tags$b("Temporal and geographic resolution:"), "daily estimates for selected US states and selected countries"),
                           hr(),
                           
                           p(tags$b("Geographic coverage of estimates:"), "Global"),
                           hr(),
                           
                           p(tags$b("Reference and source documentation:"),
                             tags$ul(
                               tags$li(tags$a(href="https://covid-19.bsvgateway.org/", "model results and visualizations", target="_blank")),
                               tags$li(tags$a(href="https://covid-19.bsvgateway.org/#uncertainty", "additional model documentation", target="_blank"))
                             )),
                           hr(),
                           
                           p(tags$b("Media coverage, responses from other researchers:"),
                             tags$ul(
                               tags$li(tags$a(href = "https://www.cdc.gov/coronavirus/2019-ncov/covid-data/forecasting-us.html",
                                              "CDC Forecast Website", target = "_blank")))),
                           hr(),
                           
                           p(tags$b("Update frequency:"), "multiple times per week"),
                           hr(),
                           
                           p(tags$b("Most recent data update in Model Inventory:"), "June 10, 2020"),
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
                         
                         p(tags$b("Modeling approach:"), '"SEIR model fit to reported death and case counts" (per CDC)'),
                         hr(),
                         
                         p(tags$b("What is predicted:"), "detected infections, detected deaths, active cases, and hospitalizations"),
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
                           
                           p(tags$b("Media coverage, responses from other researchers:"),
                             tags$ul(
                               tags$li(tags$a(href = "https://www.cdc.gov/coronavirus/2019-ncov/covid-data/forecasting-us.html",
                                              "CDC Forecast Website", target = "_blank")))),
                           hr(),
                           
                           p(tags$b("Update frequency:"), "daily"),
                           hr(),

                           p(tags$b("Most recent data update in Model Inventory:"), "June 8, 2020"),
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
                         
                         p(tags$b("Modeling approach:"), 'agent-based model'),
                         hr(),
                         
                         p(tags$b("What is predicted:"), "deaths"),
                         hr(),
                         
                         p(tags$b("Selected data inputs:"),
                           tags$ul(
                             tags$li("caseload data:", tags$a(href = "https://github.com/midas-network/COVID-19/tree/master/data/cases/united%20states%20of%20america/nytimes_covid19_data", "New York Times (via midas-network github)", target = "_blank"))
                           )),
                         hr(),
                         
                         p(tags$b("Key assumptions:") ,
                           tags$ul(
                             tags$li("please consult available documentation below for additional information on key model assumptions")),
                           
                           hr(),
                           
                           p(tags$b("Temporal and geographic resolution:"), "daily estimates for selected US states"),
                           hr(),
                           
                           p(tags$b("Geographic coverage of estimates:"), "selected US states (IL, IN, KY, MI, MN, OH, WI)"),
                           hr(),
                           
                           p(tags$b("Reference and source documentation:"),
                             tags$ul(
                               tags$li(tags$a(href="https://github.com/confunguido/covid19_ND_forecasting/tree/master/output", "model outputs", target="_blank")),
                               tags$li(tags$a(href="https://fred.publichealth.pitt.edu/", "FRED model documentation", target="_blank")),
                               tags$li(tags$a(href = "https://github.com/confunguido/covid19_ND_forecasting/blob/master/output/metadata-NotreDame-FRED.txt", "additional documentation", target = "_blank"))
                             )),
                           hr(),
                           
                           p(tags$b("Media coverage, responses from other researchers:"),
                             tags$ul(
                               tags$li(tags$a(href = "https://www.cdc.gov/coronavirus/2019-ncov/covid-data/forecasting-us.html",
                                              "CDC Forecast Website", target = "_blank")))),
                           hr(),
                           
                           p(tags$b("Update frequency:"), "multiple times per week"),
                           hr(),
                           
                           p(tags$b("Most recent data update in Model Inventory:"), "June 8, 2020"),
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
                         
                         p(tags$b("Modeling approach:"), 'modified SEIR model'),
                         hr(),
                         
                         p(tags$b("What is predicted:"), "confirmed cases, deaths, and recoveries"),
                         hr(),
                         
                         p(tags$b("Selected data inputs:"),
                           tags$ul(
                             tags$li("caseload data:", tags$a(href = "https://coronavirus.jhu.edu/map.html", "Johns Hopkins COVID-19 dashboard", target = "_blank")),
                             tags$li("caseload data:", tags$a(href = "https://github.com/nytimes/covid-19-data", "New York Times", target = "_blank")),
                             tags$li("caseload data:", tags$a(href = "https://www.worldometers.info/coronavirus/", "worldometer", target = "_blank")),
                             tags$li("caseload data:", tags$a(href = "https://coronavirus.1point3acres.com/", "1point3acres", target = "_blank")),
                             tags$li("caseload data:", tags$a(href = "http://publichealth.lacounty.gov/", "Los Angeles Department of Public Health", target = "_blank"))
                             
                           )),
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
                               tags$li(tags$a(href = "https://www.medrxiv.org/content/10.1101/2020.05.24.20111989v1", "preprint", target = "_blank")),
                               tags$li(tags$a(href = "https://covid19.uclaml.org/index.html", "model outputs and visualizations", target = "_blank"))
                             )),
                           hr(),
                           
                           p(tags$b("Media coverage, responses from other researchers:"),
                             tags$ul(
                               tags$li(tags$a(href = "https://www.cdc.gov/coronavirus/2019-ncov/covid-data/forecasting-us.html",
                                              "CDC Forecast Website", target = "_blank")))),
                           hr(),
                           
                           p(tags$b("Most recent data update in Model Inventory:"), "June 8, 2020"),
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
                            p("As the COVID-19 outbreak progresses, policy decision-makers and public health responders rely, 
                              in part, on the results of models that forecast caseload and fatalities to understand how the 
                              outbreak might progress."),
                            
                            p("Forecasts produced by different groups each have their own unique assumptions, 
                              underlying data inputs, methods, and intended uses. To understand these differences 
                              and how they might drive results, and to support research transparency, it is valuable to compare 
                              results and assumptions across models."),
                            
                            h3("Approach"),
                          
                            p("The COVID model inventory relies on a common data structure, documented in the project's", 
                              tags$a(href = "https://github.com/Innovate-For-Health/covid-ensemble/blob/master/data/Data%20Dictionary.xlsx", "data dictionary.", target = "_black"),
                              "As new model results become available, they are documented, archived, and processed via a series of routinely run R scripts 
                              and added to this relational data structure. This site will be updated every Thursday as new model results become available, though delays might occur."),
                            
                            p('A current inventory of all included models can be found in the "Model Inventory" tab above. All of these models
                            have been documented as being used by policy-makers or public health responders during the 2019-2020 COVID-19 pandemic. 
                            However, this inventory of models is by no means comprehensive, and new models are currently being assessed and added in a rolling fashion.'),
                            

                            h3("Team and acknowledgements"),
                            
                            p("This site was designed, built, and developed by", 
                              tags$a(href="https://innovateforhealth.berkeley.edu/steph-eaneff-msp", 
                                     "Steph Eaneff."),  target = "_black"),
                            
                            p("This work was made possible by support from the",
                              tags$a(href = "https://innovateforhealth.berkeley.edu/",
                                     "Innovate for Health Data Science Health Innovation program,", target = "_blank"),
                              "including support from the UCSF Bakar Computational Health Sciences Institute, the UC Berkeley Institute for Data Science, 
                              and Johnson & Johnson Innovation.")
                          ))
)