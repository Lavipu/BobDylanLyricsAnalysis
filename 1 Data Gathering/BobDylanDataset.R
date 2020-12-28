# create dataset with all songs per album 
# create dataset with all lyrics per song (per album)
# match the two 

setwd("C:/Users/Reuse/Desktop/BobDylan/Costruzione Dataset")
install.packages("geniusr")
install.packages("genius")
install.packages("dplyr")
install.packages("tidytext")
install.packages("tidyverse")
install.packages("knitr")
library(geniusr)
library(genius)
library(dplyr)
library(tidytext)
library(tidyverse)
library(knitr)

#API Access
genius_api_token <- c("HqHVQvXzrmWD-UcP8bgXh_JgwBdAFcwQYOYEU5RpoZAecvAhEtRO6Hgyaxw9szUd")
genius_token( force = TRUE)


#get album names and release years 
albuminfo <- read.delim('AlbumInfo.txt', header = TRUE, sep = ";",)
total_albums <- nrow(albuminfo)
album_titles <- albuminfo$Album
album_titles <- as.character(album_titles)
album_releases <- albuminfo$Year

#1  all songs 
n <- length(album_titles)
n
i <- 1
total_songs <- data.frame()
for(i in 1:n){
  tracklist <- cbind(genius_tracklist(artist = "Bob Dylan", album = album_titles[i])[1:2], album=album_titles[i], year = album_releases[i])
  total_songs <- rbind(total_songs,tracklist)
}
total_songs # this is BobSongs

# all lyrics 
n <- length(album_titles)
n
albums <- data.frame()
k <- 1
for (k in 1:n){
  album <- genius_album(artist = "Bob Dylan", album = album_titles[k], info = "simple")
  albums <- rbind(albums, album)
}
albums # all lyrics !!!!
names(albums)

# all lyrics in one line 
tracklist <-unique(albums$track_title)
tracklist
AllBobLyric <- data.frame()
n <- nrow(albums)
m <- length(tracklist)
i <- 1
j <- 1
for (i in (1:m)){
  for (j in (1:n)){
    if (albums$track_title[j]==tracklist[i]){
      songline <- albums[which(albums$track_title==albums$track_title[j]),] %>% 
        group_by(track_title) %>% 
        summarise_all(funs(trimws(paste(., collapse = ' ', sep = " "))))
    }
  }
  AllBobLyric <- rbind(AllBobLyric,songline)
}
AllBobLyric <- AllBobLyric[c("track_title","lyric")]
AllBobLyric # this is BobDylanData

# merging 
data <- merge(total_songs, AllBobLyric, by.x="track_title")
data[1,]


data <- data[
  with(data, order(year, track_n)),
  ]
view(data)
data
df <- data[is.na(data$lyric),]
df
 

write.csv(data, file="BobDylanDataset.csv", row.names = FALSE)






