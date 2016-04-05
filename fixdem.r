require(abind)
require(data.table)
require(dplyr)
library(plyr)
library(RCurl)


#So the only real difference between this code and that of the fixgop.r file is that there were sources such as Wilson Perkins Allen polling that did not poll for the Democratic party. At the same time, there were alot less candidates for the Democratic party (as is the case much of the time for incumbant parties)


fixday <- function(argDF) {
    modDF<- data.frame(Start.Date=argDF$Start.Date, End.Date=argDF$End.Date, Clinton=argDF$Clinton, Sanders=argDF$Sanders, O.Malley=argDF$O.Malley, Biden=argDF$Biden, Chafee=argDF$Chafee, Lessig=argDF$Lessig, Webb=argDF$Webb, Undecided=argDF$Undecided, stringsAsFactors=FALSE)
    modDF[1:2] <- lapply(modDF[1:2], as.Date)
    returnDF <- setDT(modDF)[, list(dates=seq(Start.Date, End.Date, by = '1 day'),
        Clinton=Clinton, Sanders=Sanders, O.Malley=O.Malley, Biden=Biden, Chafee=Chafee, Lessig, Webb=Webb, Undecided=Undecided),
        by = 1:nrow(modDF)][, nrow:= NULL][]
    return(returnDF[order(dates),])
}


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
            naList <- data.frame(dateSeq[i], NA, NA, NA, NA, NA, NA, NA, NA, stringsAsFactors=FALSE)
            colnames(naList) <- colnames(argDF)
            returnDF <- rbind(returnDF, naList)
            count <- count + 1}}
    rownames(returnDF) <- as.character(seq(as.Date("2015-01-01"), as.Date("2015-12-31"), by="days"))
    return(returnDF[1:nrow(returnDF), 2:ncol(returnDF)])
}

allArrayMaker <- function(ipsos, quinnipiac, gravis, yougov, abc, fox, ppp, bloomberg, nbcsm, morningconsult, pubrel, mcclatchy, usc, zogby, nbcwsj, ibdtipp, monmouth, emerson, fairleigh, suffolk, cnn, lincolnpark, robertmorris, reasonrupe) {
    xipsos <- includeNA(ipsos)
    xquinnipiac <- includeNA(quinnipiac)
    xgravis <- includeNA(gravis)
    xyougov <- includeNA(yougov)
    xabc <- includeNA(abc)
    xfox <- includeNA(fox)
    xppp <- includeNA(ppp)
    xbloomberg <- includeNA(bloomberg)
    xnbcsm <- includeNA(nbcsm)
    xmorningconsult <- includeNA(morningconsult)
    xpubrel <- includeNA(pubrel)
    xmcclatchy <- includeNA(mcclatchy)
    xusc <- includeNA(usc)
    xzogby <- includeNA(zogby)
    xnbcwsj <- includeNA(nbcwsj)
    xibdtipp <- includeNA(ibdtipp)
    xmonmouth <- includeNA(monmouth)
    xemerson <- includeNA(emerson)
    xfairleigh <- includeNA(fairleigh)
    xsuffolk <- includeNA(suffolk)
    xcnn <- includeNA(cnn)
    xlincolnpark <- includeNA(lincolnpark)
    xrobertmorris <- includeNA(robertmorris)
    xreasonrupe <- includeNA(reasonrupe)
    returnArray <- abind(xipsos, xquinnipiac, xgravis, xyougov, xabc, xfox, xppp, xbloomberg, xnbcsm, xmorningconsult, xpubrel, xmcclatchy, xusc, xzogby, xnbcwsj, xibdtipp, xmonmouth, xemerson, xfairleigh, xsuffolk, xcnn, xlincolnpark, xrobertmorris, xreasonrupe, along=3)
    dimnames(returnArray)[[3]] <- c("Ipsos/Reuters", "Quinnipiac", "Gravis Marketing/One America News", "YouGov/Economist", "ABC/Post", "FOX", "PPP (D)", "Bloomberg/Selzer", "NBC/SurveyMonkey", "Morning Consult", "Public Religion Research Institute", "McClatchy/Marist", "USC/LA Times/SurveyMonkey", "Zogby (Internet)", "NBC/WSJ", "IBD/TIPP", "Monmouth University", "Emerson College Polling Society", "Fairleigh Dickinson", "Suffolk/USA Today", "CNN", "Lincoln Park Strategies (D)", "Robert Morris University", "Reason/Rupe")
    return(returnArray)
}

sourcecsv = read.csv("http://elections.huffingtonpost.com/pollster/2016-national-democratic-primary.csv", header=TRUE, stringsAsFactors=FALSE)
sourcecsv[sourcecsv == "NA"] <- NA
argDF <- sourcecsv


ipsos <- fixday(argDF[argDF$Pollster == "Ipsos/Reuters",])
quinnipiac <- fixday(argDF[argDF$Pollster == "Quinnipiac",])
gravis <- fixday(argDF[argDF$Pollster == "Gravis Marketing/One America News",])
yougov <- fixday(argDF[argDF$Pollster == "YouGov/Economist",])
abc <- fixday(argDF[argDF$Pollster == "ABC/Post",])
fox <- fixday(argDF[argDF$Pollster == "FOX",])
ppp <- fixday(argDF[argDF$Pollster == "PPP (D)",])
bloomberg <- fixday(argDF[argDF$Pollster == "Bloomberg/Selzer",])
nbcsm <- fixday(argDF[argDF$Pollster == "NBC/SurveyMonkey",])
morningconsult <- fixday(argDF[argDF$Pollster == "Morning Consult",])
pubrel <- fixday(argDF[argDF$Pollster == "Public Religion Research Institute",])
mcclatchy <- fixday(argDF[argDF$Pollster == "McClatchy/Marist",])
usc <- fixday(argDF[argDF$Pollster == "USC/LA Times/SurveyMonkey",])
zogby <- fixday(argDF[argDF$Pollster == "Zogby (Internet)",])
nbcwsj <- fixday(argDF[argDF$Pollster == "NBC/WSJ",])
ibdtipp <- fixday(argDF[argDF$Pollster == "IBD/TIPP",])
monmouth <- fixday(argDF[argDF$Pollster == "Monmouth University",])
emerson <- fixday(argDF[argDF$Pollster == "Emerson College Polling Society",])
fairleigh <- fixday(argDF[argDF$Pollster == "Fairleigh Dickinson",])
suffolk <- fixday(argDF[argDF$Pollster == "Suffolk/USA Today",])
cnn <- fixday(argDF[argDF$Pollster == "CNN",])
lincolnpark <- fixday(argDF[argDF$Pollster == "Lincoln Park Strategies (D)",])
robertmorris <- fixday(argDF[argDF$Pollster == "Robert Morris University",])
reasonrupe <- fixday(argDF[argDF$Pollster == "Reason/Rupe",])



allDEM <- allArrayMaker(ipsos, quinnipiac, gravis, yougov, abc, fox, ppp, bloomberg, nbcsm, morningconsult, pubrel, mcclatchy, usc, zogby, nbcwsj, ibdtipp, monmouth, emerson, fairleigh, suffolk, cnn, lincolnpark, robertmorris, reasonrupe)


save(allDEM, file="/Users/andrewlee/Documents/School/CS125/Final Project/DEMArray.RData")