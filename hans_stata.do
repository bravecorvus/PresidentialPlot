/* Recreated Hans Rosling bubble plot 1950-2011
   This involves way points with linear interpolation  
   Colours are set for 4 continents 
   and radius of marker is *roughly* set in 6 categories 
   making 24 scatterplots that have to superimposed
   (but you could easily do more categories to make the 
   expanding bubbles smoother, and you could set the radii 
   by including a numeric coefficient in msize() ) */

// ###### PRELIMINARIES #####
clear all
global vidpath "C:\animation\"
global picpath "C:\animation temp\"
cd "${vidpath}"
local iframes=12 // number of interpolated frames 
global w 800
global h 600 // dimensions of graphs (and video, for best quality)
// this will be used in all the graphs for standardising:
local axisopts "xscale(range(200 80000) log) xlabel(400 1000 4000 10000 40000) yscale(range(25 85)) ylabel(25(10)85)"
tempfile animdata

// ####### DATA MANAGEMENT #######
insheet using "${vidpath}gapminder_population.csv", clear comma
drop if pop_1950==.
rename continent co
forvalues i=1950(5)2010 { 
    qui replace pop_`i'=pop_`i'/1000000 // deal with millions of people from now on
}
// linear interpolation for population (only recorded every 5 years)
forvalues i=1950(5)2005 { 
    forvalues j=1/4 { 
        local y=`i'+`j'
        local i5=`i'+5
        qui gen pop_`y'=pop_`i'+((`j'/5)*(pop_`i5'-pop_`i'))
        qui format pop_`y' %9.2f
    }
}
qui gen pop_2011=pop_2010+(0.2*(pop_2010-pop_2005)) // and then for 2011
format pop_2011 %9.2f
/* now we categorise the populations (log-10)
   this is to size the bubbles consistently across the 24 scatterplots
   (can't use [fw=pop] as this is rescaled within each -twoway scatter-) */
forvalues i=1950/2011 {
    egen popcat_`i'=cut(pop_`i'), at(0 0.1 1 10 100 1000 10000)
} 
encode country, gen(c)
save "`animdata'", replace
insheet using "${vidpath}gapminder_life.csv", comma clear
encode country, gen(c)
merge 1:1 c using "`animdata'"
keep if _merge==3
drop _merge
save "`animdata'", replace
insheet using "${vidpath}gapminder_gdp.csv", comma clear
encode country, gen(c)
merge 1:1 c using "`animdata'"
keep if _merge==3
drop _merge
order c
/* there are some unusual countries that make the graph less clear
   so we remove them because we are interested in animation here
   and not imputation techniques for global health!
   (It looks like Hans Rosling's animation removed them too) */
drop if country=="Kuwait" | country=="Russia" | gdp_1951==. 
qui gen lifei=life_1950 // will be used for interpolation later
qui gen gdpi=gdp_1950 // will be used for interpolation later

