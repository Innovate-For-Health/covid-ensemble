
###################################################################################
## User interface #################################################################
###################################################################################

ui <- navbarPage("COVID Modeling Dashboard", id = "tabs",

###################################################################################
## View Models ####################################################################
###################################################################################
                 
###################################################################################
## View Models: Sidebar selections  ###############################################
###################################################################################

tabPanel("View models",

           sidebarPanel(
             
             selectInput(inputId = "location",
                         label = "Select location:",
                         choices = locations_agg,
                         selected = "United States of America"),
             
             selectInput(inputId = "output_name",
                     label = "Select model outputs:",
                     choices = output_options,
                     selected = "Hospital beds needed per day"),
             
             ## if you want to look at changes in a model over time, you need to pick one model to look at
             conditionalPanel(condition = "input.model_tab == 'monitor'",
                       selectInput(inputId = "model_name", 
                                   label = "Select model:", 
                                   choices = c("IHME COVID-19 Model", "COVID Act Now (strict stay at home)")))
             
           ),
         
            mainPanel(
              tabsetPanel(type = "tab", id = "model_tab",
                          
                          ###################################################################################
                          ## View Models: Compare Models ####################################################
                          ###################################################################################
                          
                          tabPanel(value = "compare", title = "Compare multiple models",
                                   plotOutput("compare_most_recent_models")),
                          tabPanel(value = "monitor", title = "Monitor changes over time", 
                                   plotOutput("compare_models_over_time"))
                          )
              
              
              

         )),


###################################################################################
## Map View #######################################################################
###################################################################################

tabPanel("Model inventory",
         mainPanel(
           h3("Overview of models currently incorporated"),
           h4("IHME COVID-19 Model"),
           h4("COVID Act Now (strict stay at home model)")
         )),

###################################################################################
## Download Data Tab ##############################################################
###################################################################################

tabPanel("Download data",
         mainPanel(DT::dataTableOutput("output_table"))), 

###################################################################################
## About tab ######################################################################
###################################################################################

tabPanel("About",
         mainPanel())
)

