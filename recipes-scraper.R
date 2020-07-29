# install.packages("rvest")

library(rvest)
library(dplyr)
library(tidyr)
library(stringr)
library(purrr)
library(downloader)
library(pagedown)


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

# form 1-link vector to test with

tocollect<- dat$link[1]

pagedown::chrome_print(input=tocollect,
                       wait=20,
                       format = "pdf",
                       verbose = 0,
                       timeout=300)

# setwd("C:/Users/ctr37/Documents/GitHub/recipes_scraper_data")

setwd("/Users/rogersc/Documents/GitHub/recipes_scraper_data")

for (myurl in tocollect) {
  filename<-paste("html/test", ".html", sep="")
  download(myurl, filename)
  # download.file(url=myurl, destfile = filename, mode = 'wb')
  Sys.sleep(2)
}


# 
# pagedown::chrome_print(
#   input=tocollect[1],
#   output = "html/test.pdf",
#   wait = 2,
#   # browser = "google-chrome",
#   format = "pdf",
#   options = list(),
#   selector = "body",
#   #box_model = c("border", "content", "margin", "padding"),
#   scale = 1,
#   work_dir = tempfile(),
#   timeout = 30,
#   extra_args = c("--disable-gpu"),
#   verbose = 0,
#   async = FAL
# )

pagedown::chrome_print(
  input=tocollect[1],
  output = "html/test.pdf",
  wait = 2,
  browser = "google-chrome",
  format = "pdf",
  options = list(),
  selector = "body",
  #box_model = c("border", "content", "margin", "padding"),
  scale = 1,
  work_dir = tempfile(),
  timeout = 30,
  extra_args = c("--disable-gpu"),
  verbose = 0,
  async = FAL
)

pagedown::chrome_print("html/2012.html", format = "pdf", verbose = 2, timeout=300)


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



