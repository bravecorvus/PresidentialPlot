library(ggplot2)
load(url("http://www.clutchmemes.com/cs125/avgGOP.RData"))
load(url("http://www.clutchmemes.com/cs125/avgDEM.RData"))
load(url("http://www.clutchmemes.com/cs125/pres_trendDF.melt.RData"))
head(goppolls)



gopgtrends <- pres_trendDF.melt[pres_trendDF.melt$candidate=='Trump' | pres_trendDF.melt$candidate=='Carson' | pres_trendDF.melt$candidate=='Rand',]
goppolls <- averagedGOPPoll.melt[averagedGOPPoll.melt$candidate=='Trump' | averagedGOPPoll.melt$candidate=='Carson' | averagedGOPPoll.melt$candidate=='Rand.Paul',]
gopbubbleDF <- data.frame(Date=gopgtrends$date, Candidate=gopgtrends$candidate, Searched=gopgtrends$searched, Percentage=goppolls$percentage)
#adding a polling percentage column

gopbubbleDF$Percentage[1] <- 0
#Fixing the Percentage data so that there are no more NA's
for(i in seq_along(gopbubbleDF$Percentage[1:length(gopbubbleDF$Percentage)])){
    if(i > 1){
        if(is.nan(gopbubbleDF$Percentage[i])){
            if(!is.nan(gopbubbleDF$Percentage[i-1])){
                    z <- gopbubbleDF$Percentage[i-1]
            }else{
                for(n in gopbubbleDF$Percentage[i:length(gopbubbleDF$Percentage)]){
                    if(!is.na(n)) {
                        z <- n
                        break
                    }
                }
            }
            gopbubbleDF$Percentage[i] <- z
        }
    }
}

changeInPercentage <- c(0)
for(i in seq_along(gopbubbleDF$Percentage[1:length(gopbubbleDF$Percentage)])){
    if(i > 1){
        z <- gopbubbleDF$Percentage[i] - gopbubbleDF$Percentage[i-1]
        changeInPercentage <- append(changeInPercentage, z)}
}

gopbubbleDF <- cbind(gopbubbleDF, Change.In.Polling.Percentage=changeInPercentage)

save(gopbubbleDF, file="gopbubbledf.RData")