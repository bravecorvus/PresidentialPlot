library(devtools)
library(RJSONIO)
library(knitr)
library(httpuv)
library(shiny)
library(googleVis)
library(graphics)
library(ggplot2)
load(url("http://www.clutchmemes.com/cs125/avgGOP.RData"))
load(url("http://www.clutchmemes.com/cs125/avgDEM.RData"))
load(url("http://www.clutchmemes.com/cs125/pres_trendDF.melt.RData"))


averagedDEMPoll.melt

demgtrends <- pres_trendDF.melt[pres_trendDF.melt$candidate=='Hillary' | pres_trendDF.melt$candidate=='Bernie',]
dempolls <- averagedDEMPoll.melt[averagedDEMPoll.melt$candidate=='Clinton' | averagedDEMPoll.melt$candidate=='Sanders',]
dembubbleDF <- data.frame(Date=demgtrends$date, Candidate=demgtrends$candidate, Searched=demgtrends$searched, Percentage=dempolls$percentage)
#adding a polling percentage column

dembubbleDF$Percentage[1] <- 0
#Fixing the Percentage data so that there are no more NA's

for(i in seq_along(dembubbleDF$Percentage[1:length(dembubbleDF$Percentage)])){
    if(i > 1){
        if(is.nan(dembubbleDF$Percentage[i])){
            if(!is.nan(dembubbleDF$Percentage[i-1])){
                    z <- dembubbleDF$Percentage[i-1]
            }else{
                for(n in dembubbleDF$Percentage[i:length(dembubbleDF$Percentage)]){
                    if(!is.na(n)) {
                        z <- n
                        break
                    }
                }
            }
            dembubbleDF$Percentage[i] <- z
        }
    }
}

changeInPercentage <- c(0)
for(i in seq_along(dembubbleDF$Percentage[1:length(dembubbleDF$Percentage)])){
    if(i > 1){
        z <- dembubbleDF$Percentage[i] - dembubbleDF$Percentage[i-1]
        changeInPercentage <- append(changeInPercentage, z)}
}

dembubbleDF <- cbind(dembubbleDF, Change.In.Polling.Percentage=changeInPercentage)

save(dembubbleDF, file="dembubbledf.RData")