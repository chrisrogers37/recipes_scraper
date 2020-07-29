# install.packages("rvest")

library(rvest)
library(dplyr)
library(tidyr)
library(stringr)
library(purrr)
library(downloader)
library(pagedown)
library(xml2)


#Specifying the url for desired website to be scraped

url1 <- paste0('https://www.foodrepublic.com/author/george-embiricos/page/', '1', '/')

#Reading the HTML code from the website
webpage1 <- read_html(url1)

# Pull the links for all articles on George's initial author page

dat <- html_attr(html_nodes(webpage1, 'a'), "href") %>%
  as_tibble() %>%
  filter(str_detect(value, "([0-9]{4})")) %>%
  unique() %>%
  rename(link=value)

# Pull the links for all articles on George's 2nd-89th author page

for (i in 2:89) {

url <- paste0('https://www.foodrepublic.com/author/george-embiricos/page/', i, '/')

#Reading the HTML code from the website
webpage <- read_html(url)

links <- html_attr(html_nodes(webpage, 'a'), "href") %>%
  as_tibble() %>%
  filter(str_detect(value, "([0-9]{4})")) %>%
  unique() %>%
  rename(link=value)

dat <- bind_rows(dat, links) %>%
  unique()

}

dat <- dat %>%
  arrange(link)

articleUrls <- dat$link[1]

l <- articleUrls

# Mac
# setwd("/Users/rogersc/Documents/GitHub/recipes_scraper_data")

setwd("C:/Users/ctr37/Documents/GitHub/recipes_scraper_data")

 for(l in articleUrls) {
  a <- read_html(l) 
  xml_remove(a %>% xml_find_all("aside"))
  xml_remove(a %>% xml_find_all("footer"))
  xml_remove(a %>% xml_find_all(xpath = "//*[contains(@class, 'article-related mb20')]"))
  xml_remove(a %>% xml_find_all(xpath = "//*[contains(@class, 'tags')]"))
  xml_remove(a %>% xml_find_all("head") %>% xml2::xml_find_all("script"))
  xml_remove(a %>% xml_find_all("//*[contains(@class, 'ad box')]"))
  xml_remove(a %>% xml_find_all("//*[contains(@class, 'newsletter-signup')]"))
  xml_remove(a %>% xml_find_all("//*[contains(@class, 'article-footer')]"))
  xml_remove(a %>% xml_find_all("//*[contains(@class, 'article-footer-sidebar')]"))
  xml_remove(a %>% xml_find_all("//*[contains(@class, 'site-footer')]"))
  xml_remove(a %>% xml_find_all("//*[contains(@class, 'sticky-newsletter')]"))
  xml_remove(a %>% xml_find_all("//*[contains(@class, 'site-header')]"))
  
  xml2::write_html(a, file = "html/currentArticle.html")
  
  pagedown::chrome_print(input = "currentArticle.html")
  
}




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

text <- html_nodes(webpagetest, 'span > p')

article_text <- paste0(html_text(text), collapse=" ")

urltest

article_text

## Article Image

imgsrc <- html_nodes(webpagetest, '.article-image img') %>%
  html_attr('src')

download.file(url=imgsrc, destfile = "C:/Users/ctr37/Documents/GitHub/recipes_scraper_data/img1.jpeg", mode='wb')



