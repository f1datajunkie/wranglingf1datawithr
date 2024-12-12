

# Chapter - Getting the data from the Ergast Motro Racing Database

We can access the contents on the ergast motor racing atabase in three distinct ways:

* online, as tabular results in an HTML web page,  for seasonal data up to and including the current season and results up to and including the last race;
* online, via the ergast API, for seasonal data up to and including the current season and results up to and including the last race;
* via a downloaded image of the database for results to the end of the last completed season.

There are also several thrid party applications that have been built on top of the ergast data. For further details, see the [ergast Application Gallery](http://ergast.com/mrd/gallery).

Whilst it can be instructive to review the applications that other people have built, we are more interested in accessing the actual data, whether by the API or the database. Whilst it doesn't really matter where we get the data from for the point of view of analysis, the API and the database offer slighlty different *affordances* when it comes to actually getting data out in a particular form. For example, the API requires a network connection for live data requests or to populate a cache (a local stored copy of data returned from an API request), whereas the database can be run offline but requires a database management system to serve the data in response to database requests. The API provides data results that combines data from several separate database tables right from the start, whereas with the database we need to work out ourselves how to combine data from several separate data tables.

For convenience, I will refer to *accessing the ergast API* when I mean calling the online API, and *accessing the ergast database* when it comes to querying a local database. However, you should not need to have to install the database for the majority of examples covered in this book - the API will work fine (and is eseential when it comes to making queiries about the current season). On the other hand, if you are looking for an opportunity to learn a little bit about databases and how to query them, now might be a good time!

## Accessing Data from the ergast API

If you have a web connection, one of the most convenient ways of accessing the ergast data is via the ergast API. An API is an *application programming interface* that allows applications to pull data directly from a remote service, such as a database management system, via a programmable interface. That is, we can write a short programme to pull data directly from the ergast database that lives at *ergast.com* via the ergast API.

The ergast API publishes data as a JSON or XML data feed. Handling the data directly is a little fiddly, so I have started to put together a small library to make it easier to access this data, as well as enriching it. *For more details, see the appendix.* The library can be found at [ergastR-core.R]() and currently contains the following functions:

* *driversData.df(YEAR)*: information about the drivers competing in a given year;
* *racesData.df(YEAR)*: details of the races that took place or are scheduled to take place in a given year;
* *resultsData.df(YEAR,RACENUMBER)*: results of races by year and racenumber;
* *raceWinner(YEAR,RACENUMBER)*: the winner of a race specified by year and race number;
* *lapsData.df(YEAR,RACENUMBER)*: information about laptimes during a particular race.

*On my to do list is learn how to put together a proper R package...*

### Introducing the simple ergastR functions

To load the core *ergastR* functions in, use the `source()` command, with the path the `ergastR-core.R` file.


```r
source("~/Dropbox/wranglingf1datawithr/src/ergastR-core.R")
```


Let's look at a preview of each table in turn. We can do this using the R function *head()*, which displays just the first few rows (10 by default) of a dataframe.  For example, *head(df)* previews the first 10 rows for the dataframe *df*. To alter the number of rows displayed, for example to 5, use the construction *head(df,**n=5**)*. To view the rows at the end of the table, you can use the *tail()* command in a similar way.


```r
drivers.df = driversData.df(2014)
head(drivers.df)
```

```
##                driverId     name code permNumber
## driverId         alonso   Alonso  ALO         14
## driverId1 jules_bianchi  Bianchi  BIA         17
## driverId2        bottas   Bottas  BOT         17
## driverId3        button   Button  BUT         22
## driverId4       chilton  Chilton  CHI          4
## driverId5      ericsson Ericsson  ERI          9
```


We can also generate a prettier view of the result:


```r
# The knitr library contains a handy function - kable - for generating
# tabular markdown. We can use it in an Rmd script by setting a chunk with
# the option {r results='asis'} Note that /format='markdown'/ is actually
# the default output for kable.
drivers.df = driversData.df(2014)
kable(head(drivers.df), row.names = F, format = "markdown")
```

|driverId       |name      |code  |permNumber  |
|:--------------|:---------|:-----|:-----------|
|alonso         |Alonso    |ALO   |14          |
|jules_bianchi  |Bianchi   |BIA   |17          |
|bottas         |Bottas    |BOT   |17          |
|button         |Button    |BUT   |22          |
|chilton        |Chilton   |CHI   |4           |
|ericsson       |Ericsson  |ERI   |9           |


In the ergast database, the `driverId` is used to distinguish each driver. The `driversData.df()` function can thus be used to provide additional information about drivers from their `driverId`, such as their new permanent number and their three letter driver code.

When it comes to identifying races, we need two pieces of information. The `year` and the `round`. We can look up races by year by calling `racesData.df()` with the year of interest:


```r
races.df = racesData.df(2014)
kable(head(races.df), format = "markdown")
```

|round  |racename               |circuitId    |
|:------|:----------------------|:------------|
|1      |Australian Grand Prix  |albert_park  |
|2      |Malaysian Grand Prix   |sepang       |
|3      |Bahrain Grand Prix     |bahrain      |
|4      |Chinese Grand Prix     |shanghai     |
|5      |Spanish Grand Prix     |catalunya    |
|6      |Monaco Grand Prix      |monaco       |


Knowing the round number we are interested in then allows us to look up data about a particular race. For example, let's look at the first few lines of the results data for the 2014 Malyasian Grand Prix, which happened to be round 2 of that year:


```r
results.df = resultsData.df(2014, 2)
kable(head(results.df), format = "markdown")
```

|  carNum|  pos|driverId    |constructorId  |  grid|  laps|status    |  fastlapnum|  fastlaptime|  fastlaprank|
|-------:|----:|:-----------|:--------------|-----:|-----:|:---------|-----------:|------------:|------------:|
|      44|    1|hamilton    |mercedes       |     1|    56|Finished  |          53|        103.1|            1|
|       6|    2|rosberg     |mercedes       |     3|    56|Finished  |          55|        104.0|            2|
|       1|    3|vettel      |red_bull       |     2|    56|Finished  |          51|        104.3|            4|
|      14|    4|alonso      |ferrari        |     4|    56|Finished  |          47|        104.2|            3|
|      27|    5|hulkenberg  |force_india    |     7|    56|Finished  |          38|        106.0|           10|
|      22|    6|button      |mclaren        |    10|    56|Finished  |          47|        106.0|           11|


We can also look up the winner of that race using the `raceWinner()` function:


```r
winner = raceWinner(2014, 2)
winner
```

```
## [1] "hamilton"
```


The `raceWinner()` function makes a specific call to the ergast API to pull back the driverId for a particular position in a particular year's race. We could create a more general function that makes a call for information relating to that position.

To inspect the construction of the `raceWinner()` function, we just enter its name without any argument brackets:


```r
raceWinner
```

```
## function (year, raceNum) 
## {
##     wURL = paste(API_PATH, year, "/", raceNum, "/results/1.json", 
##         sep = "")
##     wd = fromJSON(wURL, simplify = FALSE)
##     wd$MRData$RaceTable$Races[[1]]$Results[[1]]$Driver$driverId
## }
```


We see how in the construction of the URL we pass the position number (**1**.json). To generalise this function, we might try something of the form:


```r
racePosition = function(year, raceNum, racePos) {
    wURL = paste(API_PATH, year, "/", raceNum, "/results/", racePos, ".json", 
        sep = "")
    wd = fromJSON(wURL, simplify = FALSE)
    wd$MRData$RaceTable$Races[[1]]$Results[[1]]$Driver$driverId
}

racePosition(2014, 2, 3)
```

```
## [1] "vettel"
```


As and when you develop new fragments of R code, it often makes sense to wrap them up into a function to make the code easier to reuse. By adding *paramaters* to a function, you can write create *general* functions that return *specific* results dependent on the parameters you pass into them. For data analysis, we often want to write very small pieces of code, or particular functions, that do very specific things, rather than writing large very large software programmes. Writing small code fragments in this way, and embedding them in explanatory or discursive text, is an approach referred to as *literate programming*. Perhaps  we need to start to think of programming-as-coding as more to do with writing short haikus than long epics?! 

If you compare the two functions above, you will see how they resemble each other almost completely. By learning to *read* code functions, you can often recognise bits that can be modified to create new functions, or more generalised ones. We have taken the latter approach in the above case, replacing a specific character in the first function with a parameter in the second. (That is, we have further *parameterised* the original function.)

### Indexing in to a dataframe

Another approach to finding the position of a particular individual is by indexing into the results dataframe.


```r
results.df[results.df$pos == 1, c("driverId")]
```

```
## [1] hamilton
## 22 Levels: vettel ricciardo chilton rosberg raikkonen ... sutil
```


*Don't worry about the reporting of the other factor levels. If we call on the particular result, only the request value is returned, as in this example: **hamilton**.*

The `lapsData.df()` function returns laptime data for each driver during a particular race.


```r
laps.df = lapsData.df(2014, 2)
kable(head(laps.df), format = "markdown")
```

```
## Error: invalid 'times' value
```


Note that the `cuml` and `diff` columns are not returned by the ergast API - I have generated them by ordering the laps for each driver by increasing lap number and then calculating the cumulative live time and the difference between consecutive lap times for each driver separately. *We will see how to do this in a later section.*

### Merging dataframes in R

As you might imagine, one of the very powerful tools we have to hand when working in R is the ability to merge two dataframes, in whole or in part.

We can *merge* data from two different tables if they each contain a column whose unique values match each other. For example, the `results.df` dataframe contains a column `driverId` that contains a unique ID for each driver (*hamiliton*, *vettel*, and so on). The `driverId` column in the `drivers.df` datafram pulls from the same set of values, and contains additional information about each driver. If we want to augment `results.df` with an additional column that contains the three letter driver code for each driver, we can do that using the R `merge()` function, assigning the result back to `results.df`.


```r
# We can pull just the columns we want from drivers.df We want all rows from
# drivers.df, but just the 'driverId' and 'code' columns
kable(head(drivers.df[, c("driverId", "code")]), format = "markdown")
```

```
## |id         |driverId       |code  |
## |:----------|:--------------|:-----|
## |driverId   |alonso         |ALO   |
## |driverId1  |jules_bianchi  |BIA   |
## |driverId2  |bottas         |BOT   |
## |driverId3  |button         |BUT   |
## |driverId4  |chilton        |CHI   |
## |driverId5  |ericsson       |ERI   |
```


To merge the dataframes, we specify which dataframes we wish to merge and the column on which to merge. The *order* in which we identify the dataframes is important because there are actually several different sorts of merge possible that take into account what to do if the the merge column in the first table contains a slightly different set of unique values than does the merge column in the second table. *We will review the consequences of non-matching merge column values in a later section.*


```r
results.df = merge(results.df, drivers.df[, c("driverId", "code")], by = "driverId")
kable(head(results.df, n = 3), format = "markdown")
```

```
## |driverId  |  carNum|  pos|constructorId  |  grid|  laps|status    |  fastlapnum|  fastlaptime|  fastlaprank|code  |
## |:---------|-------:|----:|:--------------|-----:|-----:|:---------|-----------:|------------:|------------:|:-----|
## |alonso    |      14|    4|ferrari        |     4|    56|Finished  |          47|        104.2|            3|ALO   |
## |bottas    |      77|    8|williams       |    18|    56|Finished  |          31|        105.5|            9|BOT   |
## |button    |      22|    6|mclaren        |    10|    56|Finished  |          47|        106.0|           11|BUT   |
```


If the columns you want to merge on actually have *different* names, they can by specified explicitly. The first dataframe is referred to as the *x* datframe and the second one as the *y* dataframe; their merge columns names are then declared explicitly:


```r
# 
driverIds.df = drivers.df[, c("driverId", "code")]
laps.df = merge(laps.df, driverIds.df, by.x = "driverId", by.y = "driverId")
kable(head(laps.df, n = 3), format = "markdown")
```

```
## Error: invalid 'times' value
```


## Accessing SQLite from R

As well as being made available over the web via a JSON API, Chris Newell also releases the data as a MySQL database export file at the end of each season. 

If you want to use F1 data as a context for learning how to write atabase queries using SQL, one of the most popular and widely used database query languages, then this download is probably for you...

MySQL is a poweful database that is arguably overkill for our purposes here, but there is another database we can draw on that is quick and easy to use - once we get the data into the right format for it: [SQLite](http://www.sqlite.org/). *For an example of how to generate a SQLite version of the database from the MySQL export, see the appendix.*

*Unfortunately, the recipe I use to generate a SQLite version of the database requires MySQL during the transformation step, which begs the question of why I donlt just connect R to MySQL. My reasoning is to try to use lightweight database tools where possible, and sqlite offers just such a solution: no database management system is required, just the sqlite database file and a SQLite library to query into it. On the to do list is a virtual machine (VM) for this book that includes all the tools introduced in this book, including RStudio and MySQL as well as all the required libraries, packages, datasets and scrapers for generatibng your own datasets.*

We can access a SQLite database from R using the [RSQLite package](http://cran.r-project.org/web/packages/RSQLite/index.html) 

```r
require(RSQLite)

con_ergastdb = dbConnect(drv = "SQLite", dbname = "./ergastdb13.sqlite")
tbs = dbGetQuery(con_ergastdb, "SELECT name FROM sqlite_master WHERE type = \"table\"")
```


Let's see what the tables are:

|name                  |
|:---------------------|
|circuits              |
|constructorResults    |
|constructorStandings  |
|constructors          |
|driverStandings       |
|drivers               |
|lapTimes              |
|pitStops              |
|qualifying            |
|races                 |
|results               |
|seasons               |
|status                |


If we're feeling adventurous, we could load the whole of the ergast database into memory as a set of R dataframes, one per database table, in a single routine. The dataframes take the name of the corresponding table in the database.



```r
## list all tables
tables <- dbListTables(con_ergastdb)

## exclude sqlite_sequence (contains table information)
tables <- tables[tables != "sqlite_sequence"]

lDataFrames <- vector("list", length = length(tables))

for (i in seq(along = tables)) {
    assign(tables[i], dbGetQuery(conn = con_ergastdb, statement = paste("SELECT * FROM '", 
        tables[[i]], "'", sep = "")))
}
```


This is the sort of data we can find in the *circuits* table (there is also a column, *nor shown*, that contains a link to the wikipedia page for the circuit. It may be possible to use this to automate a route for pulling in a circuit map from Wikipedia or DBpedia):


```r
kable(head(circuits[, 1:7], n = 5), format = "markdown")
```

|  circuitId|circuitRef   |name                            |location      |country    |      lat|      lng|
|----------:|:------------|:-------------------------------|:-------------|:----------|--------:|--------:|
|          1|albert_park  |Albert Park Grand Prix Circuit  |Melbourne     |Australia  |  -37.850|  144.968|
|          2|sepang       |Sepang International Circuit    |Kuala Lumpur  |Malaysia   |    2.761|  101.738|
|          3|bahrain      |Bahrain International Circuit   |Sakhir        |Bahrain    |   26.032|   50.511|
|          4|catalunya    |Circuit de Catalunya            |Montmeló      |Spain      |   41.570|    2.261|
|          5|istanbul     |Istanbul Park                   |Istanbul      |Turkey     |   40.952|   29.405|


Here's an example of the *constructorResults*:

|  constructorResultsId|  raceId|  constructorId|  points|
|---------------------:|-------:|--------------:|-------:|
|                     1|      18|              1|      14|
|                     2|      18|              2|       8|
|                     3|      18|              3|       9|
|                     4|      18|              4|       5|
|                     5|      18|              5|       2|


In an off itself this is not very interesting - we would probably need to blend this data with a meaninful explanation of the *constructorId* and/or *raceId*:

The *constructorStandings* also give information keyed by the *constructorId* and *raceId*:

|  constructorStandingsId|  raceId|  constructorId|  points|  position|positionText  |  wins|
|-----------------------:|-------:|--------------:|-------:|---------:|:-------------|-----:|
|                       1|      18|              1|      14|         1|1             |     1|
|                       2|      18|              2|       8|         3|3             |     0|
|                       3|      18|              3|       9|         2|2             |     0|
|                       4|      18|              4|       5|         4|4             |     0|
|                       5|      18|              5|       2|         5|5             |     0|


The *constructors* table provides descriptive information about each team. (Note, there is also a column (not shown) that gives the URL for the team's Wikipedia page.):

|  constructorId|constructorRef  |name        |nationality  |
|--------------:|:---------------|:-----------|:------------|
|              1|mclaren         |McLaren     |British      |
|              2|bmw_sauber      |BMW Sauber  |German       |
|              3|williams        |Williams    |British      |
|              4|renault         |Renault     |French       |
|              5|toro_rosso      |Toro Rosso  |Italian      |


The *driverStandings* table identifies the standing (in a particular championship year?) for each driver after each race. It is keyed by *raceId* and *driverId*:

|  driverStandingsId|  raceId|  driverId|  points|  position|positionText  |  wins|
|------------------:|-------:|---------:|-------:|---------:|:-------------|-----:|
|                  1|      18|         1|      10|         1|1             |     1|
|                  2|      18|         2|       8|         2|2             |     0|
|                  3|      18|         3|       6|         3|3             |     0|
|                  4|      18|         4|       5|         4|4             |     0|
|                  5|      18|         5|       4|         5|5             |     0|


The *drivers* table gives some descriptive information about each driver. Again, there is an additional column (not shown) that contains a link to the driver's Wikipedia page. The three letter code column is particulalry useful as it provides us with a short, recognisable label by means of which we can refer to each driver on many of the charts we'll be producing.

|  driverId|driverRef   |code  |forename  |surname     |dob         |nationality  |
|---------:|:-----------|:-----|:---------|:-----------|:-----------|:------------|
|         1|hamilton    |HAM   |Lewis     |Hamilton    |1985-01-07  |British      |
|         2|heidfeld    |HEI   |Nick      |Heidfeld    |1977-05-10  |German       |
|         3|rosberg     |ROS   |Nico      |Rosberg     |1985-06-27  |German       |
|         4|alonso      |ALO   |Fernando  |Alonso      |1981-07-29  |Spanish      |
|         5|kovalainen  |KOV   |Heikki    |Kovalainen  |1981-10-19  |Finnish      |


The *lapTimes* table is one that we shall pull data from extensively. Keyed by *raceId* and *driverId*, it gives the position of the driver at the end of each lap in a race, along with the laptime for that lap in the form *min*:*sec*.*millisec* as well as the laptime in milliseconds.

|  raceId|  driverId|  lap|  position|time      |  milliseconds|
|-------:|---------:|----:|---------:|:---------|-------------:|
|     841|        20|    1|         1|1:38.109  |         98109|
|     841|        20|    2|         1|1:33.006  |         93006|
|     841|        20|    3|         1|1:32.713  |         92713|
|     841|        20|    4|         1|1:32.803  |         92803|
|     841|        20|    5|         1|1:32.342  |         92342|


The *pitStops* table provides data about the duration of each individual pit stop. The duration is given in seconds/millisecods, as well as the total number of milliseconds. Note that the duration is essentially the sum of the stop time plus the pit loss time. ?What happens if a dirver gets a drive through penalty? Is the pit stop time the time the driver takes between enetering and leaving the pitlane? In whcih case, the pit stop times will also include penalties that involve driving through the pit lane, stop and go penalties, etc.

|  raceId|  driverId|  stop|  lap|time      |duration  |  milliseconds|
|-------:|---------:|-----:|----:|:---------|:---------|-------------:|
|     841|       153|     1|    1|17:05:23  |26.898    |         26898|
|     841|        30|     1|    1|17:05:52  |25.021    |         25021|
|     841|        17|     1|   11|17:20:48  |23.426    |         23426|
|     841|         4|     1|   12|17:22:34  |23.251    |         23251|
|     841|        13|     1|   13|17:24:10  |23.842    |         23842|


The *qualifying* table contains qualifying session times for each driver in each race, along with their position at the end of qualifying.

|  qualifyId|  raceId|  driverId|  constructorId|  number|  position|q1        |q2        |q3        |
|----------:|-------:|---------:|--------------:|-------:|---------:|:---------|:---------|:---------|
|          1|      18|         1|              1|      22|         1|1:26.572  |1:25.187  |1:26.714  |
|          2|      18|         9|              2|       4|         2|1:26.103  |1:25.315  |1:26.869  |
|          3|      18|         5|              1|      23|         3|1:25.664  |1:25.452  |1:27.079  |
|          4|      18|        13|              6|       2|         4|1:25.994  |1:25.691  |1:27.178  |
|          5|      18|         2|              2|       3|         5|1:25.960  |1:25.518  |1:27.236  |


The *races* table contains descriptive information about each actual race. (There is an additional column, not shown, that contains the URL for the Wikipedia page of the actual race):

|  raceId|  year|  round|  circuitId|name                   |date        |time      |
|-------:|-----:|------:|----------:|:----------------------|:-----------|:---------|
|       1|  2009|      1|          1|Australian Grand Prix  |2009-03-29  |06:00:00  |
|       2|  2009|      2|          2|Malaysian Grand Prix   |2009-04-05  |09:00:00  |
|       3|  2009|      3|         17|Chinese Grand Prix     |2009-04-19  |07:00:00  |
|       4|  2009|      4|          3|Bahrain Grand Prix     |2009-04-26  |12:00:00  |
|       5|  2009|      5|          4|Spanish Grand Prix     |2009-05-10  |12:00:00  |


The *results* table provides results data for each car in each race. (The *positionOrder* field is used for ranking drivers who are unclassified by virtue of not completing enough of the race distance.) LEt's split the table into two parts so we can see all the columns clearly:


|  resultId|  raceId|  driverId|  constructorId|  number|  grid|  position|positionText  |  positionOrder|
|---------:|-------:|---------:|--------------:|-------:|-----:|---------:|:-------------|--------------:|
|         1|      18|         1|              1|      22|     1|         1|1             |              1|
|         2|      18|         2|              2|       3|     5|         2|2             |              2|
|         3|      18|         3|              3|       7|     7|         3|3             |              3|
|         4|      18|         4|              4|       5|    11|         4|4             |              4|
|         5|      18|         5|              1|      23|     3|         5|5             |              5|

|  points|  laps|time         |  milliseconds|  fastestLap|  rank|fastestLapTime  |fastestLapSpeed  |  statusId|
|-------:|-----:|:------------|-------------:|-----------:|-----:|:---------------|:----------------|---------:|
|      10|    58|1:34:50.616  |       5690616|          39|     2|1:27.452        |218.300          |         1|
|       8|    58|+5.478       |       5696094|          41|     3|1:27.739        |217.586          |         1|
|       6|    58|+8.163       |       5698779|          41|     5|1:28.090        |216.719          |         1|
|       5|    58|+17.181      |       5707797|          58|     7|1:28.603        |215.464          |         1|
|       4|    58|+18.014      |       5708630|          43|     1|1:27.418        |218.385          |         1|


The *seasons* table provides a link to the Wkipedia page for each season:

|  year|url                                                   |
|-----:|:-----------------------------------------------------|
|  2009|http://en.wikipedia.org/wiki/2009_Formula_One_season  |
|  2008|http://en.wikipedia.org/wiki/2008_Formula_One_season  |
|  2007|http://en.wikipedia.org/wiki/2007_Formula_One_season  |
|  2006|http://en.wikipedia.org/wiki/2006_Formula_One_season  |
|  2005|http://en.wikipedia.org/wiki/2005_Formula_One_season  |


The *status* table gives a natural langiage description of each status code:

|  statusId|status        |
|---------:|:-------------|
|         1|Finished      |
|         2|Disqualified  |
|         3|Accident      |
|         4|Collision     |
|         5|Engine        |


## Asking Questions of the ergast Data

As you may have noticed, the data we can get from the ergast API comes in a form that we can make sense of immediately. For example, if we get the results of a particular race, we can see the name of the driver, the constructor name, the status at the end of the race, and so on. The full ergast API also supports queries that allow us to to view data based on just the results associated with a particular driver, year, constructor or circuit, for example, or even based on some combination of those things. *(The `ergastR-core.R` script does not yet contain a comprehensive wrapper for the ergast API. You are encouraged to add to the library and submit patches to it.)*

In the section introducing R dataframes, we saw how it is possible to run some simple "queries" on an R dataframe in order to select certain rows or columns. With access to our own copy of the ergast database, we might prefer to call on the full support of the SQL query language.

However, there is cost associated with making our own queries on a local copy of the ergast database versus calling the ergast API directly: the ergast API returns datasets that have been created by making queries over several ergast database data tables. In order to get a similar response from the database, we either need to run a query on the database that pulls results back from several tables that we have JOINed together ourselves i tge database query, or find a way of combining data that has been pulled from separate database requests into several separate dataframes.

### JOINing Tables Within SQLite Database Queries

If we want to find out the names of the drivers associated with the standings at the end of a particular race, we need to do several things:

* find the *raceId* for the race we are interested in from the *races* table
* get the standings associated with that race from the *driverStandings* table
* get the driver details for each driver from the *drivers* table

Let's see how to write those queries.


```r
dbGetQuery(con_ergastdb, "SELECT * FROM races WHERE year==2013 AND name==\"British Grand Prix\"")
```

```
##   raceId year round circuitId               name       date     time
## 1    887 2013     8         9 British Grand Prix 2013-06-30 12:00:00
##                                                    url
## 1 http://en.wikipedia.org/wiki/2013_British_Grand_Prix
```


What we want to do is get the driver standings at the end of this race. If we just had the *raceId* we could get the standings with the following sort of query:


```r
dbGetQuery(con_ergastdb, "SELECT * FROM driverStandings WHERE raceId=887")
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
dbGetQuery(con_ergastdb, "SELECT ds.driverId, ds.points, ds.position FROM driverStandings ds JOIN races r WHERE ds.raceId=r.raceId AND r.year=2013 AND r.name=\"British Grand Prix\"")
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


To pull in the driver names we need to do a further join with the *drivers* table:


```r
dbGetQuery(con_ergastdb, "SELECT d.surname, d.code, ds.points, ds.position FROM driverStandings ds JOIN races r JOIN drivers d WHERE ds.raceId=r.raceId AND r.year=2013 AND r.name=\"British Grand Prix\" AND d.driverId=ds.driverId")
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
dbGetQuery(con_ergastdb, "SELECT d.surname, d.code, ds.points, ds.position FROM driverStandings ds JOIN races r JOIN drivers d WHERE ds.raceId=r.raceId AND r.year=2013 AND r.name=\"British Grand Prix\" AND d.driverId=ds.driverId ORDER BY ds.position ASC LIMIT 3")
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
dbGetQuery(con_ergastdb, "SELECT COUNT(*) secondPlaceFinishes FROM results r JOIN drivers d WHERE d.code=\"ALO\" AND r.driverId=d.driverId AND r.position=2")
```

```
##   secondPlaceFinishes
## 1                  36
```


We can then go further - who are the top 5 drivers with the greatest number of podium (top 3) finishes, and how many?


```r
dbGetQuery(con_ergastdb, "SELECT d.code, d.surname, COUNT(*) podiumFinishes FROM results r JOIN drivers d WHERE r.driverId=d.driverId AND r.position>=1 AND r.position<=3 GROUP BY d.code, d.surname ORDER BY podiumFinishes DESC LIMIT 5")
```

```
##   code    surname podiumFinishes
## 1  MSC Schumacher            155
## 2 <NA>      Prost            106
## 3  ALO     Alonso             95
## 4 <NA>       Hill             94
## 5 <NA>      Senna             80
```


X> **Exercise**
X>
X> See if you can work out what queries can be used to generate some of the other results tables described on the [List of Formula One driver records](http://en.wikipedia.org/wiki/List_of_Formula_One_driver_records) Wikipedia page.


X> **Exercise**
X>
X> The ergast API offers several "high level" patterns for querying F1 results data via a URL that you can construct yourself. For example:
X> For example:
X>
X>
X>
X> Choose two or three of these rich data requests and see if you can create equivalent queries onto the ergast SQLite database. Check the results of running your query against the results returned from the ergast API.

### More Examples of Merging Dataframes in R

Here are some examples of merging dataframes pulled back from separate queries onto the ergast database.

For example, to find the names of the winners of the 2013 races, first we need to get the *raceId*s from the *races* table:


```r
raceIDs = races[races["year"] == "2013", 1:3]
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
# To trap the filter against returning NA results, we might use
# constructions such as: head(results[results['position']==1 &
# !is.na(results['position']),])

firstPositions = results[results["positionOrder"] == "1", ]
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
raceIDs = merge(raceIDs, firstPositions, by = "raceId")
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
raceIDs = merge(raceIDs, drivers, by = "driverId")
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
raceIDs = merge(raceIDs, constructors, by = "constructorId")
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
raceIDs = merge(raceIDs, races, by = "raceId")
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


Hopefully you get the idea?!

