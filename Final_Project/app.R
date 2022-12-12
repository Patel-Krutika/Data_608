#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(jsonlite)
library(data.table)
library(igraph)
library(ggraph)
library(networkD3)
library(wordcloud)
library(RColorBrewer)
library(wordcloud2)
library(DT)
library(formattable)
library(reactable)
library(bslib)
library(rsconnect)

recipies <- data.frame(read.csv('archive\\RAW_recipes.csv'))
recipies <- recipies %>% mutate(tags = str_extract_all(tags, "'(.*?)'"))
recipies <- recipies %>% mutate(steps = str_extract_all(steps, "'(.*?)'"))
recipies <- recipies %>% mutate(ingredients = str_extract_all(ingredients, "'(.*?)'"))

# Define UI for application that draws a histogram
ui <- navbarPage("What to eat? A question for the ages",
                 theme = bs_theme(version = 4, bootswatch = "lumen"),
                 
        tabPanel("Data",
                 fluidPage(
                   fluidRow(
                     h3('Dataset'),
                     textOutput('dataset')
                   ),
                   fluidRow(),
                   fluidRow(
                     h3('Data Parameters')
                   ),
                   fluidRow(
                     tableOutput('data_param')
                   )
                 )
                 
        ),
        tabPanel("Tags",
                 fluidPage(
                   fluidRow( 
                      column(12, align='center',
                        h2("Tags"),
                        wordcloud2Output('tag_wc')
                      )
                   )
                 )
        ),
        tabPanel("Ingredients",
                 fluidPage(
                   fluidRow( 
                     column(12, align='center',
                            h2("Ingredients"),
                            wordcloud2Output('ing_wc')
                     )
                   )
                 )
        ),
        tabPanel("Search",
                 sidebarLayout(
                   sidebarPanel(
                  # Filter Criteria
                     #Cuisine select
                     #selectInput('cuisine', 'Cusine', c('all','mexican','italian','indian','thai','korean','french','latin-american','chinese','japanese','spanish'), selected='all'),
                     #Popular select 
                     #selectInput('pop','Popular', c('all','casserole','chili','soup','pasta','bread','cookie','salad','tofu'), selected='all'),
                     #Num Steps slider
                     sliderInput('num_step','Number of Steps', min(recipies$n_steps), max(recipies$n_steps), 5, step=1),
                     #Num Min slider
                     sliderInput('num_min','Number of Minutes', min(recipies$minutes), 500, 20, step=10),
                     #Num Ingredients slider
                     sliderInput('num_ing','Number of Ingredients', min(recipies$n_ingredients), max(recipies$n_ingredients), 5, step=1)
                   ),
                   mainPanel(
                  # Filtered Values Table
                     DT::dataTableOutput('results')
                   )
                   
                 )
        ),
        tabPanel("Conclusion",
                 fluidPage(
                   h3("Process"),
                   fluidRow(
                     textOutput('c1')
                   ),
                   fluidRow(
                     textOutput('c2')
                   ),
                   fluidRow(
                     textOutput('c3')
                   ),
                   fluidRow(
                     textOutput('c4')
                   ),
                   h3("Future Work"),
                   fluidRow(
                     textOutput('c5')
                   ),
                   fluidRow(
                     textOutput('c6')
                   ),
                   fluidRow(
                     textOutput('c7')
                   ),
                   fluidRow(
                     textOutput('c8')
                   )
                 )
        ),
        
      )

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  # Data  
  output$dataset <- renderText('Food intake is a necessity, but the journey from the feeling of hunger to consuming food can sometime be tedious and complex web of sub questions. What do I want to eat? What cusine do I want to try? How long will it take to make? Do I have all the necessary ingredients? These questions are on constant repeat. Food data can help us make these decisions. This dataset consists of 180K+ recipes and 700K+ recipe reviews covering 18 years of user interactions and uploads on Food.com (formerly GeniusKitchen). The data was used in the following paper: Generating Personalized Recipes from Historical User Preferences. For the purposes of this analysis, only the raw recipe data will be used. The "RAW_recipies.csv" files contains 231,637 rows across 12 columns.    https://www.kaggle.com/datasets/shuyangli94/food-com-recipes-and-user-interactions')  
  
  output$data_param <- renderTable({
    Parameter <- c('Name','Recipe ID','# Minutes','Contributer ID', 'Tags', 'Nutrition','# N Steps', 'Steps','Description')
    Description <- c('Name of the recipe','Unique recipie ID','Number of minutes needed to prepare the recipe','User ID of the person who contributed the recipe','Food.com tags for this recipe','Nutrition information (calories (#), total fat (PDV), sugar (PDV) , sodium (PDV) , protein (PDV) , saturated fat','Number of Steps in the recipe','Text for the recipe steps, in order','User-provided description')
    dp <- data.frame(Parameter,Description)
    dp
  })
  
  # Tags
  
  
  output$tag_wc <- renderWordcloud2({
    wrds <- recipies %>% select(tags)
    words <- unnest(wrds, tags) %>% count(tags, sort = TRUE)
    set.seed(1234) 
    wordcloud2(data=words, size=1.6, color='random-dark')
    
  })
  
  # Ingredients
  
  output$ing_wc <- renderWordcloud2({
    wrds <- recipies %>% select(ingredients)
    words <- unnest(wrds, ingredients) %>% count(ingredients, sort = TRUE)
    set.seed(1234)
    wordcloud2(data=words, size=1.6, color='random-dark')
  })
  
  # Search
  
  output$results <- DT::renderDataTable(DT::datatable({
      # cuisine
      data <- recipies
      #if (input$cuisine != "all") {
       # data <- data %>% filter(contains(input$cuisine,tags))
      #}
      
      # popular
      #if (input$pop != "All") {
       # data <- data %>% filter(grepl(toString(input$pop),tags))
      #}
      
      # num steps
      data <- data %>% filter(n_steps <= input$num_step)
      
      # num min
      data <- data %>% filter(minutes <= input$num_min)
      
      # num ingredients
      data <- data %>% filter(n_ingredients <= input$num_ing)
    
      data <- data %>% select('name','minutes','n_steps','steps','ingredients', 'description', 'tags')
      
      colnames(data) <- c('Name','Minutes','Number of Steps', 'Steps', 'Ingredients', 'Description', 'Tags')
      data
  }))
  
  # Conclusion
  output$c1 <- renderText({
    '* The data was retrived from a Kaggle data post. Upon examination of the files provided in the dataset, it was determined that for the purposes of this analysis the RAW_Recipies.csv file contained to most useful data.'
  })
  
  output$c2 <- renderText({
    '* The dataset was examined and filtered for missing values and other data descrepencies.'
  })
    
  output$c3 <- renderText({
    '* Visual summary statistics were created for the data overall and an interative portion was built for further examination of subcategory data.'
  })
  
  output$c4 <- renderText({
    '* A recipie finder portion was created that allows the user to filter through the recipie database based on desired categorical values. '
  })
  
  output$c5 <- renderText({
    '* Add new criteria to recipe finder'
  })
  
  output$c6 <- renderText({
    '* Examine other data files in the dataset'
  })
  
  output$c7 <- renderText({
    '* Create new visual analysis techniques for new and existing data'
  })
  
  output$c8 <- renderText({
    '* Create machine learning based recommender system'
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
