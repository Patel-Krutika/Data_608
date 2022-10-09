library(ggplot2)
library(dplyr)
library(plotly)
library(tidyverse)
library(shiny)
  
df <- read.csv('https://raw.githubusercontent.com/charleyferrari/CUNY_DATA_608/master/module3/data/cleaned-cdc-mortality-1999-2010-2.csv')

# Question 1:
# As a researcher, you frequently compare mortality rates from particular causes across different
# States. You need a visualization that will let you see (for 2010 only) the crude mortality rate,
# across all States, from one cause (for example, Neoplasms, which are effectively cancers). Create
# a visualization that allows you to rank States by crude mortality for each cause of death.

data <- df
data_1 <- data %>% filter(Year==2010)

# Question 2:
#   Often you are asked whether particular States are improving their mortality rates (per cause)
# faster than, or slower than, the national average. Create a visualization that lets your clients
# see this for themselves for one cause of death at the time. Keep in mind that the national
# average should be weighted by the national population.
data_2 <- df
data_2 

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("CDC Mortality"),

    # Header title
    headerPanel("Deaths By State"),
    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
          selectInput('cause', 'Cause of Death 2010', unique(data_1$ICD.Chapter), selected='Neoplasms')
        ),
        sidebarPanel(
          selectInput('year', 'Year', unique(data_2$Year), selected = min(data_2$Year)),
          selectInput('cause_2', 'Cause of Death', unique(data_2$ICD.Chapter), selected='Neoplasms')
        )
    ),
    
        # Show a plot of the generated distribution
    mainPanel(
       plotOutput("codPlot"),
       plotOutput('ratePlot')
    )
    
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$codPlot <- renderPlot({
          # filter data to cause of Death
          data_1_cod <- data_1 %>% filter(ICD.Chapter==input$cause)
          
          # draw bar graph
          ggplot(data_1_cod, aes(x = reorder(State, -Deaths), y = Deaths)) + geom_bar(stat = 'identity', fill = 'lightgreen')+ theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
          
    })
    
    output$ratePlot <- renderPlot({
      # filter data to cause of Death
      data_2_rates <- data_2 %>% filter(Year == input$year, ICD.Chapter==input$cause_2)
      
      # calculate national avg
      nat_avg <- (sum(data_2_rates$Deaths)/sum(data_2_rates$Population))*100000
      # draw bar graph
      ggplot(data_2_rates, aes(x = State, y = Crude.Rate)) + geom_bar(stat = 'identity', fill = 'lightgreen')+ theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + geom_hline(yintercept = nat_avg)
      
    })
    
    
    
}

# Run the application 
shinyApp(ui = ui, server = server)
