library(XML)
library(RCurl)
library(tidyverse)
library(openxlsx)


# open the URL and read the page
url<-"https://www.waterkwaliteitsportaal.nl/WKP.WebApplication/Beheer/Data/GrondwaterkwaliteitMeetgegevens"
page<-readLines(url)
parsed <- htmlParse(page)

# point links to the correct absolute domain
links  <- paste("https://www.waterkwaliteitsportaal.nl", 
                xpathSApply(parsed, path="//a", xmlGetAttr, "href"),
                sep="")

# select relevant links
links   <- grep("IMmetingen_GWkwaliteit_NL", links, value=T)

# determine destination files
regex_match <- regexpr("[^/]+$", links, perl=TRUE)
destination <- regmatches(links, regex_match)

# download the files from links and unzip
## NB: this section has been commented out, because we do not want to overload the website if everyone does this!
# for(i in seq_along(links)){
#   download.file(links[i], destfile=destination[i],method="libcurl")
#   Sys.sleep(runif(1, 1, 5))
# }
# lapply(destination,unzip)

# identify data files, read and collect the data
ll<-list.files(pattern = "NL[0-9]{2}_[0-9]{8}\\.csv$")
dataset <- do.call("rbind", lapply(ll, FUN = function(file) {
  read.csv2(file)
}))