// ###### PROGRAM FOR MAKING THE GRAPHS #####
capture program drop mygraph
program define mygraph
syntax varlist, frame(integer) axes(string) time(integer)
/* this is to get a colour for each continent, 
   and a size for each population 
but is tedious in Stata (single line of R code) */
twoway (scatter `varlist' if co==1 & popcat_`time'==0, msymbol(Oh) msize(*0.2) mcolor(navy) lcolor(navy*0.2) `axes') ///
       (scatter `varlist' if co==1 & popcat_`time'==0.1, msymbol(Oh) msize(*0.5) mcolor(navy) lcolor(navy*0.2)) ///
       (scatter `varlist' if co==1 & popcat_`time'==1, msymbol(Oh) msize(*1) mcolor(navy) lcolor(navy*0.2)) ///
       (scatter `varlist' if co==1 & popcat_`time'==10, msymbol(Oh) msize(*2) mcolor(navy) lcolor(navy*0.2)) ///
       (scatter `varlist' if co==1 & popcat_`time'==100, msymbol(Oh) msize(*4) mcolor(navy) lcolor(navy*0.2)) ///
       (scatter `varlist' if co==1 & popcat_`time'==1000, msymbol(Oh) msize(*6) mcolor(navy) lcolor(navy*0.2)) ///
       /// if you want msymbol(O) then reverse the order to have the largest of any colour drawn first,
       /// otherwise the smaller countries will be obscured
       (scatter `varlist' if co==2 & popcat_`time'==0, msymbol(Oh) msize(*0.2) mcolor(cranberry) lcolor(cranberry*0.2)) ///
       (scatter `varlist' if co==2 & popcat_`time'==0.1, msymbol(Oh) msize(*0.5) mcolor(cranberry) lcolor(cranberry*0.2)) ///
       (scatter `varlist' if co==2 & popcat_`time'==1, msymbol(Oh) msize(*1) mcolor(cranberry) lcolor(cranberry*0.2)) ///
       (scatter `varlist' if co==2 & popcat_`time'==10, msymbol(Oh) msize(*2) mcolor(cranberry) lcolor(cranberry*0.2)) ///
       (scatter `varlist' if co==2 & popcat_`time'==100, msymbol(Oh) msize(*4) mcolor(cranberry) lcolor(cranberry*0.2)) ///
       (scatter `varlist' if co==2 & popcat_`time'==1000, msymbol(Oh) msize(*6) mcolor(cranberry) lcolor(cranberry*0.2)) ///
       ///
       (scatter `varlist' if co==3 & popcat_`time'==0, msymbol(Oh) msize(*0.2) mcolor(dkorange) lcolor(dkorange*0.2)) ///
       (scatter `varlist' if co==3 & popcat_`time'==0.1, msymbol(Oh) msize(*0.5) mcolor(dkorange) lcolor(dkorange*0.2)) ///
       (scatter `varlist' if co==3 & popcat_`time'==1, msymbol(Oh) msize(*1) mcolor(dkorange) lcolor(dkorange*0.2)) ///
       (scatter `varlist' if co==3 & popcat_`time'==10, msymbol(Oh) msize(*2) mcolor(dkorange) lcolor(dkorange*0.2)) ///
       (scatter `varlist' if co==3 & popcat_`time'==100, msymbol(Oh) msize(*4) mcolor(dkorange) lcolor(dkorange*0.2)) ///
       (scatter `varlist' if co==3 & popcat_`time'==1000, msymbol(Oh) msize(*6) mcolor(dkorange) lcolor(dkorange*0.2)) ///
       ///
       (scatter `varlist' if co==4 & popcat_`time'==0, msymbol(Oh) msize(*0.2) mcolor(forest_green) lcolor(forest_green*0.2)) ///
       (scatter `varlist' if co==4 & popcat_`time'==0.1, msymbol(Oh) msize(*0.5) mcolor(forest_green) lcolor(forest_green*0.2)) ///
       (scatter `varlist' if co==4 & popcat_`time'==1, msymbol(Oh) msize(*1) mcolor(forest_green) lcolor(forest_green*0.2)) ///
       (scatter `varlist' if co==4 & popcat_`time'==10, msymbol(Oh) msize(*2) mcolor(forest_green) lcolor(forest_green*0.2)) ///
       (scatter `varlist' if co==4 & popcat_`time'==100, msymbol(Oh) msize(*4) mcolor(forest_green) lcolor(forest_green*0.2)) ///
       (scatter `varlist' if co==4 & popcat_`time'==1000, msymbol(Oh) msize(*6) mcolor(forest_green) lcolor(forest_green*0.2)) ///
       , graphregion(color(white)) ///
       xtitle(GDP per capita) ytitle(Life expectancy) ///
       legend(order(3 "Africa" 9 "Asia + Oceania" 15 "Europe" 21 "Americas")) ///
       title(`time') name(g`frame', replace)
qui graph export "${picpath}g`frame'.png", replace name(g`frame') width(${w}) height(${h})
end


// ###### INTERPOLATE AND DRAW EACH FRAME #####
// loop over years
forvalues i=1950/2010 {
    local next=`i'+1
    local framenumber=(`i'-1950)*(`iframes'+1)
    mygraph life_`i' gdp_`i', frame(`framenumber') axes("`axisopts'") time(`i') 
    if `i'>1950 { // keep first graph open in the graph window
        graph drop g`framenumber'
    }
// loop between years
    forvalues j=1/`iframes' {
        local framenumber=((`i'-1950)*(`iframes'+1))+`j'
        qui replace lifei=life_`i'+((`j'/(`iframes'+1))*(life_`next'-life_`i'))
        qui replace gdpi=gdp_`i'+((`j'/(`iframes'+1))*(gdp_`next'-gdp_`i'))
        mygraph lifei gdpi, frame(`framenumber') axes("`axisopts'") time(`i')
        graph drop g`framenumber'
    }
}
// ###### END PLOT #####
mygraph life_2011 gdp_2011, frame(`framenumber') axes("`axisopts'") time(2011)

// ###### MAKE THE VIDEO! #####
!del "${vidpath}stata_hans.mpg" // overwrite existing file
sleep 1000 // make sure the file has been deleted before proceeding
winexec "C:/Program Files/ffmpeg/bin/ffmpeg.exe" ///
    -report -i "${picpath}g%d.png" -b:v 1024k ///
    "${vidpath}stata_hans.mpg"