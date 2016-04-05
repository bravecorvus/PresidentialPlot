---
title: "How Useful is Web Searching to Predict Presidential Polling Data"
author: "Andrew Lee"
date: "December 21, 2015"
output: html_document
---




![Masthead](http://andrewshinsuke.me/cs125/masthead.jpg)



#### Introduction

President Obama, first elected in 2008, is said to be the first presidential candidate to have used modern social media tactics to reach out to voters, which contributed a largescale support from the usually inactive younger voter block. As we progress further into the 21st Century, the way social media impacts many facets of our lives only increases. Today, Facebook boasts 1.4 billion people online every month, and is the second largest website on Earth by traffic. Along with Twitter, Facebook has spread social movements far faster and wider than ever possible, and played a large part in movements such as Occupy Wallstreet, the Arab Spring, the LGBT Rights movement, and most recently Black Lives Matter.

With such an evolution in human behavioral patterns, I wanted to see how the availability of mass spread information affected election outcomes. Specifically, I wanted to see if I could correlate spikes in candidate search popularity with direct gains in polls.

For example, if Donald Trump stated his intention of banning all Muslims from entering the United States until immigration could implement better policies to filter out socially beneficial Muslim immigrants from Islamist fundamentalists, I would expect to see a largescale increase in Donald Trump's Poll Ratings correlating to his virility on the internet by his voters. On the same note, if Bernie Sander's voiced his support for the "Black Live Matter" movement by acknowledging the leaders when they interupted him in a Democratic Party Primary event, I would expect a general spike in his poll numbers corresponding to voters sympathetic to his cause over the internet.


Ideally, this would be a longterm study leading up to the 2016 Presidential Election. However, within the timeframe of this project's due date, I was limited to only pre-election polls.



```{r Package Install, include=FALSE}
# Here are the packages I have used for my Project
install.packages("ftp://cran.r-project.org/pub/R/src/contrib/gtrendsR_1.3.1.tar.gz", repos="NULL", type="source")
install.packages("https://cran.r-project.org/src/contrib/tidyr_0.3.1.tar.gz", repos="NULL", type="source")
install.packages("https://cran.r-project.org/src/contrib/plyr_1.8.3.tar.gz", repos="NULL", type="source")
install.packages("https://cran.r-project.org/src/contrib/ggplot2_2.0.0.tar.gz", repos="NULL", type="source")
install.packages("https://cran.r-project.org/src/contrib/data.table_1.9.6.tar.gz", repos="NULL", type="source")
install.packages("https://cran.r-project.org/src/contrib/abind_1.4-3.tar.gz", repos="NULL", type="source")
install.packages("https://cran.r-project.org/src/contrib/scales_0.3.0.tar.gz", repos="NULL", type="source")

library(scales)
library(plyr)
library(gtrendsR)
library(dplyr)
library(ggplot2)
library(abind)
library(data.table)
library(tidyr)
#Bottom two lines are custom RData files I created myself, the souce code which can be found at "http://andrewshinsuke.me/cs125/fixgop.r" and "http://andrewshinsuke.me/cs125/fixdem.r" respectively
load(url("http://andrewshinsuke.me/cs125/GOPArray.RData"))
load(url("http://andrewshinsuke.me/cs125/DEMArray.RData"))
```


#### Google Trends

I would like to start by introducing Google Trends to you
![This is What Google Trends looks like](http://andrewshinsuke.me/cs125/GoogleTrends.png)

With Google Trends, users can search for a term, and Google returns you with a graphical representation of the total search querries over time, regional interest, and related searches pertaining to the original search querries.

Such a tool is highly useful for my project because it is the perfect way to figure out the total internet interest in a specific candidate, and with the related searches, I can use that to correlate specific events to specific spikes in candidate

Now, with just the graphical user interface, Google Trends is not too useful, as it requires manual user input. But I came across a packaged called gtrendsR (https://github.com/PMassicotte/gtrendsR), which is a customized api wrapper that allows users to work within R to search, and returns results as a list with a data.frame of the the graphical data, a data.frame of the regional interests, and a data.frame of the related search terms.

The following is an example of what can be done in gtrendsR

```{r}
usr <- "cs125fp@gmail.com"  # alternatively store as options() or env.var
psw <- "Abcd@1234" 
gconnect(usr, psw) #Stored in R environment
plot(gtrends(c("Donald Trump", "Bernie Sanders", "Hillary Clinton", "Ben Carson"))) #optionally, gtrends can be saved as a list to be operated on later
```

As you can see, the gtrendsR package neatly packages data, and retreives it in a usable form. Now that I have a reliable source for internet search data, I needed to find a good source of polling data.

#### Polling Data
After looking around, I saw that Huffington Post combined the data sources from numerous polling organizations into one location.

Here are the links
(http://elections.huffingtonpost.com/pollster/2016-national-gop-primary)            
(http://elections.huffingtonpost.com/pollster/2016-national-democratic-primary)

#### Importing the Data
Importing the data was relatively easy.

```{r}
sourcecsv = read.csv("http://elections.huffingtonpost.com/pollster/2016-national-gop-primary.csv", header=TRUE, stringsAsFactors=FALSE)
sourcecsv[sourcecsv == "NA"] <- NA
argDF <- sourcecsv
```

Now here is a snapshot of the data provided.
![What the CSV Looks like](http://andrewshinsuke.me/cs125/screenshot.jpg)

You can see a few things that are immediately problematic for comparing the data
First off, all the sources are thrown into one object with no meaningful separation. At the same time, each polling agency used their own unique timeframe. (For example, Ipsos/Reuters uses a 4 day timeframe while Quinnipiac uses a 7 day timeframe) My first step was to extract all these different parts, and save them into separate dataframes with a unified date structure.

In order to unify the date structures, I took the first day and the last day from each entry point, and created a range of dates in between the two dates, and then populating the new days with repeated data. At the same time, I proceeded to create a three dimentional array, which represents data from January 1, 2015 to December 31, 2015 (As Rows), Candidates (as Columns), and different polling sources (as the third dimention)

Visualizing the data structure before programming it in R, I came up with something like this:
 ![Visualizing what I want](http://andrewshinsuke.me/cs125/array.jpg)

So without further ado, here are the respective code for transforming the data for each party (GOP, and Democratic Party)


#### Transforming the GOP data

The following code can be found at http://andrewshinsuke.me/cs125/fixgop.r

```{r}
fixday <- function(argDF) {
    modDF<- data.frame(Start.Date=argDF$Start.Date, End.Date=argDF$End.Date, Trump=argDF$Trump, Carson=argDF$Carson, Rubio=argDF$Rubio, Cruz=argDF$Cruz, Bush=argDF$Bush, Rand.Paul=argDF$Rand.Paul, Christie=argDF$Christie, Fiorina=argDF$Fiorina, Kasich=argDF$Kasich, Huckabee=argDF$Huckabee, Santorum=argDF$Santorum, Graham=argDF$Graham, Pataki=argDF$Pataki, Gilmore=argDF$Gilmore, Jindal=argDF$Jindal, Perry=argDF$Perry, Walker=argDF$Walker, Undecided=argDF$Undecided, stringsAsFactors=FALSE)
    modDF[1:2] <- lapply(modDF[1:2], as.Date)
    returnDF <- setDT(modDF)[, list(dates=seq(Start.Date, End.Date, by = '1 day'),
        Trump=Trump, Carson=Carson, Rubio=Rubio, Cruz=Cruz, Bush=Bush, Rand.Paul=Rand.Paul, Christie=Christie, Fiorina=Fiorina, Kasich=Kasich, Huckabee=Huckabee, Santorum=Santorum, Graham=Graham, Pataki=Pataki, Gilmore=Gilmore, Jindal=Jindal, Perry=Perry, Walker=Walker, Undecided=Undecided),
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
            naList <- data.frame(dateSeq[i], NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, stringsAsFactors=FALSE)
            colnames(naList) <- colnames(argDF)
            returnDF <- rbind(returnDF, naList)
            count <- count + 1}}
    rownames(returnDF) <- as.character(seq(as.Date("2015-01-01"), as.Date("2015-12-31"), by="days"))
    return(returnDF[1:nrow(returnDF), 2:ncol(returnDF)])
}

allArrayMaker <- function(ipsos, quinnipiac, gravis, yougov, abc, fox, ppp, bloomberg, nbcsm, morningconsult, pubrel, mcclatchy, usc, zogby, nbcwsj, ibdtipp, monmouth, emerson, fairleigh, suffolk, cnn, wpaor, lincolnpark, robertmorris, reasonrupe, wilsonpr) {
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
    xwpaor <- includeNA(wpaor)
    xlincolnpark <- includeNA(lincolnpark)
    xrobertmorris <- includeNA(robertmorris)
    xreasonrupe <- includeNA(reasonrupe)
    xwilsonpr <- includeNA(wilsonpr)
    returnArray <- abind(xipsos, xquinnipiac, xgravis, xyougov, xabc, xfox, xppp, xbloomberg, xnbcsm, xmorningconsult, xpubrel, xmcclatchy, xusc, xzogby, xnbcwsj, xibdtipp, xmonmouth, xemerson, xfairleigh, xsuffolk, xcnn, xwpaor, xlincolnpark, xrobertmorris, xreasonrupe, xwilsonpr, along=3)
    dimnames(returnArray)[[3]] <- c("Ipsos/Reuters", "Quinnipiac", "Gravis Marketing/One America News", "YouGov/Economist", "ABC/Post", "FOX", "PPP (D)", "Bloomberg/Selzer", "NBC/SurveyMonkey", "Morning Consult", "Public Religion Research Institute", "McClatchy/Marist", "USC/LA Times/SurveyMonkey", "Zogby (Internet)", "NBC/WSJ", "IBD/TIPP", "Monmouth University", "Emerson College Polling Society", "Fairleigh Dickinson", "Suffolk/USA Today", "CNN", "Wilson Perkins Allen Opinion Research (R-Cruz)", "Lincoln Park Strategies (D)", "Robert Morris University", "Reason/Rupe", "Wilson Perkins Allen Opinion Research (R)")
    return(returnArray)
}

sourcecsv = read.csv("http://elections.huffingtonpost.com/pollster/2016-national-gop-primary.csv", header=TRUE, stringsAsFactors=FALSE)
#As you can see, I am direcly linking back to the huffington post csv link, so whenever this code is run, it will be updated with the most recent information.
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
wpaor <- fixday(argDF[argDF$Pollster == "Wilson Perkins Allen Opinion Research (R-Cruz)",])
lincolnpark <- fixday(argDF[argDF$Pollster == "Lincoln Park Strategies (D)",])
robertmorris <- fixday(argDF[argDF$Pollster == "Robert Morris University",])
reasonrupe <- fixday(argDF[argDF$Pollster == "Reason/Rupe",])
wilsonpr <- fixday(argDF[argDF$Pollster == "Wilson Perkins Allen Opinion Research (R)",])


allGOP <- allArrayMaker(ipsos, quinnipiac, gravis, yougov, abc, fox, ppp, bloomberg, nbcsm, morningconsult, pubrel, mcclatchy, usc, zogby, nbcwsj, ibdtipp, monmouth, emerson, fairleigh, suffolk, cnn, wpaor, lincolnpark, robertmorris, reasonrupe, wilsonpr)


save(allGOP, file="GOPArray.RData")
```



####For the Democratic Party
Here is the code for the Democratic Party's Array
It can be found at http://andrewshinsuke.me/cs125/fixdem.r

```{r}
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


save(allDEM, file="DEMArray.RData")
```

####Thinking about what to do with the data
So now I created 2 Array's with all the data I needed, in a unified form to compare with other forms or sources I might need in the future. With all these sources, I thought of the best way to find the "most accurate" picture of all the polling data, and concluded that creating a single data frame with candidates and dates, and taking the mean all the sources would be the most accurate way I could represent this data.

However, even with this organized form, in order to plot this in ggplot2 (which is designed to work with data that is organized so that each row is a different observation of an occurance, or thing, and different columns represent the differnt categories of data), whereas, my data was organized by different dates for rows, and the candidates for columns, I needed to melt the data to have the data points, a date column as a factor, a candidate column as a factor, so that I could graph it in ggplot2


The following code can be found at: http://andrewshinsuke.me/cs125/source.r

```{r}
# Melting the dataframe using gather from the tidyr package
averagedGOPPoll <- as.data.frame(aaply(allGOP, 1:2, mean, na.rm=TRUE))
averagedGOPPoll$date = as.Date(rownames(averagedGOPPoll))
averagedGOPPoll.melt <- gather(averagedGOPPoll,candidate,percentage,-date)

averagedDEMPoll <- as.data.frame(aaply(allDEM, 1:2, mean, na.rm=TRUE))
averagedDEMPoll$date = as.Date(rownames(averagedDEMPoll))
averagedDEMPoll.melt <- gather(averagedDEMPoll,candidate,percentage,-date)
```

Here is where I graph the melted data frames.

```{r}
plotaverageGOPPoll <- ggplot(averagedGOPPoll.melt,aes(x=date,y=percentage,colour=candidate))+
  geom_line() + ylab("Percentage out of 100") + xlab("Dates: January-December 2015") + scale_x_date(labels = date_format("%m/%d"), breaks = date_breaks("month")) + labs(title = "Plot of Averaged Polling Data for the Republicans")


ggsave(plotaverageGOPPoll, file="plotaverageGOPPoll.png")


plotaverageDEMPoll <- ggplot(averagedDEMPoll.melt,aes(x=date,y=percentage,colour=candidate))+
  geom_line() + ylab("Percentage out of 100") + xlab("Dates: January-December 2015") + scale_x_date(labels = date_format("%m/%d"), breaks = date_breaks("month")) + labs(title = "Plot of Averaged Polling Data for the Democrats")

ggsave(plotaverageGOPPoll, file="plotaverageDEMPoll.png")
```
Visualizing the GOP Averaged Polls looks like this:
![GOP Poll](http://andrewshinsuke.me/cs125/plotaverageGOPPoll.png)

Visualizing the Democratic Polls looks like this:
![DEM Poll](http://andrewshinsuke.me/cs125/plotaverageDEMPoll.png)


####Taking a step back to think about the data
Up to this point, I was able to create two separate data frames with the averaged data from multiple polling sources. Now it was time to use this data to find correlation with the data extracted from the gtrendsR package.

There were a few tricky things about this process. First off, Google Trends only supports querries up to five at a time. Therefore, in order to find all the data I needed, I would need to combine multiple gtrendsr querries into one data frame. Secondly, the data represented is the quantity relative to the total amount of searches for that day, whereas the data represented in the polling data is the percentage of votes each candidate has, (within the party)

This combined with my own lack of formal training in Statistics, led me to conclude that I do not have the resources to undertake a complete analysis project that would lead to any meaningful conclusions about the ability of candidates to tie themselves to a popular sentiment or popular cause.

Instead, I took took it upon myself to find a way to graph the 2 souces of data from Google Trends and the Huffington Post Aggregate data set.

Inspired by Hans Rosling's Bubble Chart Presentation about world development in his presentation from 2007, I though it would be a great project to try to use a similar graph system to represent the internet interest and polling numbers of each candidate.

The first step was to reform my data so that I would have one data frame per party that combined the elements of both the melted pres_trendDF data frame and the averegedPoll.melt, for each party.


####Reformatting the Data Frame in Bubble form for the GOP

I first started by creating a combined data frame called goppolls.

Now one of the problems for trying to create a motion graph is that there cannot be any NaN points in the data because that would make the graph dissapear. Therefore, I had to create an algorithm that replaced NA values of the Poll percentages (the Google Trends data did not come with any non-numeric values). 


I did this by checking each element of the Percentages column of the goppolls to check for NA. If the value was not an NA, the value would not change, if it was an NA, then the algorithm would check if the previous number was an NA. If the previous number was not an NA, the new value would become that value. If the previous value was an NA, then, the algorithm would proceed to go through the Percentages column for the closest numeric value, and fill that in for that element.

Next, I needed to create a new column that recorded the change in percentages from one day to the next. This algorithm just went through the Percentages column and subtracted Percentage[i] from Percentage[i-1].

The following code can be found at: http://andrewshinsuke.me/cs125/makeGOPBubble.r

```{r}
load(url("http://andrewshinsuke.me/cs125/avgGOP.RData"))
load(url("http://andrewshinsuke.me/cs125/pres_trendDF.melt.RData"))



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
```

####Reformatting the Data Frame in Bubble form for the Democratic Party

The process for the democratic party was basically exactly the same
source code is at: http://andrewshinsuke.me/cs125/makeDEMBubble.r

```{r}
load(url("http://andrewshinsuke.me/cs125/avgDEM.RData"))
load(url("http://andrewshinsuke.me/cs125/pres_trendDF.melt.RData"))


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
```

####Creating the Bubble Chart Graph
Now it was time to use the Bubble Data Frames to create the Bubble Charts. I proceeded to look at tutorials that detailed way to achieve similar results with Hans Rosling. One method was to look at the tool he used, which was Gapminder. However, after further research, I found out that Gapminder was bought by Google, which made it into an R packaged called googlevis. However, this used Adobe Flash technology to disply the results on a webpage, and since I wanted to do this project in R (as well as having a programmers distaste for Flash), I decided to go against this.

The second option was to produce the motion picture using the animation package. However, after reading the documentation, I could not really figure this package out. Therefore, what I ended up doing is to create 2 sets of 365 PNG images, and combining them in a non-linear video editor to create a single video for each party.

(as a note, the code can only be run through a special environment I have set up. If you want to recreate this process, there are notes in the code)

####Creating the PNG's for the Democratic Party
source code is at: http://andrewshinsuke.me/cs125/saveDEMVideo.r

```{r}
##CODE WILL NOT WORK AS IS to PRODUCE THE 365 PNG'S ALTHOUGH IT WILL RUN WITHOUT A PROBLEM
##TO RUN THIS AS I RAN IT, YOU WILL NEED A IDE WITH A MACROS RECORDING SYSTEM
##FOR SUBLIME TEXT 3, THIS IS CTRL-Q TO RECORD, CTRL-Q TO STOP RECORDING, CTRL-SHIFT-Q TO ACTIVATE THE KEYSTROKES.

##THEREFORE IT IS A GIVEN THAT YOU WILL NEED SUBLIME TEXT, A PACKAGED CALLED REPL WHICH INSTALLS R AND PYTHON WORKING ENVIRONMENTS WITHIN SUBLIME, CUSTOM KEYBINDINGS FOR REPL, WHICH FOR ME, I HAVE IT SET TO COMMAND-OPT-S TO SELECTIVELY RUN SOMETHING

##STARTING RECORDING AT THE BEGINNING OF day1 <-..., OPT-SHIFT-RIGHT, COMMAND-RIGHT, COMMAND-SHIFT-LEFT, DELETE, COMMAND-UP, OPT-DOWN, DOWN, OPT-RIGHT, COMMAND-V, TYPE 'plot', OPT-RIGHT-RIGHT-RIGHT, OPT-SHIFT-LEFT, COMMAND-V, OPT-DOWN, DOWN, COMMAND-RIGHT, OPT-LEFT-LEFT-LEFT-LEFT-LEFT-LEFT, OPT-SHIFT-RIGHT, COMMANDV, OPT-DOWN, DOWN, COMMAND-SHIFT-UP, OPT-COMMAND-S, DOWN.

load(url("http://andrewshinsuke.me/cs125/dembubbledf.RData"))

#The bottom step of creating individual png's were done manually with Sublime Macro's
#In essence, I repeated replacing the day1:day365 information using an automated process that recorded my key strokes
#After getting 365 PNG Files, I put those files into a video editor and merged them into a single video


day1 <- dembubbleDF[c(1, 366),]
day2 <- dembubbleDF[c(2, 367),]
day3 <- dembubbleDF[c(3, 368),]
day4 <- dembubbleDF[c(4, 369),]
day5 <- dembubbleDF[c(5, 370),]
day6 <- dembubbleDF[c(6, 371),]
day7 <- dembubbleDF[c(7, 372),]
day8 <- dembubbleDF[c(8, 373),]
day9 <- dembubbleDF[c(9, 374),]
day10 <- dembubbleDF[c(10, 375),]
day11 <- dembubbleDF[c(11, 376),]
day12 <- dembubbleDF[c(12, 377),]
day13 <- dembubbleDF[c(13, 378),]
day14 <- dembubbleDF[c(14, 379),]
day15 <- dembubbleDF[c(15, 380),]
day16 <- dembubbleDF[c(16, 381),]
day17 <- dembubbleDF[c(17, 382),]
day18 <- dembubbleDF[c(18, 383),]
day19 <- dembubbleDF[c(19, 384),]
day20 <- dembubbleDF[c(20, 385),]
day21 <- dembubbleDF[c(21, 386),]
day22 <- dembubbleDF[c(22, 387),]
day23 <- dembubbleDF[c(23, 388),]
day24 <- dembubbleDF[c(24, 389),]
day25 <- dembubbleDF[c(25, 390),]
day26 <- dembubbleDF[c(26, 391),]
day27 <- dembubbleDF[c(27, 392),]
day28 <- dembubbleDF[c(28, 393),]
day29 <- dembubbleDF[c(29, 394),]
day30 <- dembubbleDF[c(30, 395),]
day31 <- dembubbleDF[c(31, 396),]
day32 <- dembubbleDF[c(32, 397),]
day33 <- dembubbleDF[c(33, 398),]
day34 <- dembubbleDF[c(34, 399),]
day35 <- dembubbleDF[c(35, 400),]
day36 <- dembubbleDF[c(36, 401),]
day37 <- dembubbleDF[c(37, 402),]
day38 <- dembubbleDF[c(38, 403),]
day39 <- dembubbleDF[c(39, 404),]
day40 <- dembubbleDF[c(40, 405),]
day41 <- dembubbleDF[c(41, 406),]
day42 <- dembubbleDF[c(42, 407),]
day43 <- dembubbleDF[c(43, 408),]
day44 <- dembubbleDF[c(44, 409),]
day45 <- dembubbleDF[c(45, 410),]
day46 <- dembubbleDF[c(46, 411),]
day47 <- dembubbleDF[c(47, 412),]
day48 <- dembubbleDF[c(48, 413),]
day49 <- dembubbleDF[c(49, 414),]
day50 <- dembubbleDF[c(50, 415),]
day51 <- dembubbleDF[c(51, 416),]
day52 <- dembubbleDF[c(52, 417),]
day53 <- dembubbleDF[c(53, 418),]
day54 <- dembubbleDF[c(54, 419),]
day55 <- dembubbleDF[c(55, 420),]
day56 <- dembubbleDF[c(56, 421),]
day57 <- dembubbleDF[c(57, 422),]
day58 <- dembubbleDF[c(58, 423),]
day59 <- dembubbleDF[c(59, 424),]
day60 <- dembubbleDF[c(60, 425),]
day61 <- dembubbleDF[c(61, 426),]
day62 <- dembubbleDF[c(62, 427),]
day63 <- dembubbleDF[c(63, 428),]
day64 <- dembubbleDF[c(64, 429),]
day65 <- dembubbleDF[c(65, 430),]
day66 <- dembubbleDF[c(66, 431),]
day67 <- dembubbleDF[c(67, 432),]
day68 <- dembubbleDF[c(68, 433),]
day69 <- dembubbleDF[c(69, 434),]
day70 <- dembubbleDF[c(70, 435),]
day71 <- dembubbleDF[c(71, 436),]
day72 <- dembubbleDF[c(72, 437),]
day73 <- dembubbleDF[c(73, 438),]
day74 <- dembubbleDF[c(74, 439),]
day75 <- dembubbleDF[c(75, 440),]
day76 <- dembubbleDF[c(76, 441),]
day77 <- dembubbleDF[c(77, 442),]
day78 <- dembubbleDF[c(78, 443),]
day79 <- dembubbleDF[c(79, 444),]
day80 <- dembubbleDF[c(80, 445),]
day81 <- dembubbleDF[c(81, 446),]
day82 <- dembubbleDF[c(82, 447),]
day83 <- dembubbleDF[c(83, 448),]
day84 <- dembubbleDF[c(84, 449),]
day85 <- dembubbleDF[c(85, 450),]
day86 <- dembubbleDF[c(86, 451),]
day87 <- dembubbleDF[c(87, 452),]
day88 <- dembubbleDF[c(88, 453),]
day89 <- dembubbleDF[c(89, 454),]
day90 <- dembubbleDF[c(90, 455),]
day91 <- dembubbleDF[c(91, 456),]
day92 <- dembubbleDF[c(92, 457),]
day93 <- dembubbleDF[c(93, 458),]
day94 <- dembubbleDF[c(94, 459),]
day95 <- dembubbleDF[c(95, 460),]
day96 <- dembubbleDF[c(96, 461),]
day97 <- dembubbleDF[c(97, 462),]
day98 <- dembubbleDF[c(98, 463),]
day99 <- dembubbleDF[c(99, 464),]
day100 <- dembubbleDF[c(100, 465),]
day101 <- dembubbleDF[c(101, 466),]
day102 <- dembubbleDF[c(102, 467),]
day103 <- dembubbleDF[c(103, 468),]
day104 <- dembubbleDF[c(104, 469),]
day105 <- dembubbleDF[c(105, 470),]
day106 <- dembubbleDF[c(106, 471),]
day107 <- dembubbleDF[c(107, 472),]
day108 <- dembubbleDF[c(108, 473),]
day109 <- dembubbleDF[c(109, 474),]
day110 <- dembubbleDF[c(110, 475),]
day111 <- dembubbleDF[c(111, 476),]
day112 <- dembubbleDF[c(112, 477),]
day113 <- dembubbleDF[c(113, 478),]
day114 <- dembubbleDF[c(114, 479),]
day115 <- dembubbleDF[c(115, 480),]
day116 <- dembubbleDF[c(116, 481),]
day117 <- dembubbleDF[c(117, 482),]
day118 <- dembubbleDF[c(118, 483),]
day119 <- dembubbleDF[c(119, 484),]
day120 <- dembubbleDF[c(120, 485),]
day121 <- dembubbleDF[c(121, 486),]
day122 <- dembubbleDF[c(122, 487),]
day123 <- dembubbleDF[c(123, 488),]
day124 <- dembubbleDF[c(124, 489),]
day125 <- dembubbleDF[c(125, 490),]
day126 <- dembubbleDF[c(126, 491),]
day127 <- dembubbleDF[c(127, 492),]
day128 <- dembubbleDF[c(128, 493),]
day129 <- dembubbleDF[c(129, 494),]
day130 <- dembubbleDF[c(130, 495),]
day131 <- dembubbleDF[c(131, 496),]
day132 <- dembubbleDF[c(132, 497),]
day133 <- dembubbleDF[c(133, 498),]
day134 <- dembubbleDF[c(134, 499),]
day135 <- dembubbleDF[c(135, 500),]
day136 <- dembubbleDF[c(136, 501),]
day137 <- dembubbleDF[c(137, 502),]
day138 <- dembubbleDF[c(138, 503),]
day139 <- dembubbleDF[c(139, 504),]
day140 <- dembubbleDF[c(140, 505),]
day141 <- dembubbleDF[c(141, 506),]
day142 <- dembubbleDF[c(142, 507),]
day143 <- dembubbleDF[c(143, 508),]
day144 <- dembubbleDF[c(144, 509),]
day145 <- dembubbleDF[c(145, 510),]
day146 <- dembubbleDF[c(146, 511),]
day147 <- dembubbleDF[c(147, 512),]
day148 <- dembubbleDF[c(148, 513),]
day149 <- dembubbleDF[c(149, 514),]
day150 <- dembubbleDF[c(150, 515),]
day151 <- dembubbleDF[c(151, 516),]
day152 <- dembubbleDF[c(152, 517),]
day153 <- dembubbleDF[c(153, 518),]
day154 <- dembubbleDF[c(154, 519),]
day155 <- dembubbleDF[c(155, 520),]
day156 <- dembubbleDF[c(156, 521),]
day157 <- dembubbleDF[c(157, 522),]
day158 <- dembubbleDF[c(158, 523),]
day159 <- dembubbleDF[c(159, 524),]
day160 <- dembubbleDF[c(160, 525),]
day161 <- dembubbleDF[c(161, 526),]
day162 <- dembubbleDF[c(162, 527),]
day163 <- dembubbleDF[c(163, 528),]
day164 <- dembubbleDF[c(164, 529),]
day165 <- dembubbleDF[c(165, 530),]
day166 <- dembubbleDF[c(166, 531),]
day167 <- dembubbleDF[c(167, 532),]
day168 <- dembubbleDF[c(168, 533),]
day169 <- dembubbleDF[c(169, 534),]
day170 <- dembubbleDF[c(170, 535),]
day171 <- dembubbleDF[c(171, 536),]
day172 <- dembubbleDF[c(172, 537),]
day173 <- dembubbleDF[c(173, 538),]
day174 <- dembubbleDF[c(174, 539),]
day175 <- dembubbleDF[c(175, 540),]
day176 <- dembubbleDF[c(176, 541),]
day177 <- dembubbleDF[c(177, 542),]
day178 <- dembubbleDF[c(178, 543),]
day179 <- dembubbleDF[c(179, 544),]
day180 <- dembubbleDF[c(180, 545),]
day181 <- dembubbleDF[c(181, 546),]
day182 <- dembubbleDF[c(182, 547),]
day183 <- dembubbleDF[c(183, 548),]
day184 <- dembubbleDF[c(184, 549),]
day185 <- dembubbleDF[c(185, 550),]
day186 <- dembubbleDF[c(186, 551),]
day187 <- dembubbleDF[c(187, 552),]
day188 <- dembubbleDF[c(188, 553),]
day189 <- dembubbleDF[c(189, 554),]
day190 <- dembubbleDF[c(190, 555),]
day191 <- dembubbleDF[c(191, 556),]
day192 <- dembubbleDF[c(192, 557),]
day193 <- dembubbleDF[c(193, 558),]
day194 <- dembubbleDF[c(194, 559),]
day195 <- dembubbleDF[c(195, 560),]
day196 <- dembubbleDF[c(196, 561),]
day197 <- dembubbleDF[c(197, 562),]
day198 <- dembubbleDF[c(198, 563),]
day199 <- dembubbleDF[c(199, 564),]
day200 <- dembubbleDF[c(200, 565),]
day201 <- dembubbleDF[c(201, 566),]
day202 <- dembubbleDF[c(202, 567),]
day203 <- dembubbleDF[c(203, 568),]
day204 <- dembubbleDF[c(204, 569),]
day205 <- dembubbleDF[c(205, 570),]
day206 <- dembubbleDF[c(206, 571),]
day207 <- dembubbleDF[c(207, 572),]
day208 <- dembubbleDF[c(208, 573),]
day209 <- dembubbleDF[c(209, 574),]
day210 <- dembubbleDF[c(210, 575),]
day211 <- dembubbleDF[c(211, 576),]
day212 <- dembubbleDF[c(212, 577),]
day213 <- dembubbleDF[c(213, 578),]
day214 <- dembubbleDF[c(214, 579),]
day215 <- dembubbleDF[c(215, 580),]
day216 <- dembubbleDF[c(216, 581),]
day217 <- dembubbleDF[c(217, 582),]
day218 <- dembubbleDF[c(218, 583),]
day219 <- dembubbleDF[c(219, 584),]
day220 <- dembubbleDF[c(220, 585),]
day221 <- dembubbleDF[c(221, 586),]
day222 <- dembubbleDF[c(222, 587),]
day223 <- dembubbleDF[c(223, 588),]
day224 <- dembubbleDF[c(224, 589),]
day225 <- dembubbleDF[c(225, 590),]
day226 <- dembubbleDF[c(226, 591),]
day227 <- dembubbleDF[c(227, 592),]
day228 <- dembubbleDF[c(228, 593),]
day229 <- dembubbleDF[c(229, 594),]
day230 <- dembubbleDF[c(230, 595),]
day231 <- dembubbleDF[c(231, 596),]
day232 <- dembubbleDF[c(232, 597),]
day233 <- dembubbleDF[c(233, 598),]
day234 <- dembubbleDF[c(234, 599),]
day235 <- dembubbleDF[c(235, 600),]
day236 <- dembubbleDF[c(236, 601),]
day237 <- dembubbleDF[c(237, 602),]
day238 <- dembubbleDF[c(238, 603),]
day239 <- dembubbleDF[c(239, 604),]
day240 <- dembubbleDF[c(240, 605),]
day241 <- dembubbleDF[c(241, 606),]
day242 <- dembubbleDF[c(242, 607),]
day243 <- dembubbleDF[c(243, 608),]
day244 <- dembubbleDF[c(244, 609),]
day245 <- dembubbleDF[c(245, 610),]
day246 <- dembubbleDF[c(246, 611),]
day247 <- dembubbleDF[c(247, 612),]
day248 <- dembubbleDF[c(248, 613),]
day249 <- dembubbleDF[c(249, 614),]
day250 <- dembubbleDF[c(250, 615),]
day251 <- dembubbleDF[c(251, 616),]
day252 <- dembubbleDF[c(252, 617),]
day253 <- dembubbleDF[c(253, 618),]
day254 <- dembubbleDF[c(254, 619),]
day255 <- dembubbleDF[c(255, 620),]
day256 <- dembubbleDF[c(256, 621),]
day257 <- dembubbleDF[c(257, 622),]
day258 <- dembubbleDF[c(258, 623),]
day259 <- dembubbleDF[c(259, 624),]
day260 <- dembubbleDF[c(260, 625),]
day261 <- dembubbleDF[c(261, 626),]
day262 <- dembubbleDF[c(262, 627),]
day263 <- dembubbleDF[c(263, 628),]
day264 <- dembubbleDF[c(264, 629),]
day265 <- dembubbleDF[c(265, 630),]
day266 <- dembubbleDF[c(266, 631),]
day267 <- dembubbleDF[c(267, 632),]
day268 <- dembubbleDF[c(268, 633),]
day269 <- dembubbleDF[c(269, 634),]
day270 <- dembubbleDF[c(270, 635),]
day271 <- dembubbleDF[c(271, 636),]
day272 <- dembubbleDF[c(272, 637),]
day273 <- dembubbleDF[c(273, 638),]
day274 <- dembubbleDF[c(274, 639),]
day275 <- dembubbleDF[c(275, 640),]
day276 <- dembubbleDF[c(276, 641),]
day277 <- dembubbleDF[c(277, 642),]
day278 <- dembubbleDF[c(278, 643),]
day279 <- dembubbleDF[c(279, 644),]
day280 <- dembubbleDF[c(280, 645),]
day281 <- dembubbleDF[c(281, 646),]
day282 <- dembubbleDF[c(282, 647),]
day283 <- dembubbleDF[c(283, 648),]
day284 <- dembubbleDF[c(284, 649),]
day285 <- dembubbleDF[c(285, 650),]
day286 <- dembubbleDF[c(286, 651),]
day287 <- dembubbleDF[c(287, 652),]
day288 <- dembubbleDF[c(288, 653),]
day289 <- dembubbleDF[c(289, 654),]
day290 <- dembubbleDF[c(290, 655),]
day291 <- dembubbleDF[c(291, 656),]
day292 <- dembubbleDF[c(292, 657),]
day293 <- dembubbleDF[c(293, 658),]
day294 <- dembubbleDF[c(294, 659),]
day295 <- dembubbleDF[c(295, 660),]
day296 <- dembubbleDF[c(296, 661),]
day297 <- dembubbleDF[c(297, 662),]
day298 <- dembubbleDF[c(298, 663),]
day299 <- dembubbleDF[c(299, 664),]
day300 <- dembubbleDF[c(300, 665),]
day301 <- dembubbleDF[c(301, 666),]
day302 <- dembubbleDF[c(302, 667),]
day303 <- dembubbleDF[c(303, 668),]
day304 <- dembubbleDF[c(304, 669),]
day305 <- dembubbleDF[c(305, 670),]
day306 <- dembubbleDF[c(306, 671),]
day307 <- dembubbleDF[c(307, 672),]
day308 <- dembubbleDF[c(308, 673),]
day309 <- dembubbleDF[c(309, 674),]
day310 <- dembubbleDF[c(310, 675),]
day311 <- dembubbleDF[c(311, 676),]
day312 <- dembubbleDF[c(312, 677),]
day313 <- dembubbleDF[c(313, 678),]
day314 <- dembubbleDF[c(314, 679),]
day315 <- dembubbleDF[c(315, 680),]
day316 <- dembubbleDF[c(316, 681),]
day317 <- dembubbleDF[c(317, 682),]
day318 <- dembubbleDF[c(318, 683),]
day319 <- dembubbleDF[c(319, 684),]
day320 <- dembubbleDF[c(320, 685),]
day321 <- dembubbleDF[c(321, 686),]
day322 <- dembubbleDF[c(322, 687),]
day323 <- dembubbleDF[c(323, 688),]
day324 <- dembubbleDF[c(324, 689),]
day325 <- dembubbleDF[c(325, 690),]
day326 <- dembubbleDF[c(326, 691),]
day327 <- dembubbleDF[c(327, 692),]
day328 <- dembubbleDF[c(328, 693),]
day329 <- dembubbleDF[c(329, 694),]
day330 <- dembubbleDF[c(330, 695),]
day331 <- dembubbleDF[c(331, 696),]
day332 <- dembubbleDF[c(332, 697),]
day333 <- dembubbleDF[c(333, 698),]
day334 <- dembubbleDF[c(334, 699),]
day335 <- dembubbleDF[c(335, 700),]
day336 <- dembubbleDF[c(336, 701),]
day337 <- dembubbleDF[c(337, 702),]
day338 <- dembubbleDF[c(338, 703),]
day339 <- dembubbleDF[c(339, 704),]
day340 <- dembubbleDF[c(340, 705),]
day341 <- dembubbleDF[c(341, 706),]
day342 <- dembubbleDF[c(342, 707),]
day343 <- dembubbleDF[c(343, 708),]
day344 <- dembubbleDF[c(344, 709),]
day345 <- dembubbleDF[c(345, 710),]
day346 <- dembubbleDF[c(346, 711),]
day347 <- dembubbleDF[c(347, 712),]
day348 <- dembubbleDF[c(348, 713),]
day349 <- dembubbleDF[c(349, 714),]
day350 <- dembubbleDF[c(350, 715),]
day351 <- dembubbleDF[c(351, 716),]
day352 <- dembubbleDF[c(352, 717),]
day353 <- dembubbleDF[c(353, 718),]
day354 <- dembubbleDF[c(354, 719),]
day355 <- dembubbleDF[c(355, 720),]
day356 <- dembubbleDF[c(356, 721),]
day357 <- dembubbleDF[c(357, 722),]
day358 <- dembubbleDF[c(358, 723),]
day359 <- dembubbleDF[c(359, 724),]
day360 <- dembubbleDF[c(360, 725),]
day361 <- dembubbleDF[c(361, 726),]
day362 <- dembubbleDF[c(362, 727),]
day363 <- dembubbleDF[c(363, 728),]
day364 <- dembubbleDF[c(364, 729),]
day365 <- dembubbleDF[c(365, 730),]

plotday1 <- ggplot(day1, aes(x = Percentage, y = Change.In.Polling.Percentage, size = Searched, fill=Candidate, label=Candidate)) +
  labs(x="Total Percentage of Democrat Vote", y="Change in Percentage")+
  geom_point(shape = 21, show_guide = FALSE) +
  geom_text(size=4)+
  # map z to area and make larger circles
  scale_size_area(max_size = 70) +
  scale_x_continuous(breaks = c(20, 40, 60, 80), limit = c(0, 100), 
                     expand = c(0, 0)) +
  scale_y_continuous(breaks = c(-40, -20, 0, 20, 40), limit = c(-60, 60), 
                     expand = c(0, 0)) +
  theme_bw() +
  theme(panel.grid.major = element_blank(),
        plot.title = element_text(size = rel(1.5), face = "bold", vjust = 1.5),
        axis.title=element_blank(),
        axis.text.x=element_text(size=10),
        axis.text.y=element_text(size=10))+

ggtitle(paste(as.character(day1$Date[1]), " Democrats"))
ggsave(filename="DEMday1.png")
```


####Creating the PNG's for the GOP
The same applies here.
The source code is at: http://andrewshinsuke.me/cs125/saveGOPVideo.r


```{r}
require(ggplot2)
load(url("http://andrewshinsuke.me/cs125/gopbubbledf.RData"))



day1 <- gopbubbleDF[c(1, 366, 731),]
day2 <- gopbubbleDF[c(2, 367, 732),]
day3 <- gopbubbleDF[c(3, 368, 733),]
day4 <- gopbubbleDF[c(4, 369, 734),]
day5 <- gopbubbleDF[c(5, 370, 735),]
day6 <- gopbubbleDF[c(6, 371, 736),]
day7 <- gopbubbleDF[c(7, 372, 737),]
day8 <- gopbubbleDF[c(8, 373, 738),]
day9 <- gopbubbleDF[c(9, 374, 739),]
day10 <- gopbubbleDF[c(10, 375, 740),]
day11 <-gopbubbleDF[c(11, 376, 741),]
day12 <-gopbubbleDF[c(12, 377, 742),]
day13 <-gopbubbleDF[c(13, 378, 743),]
day14 <-gopbubbleDF[c(14, 379, 744),]
day15 <-gopbubbleDF[c(15, 380, 745),]
day16 <-gopbubbleDF[c(16, 381, 746),]
day17 <-gopbubbleDF[c(17, 382, 747),]
day18 <-gopbubbleDF[c(18, 383, 748),]
day19 <-gopbubbleDF[c(19, 384, 749),]
day20 <-gopbubbleDF[c(20, 385, 750),]
day21 <- gopbubbleDF[c(21, 386, 751),]
day22 <- gopbubbleDF[c(22, 387, 752),]
day23 <- gopbubbleDF[c(23, 388, 753),]
day24 <- gopbubbleDF[c(24, 389, 754),]
day25 <- gopbubbleDF[c(25, 390, 755),]
day26 <- gopbubbleDF[c(26, 391, 756),]
day27 <- gopbubbleDF[c(27, 392, 757),]
day28 <- gopbubbleDF[c(28, 393, 758),]
day29 <- gopbubbleDF[c(29, 394, 759),]
day30 <- gopbubbleDF[c(30, 395, 760),]
day31 <- gopbubbleDF[c(31, 396, 761),]
day32 <- gopbubbleDF[c(32, 397, 762),]
day33 <- gopbubbleDF[c(33, 398, 763),]
day34 <- gopbubbleDF[c(34, 399, 764),]
day35 <- gopbubbleDF[c(35, 400, 765),]
day36 <- gopbubbleDF[c(36, 401, 766),]
day37 <- gopbubbleDF[c(37, 402, 767),]
day38 <- gopbubbleDF[c(38, 403, 768),]
day39 <- gopbubbleDF[c(39, 404, 769),]
day40 <- gopbubbleDF[c(40, 405, 770),]
day41 <- gopbubbleDF[c(41, 406, 771),]
day42 <- gopbubbleDF[c(42, 407, 772),]
day43 <- gopbubbleDF[c(43, 408, 773),]
day44 <- gopbubbleDF[c(44, 409, 774),]
day45 <- gopbubbleDF[c(45, 410, 775),]
day46 <- gopbubbleDF[c(46, 411, 776),]
day47 <- gopbubbleDF[c(47, 412, 777),]
day48 <- gopbubbleDF[c(48, 413, 778),]
day49 <- gopbubbleDF[c(49, 414, 779),]
day50 <- gopbubbleDF[c(50, 415, 780),]
day51 <- gopbubbleDF[c(51, 416, 781),]
day52 <- gopbubbleDF[c(52, 417, 782),]
day53 <- gopbubbleDF[c(53, 418, 783),]
day54 <- gopbubbleDF[c(54, 419, 784),]
day55 <- gopbubbleDF[c(55, 420, 785),]
day56 <- gopbubbleDF[c(56, 421, 786),]
day57 <- gopbubbleDF[c(57, 422, 787),]
day58 <- gopbubbleDF[c(58, 423, 788),]
day59 <- gopbubbleDF[c(59, 424, 789),]
day60 <- gopbubbleDF[c(60, 425, 790),]
day61 <- gopbubbleDF[c(61, 426, 791),]
day62 <- gopbubbleDF[c(62, 427, 792),]
day63 <- gopbubbleDF[c(63, 428, 793),]
day64 <- gopbubbleDF[c(64, 429, 794),]
day65 <- gopbubbleDF[c(65, 430, 795),]
day66 <- gopbubbleDF[c(66, 431, 796),]
day67 <- gopbubbleDF[c(67, 432, 797),]
day68 <- gopbubbleDF[c(68, 433, 798),]
day69 <- gopbubbleDF[c(69, 434, 799),]
day70 <- gopbubbleDF[c(70, 435, 800),]
day71 <- gopbubbleDF[c(71, 436, 801),]
day72 <- gopbubbleDF[c(72, 437, 802),]
day73 <- gopbubbleDF[c(73, 438, 803),]
day74 <- gopbubbleDF[c(74, 439, 804),]
day75 <- gopbubbleDF[c(75, 440, 805),]
day76 <- gopbubbleDF[c(76, 441, 806),]
day77 <- gopbubbleDF[c(77, 442, 807),]
day78 <- gopbubbleDF[c(78, 443, 808),]
day79 <- gopbubbleDF[c(79, 444, 809),]
day80 <- gopbubbleDF[c(80, 445, 810),]
day81 <- gopbubbleDF[c(81, 446, 811),]
day82 <- gopbubbleDF[c(82, 447, 812),]
day83 <- gopbubbleDF[c(83, 448, 813),]
day84 <- gopbubbleDF[c(84, 449, 814),]
day85 <- gopbubbleDF[c(85, 450, 815),]
day86 <- gopbubbleDF[c(86, 451, 816),]
day87 <- gopbubbleDF[c(87, 452, 817),]
day88 <- gopbubbleDF[c(88, 453, 818),]
day89 <- gopbubbleDF[c(89, 454, 819),]
day90 <- gopbubbleDF[c(90, 455, 820),]
day91 <- gopbubbleDF[c(91, 456, 821),]
day92 <- gopbubbleDF[c(92, 457, 822),]
day93 <- gopbubbleDF[c(93, 458, 823),]
day94 <- gopbubbleDF[c(94, 459, 824),]
day95 <- gopbubbleDF[c(95, 460, 825),]
day96 <- gopbubbleDF[c(96, 461, 826),]
day97 <- gopbubbleDF[c(97, 462, 827),]
day98 <- gopbubbleDF[c(98, 463, 828),]
day99 <- gopbubbleDF[c(99, 464, 829),]
day100 <- gopbubbleDF[c(100, 465, 830),]
day101 <- gopbubbleDF[c(101, 466, 831),]
day102 <- gopbubbleDF[c(102, 467, 832),]
day103 <- gopbubbleDF[c(103, 468, 833),]
day104 <- gopbubbleDF[c(104, 469, 834),]
day105 <- gopbubbleDF[c(105, 470, 835),]
day106 <- gopbubbleDF[c(106, 471, 836),]
day107 <- gopbubbleDF[c(107, 472, 837),]
day108 <- gopbubbleDF[c(108, 473, 838),]
day109 <- gopbubbleDF[c(109, 474, 839),]
day110 <- gopbubbleDF[c(110, 475, 840),]
day111 <- gopbubbleDF[c(111, 476, 841),]
day112 <- gopbubbleDF[c(112, 477, 842),]
day113 <- gopbubbleDF[c(113, 478, 843),]
day114 <- gopbubbleDF[c(114, 479, 844),]
day115 <- gopbubbleDF[c(115, 480, 845),]
day116 <- gopbubbleDF[c(116, 481, 846),]
day117 <- gopbubbleDF[c(117, 482, 847),]
day118 <- gopbubbleDF[c(118, 483, 848),]
day119 <- gopbubbleDF[c(119, 484, 849),]
day120 <- gopbubbleDF[c(120, 485, 850),]
day121 <- gopbubbleDF[c(121, 486, 851),]
day122 <- gopbubbleDF[c(122, 487, 852),]
day123 <- gopbubbleDF[c(123, 488, 853),]
day124 <- gopbubbleDF[c(124, 489, 854),]
day125 <- gopbubbleDF[c(125, 490, 855),]
day126 <- gopbubbleDF[c(126, 491, 856),]
day127 <- gopbubbleDF[c(127, 492, 857),]
day128 <- gopbubbleDF[c(128, 493, 858),]
day129 <- gopbubbleDF[c(129, 494, 859),]
day130 <- gopbubbleDF[c(130, 495, 860),]
day131 <- gopbubbleDF[c(131, 496, 861),]
day132 <- gopbubbleDF[c(132, 497, 862),]
day133 <- gopbubbleDF[c(133, 498, 863),]
day134 <- gopbubbleDF[c(134, 499, 864),]
day135 <- gopbubbleDF[c(135, 500, 865),]
day136 <- gopbubbleDF[c(136, 501, 866),]
day137 <- gopbubbleDF[c(137, 502, 867),]
day138 <- gopbubbleDF[c(138, 503, 868),]
day139 <- gopbubbleDF[c(139, 504, 869),]
day140 <- gopbubbleDF[c(140, 505, 870),]
day141 <- gopbubbleDF[c(141, 506, 871),]
day142 <- gopbubbleDF[c(142, 507, 872),]
day143 <- gopbubbleDF[c(143, 508, 873),]
day144 <- gopbubbleDF[c(144, 509, 874),]
day145 <- gopbubbleDF[c(145, 510, 875),]
day146 <- gopbubbleDF[c(146, 511, 876),]
day147 <- gopbubbleDF[c(147, 512, 877),]
day148 <- gopbubbleDF[c(148, 513, 878),]
day149 <- gopbubbleDF[c(149, 514, 879),]
day150 <- gopbubbleDF[c(150, 515, 880),]
day151 <- gopbubbleDF[c(151, 516, 881),]
day152 <- gopbubbleDF[c(152, 517, 882),]
day153 <- gopbubbleDF[c(153, 518, 883),]
day154 <- gopbubbleDF[c(154, 519, 884),]
day155 <- gopbubbleDF[c(155, 520, 885),]
day156 <- gopbubbleDF[c(156, 521, 886),]
day157 <- gopbubbleDF[c(157, 522, 887),]
day158 <- gopbubbleDF[c(158, 523, 888),]
day159 <- gopbubbleDF[c(159, 524, 889),]
day160 <- gopbubbleDF[c(160, 525, 890),]
day161 <- gopbubbleDF[c(161, 526, 891),]
day162 <- gopbubbleDF[c(162, 527, 892),]
day163 <- gopbubbleDF[c(163, 528, 893),]
day164 <- gopbubbleDF[c(164, 529, 894),]
day165 <- gopbubbleDF[c(165, 530, 895),]
day166 <- gopbubbleDF[c(166, 531, 896),]
day167 <- gopbubbleDF[c(167, 532, 897),]
day168 <- gopbubbleDF[c(168, 533, 898),]
day169 <- gopbubbleDF[c(169, 534, 899),]
day170 <- gopbubbleDF[c(170, 535, 900),]
day171 <- gopbubbleDF[c(171, 536, 901),]
day172 <- gopbubbleDF[c(172, 537, 902),]
day173 <- gopbubbleDF[c(173, 538, 903),]
day174 <- gopbubbleDF[c(174, 539, 904),]
day175 <- gopbubbleDF[c(175, 540, 905),]
day176 <- gopbubbleDF[c(176, 541, 906),]
day177 <- gopbubbleDF[c(177, 542, 907),]
day178 <- gopbubbleDF[c(178, 543, 908),]
day179 <- gopbubbleDF[c(179, 544, 909),]
day180 <- gopbubbleDF[c(180, 545, 910),]
day181 <- gopbubbleDF[c(181, 546, 911),]
day182 <- gopbubbleDF[c(182, 547, 912),]
day183 <- gopbubbleDF[c(183, 548, 913),]
day184 <- gopbubbleDF[c(184, 549, 914),]
day185 <- gopbubbleDF[c(185, 550, 915),]
day186 <- gopbubbleDF[c(186, 551, 916),]
day187 <- gopbubbleDF[c(187, 552, 917),]
day188 <- gopbubbleDF[c(188, 553, 918),]
day189 <- gopbubbleDF[c(189, 554, 919),]
day190 <- gopbubbleDF[c(190, 555, 920),]
day191 <- gopbubbleDF[c(191, 556, 921),]
day192 <- gopbubbleDF[c(192, 557, 922),]
day193 <- gopbubbleDF[c(193, 558, 923),]
day194 <- gopbubbleDF[c(194, 559, 924),]
day195 <- gopbubbleDF[c(195, 560, 925),]
day196 <- gopbubbleDF[c(196, 561, 926),]
day197 <- gopbubbleDF[c(197, 562, 927),]
day198 <- gopbubbleDF[c(198, 563, 928),]
day199 <- gopbubbleDF[c(199, 564, 929),]
day200 <- gopbubbleDF[c(200, 565, 930),]
day201 <- gopbubbleDF[c(201, 566, 931),]
day202 <- gopbubbleDF[c(202, 567, 932),]
day203 <- gopbubbleDF[c(203, 568, 933),]
day204 <- gopbubbleDF[c(204, 569, 934),]
day205 <- gopbubbleDF[c(205, 570, 935),]
day206 <- gopbubbleDF[c(206, 571, 936),]
day207 <- gopbubbleDF[c(207, 572, 937),]
day208 <- gopbubbleDF[c(208, 573, 938),]
day209 <- gopbubbleDF[c(209, 574, 939),]
day210 <- gopbubbleDF[c(210, 575, 940),]
day211 <- gopbubbleDF[c(211, 576, 941),]
day212 <- gopbubbleDF[c(212, 577, 942),]
day213 <- gopbubbleDF[c(213, 578, 943),]
day214 <- gopbubbleDF[c(214, 579, 944),]
day215 <- gopbubbleDF[c(215, 580, 945),]
day216 <- gopbubbleDF[c(216, 581, 946),]
day217 <- gopbubbleDF[c(217, 582, 947),]
day218 <- gopbubbleDF[c(218, 583, 948),]
day219 <- gopbubbleDF[c(219, 584, 949),]
day220 <- gopbubbleDF[c(220, 585, 950),]
day221 <- gopbubbleDF[c(221, 586, 951),]
day222 <- gopbubbleDF[c(222, 587, 952),]
day223 <- gopbubbleDF[c(223, 588, 953),]
day224 <- gopbubbleDF[c(224, 589, 954),]
day225 <- gopbubbleDF[c(225, 590, 955),]
day226 <- gopbubbleDF[c(226, 591, 956),]
day227 <- gopbubbleDF[c(227, 592, 957),]
day228 <- gopbubbleDF[c(228, 593, 958),]
day229 <- gopbubbleDF[c(229, 594, 959),]
day230 <- gopbubbleDF[c(230, 595, 960),]
day231 <- gopbubbleDF[c(231, 596, 961),]
day232 <- gopbubbleDF[c(232, 597, 962),]
day233 <- gopbubbleDF[c(233, 598, 963),]
day234 <- gopbubbleDF[c(234, 599, 964),]
day235 <- gopbubbleDF[c(235, 600, 965),]
day236 <- gopbubbleDF[c(236, 601, 966),]
day237 <- gopbubbleDF[c(237, 602, 967),]
day238 <- gopbubbleDF[c(238, 603, 968),]
day239 <- gopbubbleDF[c(239, 604, 969),]
day240 <- gopbubbleDF[c(240, 605, 970),]
day241 <- gopbubbleDF[c(241, 606, 971),]
day242 <- gopbubbleDF[c(242, 607, 972),]
day243 <- gopbubbleDF[c(243, 608, 973),]
day244 <- gopbubbleDF[c(244, 609, 974),]
day245 <- gopbubbleDF[c(245, 610, 975),]
day246 <- gopbubbleDF[c(246, 611, 976),]
day247 <- gopbubbleDF[c(247, 612, 977),]
day248 <- gopbubbleDF[c(248, 613, 978),]
day249 <- gopbubbleDF[c(249, 614, 979),]
day250 <- gopbubbleDF[c(250, 615, 980),]
day251 <- gopbubbleDF[c(251, 616, 981),]
day252 <- gopbubbleDF[c(252, 617, 982),]
day253 <- gopbubbleDF[c(253, 618, 983),]
day254 <- gopbubbleDF[c(254, 619, 984),]
day255 <- gopbubbleDF[c(255, 620, 985),]
day256 <- gopbubbleDF[c(256, 621, 986),]
day257 <- gopbubbleDF[c(257, 622, 987),]
day258 <- gopbubbleDF[c(258, 623, 988),]
day259 <- gopbubbleDF[c(259, 624, 989),]
day260 <- gopbubbleDF[c(260, 625, 990),]
day261 <- gopbubbleDF[c(261, 626, 991),]
day262 <- gopbubbleDF[c(262, 627, 992),]
day263 <- gopbubbleDF[c(263, 628, 993),]
day264 <- gopbubbleDF[c(264, 629, 994),]
day265 <- gopbubbleDF[c(265, 630, 995),]
day266 <- gopbubbleDF[c(266, 631, 996),]
day267 <- gopbubbleDF[c(267, 632, 997),]
day268 <- gopbubbleDF[c(268, 633, 998),]
day269 <- gopbubbleDF[c(269, 634, 999),]
day270 <- gopbubbleDF[c(270, 635, 1000),]
day271 <- gopbubbleDF[c(271, 636, 1001),]
day272 <- gopbubbleDF[c(272, 637, 1002),]
day273 <- gopbubbleDF[c(273, 638, 1003),]
day274 <- gopbubbleDF[c(274, 639, 1004),]
day275 <- gopbubbleDF[c(275, 640, 1005),]
day276 <- gopbubbleDF[c(276, 641, 1006),]
day277 <- gopbubbleDF[c(277, 642, 1007),]
day278 <- gopbubbleDF[c(278, 643, 1008),]
day279 <- gopbubbleDF[c(279, 644, 1009),]
day280 <- gopbubbleDF[c(280, 645, 1010),]
day281 <- gopbubbleDF[c(281, 646, 1011),]
day282 <- gopbubbleDF[c(282, 647, 1012),]
day283 <- gopbubbleDF[c(283, 648, 1013),]
day284 <- gopbubbleDF[c(284, 649, 1014),]
day285 <- gopbubbleDF[c(285, 650, 1015),]
day286 <- gopbubbleDF[c(286, 651, 1016),]
day287 <- gopbubbleDF[c(287, 652, 1017),]
day288 <- gopbubbleDF[c(288, 653, 1018),]
day289 <- gopbubbleDF[c(289, 654, 1019),]
day290 <- gopbubbleDF[c(290, 655, 1020),]
day291 <- gopbubbleDF[c(291, 656, 1021),]
day292 <- gopbubbleDF[c(292, 657, 1022),]
day293 <- gopbubbleDF[c(293, 658, 1023),]
day294 <- gopbubbleDF[c(294, 659, 1024),]
day295 <- gopbubbleDF[c(295, 660, 1025),]
day296 <- gopbubbleDF[c(296, 661, 1026),]
day297 <- gopbubbleDF[c(297, 662, 1027),]
day298 <- gopbubbleDF[c(298, 663, 1028),]
day299 <- gopbubbleDF[c(299, 664, 1029),]
day300 <- gopbubbleDF[c(300, 665, 1030),]
day301 <- gopbubbleDF[c(301, 666, 1031),]
day302 <- gopbubbleDF[c(302, 667, 1032),]
day303 <- gopbubbleDF[c(303, 668, 1033),]
day304 <- gopbubbleDF[c(304, 669, 1034),]
day305 <- gopbubbleDF[c(305, 670, 1035),]
day306 <- gopbubbleDF[c(306, 671, 1036),]
day307 <- gopbubbleDF[c(307, 672, 1037),]
day308 <- gopbubbleDF[c(308, 673, 1038),]
day309 <- gopbubbleDF[c(309, 674, 1039),]
day310 <- gopbubbleDF[c(310, 675, 1040),]
day311 <- gopbubbleDF[c(311, 676, 1041),]
day312 <- gopbubbleDF[c(312, 677, 1042),]
day313 <- gopbubbleDF[c(313, 678, 1043),]
day314 <- gopbubbleDF[c(314, 679, 1044),]
day315 <- gopbubbleDF[c(315, 680, 1045),]
day316 <- gopbubbleDF[c(316, 681, 1046),]
day317 <- gopbubbleDF[c(317, 682, 1047),]
day318 <- gopbubbleDF[c(318, 683, 1048),]
day319 <- gopbubbleDF[c(319, 684, 1049),]
day320 <- gopbubbleDF[c(320, 685, 1050),]
day321 <- gopbubbleDF[c(321, 686, 1051),]
day322 <- gopbubbleDF[c(322, 687, 1052),]
day323 <- gopbubbleDF[c(323, 688, 1053),]
day324 <- gopbubbleDF[c(324, 689, 1054),]
day325 <- gopbubbleDF[c(325, 690, 1055),]
day326 <- gopbubbleDF[c(326, 691, 1056),]
day327 <- gopbubbleDF[c(327, 692, 1057),]
day328 <- gopbubbleDF[c(328, 693, 1058),]
day329 <- gopbubbleDF[c(329, 694, 1059),]
day330 <- gopbubbleDF[c(330, 695, 1060),]
day331 <- gopbubbleDF[c(331, 696, 1061),]
day332 <- gopbubbleDF[c(332, 697, 1062),]
day333 <- gopbubbleDF[c(333, 698, 1063),]
day334 <- gopbubbleDF[c(334, 699, 1064),]
day335 <- gopbubbleDF[c(335, 700, 1065),]
day336 <- gopbubbleDF[c(336, 701, 1066),]
day337 <- gopbubbleDF[c(337, 702, 1067),]
day338 <- gopbubbleDF[c(338, 703, 1068),]
day339 <- gopbubbleDF[c(339, 704, 1069),]
day340 <- gopbubbleDF[c(340, 705, 1070),]
day341 <- gopbubbleDF[c(341, 706, 1071),]
day342 <- gopbubbleDF[c(342, 707, 1072),]
day343 <- gopbubbleDF[c(343, 708, 1073),]
day344 <- gopbubbleDF[c(344, 709, 1074),]
day345 <- gopbubbleDF[c(345, 710, 1075),]
day346 <- gopbubbleDF[c(346, 711, 1076),]
day347 <- gopbubbleDF[c(347, 712, 1077),]
day348 <- gopbubbleDF[c(348, 713, 1078),]
day349 <- gopbubbleDF[c(349, 714, 1079),]
day350 <- gopbubbleDF[c(350, 715, 1080),]
day351 <- gopbubbleDF[c(351, 716, 1081),]
day352 <- gopbubbleDF[c(352, 717, 1082),]
day353 <- gopbubbleDF[c(353, 718, 1083),]
day354 <- gopbubbleDF[c(354, 719, 1084),]
day355 <- gopbubbleDF[c(355, 720, 1085),]
day356 <- gopbubbleDF[c(356, 721, 1086),]
day357 <- gopbubbleDF[c(357, 722, 1087),]
day358 <- gopbubbleDF[c(358, 723, 1088),]
day359 <- gopbubbleDF[c(359, 724, 1089),]
day360 <- gopbubbleDF[c(360, 725, 1090),]
day361 <- gopbubbleDF[c(361, 726, 1091),]
day362 <- gopbubbleDF[c(362, 727, 1092),]
day363 <- gopbubbleDF[c(363, 728, 1093),]
day364 <- gopbubbleDF[c(364, 729, 1094),]
day365 <- gopbubbleDF[c(365, 730, 1095),]


day1plot <- ggplot(day1, aes(x = Percentage, y = Change.In.Polling.Percentage, size = Searched, fill=Candidate, label=Candidate)) +
  labs(x="Total Percentage of GOP Vote", y="Change in Percentage")+
  geom_point(shape = 21, show_guide = FALSE) +
  geom_text(size=4)+
  # map z to area and make larger circles
  scale_size_area(max_size = 70) +
  scale_x_continuous(breaks = c(20, 40, 60, 80), limit = c(0, 100), 
                     expand = c(0, 0)) +
  scale_y_continuous(breaks = c(-40, -20, 0, 20, 40), limit = c(-60, 60), 
                     expand = c(0, 0)) +
  theme_bw() +
  theme(panel.grid.major = element_blank(),
        plot.title = element_text(size = rel(1.5), face = "bold", vjust = 1.5),
        axis.title=element_blank(),
        axis.text.x=element_text(size=10),
        axis.text.y=element_text(size=10))+

ggtitle(paste(as.character(day1$Date[1]), " GOP"))
ggsave(filename="GOPday1.png")
```

####Creating the Videos
Now that I have two sets of 365 individual PNG image files representing each day of 2015, I needed a way to combine this. I imported the videos into my video editor, Final Cut, and set each image to show for 5 frames, then exported the video as an M4V video.

![Using Final Cut](http://andrewshinsuke.me/cs125/finalcut1.png)
![Using Final Cut](http://andrewshinsuke.me/cs125/finalcut2.png)


If you want to recreate the process yourself, I have the zip files of all the PNG's for each party saved as ZIP files, which can be downloaded here:

for the GOP: http://andrewshinsuke.me/cs125/GOP.zip
for the Democrats: http://andrewshinsuke.me/cs125/Democrat.zip

Here are the videos
Republican Party                                     
<iframe width="854" height="480" src="https://www.youtube.com/embed/CHQPOvssHuk" frameborder="0" allowfullscreen></iframe>

Democratic Party                                            
<iframe width="854" height="480" src="https://www.youtube.com/embed/6KmAKMdoo1U" frameborder="0" allowfullscreen></iframe>


####Conclusion
Although I could not make any definative judgments about how politicians can tie themselves to popular (or unpopular) causes, through these motion graphs, we can make some inferences.

First, we can observe Bernie Sanders rise to fame over Hillary Clinton. As he tied himself with issues popular with the younger generation such as free college tuition, Black Lives Matter, and his stance against the War on Drugs, you can see him becoming more and more popular in Google search indexes.

Contrasting that with Donald Trump, his often controversial comments have given him large notoriety on the internet, and can be attributed to his dominance in the GOP polls.

Although I have stopped here, I believe much more can be done with the data I have formed. For example, using the "related searches" data frame that gets returned in the gtrends function, someone could potentially create an algorithm that filters out the irrelevant searches, and searches for specific contexts the candidate was involved in within a given timespan. With that data, we would really be able to see if successful positioning as pro or con for a viral social media movement can affeect a politicians success.

At the same time, the three dimentional array I created from the Polling data from Huffington Post can be used in a study that compares different media outlets, and how their own perceived political leanings can have (or not have) an affect on their given poll ratings.