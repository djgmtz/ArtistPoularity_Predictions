library(shiny)
library(rvest)
library(tidyverse)
library(magrittr)
library(scales)
library(knitr)
library(lubridate)
library(readr)
library(dplyr)
library(ggplot2)
library(DT)


top_artists_new<- as.list(numFollowers$artist_name)
# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Artist Popularity"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      selectInput("Select Artist",label="Artist Selected:",
                  choices= top_artists_new
      ),
      selected=top_artists_new[1]
      
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("distPlot"),
      DT::dataTableOutput("tablemusic") 
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  attach(numFollowers)
  output$distPlot <- renderPlot({
    # generate bins based on input$bins from ui.R
    numFollowers$artist_name <- factor(numFollowers$artist_name, levels = numFollowers$artist_name)
    
    
    numFollowers$artist_name <- factor(numFollowers$artist_name, levels = numFollowers$artist_name[order(numFollowers$artist_num_followers)]) # to visualise the list in descending order 
    
    ggplot(numFollowers, aes(x = numFollowers$artist_name, y = numFollowers$artist_num_followers)) +
      geom_bar(stat = "identity",  fill = "tomato2", width = 0.6 ) + 
      labs(title = "Top Artists by popularity", x = "Artists", y = "Spotify Popularity Ranking") +
      theme(plot.title = element_text(size=14,hjust=-.3,face = "bold"), axis.title = element_text(size=12)) +
      geom_text(aes(label= artist_popularity), hjust = 1, size = 2, color = 'white') +
      coord_flip()
  })
  
  
  output$tablemusic <- DT::renderDataTable({
    attach(final_trackOutput_analysis)
    
    datatable(final_trackOutput_analysis[,1:7])
  })
  
  
}

# Run the application 
shinyApp(ui = ui, server = server)

