library(tidyverse)
library(rvest)

#Warning- this was written Feb 12, 2023 so the way the data is stored at the URL below could change in a way that this script doesn't pick it up

# Get the URL for the top 250 movies of all time according to IMDb
url <- "https://www.imdb.com/chart/top"

# Read the HTML from the URL
html_data <- read_html(url)

# Extract the movie titles, release years from the HTML
movies_list <- html_data %>%
  html_nodes("td.titleColumn") %>%
  html_text() %>%
  strsplit("\n")


movies_list <- lapply(movies_list, function(x) {
  x[4] <- gsub("[()]", "", x[4])
  x
})

# Convert the list to a data frame
movies_df <- data.frame(title = sapply(movies_list, function(x) gsub("^ +", "", x[3])),
                        year = sapply(movies_list, function(x) gsub("^ +", "", x[4])),
                        stringsAsFactors = FALSE)

movies_df$year <- as.numeric(movies_df$year)

#admittedly this could totally be fixed up.. 
Nodey<-html_data %>%
  html_nodes("td.titleColumn + td")  #xml_node is ready for extraction...

nodeee_ratings <- lapply(Nodey, function(x) {
  rating_text <- html_text(html_node(x, "strong"))
  rating <- as.numeric(rating_text)
  rating
})

# Convert the result to a vector
rating <- unlist(nodeee_ratings)

movies_df$rating<-rating

#yes repeaty below and should just roll up the code below into the rating work above .. will do later hopefully but you can if you'd like

# Extract the number of ratings for each element in nodey
nodey_num_ratings <- lapply(Nodey, function(x) {
  rating_text <- html_attr(html_node(x, "strong"), "title")
  num_ratings_text <- gsub("^[^0-9.]*[0-9.]+ based on ([0-9,]+)[^0-9]+$", "\\1", rating_text)
  num_ratings <- as.numeric(gsub(",", "", num_ratings_text))
  num_ratings
})
# Convert the result to a vector
num_ratings<- unlist(nodey_num_ratings)

movies_df$num_ratings<-num_ratings

#so you can write movies_df to your local disk
write.table(movies_df, "movies_top_250.csv", sep=",", row.names=FALSE)
