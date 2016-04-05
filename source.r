library(jsonlite)
library(gtrendsR)
library(plyr)
library(dplyr)
library(ggplot2)
library(scales)
library(abind)
library(data.table)
library(tidyr)
library(RCurl)

#Bottom two lines are custom RData files I created myself, the souce code which can be found at "http://www.clutchmemes.com/cs125/fixgop.r" and "http://www.clutchmemes.com/cs125/fixdem.r" respectively
load(url("http://www.clutchmemes.com/cs125/GOPArray.RData"))
load(url("http://www.clutchmemes.com/cs125/DEMArray.RData"))





# Plotting the GOP Average Data Frame
averagedGOPPoll <- as.data.frame(aaply(allGOP, 1:2, mean, na.rm=TRUE))
averagedGOPPoll$date = as.Date(rownames(averagedGOPPoll))
averagedGOPPoll.melt <- gather(averagedGOPPoll,candidate,percentage,-date)
plotaverageGOPPoll <- ggplot(averagedGOPPoll.melt,aes(x=date,y=percentage,colour=candidate))+
  geom_line() + ylab("Percentage out of 100") + xlab("Dates: January-December 2015") + scale_x_date(labels = date_format("%m/%d"), breaks = date_breaks("month")) + labs(title = "Plot of Averaged Polling Data for the Republicans")


ggsave(plotaverageGOPPoll, file="plotaverageGOPPoll.png")



#Plotting the Democratic Average Data Frame
averagedDEMPoll <- as.data.frame(aaply(allDEM, 1:2, mean, na.rm=TRUE))
averagedDEMPoll$date = as.Date(rownames(averagedDEMPoll))


averagedDEMPoll.melt <- gather(averagedDEMPoll,candidate,percentage,-date)
plotaverageDEMPoll <- ggplot(averagedDEMPoll.melt,aes(x=date,y=percentage,colour=candidate))+
  geom_line() + ylab("Percentage out of 100") + xlab("Dates: January-December 2015") + scale_x_date(labels = date_format("%m/%d"), breaks = date_breaks("month")) + labs(title = "Plot of Averaged Polling Data for the Democrats")


ggsave(plotaverageDEMPoll, file="plotaverageDEMPoll.png")





#Creating RData for the averaged frames
save(averagedDEMPoll.melt, file="avgDEM.RData")
#Also saving a non-melted form of the data
save(averagedDEMPoll, file="avgDEMNoMelt.RData")
save(averagedGOPPoll.melt, file="avgGOP.RData")
#Also saving a non-melted form of the data
save(averagedGOPPoll, file="avgGOPNoMelt.RData")


# Melting the GTrends Data Frame
load(url("http://www.clutchmemes.com/cs125/pres_trendDF.RData"))
pres_trendDF$date = as.Date(rownames(pres_trendDF))
pres_trendDF.melt <- gather(pres_trendDF,candidate,searched,-date)
plotpres_trendDF <- ggplot(pres_trendDF.melt,aes(x=date,y=searched,colour=candidate))+
  geom_line() + ylab("Total Search Volume") + xlab("Dates: January-December 2015") + scale_x_date(labels = date_format("%m/%d"), breaks = date_breaks("month")) + labs(title = "Plot of Search Volume Over for Candidates")

save(pres_trendDF.melt, file="pres_trendDF.melt.RData")