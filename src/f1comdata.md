
# Data Scraped from the Formula One Website (Pre-2015)

Until a redesign of the formula1.com website for the 2015 season, data was available detailing results and session data from the current, as well as previous, sessions. The original website, including the results data, remains available on the [Internet Archive Wayback Machine](https://archive.org/web/).

Data originally scraped from the Formula One website is available as a simple SQLite database (accessible from the [*wranglingf1datawithr* repository](https://github.com/psychemedia/wranglingf1datawithr) as *scraperwiki.sqlite*. Python code for the scraper used against that website is contained in the appendix *Scraping Formula1.com Timing Data*; tweaks to that code may be required to run it against the Internet Archive version of the website. A second, improved scrape into a newly formatted database - *f1com_results_archive.sqlite* -  was completed at the end of 2014.

__The current version of this book utilises data from *both* SQLite databases.__

## Format of the Original scraperwiki.sqlite Database

The original database contained the following tables:


```r
library(DBI)
f1 =dbConnect(RSQLite::SQLite(), './scraperwiki.sqlite')

#dbGetQuery(f1,'SET NAMES utf8;') 
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

The `pNSectors` tables contain the best sector times recorded by each driver in each practice session (N=1,2,3), and the `qualiSectors` table the best sector times from qualifying:


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

We can combine the sector times from each sector by binding the rows from queries onto separate session tables together, as well as creating appropriately named dataframes in the global scope. To distinguish in which session the best sector times were set, we add a new column that specifies the session in which the time was recorded; to generalise the underlying function, we pass in the partial name of the data table according to the session data we want to return (*Sectors* or *Speeds*):


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

#This function can be found in the file f1comdataR-core.R
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

The `qualiResults` table is more elaborate than the results tables for the practice sessions, because it includes the best lap time recorded in each qualifying session as well as the number of laps completed across qualifying.



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

```
##        race laps driverNum pos points grid       driverName raceNum year
## 1 AUSTRALIA   58         3   1     25    2    Jenson Button       1 2012
## 2 AUSTRALIA   58         1   2     18    6 Sebastian Vettel       1 2012
## 3 AUSTRALIA   58         4   3     15    1   Lewis Hamilton       1 2012
## 4 AUSTRALIA   58         2   4     12    5      Mark Webber       1 2012
## 5 AUSTRALIA   58         5   5     10   12  Fernando Alonso       1 2012
##                      team timeOrRetired
## 1        McLaren-Mercedes   1:34:09.565
## 2 Red Bull Racing-Renault     +2.1 secs
## 3        McLaren-Mercedes     +4.0 secs
## 4 Red Bull Racing-Renault     +4.5 secs
## 5                 Ferrari    +21.5 secs
```

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

The `raceFastLaps` table records the race lap on which each driver recorded their fastest laptime, along with that laptime and the average speed round the lap.


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

## Format of the f1com_results_archive.sqlite Database

The revised `f1com_results_archive.sqlite` database contains the following tables.


```r
f1archive = dbConnect(RSQLite::SQLite(), './f1com_results_archive.sqlite')

dbListTables(f1archive)
```

```
## [1] "QualiResultsto2005" "Sectors"            "Speeds"            
## [4] "pResults"           "qualiResults"       "raceFastlaps"      
## [7] "racePits"           "raceResults"
```

One noticeable difference compared with the original scraped database is that the practice results are combined into a single table.


```r
str(dbGetQuery(f1archive, ("SELECT * FROM pResults")))
```

```
## 'data.frame':	15552 obs. of  12 variables:
##  $ driverNum : chr  "14" "22" "77" "19" ...
##  $ time      : num  91.8 92.4 92.4 92.4 92.6 ...
##  $ laps      : int  20 23 27 19 26 17 10 28 19 30 ...
##  $ year      : int  2014 2014 2014 2014 2014 2014 2014 2014 2014 2014 ...
##  $ natGap    : num  0 0.517 0.563 0.591 0.759 ...
##  $ gap       : num  0 0.517 0.563 0.591 0.759 ...
##  $ session   : chr  "PRACTICE 1" "PRACTICE 1" "PRACTICE 1" "PRACTICE 1" ...
##  $ pos       : int  1 2 3 4 5 6 7 8 9 10 ...
##  $ driverName: chr  "Fernando Alonso" "Jenson Button" "Valtteri  Bottas" "Felipe Massa" ...
##  $ race      : chr  "AUSTRALIA" "AUSTRALIA" "AUSTRALIA" "AUSTRALIA" ...
##  $ team      : chr  "Ferrari" "McLaren-Mercedes" "Williams-Mercedes" "Williams-Mercedes" ...
##  $ natTime   : chr  "1:31.840" "1:32.357" "1:32.403" "1:32.431" ...
```

The qualification results scrape has been improved to take into account the different approach to qualifying prior to 2005.


```r
str(dbGetQuery(f1archive, ("SELECT * FROM QualiResultsto2005")))
```

```
## 'data.frame':	143 obs. of  9 variables:
##  $ race      : chr  "SUNDAY QUALIFYING" "SATURDAY QUALIFYING" "SATURDAY QUALIFYING" "SUNDAY QUALIFYING" ...
##  $ year      : int  2005 2005 2005 2005 2005 2005 2005 2005 2005 2005 ...
##  $ pos       : chr  "15" "5" "10" "3" ...
##  $ driverNum : chr  "0" "3" "4" "3" ...
##  $ session   : chr  "SUNDAY QUALIFYING" "SATURDAY QUALIFYING" "SATURDAY QUALIFYING" "SUNDAY QUALIFYING" ...
##  $ driverName: chr  "Anthony Davidson" "Jenson Button" "Takuma Sato" "Jenson Button" ...
##  $ time      : num  191.9 80.5 80.9 164.1 164.7 ...
##  $ team      : chr  "BAR-Honda" "BAR-Honda" "BAR-Honda" "BAR-Honda" ...
##  $ natTime   : chr  "3:11.890" "1:20.464" "1:20.851" "2:44.105" ...
```


```r
str(dbGetQuery(f1archive, ("SELECT * FROM qualiResults")))
```

```
## 'data.frame':	3695 obs. of  14 variables:
##  $ session   : chr  "QUALIFYING" "QUALIFYING" "QUALIFYING" "QUALIFYING" ...
##  $ q1time    : num  91.7 90.8 92.6 90.9 91.4 ...
##  $ driverNum : chr  "44" "3" "6" "20" ...
##  $ pos       : chr  "1" "2" "3" "4" ...
##  $ q2time    : num  103 102 102 103 103 ...
##  $ race      : chr  "AUSTRALIA" "AUSTRALIA" "AUSTRALIA" "AUSTRALIA" ...
##  $ q3natTime : chr  "1:44.231" "1:44.548" "1:44.595" "1:45.745" ...
##  $ q3time    : num  104 105 105 106 106 ...
##  $ year      : int  2014 2014 2014 2014 2014 2014 2014 2014 2014 2014 ...
##  $ q2natTime : chr  "1:42.890" "1:42.295" "1:42.264" "1:43.247" ...
##  $ qlaps     : chr  "22" "20" "21" "19" ...
##  $ team      : chr  "Mercedes" "Red Bull Racing-Renault" "Mercedes" "McLaren-Mercedes" ...
##  $ q1natTime : chr  "1:31.699" "1:30.775" "1:32.564" "1:30.949" ...
##  $ driverName: chr  "Lewis Hamilton" "Daniel Ricciardo" "Nico Rosberg" "Kevin Magnussen" ...
```


```r
str(dbGetQuery(f1archive, ("SELECT * FROM raceResults")))
```

```
## 'data.frame':	22148 obs. of  12 variables:
##  $ race         : chr  "AUSTRALIA" "AUSTRALIA" "AUSTRALIA" "AUSTRALIA" ...
##  $ laps         : chr  "57" "57" "57" "57" ...
##  $ driverNum    : chr  "6" "20" "22" "14" ...
##  $ pos          : chr  "1" "2" "3" "4" ...
##  $ session      : chr  "RACE" "RACE" "RACE" "RACE" ...
##  $ grid         : chr  "3" "4" "10" "5" ...
##  $ driverName   : chr  "Nico Rosberg" "Kevin Magnussen" "Jenson Button" "Fernando Alonso" ...
##  $ raceNum      : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ year         : int  2014 2014 2014 2014 2014 2014 2014 2014 2014 2014 ...
##  $ team         : chr  "Mercedes" "McLaren-Mercedes" "McLaren-Mercedes" "Ferrari" ...
##  $ timeOrRetired: chr  "1:32:58.710" "+26.7 secs" "+30.0 secs" "+35.2 secs" ...
##  $ points       : chr  "25" "18" "15" "12" ...
```

Speed trap data is aggregated from across sessions into a single table.


```r
str(dbGetQuery(f1archive, ("SELECT * FROM Speeds")))
```

```
## 'data.frame':	18900 obs. of  8 variables:
##  $ race      : chr  "AUSTRALIA" "AUSTRALIA" "AUSTRALIA" "AUSTRALIA" ...
##  $ driverNum : chr  "77" "11" "20" "6" ...
##  $ qspeed    : chr  "317.5" "315.4" "314.8" "313.8" ...
##  $ pos       : chr  "1" "2" "3" "4" ...
##  $ session   : chr  "QUALIFYING" "QUALIFYING" "QUALIFYING" "QUALIFYING" ...
##  $ driverName: chr  "Valtteri  Bottas" "Sergio Perez" "Kevin Magnussen" "Nico Rosberg" ...
##  $ year      : int  2014 2014 2014 2014 2014 2014 2014 2014 2014 2014 ...
##  $ timeOfDay : chr  "17:03:47" "17:03:36" "17:04:23" "17:05:23" ...
```

Sector times recorded in different sessions are also now contained within the same table.


```r
str(dbGetQuery(f1archive, ("SELECT * FROM Sectors")))
```

```
## 'data.frame':	56457 obs. of  8 variables:
##  $ sector    : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ race      : chr  "AUSTRALIA" "AUSTRALIA" "AUSTRALIA" "AUSTRALIA" ...
##  $ driverNum : chr  "44" "19" "3" "20" ...
##  $ pos       : chr  "1" "2" "3" "4" ...
##  $ session   : chr  "QUALIFYING" "QUALIFYING" "QUALIFYING" "QUALIFYING" ...
##  $ driverName: chr  "Lewis Hamilton" "Felipe Massa" "Daniel Ricciardo" "Kevin Magnussen" ...
##  $ year      : int  2014 2014 2014 2014 2014 2014 2014 2014 2014 2014 ...
##  $ sectortime: chr  "29.863" "29.940" "30.045" "30.069" ...
```


```r
str(dbGetQuery(f1archive, ("SELECT * FROM raceFastlaps")))
```

```
## 'data.frame':	4234 obs. of  12 variables:
##  $ timeOfDay : chr  "17:41:08" "18:40:12" "18:39:59" "18:12:04" ...
##  $ lap       : chr  "19" "56" "56" "38" ...
##  $ driverNum : chr  "6" "77" "14" "26" ...
##  $ pos       : chr  "1" "2" "3" "4" ...
##  $ race      : chr  "AUSTRALIA" "AUSTRALIA" "AUSTRALIA" "AUSTRALIA" ...
##  $ stime     : num  92.5 92.6 92.6 92.6 92.9 ...
##  $ raceNum   : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ year      : int  2014 2014 2014 2014 2014 2014 2014 2014 2014 2014 ...
##  $ team      : chr  "Mercedes" "Williams-Mercedes" "Ferrari" "STR-Renault" ...
##  $ speed     : chr  "206.436" "206.235" "206.128" "206.088" ...
##  $ natTime   : chr  "1:32.478" "1:32.568" "1:32.616" "1:32.634" ...
##  $ driverName: chr  "Nico Rosberg" "Valtteri  Bottas" "Fernando Alonso" "Daniil Kvyat" ...
```


```r
str(dbGetQuery(f1archive, ("SELECT * FROM racePits")))
```

```
## 'data.frame':	8599 obs. of  13 variables:
##  $ natPitTime     : chr  "17.255" "32.657" "25.541" "34.921" ...
##  $ totalPitTime   : num  17.3 32.7 25.5 34.9 22.4 ...
##  $ race           : chr  "AUSTRALIA" "AUSTRALIA" "AUSTRALIA" "AUSTRALIA" ...
##  $ natTotalPitTime: chr  "17.255" "32.657" "25.541" "34.921" ...
##  $ driverNum      : chr  "8" "21" "11" "77" ...
##  $ stops          : chr  "1" "1" "1" "1" ...
##  $ pitTime        : num  17.3 32.7 25.5 34.9 22.4 ...
##  $ driverName     : chr  "Romain Grosjean" "Esteban Gutierrez" "Sergio Perez" "Valtteri  Bottas" ...
##  $ raceNum        : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ year           : int  2014 2014 2014 2014 2014 2014 2014 2014 2014 2014 ...
##  $ team           : chr  "Lotus-Renault" "Sauber-Ferrari" "Force India-Mercedes" "Williams-Mercedes" ...
##  $ lap            : chr  "1" "1" "1" "10" ...
##  $ timeOfDay      : chr  "17:09:56" "17:10:12" "17:10:14" "17:24:46" ...
```

## Problems with the Formula One Data
Until the 2014 season, driver numbers were allocated to drivers based on the team they drove for and the classification of the team in the previous year's Constructors' Championship. This makes them impossible to use as a consistent identifier across years (driver number 3 this year may not be the same person as driver number 3 last year), something that the introduction of personal driver numbers should help to address. That said, who takes driver number 1 may still change year on year, that number being reserved for the previous year's Driver's World Champion.

## How to use the Formula1.com Data alongside the *ergast* data

If we compare certain key elements of the data scraped from the Formula1.com website and the *ergast* data, there are several differences in the presentation of what we might term "naturally occurring" keys, such as the name of a race, or driver.

To be able to jointly work on *ergast* data and data from the Formula1.com website, we need to define mapping or lookup operations that allows us to associate unique elements from one dataset with corresponding unique elements from the other.
