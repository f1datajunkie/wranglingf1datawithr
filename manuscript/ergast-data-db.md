
# Getting the data from the *ergast* Motor Racing Database Download

As well as being made available over the web via a JSON API, Chris Newell also releases the data as a MySQL database export file at the end of each season. 

If you want to use F1 data as a context for learning how to write database queries using SQL, one of the most popular and widely used database query languages, then this download is probably for you...

## Accessing SQLite from R

MySQL is a poweful database that is arguably overkill for our purposes here, but there is another database we can draw on that is quick and easy to use - once we get the data into the right format for it: [SQLite](http://www.sqlite.org/). *For an example of how to generate a SQLite version of the database from the MySQL export, see the appendix.*

*Unfortunately, the recipe I use to generate a SQLite version of the database requires MySQL during the transformation step, which begs the question of why I don't just connect R to MySQL directly. My reasoning is to try to use lightweight database tools where possible, and sqlite offers just such a solution: no database management system is required, just the sqlite database file and the RSQLite library to query into it.*

*You can download a copy of the *ergast* database as a sqlite database from the [wranglingf1datawithr repository](https://github.com/psychemedia/wranglingf1datawithr) as **ergastdb13.sqlite***

*On the to do list is to put together a virtual machine (VM) for this book that includes all the tools introduced in this book, including RStudio and MySQL as well as all the required libraries, packages, datasets and scrapers for generating your own datasets.*

We can access a SQLite database from R using the [RSQLite package](http://cran.r-project.org/web/packages/RSQLite/index.html):

```r
#We start off by creeating a connection to the database
require(DBI)
ergastdb =dbConnect(RSQLite::SQLite(), './ergastdb13.sqlite')

#Then we can run queries against it
#For example, let's see what tables it contains:
dbGetQuery(ergastdb, 'SELECT name FROM sqlite_master WHERE type = "table"')
```

```
##                    name
## 1              circuits
## 2    constructorResults
## 3  constructorStandings
## 4          constructors
## 5       driverStandings
## 6               drivers
## 7              lapTimes
## 8              pitStops
## 9            qualifying
## 10                races
## 11              results
## 12              seasons
## 13               status
```

## The Virtual Machine Approach

Another approach to setting up an environment in which to work with the eragst database is to load it into a MySQL database running as a service and then connect to that service from RStudio. However, this requires that a user can install the database server and populate it with the *ergast* database. Another approach is to run either the database server alone, or the database server *and* RStudio in a virtual machine running either on your own computer or on a cloud hosted machine.

In the latter case, we can Docker virtual machine containers to run and interconnect a variety of services, such as a MySQL database server and an RStudio server, and then access the RStudio server through a browser based interface.

*For an example of connecting to the *ergast* database running in a MySQL docker container, see [Connecting RStudio and MySQL Docker Containers – an example using the *ergast* db](http://blog.ouseful.info/2015/01/17/connecting-rstudio-and-mysql-docker-containers-the-ergastdb/)*

## Getting Started with the *ergast* Database

If we're feeling adventurous, we could load the whole of the *ergast* database into memory as a set of R dataframes, one per database table, in a single routine. The dataframes take the name of the corresponding table in the database.



```r
## list all tables
tables <- dbListTables(ergastdb)

## exclude sqlite_sequence (contains table information)
tables <- tables[tables != "sqlite_sequence"]

lDataFrames <- vector("list", length=length(tables))

for (i in seq(along=tables)) {
  assign(tables[i],dbGetQuery(conn=ergastdb, statement=paste("SELECT * FROM '", tables[[i]], "'", sep="")))
}
```

This is the sort of data we can find in the *circuits* table (there is also a column, *not shown*, that contains a link to the Wikipedia page for the circuit. It may be possible to use this to automate a route for pulling in a circuit map from Wikipedia or DBpedia):


```r
kable( head(circuits[,1:7],n=5),format='markdown' )
```



| circuitId|circuitRef  |name                           |location     |country   |       lat|       lng|
|---------:|:-----------|:------------------------------|:------------|:---------|---------:|---------:|
|         1|albert_park |Albert Park Grand Prix Circuit |Melbourne    |Australia | -37.84970| 144.96800|
|         2|sepang      |Sepang International Circuit   |Kuala Lumpur |Malaysia  |   2.76083| 101.73800|
|         3|bahrain     |Bahrain International Circuit  |Sakhir       |Bahrain   |  26.03250|  50.51060|
|         4|catalunya   |Circuit de Catalunya           |Montmeló     |Spain     |  41.57000|   2.26111|
|         5|istanbul    |Istanbul Park                  |Istanbul     |Turkey    |  40.95170|  29.40500|

Alternatively, we might use a package such as RMaps to plot the circuits visited in each season on a world map, perhaps using great circles to to connect the consecutive races to show just how far the race teams travel year on year.

Here's an example of the *constructorResults*:


| constructorResultsId| raceId| constructorId| points|
|--------------------:|------:|-------------:|------:|
|                    1|     18|             1|     14|
|                    2|     18|             2|      8|
|                    3|     18|             3|      9|
|                    4|     18|             4|      5|
|                    5|     18|             5|      2|

In and of itself, this is not very interesting - we would probably need to blend this data with a meaningful explanation of the *constructorId* and/or *raceId* from another table. For example, the *constructors* table provides descriptive information about each team. (Note, there is also a column (not shown) that gives the URL for the team's Wikipedia page.):


| constructorId|constructorRef |name       |nationality |
|-------------:|:--------------|:----------|:-----------|
|             1|mclaren        |McLaren    |British     |
|             2|bmw_sauber     |BMW Sauber |German      |
|             3|williams       |Williams   |British     |
|             4|renault        |Renault    |French      |
|             5|toro_rosso     |Toro Rosso |Italian     |

We might therefore merge the *constructors* and *constructorResults* dataframes using the R *merge()* function:

`merge(constructors[,1:4],constructorResults,by='constructorId'), n=5)`


| constructorId|constructorRef |name    |nationality | constructorResultsId| raceId| points|status |
|-------------:|:--------------|:-------|:-----------|--------------------:|------:|------:|:------|
|             1|mclaren        |McLaren |British     |                    1|     18|     14|NA     |
|             1|mclaren        |McLaren |British     |                 4375|    376|     15|NA     |
|             1|mclaren        |McLaren |British     |                11338|    674|      0|NA     |
|             1|mclaren        |McLaren |British     |                 3406|    314|     13|NA     |
|             1|mclaren        |McLaren |British     |                 6609|    522|      0|NA     |

However, we will see later on in this chapter how to join data from two or more tables as part of the same SQL query.

The *constructorStandings* also give information keyed by the *constructorId* and *raceId*:


| constructorStandingsId| raceId| constructorId| points| position|positionText | wins|
|----------------------:|------:|-------------:|------:|--------:|:------------|----:|
|                      1|     18|             1|     14|        1|1            |    1|
|                      2|     18|             2|      8|        3|3            |    0|
|                      3|     18|             3|      9|        2|2            |    0|
|                      4|     18|             4|      5|        4|4            |    0|
|                      5|     18|             5|      2|        5|5            |    0|

The *driverStandings* table identifies the standings for each driver after each race. It is keyed by *raceId* and *driverId*:


| driverStandingsId| raceId| driverId| points| position|positionText | wins|
|-----------------:|------:|--------:|------:|--------:|:------------|----:|
|                 1|     18|        1|     10|        1|1            |    1|
|                 2|     18|        2|      8|        2|2            |    0|
|                 3|     18|        3|      6|        3|3            |    0|
|                 4|     18|        4|      5|        4|4            |    0|
|                 5|     18|        5|      4|        5|5            |    0|

In order to find the driver standings at the end of a particular race, we need to find the raceId for the corresponding race. This can be doen via the *races* table described below. 

The *drivers* table gives some descriptive information about each driver. Again, there is an additional column (not shown) that contains a link to the driver's Wikipedia page. The three letter code column is particulalry useful as it provides us with a short, recognisable label by means of which we can refer to each driver on many of the charts we'll be producing.


| driverId|driverRef  |code |forename |surname    |dob        |nationality |
|--------:|:----------|:----|:--------|:----------|:----------|:-----------|
|        1|hamilton   |HAM  |Lewis    |Hamilton   |1985-01-07 |British     |
|        2|heidfeld   |HEI  |Nick     |Heidfeld   |1977-05-10 |German      |
|        3|rosberg    |ROS  |Nico     |Rosberg    |1985-06-27 |German      |
|        4|alonso     |ALO  |Fernando |Alonso     |1981-07-29 |Spanish     |
|        5|kovalainen |KOV  |Heikki   |Kovalainen |1981-10-19 |Finnish     |

The *lapTimes* table is one that we shall pull data from extensively. Keyed by *raceId* and *driverId*, it gives the position of the driver at the end of each lap in a race, along with the laptime for that lap in the form *min*:*sec*.*millisec* as well as the laptime in milliseconds. Lap time data is only available from the 2011 season onwards.


| raceId| driverId| lap| position|time     | milliseconds|
|------:|--------:|---:|--------:|:--------|------------:|
|    841|       20|   1|        1|1:38.109 |        98109|
|    841|       20|   2|        1|1:33.006 |        93006|
|    841|       20|   3|        1|1:32.713 |        92713|
|    841|       20|   4|        1|1:32.803 |        92803|
|    841|       20|   5|        1|1:32.342 |        92342|

The *pitStops* table provides data about the duration of each individual pit stop. The duration is given in seconds/millisecods, as well as the total number of milliseconds. Note that the duration is essentially the sum of the stop time plus the pit loss time. *(What happens if a driver gets a drive through penalty? Is the pit stop time the time the driver takes between enetering and leaving the pitlane? In which case, the pit stop times will also include penalties that involve driving through the pit lane, stop and go penalties, etc.)*


| raceId| driverId| stop| lap|time     |duration | milliseconds|
|------:|--------:|----:|---:|:--------|:--------|------------:|
|    841|      153|    1|   1|17:05:23 |26.898   |        26898|
|    841|       30|    1|   1|17:05:52 |25.021   |        25021|
|    841|       17|    1|  11|17:20:48 |23.426   |        23426|
|    841|        4|    1|  12|17:22:34 |23.251   |        23251|
|    841|       13|    1|  13|17:24:10 |23.842   |        23842|

The *qualifying* table contains qualifying session times for each driver in each race, along with their position at the end of qualifying. We'll split it into two to make it easier to read.


| qualifyId| raceId| driverId| constructorId|
|---------:|------:|--------:|-------------:|
|         1|     18|        1|             1|
|         2|     18|        9|             2|
|         3|     18|        5|             1|
|         4|     18|       13|             6|
|         5|     18|        2|             2|

| number| position|q1       |q2       |q3       |
|------:|--------:|:--------|:--------|:--------|
|     22|        1|1:26.572 |1:25.187 |1:26.714 |
|      4|        2|1:26.103 |1:25.315 |1:26.869 |
|     23|        3|1:25.664 |1:25.452 |1:27.079 |
|      2|        4|1:25.994 |1:25.691 |1:27.178 |
|      3|        5|1:25.960 |1:25.518 |1:27.236 |

The *races* table contains descriptive information about each actual race. (There is an additional column, not shown, that contains the URL for the Wikipedia page of the actual race):


| raceId| year| round| circuitId|name                  |date       |time     |
|------:|----:|-----:|---------:|:---------------------|:----------|:--------|
|      1| 2009|     1|         1|Australian Grand Prix |2009-03-29 |06:00:00 |
|      2| 2009|     2|         2|Malaysian Grand Prix  |2009-04-05 |09:00:00 |
|      3| 2009|     3|        17|Chinese Grand Prix    |2009-04-19 |07:00:00 |
|      4| 2009|     4|         3|Bahrain Grand Prix    |2009-04-26 |12:00:00 |
|      5| 2009|     5|         4|Spanish Grand Prix    |2009-05-10 |12:00:00 |

The *results* table provides results data for each car in each race. (The *positionOrder* field is used for ranking drivers who are unclassified by virtue of not completing enough of the race distance.) Let's split the table into three parts so we can see all the columns clearly:



| resultId| raceId| driverId| constructorId| number| grid| position|
|--------:|------:|--------:|-------------:|------:|----:|--------:|
|        1|     18|        1|             1|     22|    1|        1|
|        2|     18|        2|             2|      3|    5|        2|
|        3|     18|        3|             3|      7|    7|        3|
|        4|     18|        4|             4|      5|   11|        4|
|        5|     18|        5|             1|     23|    3|        5|

|positionText | positionOrder| points| laps|time        | milliseconds|
|:------------|-------------:|------:|----:|:-----------|------------:|
|1            |             1|     10|   58|1:34:50.616 |      5690616|
|2            |             2|      8|   58|+5.478      |      5696094|
|3            |             3|      6|   58|+8.163      |      5698779|
|4            |             4|      5|   58|+17.181     |      5707797|
|5            |             5|      4|   58|+18.014     |      5708630|

| fastestLap| rank|fastestLapTime |fastestLapSpeed | statusId|
|----------:|----:|:--------------|:---------------|--------:|
|         39|    2|1:27.452       |218.300         |        1|
|         41|    3|1:27.739       |217.586         |        1|
|         41|    5|1:28.090       |216.719         |        1|
|         58|    7|1:28.603       |215.464         |        1|
|         43|    1|1:27.418       |218.385         |        1|

The *seasons* table provides a link to the Wkipedia page for each season:


| year|url                                                  |
|----:|:----------------------------------------------------|
| 2009|http://en.wikipedia.org/wiki/2009_Formula_One_season |
| 2008|http://en.wikipedia.org/wiki/2008_Formula_One_season |
| 2007|http://en.wikipedia.org/wiki/2007_Formula_One_season |
| 2006|http://en.wikipedia.org/wiki/2006_Formula_One_season |
| 2005|http://en.wikipedia.org/wiki/2005_Formula_One_season |

The *status* table gives a natural langiage description of each status code:


| statusId|status       |
|--------:|:------------|
|        1|Finished     |
|        2|Disqualified |
|        3|Accident     |
|        4|Collision    |
|        5|Engine       |

## Asking Questions of the *ergast* Data

As you may have noticed, the data we can get from the online *ergast* API comes in a form that we can make sense of immediately. For example, if we get the results of a particular race, we can see the name of the driver, the constructor name, the status at the end of the race, and so on. The full *ergast* API also supports queries that allow us to to view data based on just the results associated with a particular driver, year, constructor or circuit, for example, or even based on some combination of those things. *(The `ergastR-core.R` script does not yet contain a comprehensive wrapper for the *ergast* API. You are encouraged to add to the library and submit patches to it.)*

In the section introducing R dataframes, we saw how it is possible to use the routines in the `ergastR-core.R` source file to query the *ergast* APIm and then run some simple "queries" on the returned R dataframes in order to select certain rows or columns. With access to our own copy of the *ergast* database, we might prefer to call on the full support of the SQL query language to pull back this specific data.

However, there is cost associated with making our own queries on a local copy of the *ergast* database versus calling the *ergast* API directly: the *ergast* API returns datasets that have been created by making queries over several *ergast* database data tables. In order to get a similar response from the database, we either need to run a query on the database that pulls results back from several tables that we have JOINed together ourselves via the database query, or find an alternative way of combining data that has been pulled from separate database requests into several separate dataframes.

### JOINing Tables Within SQLite Database Queries

If we want to find out the names of the drivers associated with the standings at the end of a particular race, we need to do several things:

* find the *raceId* for the race we are interested in from the *races* table
* get the standings associated with that race from the *driverStandings* table
* get the driver details for each driver from the *drivers* table

Let's see how to write those queries. In the first case, we can attach a series of conditions to a query in which the results are pulled *FROM* a particular table; the rows that are returned are those rows WHERE the associated conditions are evaluated as true. The *SELECT* statement declares which columns to return: the * denotes "all columns"; we could also provide a commas separated list of column names in order to just pull back data from those columns.


```r
dbGetQuery(ergastdb, 'SELECT * FROM races WHERE year==2013 AND name=="British Grand Prix"')
```

```
##   raceId year round circuitId               name       date     time
## 1    887 2013     8         9 British Grand Prix 2013-06-30 12:00:00
##                                                    url
## 1 http://en.wikipedia.org/wiki/2013_British_Grand_Prix
```

Note that we can order the results from a search by adding *ORDER BY* on the the end of the query, followed by one or more column names we wish to sort by. The result is returned in **ASC**ending order, but we can also specify a **DESC**ending order.

To limit the number of results that are returned (similar the T *head()* command), add *LIMIT N* to the end of the query to return at most *N* results. (If you ask for results in any order, the *LIMIT* will return the first N results that are found and the query execution will termninate. If you sort the results first, the query needs to execute in full, finding all the results of the query, before then ordering the results.)

What we want to do is get the driver standings at the end of this race. If we just had the *raceId* we could get the standings with the following sort of query:


```r
dbGetQuery(ergastdb, 'SELECT * FROM driverStandings WHERE raceId=887')
```

```
##    driverStandingsId raceId driverId points position positionText wins
## 1              65734    887      807      6       15           15    0
## 2              65733    887      813      0       16           16    0
## 3              65731    887      817     11       14           14    0
## 4              65730    887      823      0       22           22    0
## 5              65728    887      819      0       20           20    0
## 6              65727    887      824      0       19           19    0
## 7              65725    887      821      0       18           18    0
## 8              65724    887      818     13       12           12    0
## 9              65719    887       16     23       11           11    0
## 10             65718    887       17     87        5            5    0
## 11             65715    887       20    132        1            1    3
## 12             65716    887       13     57        7            7    0
## 13             65717    887        1     89        4            4    0
## 14             65732    887        3     82        6            6    2
## 15             65729    887      820      0       21           21    0
## 16             65726    887      822      0       17           17    0
## 17             65720    887      814     36        8            8    0
## 18             65713    887        8     98        3            3    1
## 19             65714    887        4    111        2            2    2
## 20             65723    887      815     12       13           13    0
## 21             65722    887      154     26        9            9    0
## 22             65721    887       18     25       10           10    0
```

We can actually combine those two queries into one, limiting the results to show just the driver standings:


```r
dbGetQuery(ergastdb,
           'SELECT ds.driverId, ds.points, ds.position 
            FROM driverStandings ds JOIN races r 
            WHERE ds.raceId=r.raceId AND r.year=2013 AND r.name="British Grand Prix"')
```

```
##    driverId points position
## 1       807      6       15
## 2       813      0       16
## 3       817     11       14
## 4       823      0       22
## 5       819      0       20
## 6       824      0       19
## 7       821      0       18
## 8       818     13       12
## 9        16     23       11
## 10       17     87        5
## 11       20    132        1
## 12       13     57        7
## 13        1     89        4
## 14        3     82        6
## 15      820      0       21
## 16      822      0       17
## 17      814     36        8
## 18        8     98        3
## 19        4    111        2
## 20      815     12       13
## 21      154     26        9
## 22       18     25       10
```

In this case, the *JOIN* command declares which tables we want to return data from, providing each with a shorthand name we can use as prefixes to identify columns from the different tables. The *WHERE* condition is used in the first condition to merge the rows from the two tables on common elements in their resepctive *raceId* values, with the second and third conditions limiting which rows to return based on column values in the *races* table.

We can construct JOINS over multiple tables, not just pairs of tables. For example, to pull in the driver names we need to do a further join with the *drivers* table:


```r
dbGetQuery(ergastdb,
           'SELECT d.surname, d.code, ds.points, ds.position 
            FROM driverStandings ds JOIN races r JOIN drivers d 
            WHERE ds.raceId=r.raceId AND r.year=2013 
              AND r.name="British Grand Prix" AND d.driverId=ds.driverId')
```

```
##          surname code points position
## 1     Hülkenberg  HUL      6       15
## 2      Maldonado  MAL      0       16
## 3      Ricciardo  RIC     11       14
## 4  van der Garde  VDG      0       22
## 5            Pic  PIC      0       20
## 6        Bianchi  BIA      0       19
## 7      Gutiérrez  GUT      0       18
## 8         Vergne  VER     13       12
## 9          Sutil  SUT     23       11
## 10        Webber  WEB     87        5
## 11        Vettel  VET    132        1
## 12         Massa  MAS     57        7
## 13      Hamilton  HAM     89        4
## 14       Rosberg  ROS     82        6
## 15       Chilton  CHI      0       21
## 16        Bottas  BOT      0       17
## 17      di Resta  DIR     36        8
## 18     Räikkönen  RAI     98        3
## 19        Alonso  ALO    111        2
## 20         Pérez  PER     12       13
## 21      Grosjean  GRO     26        9
## 22        Button  BUT     25       10
```

Let's just tidy that up a little and order by the position, then limit the results to show just the top 3:


```r
dbGetQuery(ergastdb,
           'SELECT d.surname, d.code, ds.points, ds.position 
            FROM driverStandings ds JOIN races r JOIN drivers d 
            WHERE ds.raceId=r.raceId AND r.year=2013 
              AND r.name="British Grand Prix" AND d.driverId=ds.driverId 
            ORDER BY ds.position ASC 
            LIMIT 3')
```

```
##     surname code points position
## 1    Vettel  VET    132        1
## 2    Alonso  ALO    111        2
## 3 Räikkönen  RAI     98        3
```

As you can see, we can build up quite complex queries that pull data in from several different tables. The trick to writing the queries is to think clearly about the data you want (that is, the question you want to ask) and then work through the following steps:

* identify which tables that data appears in
* work out what common key columns would allow you to combine data from the different tables
* identify what key values give you a way in to the question  (for example, in the above case we had to identify the rabce name and year to get the *raceId*)
* add in any other search limits or ordering terms

As well as pulling back separate results rows, we can also aggregate the results data. For example, suppose we wanted to count the number of second place finishes Alonso has ever had. We could get the separate instances back as follows:

* find Alonso's *driverId* (so something like *SELECT driverId FROM drivers WHERE code="ALO"*)
* find the races in 2013 where he was in second position (the base query would be something like *SELECT raceId FROM results WHERE driverId=??? AND position=2*. We can find the *driverId* from a JOIN: *SELECT r.raceId FROM results r JOIN drivers d WHERE d.code="ALO" AND r.driverId=d.driverId AND r.position=2*)

We can now count the number of instances as follows:


```r
dbGetQuery(ergastdb,
           'SELECT COUNT(*) secondPlaceFinishes 
            FROM results r JOIN drivers d 
            WHERE d.code="ALO" AND r.driverId=d.driverId AND r.position=2')
```

```
##   secondPlaceFinishes
## 1                  36
```

We can then go further - who are the top 5 drivers with the greatest number of podium (top 3) finishes, and how many?


```r
dbGetQuery(ergastdb,
           'SELECT d.code, d.surname, COUNT(*) podiumFinishes
            FROM results r JOIN drivers d 
            WHERE r.driverId=d.driverId AND r.position>=1 AND r.position<=3 
            GROUP BY d.code, d.surname 
            ORDER BY podiumFinishes DESC 
            LIMIT 5')
```

```
##   code    surname podiumFinishes
## 1  MSC Schumacher            155
## 2 <NA>      Prost            106
## 3  ALO     Alonso             95
## 4 <NA>       Hill             94
## 5 <NA>      Senna             80
```

Do you notice anything odd about that result?

```r
dbGetQuery(ergastdb,
           'SELECT DISTINCT driverRef, surname 
            FROM drivers 
            WHERE surname=="Hill"')
```

```
##    driverRef surname
## 1 damon_hill    Hill
## 2       hill    Hill
## 3  phil_hill    Hill
```
The surname is an ambiguous identifier, so we need to be a little more precise in our query of podium finishers:


```r
dbGetQuery(ergastdb, 
           'SELECT d.code, d.driverRef, COUNT(*) podiumFinishes 
            FROM results r JOIN drivers d 
            WHERE r.driverId=d.driverId AND r.position>=1 AND r.position<=3 
            GROUP BY d.code, d.surname 
            ORDER BY podiumFinishes DESC 
            LIMIT 5')
```

```
##   code          driverRef podiumFinishes
## 1  MSC michael_schumacher            155
## 2 <NA>              prost            106
## 3  ALO             alonso             95
## 4 <NA>               hill             94
## 5 <NA>              senna             80
```

In this case, the COUNT operator is applied over groups of rows returned from the GROUP BY operator. Other summarising operators are also available. For example, MAX() returns the maximum value from a group of values, MIN() the minimum, SUM() the sum of values, and so on. (See also: [SQLite aggregate functions](http://sqlite.org/lang_aggfunc.html))

X> **Exercise**
X>
X> See if you can work out what queries can be used to generate some of the other results tables described on the [List of Formula One driver records](http://en.wikipedia.org/wiki/List_of_Formula_One_driver_records) Wikipedia page.


X> **Exercise**
X>
X> The *ergast* API offers several "high level" patterns for querying F1 results data via a URL that you can construct yourself.
X>
X>
X> Explore some of the queries you can make on the *ergast* website. Choose two or three of these rich data requests and see if you can create equivalent queries onto the *ergast* SQLite database. Check the results of running your query against the results returned from the *ergast* API.

### Nested SELECTs and TEMPORARY VIEWS

Sometimes we may want to run a SELECT query that draws on the results of another query. For example, consider this query, which finds the distinct *driverId*s for drivers competing in the 2013 season:


```r
dbGetQuery(ergastdb, 
           'SELECT DISTINCT ds.driverId 
            FROM driverStandings ds JOIN races r 
            WHERE r.year=2013 AND r.raceId=ds.raceId')
```

```
##    driverId
## 1         8
## 2         4
## 3        20
## 4        13
## 5         1
## 6        17
## 7        16
## 8       814
## 9        18
## 10      154
## 11      815
## 12      818
## 13      821
## 14      822
## 15      824
## 16      819
## 17      820
## 18      823
## 19      817
## 20        3
## 21      813
## 22      807
## 23        5
```

We can pull on this list of *driverId*s to return the full driver information from the *drivers* for each driver competing in 2013.


```r
dbGetQuery(ergastdb,
           'SELECT * 
            FROM drivers 
            WHERE driverId IN 
              (SELECT DISTINCT ds.driverId 
               FROM driverStandings ds JOIN races r 
               WHERE r.year=2013 AND r.raceId=ds.raceId ) ')
```

```
##    driverId     driverRef code  forename       surname        dob
## 1         1      hamilton  HAM     Lewis      Hamilton 1985-01-07
## 2         3       rosberg  ROS      Nico       Rosberg 1985-06-27
## 3         4        alonso  ALO  Fernando        Alonso 1981-07-29
## 4         5    kovalainen  KOV    Heikki    Kovalainen 1981-10-19
## 5         8     raikkonen  RAI      Kimi     Räikkönen 1979-10-17
## 6        13         massa  MAS    Felipe         Massa 1981-04-25
## 7        16         sutil  SUT    Adrian         Sutil 1983-01-11
## 8        17        webber  WEB      Mark        Webber 1976-08-27
## 9        18        button  BUT    Jenson        Button 1980-01-19
## 10       20        vettel  VET Sebastian        Vettel 1987-07-03
## 11      154      grosjean  GRO    Romain      Grosjean 1986-04-17
## 12      807    hulkenberg  HUL      Nico    Hülkenberg 1987-08-19
## 13      813     maldonado  MAL    Pastor     Maldonado 1985-03-09
## 14      814         resta  DIR      Paul      di Resta 1986-04-16
## 15      815         perez  PER    Sergio         Pérez 1990-01-26
## 16      817     ricciardo  RIC    Daniel     Ricciardo 1989-07-01
## 17      818        vergne  VER Jean-Éric        Vergne 1990-04-25
## 18      819           pic  PIC   Charles           Pic 1990-02-15
## 19      820       chilton  CHI       Max       Chilton 1991-04-21
## 20      821     gutierrez  GUT   Esteban     Gutiérrez 1991-08-05
## 21      822        bottas  BOT  Valtteri        Bottas 1989-08-29
## 22      823         garde  VDG     Giedo van der Garde 1985-04-25
## 23      824 jules_bianchi  BIA     Jules       Bianchi 1989-08-03
##    nationality                                                   url
## 1      British           http://en.wikipedia.org/wiki/Lewis_Hamilton
## 2       German             http://en.wikipedia.org/wiki/Nico_Rosberg
## 3      Spanish          http://en.wikipedia.org/wiki/Fernando_Alonso
## 4      Finnish        http://en.wikipedia.org/wiki/Heikki_Kovalainen
## 5      Finnish http://en.wikipedia.org/wiki/Kimi_R%C3%A4ikk%C3%B6nen
## 6    Brazilian             http://en.wikipedia.org/wiki/Felipe_Massa
## 7       German             http://en.wikipedia.org/wiki/Adrian_Sutil
## 8   Australian              http://en.wikipedia.org/wiki/Mark_Webber
## 9      British            http://en.wikipedia.org/wiki/Jenson_Button
## 10      German         http://en.wikipedia.org/wiki/Sebastian_Vettel
## 11      French          http://en.wikipedia.org/wiki/Romain_Grosjean
## 12      German     http://en.wikipedia.org/wiki/Nico_H%C3%BClkenberg
## 13  Venezuelan         http://en.wikipedia.org/wiki/Pastor_Maldonado
## 14    Scottish            http://en.wikipedia.org/wiki/Paul_di_Resta
## 15     Mexican        http://en.wikipedia.org/wiki/Sergio_P%C3%A9rez
## 16  Australian         http://en.wikipedia.org/wiki/Daniel_Ricciardo
## 17      French    http://en.wikipedia.org/wiki/Jean-%C3%89ric_Vergne
## 18      French              http://en.wikipedia.org/wiki/Charles_Pic
## 19     British              http://en.wikipedia.org/wiki/Max_Chilton
## 20     Mexican   http://en.wikipedia.org/wiki/Esteban_Guti%C3%A9rrez
## 21     Finnish          http://en.wikipedia.org/wiki/Valtteri_Bottas
## 22       Dutch      http://en.wikipedia.org/wiki/Giedo_van_der_Garde
## 23      French            http://en.wikipedia.org/wiki/Jules_Bianchi
```

To support the reuse of this dataset, we can CREATE a TEMPORARY VIEW that acts like a database table containing this data.


```r
dbGetQuery(ergastdb, 
           'CREATE TEMPORARY VIEW drivers2013 AS 
              SELECT * FROM drivers 
              WHERE driverId IN 
                (SELECT DISTINCT ds.driverId 
                 FROM driverStandings ds JOIN races r 
                 WHERE r.year=2013 AND r.raceId=ds.raceId ) ')
```

We can then run SELECT queries FROM this view as if it were any other data table.

```r
dbGetQuery(ergastdb, 'SELECT * FROM drivers2013')
```

```
##    driverId     driverRef code  forename       surname        dob
## 1         1      hamilton  HAM     Lewis      Hamilton 1985-01-07
## 2         3       rosberg  ROS      Nico       Rosberg 1985-06-27
## 3         4        alonso  ALO  Fernando        Alonso 1981-07-29
## 4         5    kovalainen  KOV    Heikki    Kovalainen 1981-10-19
## 5         8     raikkonen  RAI      Kimi     Räikkönen 1979-10-17
## 6        13         massa  MAS    Felipe         Massa 1981-04-25
## 7        16         sutil  SUT    Adrian         Sutil 1983-01-11
## 8        17        webber  WEB      Mark        Webber 1976-08-27
## 9        18        button  BUT    Jenson        Button 1980-01-19
## 10       20        vettel  VET Sebastian        Vettel 1987-07-03
## 11      154      grosjean  GRO    Romain      Grosjean 1986-04-17
## 12      807    hulkenberg  HUL      Nico    Hülkenberg 1987-08-19
## 13      813     maldonado  MAL    Pastor     Maldonado 1985-03-09
## 14      814         resta  DIR      Paul      di Resta 1986-04-16
## 15      815         perez  PER    Sergio         Pérez 1990-01-26
## 16      817     ricciardo  RIC    Daniel     Ricciardo 1989-07-01
## 17      818        vergne  VER Jean-Éric        Vergne 1990-04-25
## 18      819           pic  PIC   Charles           Pic 1990-02-15
## 19      820       chilton  CHI       Max       Chilton 1991-04-21
## 20      821     gutierrez  GUT   Esteban     Gutiérrez 1991-08-05
## 21      822        bottas  BOT  Valtteri        Bottas 1989-08-29
## 22      823         garde  VDG     Giedo van der Garde 1985-04-25
## 23      824 jules_bianchi  BIA     Jules       Bianchi 1989-08-03
##    nationality                                                   url
## 1      British           http://en.wikipedia.org/wiki/Lewis_Hamilton
## 2       German             http://en.wikipedia.org/wiki/Nico_Rosberg
## 3      Spanish          http://en.wikipedia.org/wiki/Fernando_Alonso
## 4      Finnish        http://en.wikipedia.org/wiki/Heikki_Kovalainen
## 5      Finnish http://en.wikipedia.org/wiki/Kimi_R%C3%A4ikk%C3%B6nen
## 6    Brazilian             http://en.wikipedia.org/wiki/Felipe_Massa
## 7       German             http://en.wikipedia.org/wiki/Adrian_Sutil
## 8   Australian              http://en.wikipedia.org/wiki/Mark_Webber
## 9      British            http://en.wikipedia.org/wiki/Jenson_Button
## 10      German         http://en.wikipedia.org/wiki/Sebastian_Vettel
## 11      French          http://en.wikipedia.org/wiki/Romain_Grosjean
## 12      German     http://en.wikipedia.org/wiki/Nico_H%C3%BClkenberg
## 13  Venezuelan         http://en.wikipedia.org/wiki/Pastor_Maldonado
## 14    Scottish            http://en.wikipedia.org/wiki/Paul_di_Resta
## 15     Mexican        http://en.wikipedia.org/wiki/Sergio_P%C3%A9rez
## 16  Australian         http://en.wikipedia.org/wiki/Daniel_Ricciardo
## 17      French    http://en.wikipedia.org/wiki/Jean-%C3%89ric_Vergne
## 18      French              http://en.wikipedia.org/wiki/Charles_Pic
## 19     British              http://en.wikipedia.org/wiki/Max_Chilton
## 20     Mexican   http://en.wikipedia.org/wiki/Esteban_Guti%C3%A9rrez
## 21     Finnish          http://en.wikipedia.org/wiki/Valtteri_Bottas
## 22       Dutch      http://en.wikipedia.org/wiki/Giedo_van_der_Garde
## 23      French            http://en.wikipedia.org/wiki/Jules_Bianchi
```


### More Examples of Merging Dataframes in R

As well as running compound queries and multiple joins via SQL queries, we can of course further manipulate data that is returned from a SQL query using R dataframe operations. For example, here are some examples of merging R dataframes pulled back from separate queries onto the *ergast* database.

For example, to find the names of the winners of the 2013 races, first we need to get the *raceId*s from the *races* table:


```r
raceIDs=races[races['year']=='2013',1:3]
raceIDs
```

```
##     raceId year round
## 879    880 2013     1
## 880    881 2013     2
## 881    882 2013     3
## 882    883 2013     4
## 883    884 2013     5
## 884    885 2013     6
## 885    886 2013     7
## 886    887 2013     8
## 887    888 2013     9
## 888    890 2013    10
## 889    891 2013    11
## 890    892 2013    12
## 891    893 2013    13
## 892    894 2013    14
## 893    895 2013    15
## 894    896 2013    16
## 895    897 2013    17
## 896    898 2013    18
## 897    899 2013    19
```

The next thing we need to do is pull in information about the winners of each race in 2013. The winners are in the results table. We want to pull in information about the person in the first position in each race, but to make sure we match on the correct thing we need to see whether or not we want to match on 1 as a digit or as a character. We can ask R what sort of thing it thinks is the type of each column in the *results* table:


```r
str(results)
```

```
## 'data.frame':	22129 obs. of  18 variables:
##  $ resultId       : int  1 2 3 4 5 6 7 8 9 10 ...
##  $ raceId         : int  18 18 18 18 18 18 18 18 18 18 ...
##  $ driverId       : int  1 2 3 4 5 6 7 8 9 10 ...
##  $ constructorId  : int  1 2 3 4 1 3 5 6 2 7 ...
##  $ number         : int  22 3 7 5 23 8 14 1 4 12 ...
##  $ grid           : int  1 5 7 11 3 13 17 15 2 18 ...
##  $ position       : int  1 2 3 4 5 6 7 8 NA NA ...
##  $ positionText   : chr  "1" "2" "3" "4" ...
##  $ positionOrder  : int  1 2 3 4 5 6 7 8 9 10 ...
##  $ points         : num  10 8 6 5 4 3 2 1 0 0 ...
##  $ laps           : int  58 58 58 58 58 57 55 53 47 43 ...
##  $ time           : chr  "1:34:50.616" "+5.478" "+8.163" "+17.181" ...
##  $ milliseconds   : int  5690616 5696094 5698779 5707797 5708630 NA NA NA NA NA ...
##  $ fastestLap     : int  39 41 41 58 43 50 22 20 15 23 ...
##  $ rank           : int  2 3 5 7 1 14 12 4 9 13 ...
##  $ fastestLapTime : chr  "1:27.452" "1:27.739" "1:28.090" "1:28.603" ...
##  $ fastestLapSpeed: chr  "218.300" "217.586" "216.719" "215.464" ...
##  $ statusId       : int  1 1 1 1 1 11 5 5 4 3 ...
```

So, do we want to test on *position==1*, *positionText=="1"*, or *positionOrder=="1"*? Looking carefully at the structure of the table, we see that the *position* element is occasionally undetermined (*NA*); that is, no position is recorded. If we test whether or not *1==NA*, we get *NA* rather than *FALSE* as a result. As the simple filter brings back results if the answer is not FALSE, we would get a false positive match if the position is NA, rather than 1. That is, if we were to trivially filter the dataframe by testing for *position==1*, it would pull back results where the position is either 1 or NA,


```r
#To trap the filter against returning NA results, we might use something like:
#head(results[results['position']==1 & !is.na(results['position']),])

firstPositions=results[results['positionOrder']=="1",]
```

We can now merge the first place results dataframe with the 2013 raceIDs dataframe. To show there's no sleight of hand involved, here are the columns we have in original *raceIDs* dataframe:


```r
colnames(raceIDs)
```

```
## [1] "raceId" "year"   "round"
```

Now let's see what happens when we merge in *from the right* some matching data from the *firstPositions* dataframe:


```r
raceIDs=merge(raceIDs, firstPositions,by='raceId')
colnames(raceIDs)
```

```
##  [1] "raceId"          "year"            "round"          
##  [4] "resultId"        "driverId"        "constructorId"  
##  [7] "number"          "grid"            "position"       
## [10] "positionText"    "positionOrder"   "points"         
## [13] "laps"            "time"            "milliseconds"   
## [16] "fastestLap"      "rank"            "fastestLapTime" 
## [19] "fastestLapSpeed" "statusId"
```

We can also pull in information about the drivers:


```r
raceIDs=merge(raceIDs, drivers,by='driverId')
colnames(raceIDs)
```

```
##  [1] "driverId"        "raceId"          "year"           
##  [4] "round"           "resultId"        "constructorId"  
##  [7] "number"          "grid"            "position"       
## [10] "positionText"    "positionOrder"   "points"         
## [13] "laps"            "time"            "milliseconds"   
## [16] "fastestLap"      "rank"            "fastestLapTime" 
## [19] "fastestLapSpeed" "statusId"        "driverRef"      
## [22] "code"            "forename"        "surname"        
## [25] "dob"             "nationality"     "url"
```

And the constructors...


```r
raceIDs=merge(raceIDs, constructors,by='constructorId')
colnames(raceIDs)
```

```
##  [1] "constructorId"   "driverId"        "raceId"         
##  [4] "year"            "round"           "resultId"       
##  [7] "number"          "grid"            "position"       
## [10] "positionText"    "positionOrder"   "points"         
## [13] "laps"            "time"            "milliseconds"   
## [16] "fastestLap"      "rank"            "fastestLapTime" 
## [19] "fastestLapSpeed" "statusId"        "driverRef"      
## [22] "code"            "forename"        "surname"        
## [25] "dob"             "nationality.x"   "url.x"          
## [28] "constructorRef"  "name"            "nationality.y"  
## [31] "url.y"
```

Note that where column names collide, an additional suffix is added to the column names, working "from the left". So for example, there was a collision on the column name *nationality*, so new column names are derived to break that collision. *nationality.x* now refers to the nationality column from the left hand table in the merge (that is, corresponding to the driver nationality, which we had already merged into the *raceIDs* dataframe) and *nationality.y* refers to the nationality of the constructor.

Let's also pull in the races themselves...


```r
raceIDs=merge(raceIDs, races,by='raceId')
colnames(raceIDs)
```

```
##  [1] "raceId"          "constructorId"   "driverId"       
##  [4] "year.x"          "round.x"         "resultId"       
##  [7] "number"          "grid"            "position"       
## [10] "positionText"    "positionOrder"   "points"         
## [13] "laps"            "time.x"          "milliseconds"   
## [16] "fastestLap"      "rank"            "fastestLapTime" 
## [19] "fastestLapSpeed" "statusId"        "driverRef"      
## [22] "code"            "forename"        "surname"        
## [25] "dob"             "nationality.x"   "url.x"          
## [28] "constructorRef"  "name.x"          "nationality.y"  
## [31] "url.y"           "year.y"          "round.y"        
## [34] "circuitId"       "name.y"          "date"           
## [37] "time.y"          "url"
```

Hopefully you get the idea?! We can mix and match the way we work with data in a way that is most convenient for us.

## Summary

In this chapter we have seen how we can write a wide variety of powerful queries over the *ergast* database, in this case managed via SQLite. (The same SQL queries should work equally well if the data is being pulled from a MySQL database, or PostgreSQL database.)

In particular, we have seen (albeit briefly) how to:

* retrieve data columns from a database table using SELECT .. FROM .., along with the DISTINCT modifier to retrieve unique values or combinations of values
* use the WHERE operator to filter rows and match row values from separate tables
* use the JOIN statement to support the retrieval of data from multiple columns
* use the GROUP BY operator to group rows (and the *COUNT()* operator in the SELECT statemnt to count the number of rows in each group)
* use the HAVING operator to filter results based on GROUP operations
* use the IN statement to allow selection of data based on the results on another SELECT statement (a "nested" SELECT)
* generate a temporary view that acts like a custom datatable using CREATE TEMPORARY VIEW


## Exercises

Practice your SQL skills by coming up with a range of trivia questions about historical Formula One statistics and then seeing whether you can write one or more SQL queries over the *ergast* database that will answer each question.

If you feel that SQL is easier to use than the native R based filtering and sorting operations, you might find the `sqldf` package on CRAN useful. This package allows you to execute SQL style queries over the contents of a dataframe.
