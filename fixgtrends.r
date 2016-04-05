library(jsonlite)
library(gtrendsR)
library(plyr)
library(dplyr)
library(ggplot2)
library(scales)
library(abind)
library(data.table)
library(tidyr)


#So the only real difference between this code and that of the fixgop.r file is that there were sources such as Wilson Perkins Allen polling that did not poll for the Democratic party. At the same time, there were alot less candidates for the Democratic party (as is the case much of the time for incumbant parties)



includeNA <- function(argDF) {
    returnDF <- data.frame(stringsAsFactors=FALSE)
    argDF <- as.data.frame(argDF, stringsAsFactors=FALSE)

    dateSeq <- seq(as.Date("2015-01-01"), as.Date("2015-12-31"), by="days")
    count = 1
    for(i in seq_along(dateSeq)){
        if(any(dateSeq[i] %in% argDF$dates)==TRUE){
            returnDF <- rbind(returnDF, argDF[match(dateSeq[i], argDF$dates),])
            colnames(returnDF) <- colnames(argDF) 
        }else{
            naList <- data.frame(dateSeq[i], NA, NA, NA, NA, NA, stringsAsFactors=FALSE)
            colnames(naList) <- colnames(argDF)
            returnDF <- rbind(returnDF, naList)
            count <- count + 1}}
    rownames(returnDF) <- as.character(seq(as.Date("2015-01-01"), as.Date("2015-12-31"), by="days"))
    return(returnDF[1:nrow(returnDF), 2:ncol(returnDF)])
}

fixday <- function(argDF) {
    modDF<- data.frame(Start.Date=argDF$start, End.Date=argDF$end, Trump=argDF$Trump, Bernie=argDF$Bernie, Hillary=argDF$Hillary, Carson=argDF$Carson, Rand=argDF$Rand, stringsAsFactors=FALSE)
    modDF[1:2] <- lapply(modDF[1:2], as.Date)
    returnDF <- setDT(modDF)[, list(dates=seq(Start.Date, End.Date, by = '1 day'),
        Trump=Trump, Bernie=Bernie, Hillary=Hillary, Carson=Carson, Rand=Rand),
        by = 1:nrow(modDF)][, nrow:= NULL][]
    return(returnDF[order(dates),])
}




#Google Trends Package Set Up
usr <- "cs125fp@gmail.com"  
psw <- "Abcd@1234"      
gconnect(usr, psw)       
pres_trend <- gtrends(c("Trump", "Bernie", "Hillary", "Carson", "Rand"))


pres_trendDF <- pres_trend[[3]][574:nrow(pres_trend[[3]]),]
pres_trendDF <- fixday(pres_trendDF)
pres_trendDF <- includeNA(pres_trendDF)
save(pres_trendDF, file="/Users/andrewlee/Documents/School/CS125/Final Project/pres_trendDF.RData")