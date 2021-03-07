library(XML)
library(RCurl)
library(tidyverse)
library(openxlsx)

url<-"https://www.waterkwaliteitsportaal.nl/WKP.WebApplication/Beheer/Data/GrondwaterkwaliteitMeetgegevens"

page<-readLines(url)
#page   <- getURL(url)
parsed <- htmlParse(page)
links  <- paste("https://www.waterkwaliteitsportaal.nl", xpathSApply(parsed, path="//a", xmlGetAttr, "href"),sep="")
inds   <- grep("IMmetingen_GWkwaliteit_NL", links)
links  <- links[inds]

regex_match <- regexpr("[^/]+$", links, perl=TRUE)
destination <- regmatches(links, regex_match)
#setInternet2(use = TRUE)


for(i in seq_along(links)){
  download.file(links[i], destfile=destination[i],method="libcurl")
  Sys.sleep(runif(1, 1, 5))
}

# unzip the zipped files in the folder
lapply(destination,unzip)

#IMmetingen_GWkwaliteit_NL67_20191210.csv
ll<-list.files(pattern = "NL[0-9]{2}_[0-9]{8}\\.csv$")


dataset <- do.call("rbind", lapply(ll, FUN = function(file) {
  read.csv2(file)
}))
