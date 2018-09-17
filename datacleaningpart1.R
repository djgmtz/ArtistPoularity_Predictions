---
  title: "las30daytest"
author: "Diego Gutierrez"
date: "September 15, 2018"
output: html_document
---
  
  ```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)

library(rvest)
library(tidyverse)
library(magrittr)
library(scales)
library(knitr)
library(lubridate)
library(readr)
library(plyr)
library(dplyr)
library(ggplot2)
library(spotifyr)

#Diego Credentials
Sys.setenv(SPOTIFY_CLIENT_ID = '6b8e19bd2af0448aa0476c469b222d46')
Sys.setenv(SPOTIFY_CLIENT_SECRET = 'dd8b18877d4941febca6703986424129')

#geting access token
access_token <- get_spotify_access_token()
```


##Getting 30 days back from latest sequence
```{r}
library(lubridate)

url<- "https://spotifycharts.com/regional/us/daily/latest"


SpotifyScrapeDate <- function(x){
  page <- x
  dates <- page %>% read_html() %>% html_nodes('.responsive-select~ .responsive-select+ .responsive-select .responsive-select-value') %>% html_text() %>% as.data.frame()
  chart <- cbind(dates)
  
  names(chart) <- c("Date")
  chart <- as.tibble(chart)
  return(chart)
}

latestdate <- map_df(url, SpotifyScrapeDate)
latestdate<- as.Date(latestdate$Date, "%m/%d/%Y")

##Looking for last 30days data from latest version
#latest= spotify$Date[1]

monthago=ymd(latestdate)-28

#Creating the sequence from 30days ago to latest date
last30darray= as.array(seq(from=monthago,to=latestdate,by=1))
last30d=seq(from=monthago,to=latestdate,by=1)

#View(last30darray)
#View(last30d)

```


##Creating the URL LIST of last 30 days
```{r}
url_template <- "https://spotifycharts.com/regional/us/daily/"

UrlList<- function(x){
  url_list <- paste0(url_template, x)
  url_list
}

finalurl <- UrlList(last30d)
#View(finalurl)
```

#Iterating the list
```{r}

#  Scrapping the top 200 songs in the US for current date 
url <- "https://spotifycharts.com/regional/us/daily/latest"

SpotifyScrape <- function(x){
  
  page <- x
  #if()
  rank <- page %>% read_html() %>% html_nodes('.chart-table-position') %>% html_text() %>% as.data.frame()
  track <- page %>% read_html() %>% html_nodes('strong') %>% html_text() %>% as.data.frame()
  artist <- page %>% read_html() %>% html_nodes('.chart-table-track span') %>% html_text() %>% as.data.frame()
  streams <- page %>% read_html() %>% html_nodes('td.chart-table-streams') %>% html_text() %>% as.data.frame()
  dates <- page %>% read_html() %>% html_nodes('.responsive-select~ .responsive-select+ .responsive-select .responsive-select-value') %>% html_text() %>% as.data.frame()
  
  #combining, naming, classifying our variables
  
  chart <- cbind(rank, track, artist, streams, dates)
  
  names(chart) <- c("Rank", "track_name", "Artist", "Streams", "Date")
  chart <- as.tibble(chart)
  chart<- chart[0:10,]
  chart%<>% mutate(Rank= as.character(Rank),
                   Artist = gsub("by ", "", Artist), 
                   Streams = gsub(",", "", Streams), 
                   Streams = as.numeric(Streams), 
                   Date = as.Date(chart$Date, "%m/%d/%Y"))
  
  chart<- as.data.frame(chart)
  return(chart)
}

```

```{r Importdata, eval=FALSE, message=TRUE, warning=FALSE, include=FALSE, paged.print=TRUE}
####Dataframe
# storing values in a dataframe called spotify
spotifymonthlydf <- map_df(finalurl, SpotifyScrape)

levels(spotifymonthlydf$Rank)<- c("1","2","3","4","5","6","7","8","9","10")

spotifymonthlydf$Rank<-as.numeric(spotifymonthlydf$Rank)
spotifymonthlydf$Streams<- as.numeric(spotifymonthlydf$Streams)

write.csv(spotifymonthlydf, file = "last30d.csv")

```

##END OF DATA CLEANING PART 1

```{r message=FALSE, warning=FALSE}

library(readr)
spotifymonthlydf<- read_csv("last30d.csv")[,2:6]

str(spotifymonthlydf)
levels(spotifymonthlydf$Rank)
```


##ANALYSIS STARTS HERE 
###GROUPING DATA FOR FINAL DATAFRAMES
***
  
  #ARTIST OVERVIEW
  
  ```{r}

artist_monthoverview<-spotifymonthlydf %>%
  group_by(Artist) %>%
  dplyr::summarise(
    timesappeared= n(),
    avgpos= round(mean(Rank),1),
    totalstreams= sum(Streams),
    bestpos= min(Rank),
    worsepos=max(Rank)
  )

##Ordering data frame by AVGPOS
artist_monthoverview<-artist_monthoverview[order(artist_monthoverview$totalstreams,decreasing = TRUE),]

```



#TRACK OVERVIEW
```{r}
track_monthoverview<-spotifymonthlydf %>%
  group_by(track_name) %>%
  dplyr::summarise(
    Artist= Artist[1],
    timesappeared= n(),
    avgpos= round(mean(Rank),1),
    bestdaystreams= max(Streams),
    worsedaystreams=min(Streams),
    totalstreams= sum(Streams),
    bestposition= min(Rank),
    worseposition=max(Rank),
    firstshowup= min(Date),
    lastshowup=max(Date)
  )

track_monthoverview<-track_monthoverview[order(track_monthoverview$totalstreams,decreasing = TRUE),]


```

