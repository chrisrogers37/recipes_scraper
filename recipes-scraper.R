# install.packages("rvest")

library(rvest)
library(dplyr)
library(tidyr)
library(stringr)
library(purrr)

#Specifying the url for desired website to be scraped

url1 <- paste0('https://www.foodrepublic.com/author/george-embiricos/page/', '1', '/')

#Reading the HTML code from the website
webpage1 <- read_html(url1)

dat <- html_attr(html_nodes(webpage, 'a'), "href") %>%
  as_tibble() %>%
  filter(str_detect(value, "([0-9]{4})")) %>%
  # filter(str_detect(value, "[/][0-9]{4}[/][0-9]{2}[/][0-9]{2}[/]")) %>%
  unique() %>%
  rename(link=value)

for (i in 2:89) {

url <- paste0('https://www.foodrepublic.com/author/george-embiricos/page/', i, '/')

#Reading the HTML code from the website
webpage <- read_html(url)

links <- html_attr(html_nodes(webpage, 'a'), "href") %>%
  as_tibble() %>%
  filter(str_detect(value, "([0-9]{4})")) %>%
  # filter(str_detect(value, "[/][0-9]{4}[/][0-9]{2}[/][0-9]{2}[/]")) %>%
  unique() %>%
  rename(link=value)

dat <- bind_rows(dat, links) %>%
  unique()

}

dat <- dat %>%
  arrange(link)

urltest <- dat$link[1]

urltest

webpagetest <- read_html(urltest)

## Title of Recipe

title <- html_nodes(webpagetest, '.article-title')

article_title <- html_text(title)

## Date

date <- html_nodes(webpagetest, 'time')

article_date <- html_text(date)

## Article Text

text <- html_nodes(webpagetest, 'span p')

article_text <- paste0(html_text(text), collapse=" ")

article_text

## Article Image

imgsrc <- html_nodes(webpagetest, '.article-image img') %>%
  html_attr('src')

download.file(url=imgsrc, destfile = "C:/Users/ctr37/Documents/GitHub/recipes_scraper_data/img1.jpeg", mode='wb')



