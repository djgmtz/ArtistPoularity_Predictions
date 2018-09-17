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

load(file = "finaltrack_environment.Rdata")

top_track_data<- as.list(trackOutput_analysis$track_name)
# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Most streamed song (last 30 days)"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      selectInput("Select Track",label="Track Selected:",
                  choices= top_track_data
      ),
      selected=top_track_data[1]
      
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
  
  ###MOST STREAMED
  attach(track_monthoverview)
  
  output$distPlot <- renderPlot({
    # generate bins based on input$bins from ui.
    
    track_monthoverview$track_name  <- factor(track_monthoverview$track_name , levels = track_monthoverview$track_name [order(track_monthoverview$totalstreams )]) # to visualise the list in descending order 
    
    ggplot(track_monthoverview, aes(x = track_monthoverview$track_name, y = track_monthoverview$totalstreams)) +
      geom_bar(stat = "identity",  fill = "tomato2", width = 0.6 ) +
      labs(title = "Most streamed song", x = "Track", y = "Spotify Popularity Ranking") +
      theme(plot.title = element_text(size=14,hjust=-.3,face = "bold"), axis.title = element_text(size=12)) +
      geom_text(aes(label= totalstreams), hjust = 1, size = 2, color = 'white') +
      coord_flip()
  })
  
  
  output$tablemusic <- DT::renderDataTable({
    attach(final_trackOutput_analysis)
    
    datatable(final_trackOutput_analysis[,1:7])
  })
  
  
}

# Run the application 
shinyApp(ui = ui, server = server)

