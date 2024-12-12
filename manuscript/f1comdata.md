
# Data Scraped from the Formula One Website (Pre-2015)

*UPDATE March 2015 - a redesign of the formulaone.com ebsite has removed all but the individual session results standings from the formulaone.com website. The Formulua One Administration do appear to be making more "data driven" products available through paid for applications, but access to the data itself is locked down.*

Using the recipe described in *Appendix One - Scraping formula1.com Timing Data*, I originally scraped the data from the Formula One website into a simple SQLite database (accessible from the [*wranglingf1datawithr* repository](https://github.com/psychemedia/wranglingf1datawithr) as *scraperwiki.sqlite*. A second scrape into a newly formatted database - f1com_results_archive.sqlite -  was completed at the end of 2014.

*The original version of this book utilised the original database format. As the book is (continually) revised, all code and database queries will be updated to use the new, archival database.*

## Format of the Original scraperwiki.sqlite Database

The original database contains the following tables:


```r
library(DBI)
f1 =dbConnect(RSQLite::SQLite(), './scraperwiki.sqlite')

dbListTables(f1)
```

```
##  [1] "p1Results"    "p1Sectors"    "p1Speeds"     "p2Results"   
##  [5] "p2Sectors"    "p2Speeds"     "p3Results"    "p3Sectors"   
##  [9] "p3Speeds"     "qualiResults" "qualiSectors" "qualiSpeeds" 
## [13] "raceFastlaps" "racePits"     "raceResults"
```

The `pNResults` tables record the classification for each of the three practice sessions (N=1,2,3) run over each race weekend:


```r
dbGetQuery(f1, ("SELECT * FROM p1Results LIMIT 5"))
```

```
##   driverNum   time laps year natGap   gap      race pos         driverName
## 1         3 87.560   11 2012  0.000 0.000 AUSTRALIA   1      Jenson Button
## 2         4 87.805   14 2012  0.245 0.245 AUSTRALIA   2     Lewis Hamilton
## 3         7 88.235   17 2012  0.675 0.675 AUSTRALIA   3 Michael Schumacher
## 4         5 88.360   21 2012  0.800 0.800 AUSTRALIA   4    Fernando Alonso
## 5         2 88.467   21 2012  0.907 0.907 AUSTRALIA   5        Mark Webber
##                      team  natTime
## 1        McLaren-Mercedes 1:27.560
## 2        McLaren-Mercedes 1:27.805
## 3                Mercedes 1:28.235
## 4                 Ferrari 1:28.360
## 5 Red Bull Racing-Renault 1:28.467
```

The practice session results include the name of each driver, their classification within that session, their team, the number of laps they completed, their best laptime as a natural time (using the format *minutes:seconds.milliseconds*) and as a time in seconds and milliseconds, and the natural gap (*natgap*)/*gap* (the *natgap* as seconds/milliseconds) to the best time in the session.

The `pNSectors` tables contain the best sector times recorded by each driver in each practice session (N=1,2,3), and the 'qualiSectors` table the best sector times from qualifying:


```r
dbGetQuery(f1, ("SELECT * FROM p1Sectors LIMIT 5"))
```

```
##   sector      race         driverName year sectortime driverNum pos
## 1      1 AUSTRALIA      Jenson Button 2012     29.184         3   1
## 2      1 AUSTRALIA     Lewis Hamilton 2012     29.190         4   2
## 3      1 AUSTRALIA       Nico Rosberg 2012     29.514         8   3
## 4      1 AUSTRALIA Michael Schumacher 2012     29.583         7   4
## 5      1 AUSTRALIA        Mark Webber 2012     29.645         2   5
```


The `pNSpeeds` table records the fastest speed recorded by each driver in a given practice session (N=1,2,3), with the `qualiSpeeds` table given the best speeds achieved during qualifying:


```r
dbGetQuery(f1, ("SELECT * FROM p1Speeds LIMIT 5"))
```

```
##   timeOfDay      race         driverName year driverNum qspeed pos
## 1  13:58:43 AUSTRALIA     Kimi Räikkönen 2012         9  313.9   1
## 2  13:32:04 AUSTRALIA Michael Schumacher 2012         7  312.8   2
## 3  13:59:30 AUSTRALIA    Romain Grosjean 2012        10  312.8   3
## 4  13:52:10 AUSTRALIA   Daniel Ricciardo 2012        16  312.5   4
## 5  13:34:45 AUSTRALIA       Nico Rosberg 2012         8  312.0   5
```

We can combine the sector times from each sector by binding the rows from queries onto separate session tables together, as well as creating appropriately named dataframes in the global scope. To distinguish which session the sector times were set in, we add a new column that specifies the session; to generalise the underlying function, we pass in the partial name of the data table according to the session data we want to return (*Sectors* or *Speeds*):


```r
sessionData=function(race,year,sessionType='Sectors',sessions=c('p1','p2','p3','quali')){
  df=data.frame()
  if (length(sessions)>=1)
    for (session in sessions) {
      sessionName=paste(session,sessionType,sep='')
      q=paste("SELECT * FROM ", sessionName, " WHERE race=UPPER('",race,"') AND year='",year,"'", sep="")
      #print(q)
      #The following line creates appropriately named dataframes in the global scope
      #containing the results of each seprate query
      assign(sessionName,dbGetQuery(conn=f1, statement=q), envir = .GlobalEnv)
      df.tmp=get(sessionName)
      df.tmp['session']=session
      df=rbind(df,df.tmp)
    }
  df
}

sectorTimes=function(race,year,sessions=c('p1','p2','p3','quali')){
  sessionData(race,year,'Sectors',sessions)
}

sessionSpeeds=function(race,year,sessions=c('p1','p2','p3','quali')){
  sessionData(race,year,'Speeds',sessions)
}

#Usage:
#Get all the practice and qualifying session sector times for a specific race
#df=sectorTimes('AUSTRALIA','2012')

#Get P3 and Quali sector times
#df=sectorTimes('AUSTRALIA','2012',c('p3','quali'))

#Get the speeds from the quali session.
#df=sessionSpeeds('Australia','2012','quali')

#This function can be found in the file f1comdataR-core.R from ?????
```


```r
head(sessionSpeeds('Australia','2012','quali'),n=5)
```

```
##   timeOfDay      race       driverName year driverNum qspeed pos session
## 1  17:16:37 AUSTRALIA Sebastian Vettel 2012         1  303.7  19   quali
## 2  17:16:17 AUSTRALIA  Romain Grosjean 2012        10  310.2   7   quali
## 3  17:16:08 AUSTRALIA    Paul di Resta 2012        11  308.1  12   quali
## 4  17:04:53 AUSTRALIA  Nico Hulkenberg 2012        12  308.0  14   quali
## 5  17:06:58 AUSTRALIA  Kamui Kobayashi 2012        14  312.5   5   quali
```

The `qualiResults` table is more elaborate than the results tables for the practice sessions, becuase it includes the best lap time recorded in each qualifying session as well as the number of laps completed across qualifying.



```r
dbGetQuery(f1, ("SELECT * FROM qualiResults LIMIT 5"))
```

```
##   q1time driverNum pos q1natTime q2time      race q3time year q2natTime
## 1 86.800         4   1  1:26.800 85.626 AUSTRALIA 84.922 2012  1:25.626
## 2 86.832         3   2  1:26.832 85.663 AUSTRALIA 85.074 2012  1:25.663
## 3 86.498        10   3  1:26.498 85.845 AUSTRALIA 85.302 2012  1:25.845
## 4 86.586         7   4  1:26.586 85.571 AUSTRALIA 85.336 2012  1:25.571
## 5 87.117         2   5  1:27.117 86.297 AUSTRALIA 85.651 2012  1:26.297
##   q3natTime                    team qlaps         driverName
## 1  1:24.922        McLaren-Mercedes    14     Lewis Hamilton
## 2  1:25.074        McLaren-Mercedes    15      Jenson Button
## 3  1:25.302           Lotus-Renault    21    Romain Grosjean
## 4  1:25.336                Mercedes    18 Michael Schumacher
## 5  1:25.651 Red Bull Racing-Renault    17        Mark Webber
```

The race results include the race time for the winner and the total gap to each of the following drivers (or the number of laps they were behind). For drivers that did not finish, the status is returned. The `laps` column gives the number of race laps completed by each driver:


```r
dbGetQuery(f1, ("SELECT * FROM raceResults LIMIT 5"))
```

       race laps driverNum pos points grid       driverName raceNum year
1 AUSTRALIA   58         3   1     25    2    Jenson Button       1 2012
2 AUSTRALIA   58         1   2     18    6 Sebastian Vettel       1 2012
3 AUSTRALIA   58         4   3     15    1   Lewis Hamilton       1 2012
4 AUSTRALIA   58         2   4     12    5      Mark Webber       1 2012
5 AUSTRALIA   58         5   5     10   12  Fernando Alonso       1 2012
                     team timeOrRetired
1        McLaren-Mercedes   1:34:09.565
2 Red Bull Racing-Renault     +2.1 secs
3        McLaren-Mercedes     +4.0 secs
4 Red Bull Racing-Renault     +4.5 secs
5                 Ferrari    +21.5 secs

The `racePits` table summarises pit stop activity, with one line for each pit stop including the lap number the stop was taken on and the time of day. The pit loss time for each stop is given along with the cumulative pit loss time.


```r
dbGetQuery(f1, ("SELECT * FROM racePits LIMIT 5"))
```

```
##   natPitTime totalPitTime      race natTotalPitTime driverNum stops
## 1     24.599       24.599 AUSTRALIA          24.599        19     1
## 2     32.319       32.319 AUSTRALIA          32.319        16     1
## 3     22.313       22.313 AUSTRALIA          22.313         6     1
## 4     23.203       23.203 AUSTRALIA          23.203         8     1
## 5     22.035       22.035 AUSTRALIA          22.035         5     1
##   pitTime       driverName raceNum year             team lap timeOfDay
## 1  24.599      Bruno Senna       1 2012 Williams-Renault   1  17:05:23
## 2  32.319 Daniel Ricciardo       1 2012      STR-Ferrari   1  17:05:35
## 3  22.313     Felipe Massa       1 2012          Ferrari  11  17:21:08
## 4  23.203     Nico Rosberg       1 2012         Mercedes  12  17:22:31
## 5  22.035  Fernando Alonso       1 2012          Ferrari  13  17:24:04
```

The `raceFastLaps` table records the race lap on which each driver recorded their fastes laptime, along with that laptime and the average speed round the lap.


```r
dbGetQuery(f1, ("SELECT * FROM raceFastlaps LIMIT 5"))
```

```
##   timeOfDay lap driverNum pos      race  stime raceNum year
## 1  18:34:37  56         3   1 AUSTRALIA 89.187       1 2012
## 2  18:36:10  57         1   2 AUSTRALIA 89.417       1 2012
## 3  18:36:12  57         2   3 AUSTRALIA 89.438       1 2012
## 4  18:36:11  57         4   4 AUSTRALIA 89.538       1 2012
## 5  18:30:22  53        18   5 AUSTRALIA 90.254       1 2012
##                      team   speed  natTime       driverName
## 1        McLaren-Mercedes 214.053 1:29.187    Jenson Button
## 2 Red Bull Racing-Renault 213.503 1:29.417 Sebastian Vettel
## 3 Red Bull Racing-Renault 213.452 1:29.438      Mark Webber
## 4        McLaren-Mercedes 213.214 1:29.538   Lewis Hamilton
## 5        Williams-Renault 211.523 1:30.254 Pastor Maldonado
```

## Format of the Archival f1com_results_archive.sqlite Database


```r
f1archive =dbConnect(RSQLite::SQLite(), './f1com_results_archive.sqlite')

dbListTables(f1archive)
```

```
## [1] "QualiResultsto2005" "Sectors"            "Speeds"            
## [4] "pResults"           "qualiResults"       "raceFastlaps"      
## [7] "racePits"           "raceResults"
```

## Problems with the Formula One Data
Until the 2014 season, driver numbers were allocated to drivers based on the team they drove for and the classification of the team in the previous year's Constructors' Chanpionship. This makes them impossible to use as a consistent identifier across years (driver number 3 this year may not be the same person as driver number 3 last year), something that the introduction of personal driver numbers should help to address. That said, driver number 1 will still change year on year.

## How to use the FormulaOne.com alongside the ergast data

If we compare certain key elements of the data scraped from the FormulaOne.com website and the ergast data, we notice several differences:

?as table

item f1com  ergast notes
driverName
driver ID ? *driverName*
driver three letter ID No Partial (since 201?)
race name
race ID  ? race/year key pair

To be able to jointly work on ergast data and data from the FormulaOne.com website, we need to define mapping or lookup operations that allows us to associate unique elements from one dataset with corresponding unique elements from the other.
