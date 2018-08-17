devtools::install_github('charlie86/spotifyr')
devtools::install_github('JosiahParry/geniusR')
library(spotifyr)
library(tidyverse)
library(geniusR)

#set system enviroment variables for client ID and Secret ID
#set system enviroment variables for client ID and Secret ID
Sys.setenv(SPOTIFY_CLIENT_ID = '6b99e144dd674a0cba426bc94c823929')
Sys.setenv(SPOTIFY_CLIENT_SECRET = '44727842431e4f3cb1909db30515aa70')

access_token <- get_spotify_access_token()

get_artists('blink182')
#pull in artist metrics such as genere, num followers, and popularity
for (i in 1:nrow(spotify_artists)) {
  if (i == 1){
    numFollowers <- get_artists(as.character(spotify_artists$dbname[i]))
  }else {
    tryCatch({
      numFollowers <- rbind(numFollowers, get_artists(as.character(spotify_artists$dbname[i])))},error=function(cond)
      {
        NA
      })
  }
  cat(paste0('\nFinished: ', i, ". Starting next loop on " , i+1, sep =' '))
}

#pull in album audio features 
for (i in 1:nrow(spotify_artists)) {
  if (i == 1){
    final_data <- get_artist_audio_features(as.character(spotify_artists$dbname[i]))
  }else {
    tryCatch({
      final_data <- rbind(final_data, get_artist_audio_features(as.character(spotify_artists$dbname[i])))},error=function(cond)
      {
        NA
      })
  }
  cat(paste0('\nFinished: ', i, ". Starting next loop on " , i+1, sep =' '))
}

####################
#clean and merge data -> save csv
#################
numFollowers <- numFollowers[,(1,2,4,5)]
aggData <- final_data[,c(1,4,8,10,13,14,16,18,19,20,21,22,23,24,27)]

#convert date to an actuall date object
aggData$album_release_date <- as.POSIXct(aggData$album_release_date, format = "%Y-%m-%d")

#get mean of each discographic variable for each unique artist/album combo
aggData <-aggregate(aggData, by=list(aggData$artist_name,aggData$album_name, aggData$album_release_date), FUN=mean)

#repreat three times to get rid of unused columns
aggData <- aggData[,-3]

#rename columns
colnames(aggData)[1] <- "artist_name"
colnames(aggData)[2] <- "album_name"

#subset numFollowers and merge with aggData
numFollowers <- numFollowers[,c(1,4,5,6)]
aggData <- as.data.frame(aggData)
aggData <- merge(aggData,numFollowers,by="artist_name" )

#unlist generes column
aggData$ artist_genres <- unlist(aggData$artist_genres)

#save as csv
write.csv(aggData, "C:/Users/pete/OneDrive/Desktop/spotify_agg_data.csv")
