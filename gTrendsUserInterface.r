searchterms <- c()
count = 0
while(TRUE){
    count = count + 1
    userinput <- readline('Enter a querry to look up... up to five..., None to stop adding:')
    if (userinput=='None' | count > 5){
        break
    }else if (length(searchterms)==0){
        next
    }else{
        searchterms <- append(searchterms, userinput)
    }
}

print(searchterms)

#Google Trends Package Set Up
usr <- "cs125fp@gmail.com"  
psw <- "Abcd@1234"      
gconnect(usr, psw)       
pres_trend <- gtrends(c("Trump", "Bernie", "Hillary", "Carson", "Rand"))


pres_trendDF <- pres_trend[[3]][574:nrow(pres_trend[[3]]),]
pres_trendDF <- fixday(pres_trendDF)
pres_trendDF <- includeNA(pres_trendDF)
save(pres_trendDF, file="/Users/andrewlee/Documents/School/CS125/Final Project/pres_trendDF.RData")