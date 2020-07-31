# install.packages("rvest")

library(rvest)
library(dplyr)
library(tidyr)
library(stringr)
library(purrr)
library(downloader)
library(pagedown)
library(xml2)
library(htmltools)
library(tibble)
library(pdftools)

# Mac
# setwd("/Users/rogersc/Documents/GitHub/recipes_scraper_data")

# Windows
setwd("C:/Users/ctr37/Documents/GitHub/recipes_scraper_data")

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

dat <- head(dat, 10)

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

dat <- tail(dat, 890)

articleUrls <- dat$link

# articleUrls <- articleUrls[1]

for(i in seq_along(articleUrls)) {
  
  filename <- str_extract(articleUrls[i], "[^/]+(?=/$|$)")
 
  a <- read_html(articleUrls[i]) 
  xml_remove(a %>% xml_find_all("aside"))
  xml_remove(a %>% xml_find_all("footer"))
  xml_remove(a %>% xml_find_all(xpath = "//*[contains(@class, 'article-related mb20')]"))
  xml_remove(a %>% xml_find_all(xpath = "//*[contains(@class, 'tags')]"))
  #xml_remove(a %>% xml_find_all("head") %>% xml2::xml_find_all("script"))
  xml_remove(a %>% xml2::xml_find_all("//script"))
  xml_remove(a %>% xml_find_all("//*[contains(@class, 'ad box')]"))
  xml_remove(a %>% xml_find_all("//*[contains(@class, 'newsletter-signup')]"))
  xml_remove(a %>% xml_find_all("//*[contains(@class, 'article-footer')]"))
  xml_remove(a %>% xml_find_all("//*[contains(@class, 'article-footer-sidebar')]"))
  xml_remove(a %>% xml_find_all("//*[contains(@class, 'site-footer')]"))
  xml_remove(a %>% xml_find_all("//*[contains(@class, 'sticky-newsletter')]"))
  xml_remove(a %>% xml_find_all("//*[contains(@class, 'site-header')]"))
  xml_remove(a %>% xml_find_all("//*[contains(@class, '.fb_iframe_widget')]"))
  xml_remove(a %>% xml_find_all("//*[contains(@class, '_8f1i')]"))
  xml_remove(a %>% xml_find_all("//*[contains(@class, 'newsletter-toggle')]"))

  # xml_remove(a %>% xml_find_all("//*[contains(@class, 'articleBody')]"))
  
  # xml_remove(a %>% xml_find_all("//href='([^\"]*)'"))

  xml2::write_html(a, file = paste0("html/", filename, ".html"))
  
  tryCatch(pagedown::chrome_print(input = paste0("html/", filename, ".html"),
                         output=paste0("pdf/", filename, ".pdf"),
                         format="pdf", timeout = 300, verbose=0,
                         wait=20), error=function(e) paste("wrong"))
  
}

pdf_titles <- list.files("pdf/", full.names=T) %>%
  enframe(name = NULL) %>% 
  bind_cols(pmap_df(., file.info))%>% 
  arrange(mtime) %>%
  pull(value)

pdf_titles1 <- pdf_titles[1:300]
pdf_titles2 <- pdf_titles[301:600]
pdf_titles3 <- pdf_titles[601:870]

file.remove("output/PDF_CHUNK1.pdf")
file.remove("output/PDF_CHUNK2.pdf")
file.remove("output/PDF_CHUNK3.pdf")

pdftools::pdf_combine(input=pdf_titles1, output="output/PDF_CHUNK1.pdf")
pdftools::pdf_combine(input=pdf_titles2, output="output/PDF_CHUNK2.pdf")
pdftools::pdf_combine(input=pdf_titles3, output="output/PDF_CHUNK3.pdf")

pdftools::pdf_combine(input=c("output/PDF_CHUNK1.pdf", "output/PDF_CHUNK2.pdf", "output/PDF_CHUNK3.pdf"), output="output/FINAL_OUTPUT.pdf")
                      
