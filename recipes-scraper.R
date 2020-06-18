# install.packages("rvest")

library(rvest)
library(dplyr)
library(tidyr)
library(stringr)


#Specifying the url for desired website to be scraped
url <- 'https://www.foodrepublic.com/author/george-embiricos/'

#Reading the HTML code from the website
webpage <- read_html(url)

html_attr(html_nodes(webpage, 'a'), "href")

links <- html_attr(html_nodes(webpage, '.desktop'), "href") %>%
  as_tibble() %>%
  filter(str_detect(value, "[0-9]{3}")) %>%
  # filter(str_detect(value, "[/][0-9]{4}[/][0-9]{2}[/][0-9]{2}[/]")) %>%
  unique() %>%
  rename(link=value)


# for i seq_along(as.vector(links$link)) {
#   
# }

url_new <- links$link[2]

webpage_new <- read_html(url_new)

## Title of Recipe

title <- html_nodes(webpage_new, '.article-title')

recipe_title <- html_text(title)

recipe_title

## Author of Recipe

author <- html_nodes(webpage_new, '.byline') 

recipe_author <- html_text(author)

## Date of Recipe

date <- html_nodes(webpage_new, 'time') 

recipe_date <- html_text(date)

recipe_date

## First Paragraph

p1 <- html_nodes(webpage_new, 'p > em') 

recipe_p1 <- html_text(p1)

recipe_p1

## Second Paragraph

p2 <- html_nodes(webpage_new, '#content p:nth-child(2)') 

recipe_p2 <- html_text(p2)

recipe_p2

## Recipe Components

components <- html_nodes(webpage_new, '.recipe-component:nth-child(1)') 

recipe_components <- html_text(components)

recipe_components <- str_replace_all(string = recipe_components, pattern = c("\t", "\n"), replacement = ' ')

recipe_components













