# Chapter - Practice Sessions

Whilst the focus of a race weekend are rightly the Saturday qualifying session and the Sunday race, the practice sessions also provide a source of data that may help us identify which cars are likely to be competitive on any particular race weekend.

The ergast database does not contain any data relating to the practice sessions, but we can get a certain amount of information from the formulaOne.com results pages, as well as more detailed timing information from the FIA media centre.

//sidebar
The intelligentf1.com website provides a great example of how we can make use of lap time data from the race simulations that are typically carried out by each team in second practice. In particular, ??? uses the laptime data to calibrate a model that explores the relative competitiveness of each driver and give a feel for the relative tyre degradation rates experienced by each team.

Using the recipe described in Appendix ??, I have scraped the data from the Formula One website into a simple database. The database contains the following tables:


```r
library("RSQLite")
```

```
## Loading required package: DBI
```

```r
f1 = dbConnect(drv = "SQLite", dbname = "~/code/f1/f1timingData/f1djR/ergastdb/f1com_megascraper.sqlite")
dbListTables(f1)
```

```
##  [1] "p1Results"    "p1Sectors"    "p1Speeds"     "p2Results"   
##  [5] "p2Sectors"    "p2Speeds"     "p3Results"    "p3Sectors"   
##  [9] "p3Speeds"     "qualiResults" "qualiSectors" "qualiSpeeds" 
## [13] "raceFastlaps" "racePits"     "raceResults"
```


The structure of each of the practice tables are the same. The tables containing results from a practice session take the following form:


```r
kable(dbGetQuery(f1, ("SELECT * FROM p1Results LIMIT 5")))
```

```
## |team                     |laps  |driverNum  |year  |pos  |  natGap|race       |driverName          |   time|  gap|natTime   |
## |:------------------------|:-----|:----------|:-----|:----|-------:|:----------|:-------------------|------:|----:|:---------|
## |McLaren-Mercedes         |11    |3          |2012  |1    |       0|AUSTRALIA  |Jenson Button       |  87.56|    0|1:27.560  |
## |McLaren-Mercedes         |14    |4          |2012  |2    |       0|AUSTRALIA  |Lewis Hamilton      |  87.81|    0|1:27.805  |
## |Mercedes                 |17    |7          |2012  |3    |       0|AUSTRALIA  |Michael Schumacher  |  88.23|    0|1:28.235  |
## |Ferrari                  |21    |5          |2012  |4    |       0|AUSTRALIA  |Fernando Alonso     |  88.36|    0|1:28.360  |
## |Red Bull Racing-Renault  |21    |2          |2012  |5    |       0|AUSTRALIA  |Mark Webber         |  88.47|    0|1:28.467  |
```


The results in clude the name of each driver, their classification within that session, their team, the number of laps they completed, their best laptime as a natural time (using the format *minutes:seconds.milliseconds*) and as a time in seconds and milliseconds, and the gap to the best time in the session.

???need to mend the gap...

The data in the sectors table contains the sector number, the driver number, their position in the session classification, their name, and theit best recorded sector time in that session.


```r
kable(dbGetQuery(f1, ("SELECT * FROM p1Sectors LIMIT 5")))
```

```
## |  sector|driverNum  |pos  |race       |driverName          |year  |sectortime  |
## |-------:|:----------|:----|:----------|:-------------------|:-----|:-----------|
## |       1|3          |1    |AUSTRALIA  |Jenson Button       |2012  |29.184      |
## |       1|4          |2    |AUSTRALIA  |Lewis Hamilton      |2012  |29.190      |
## |       1|8          |3    |AUSTRALIA  |Nico Rosberg        |2012  |29.514      |
## |       1|7          |4    |AUSTRALIA  |Michael Schumacher  |2012  |29.583      |
## |       1|2          |5    |AUSTRALIA  |Mark Webber         |2012  |29.645      |
```


If we inspect the structure of the data, we see that not all the columns are typed as naturally as we might like:


```r
str(dbGetQuery(f1, ("SELECT * FROM p1Sectors LIMIT 5")))
```

```
## 'data.frame':	5 obs. of  7 variables:
##  $ sector    : int  1 1 1 1 1
##  $ driverNum : chr  "3" "4" "8" "7" ...
##  $ pos       : chr  "1" "2" "3" "4" ...
##  $ race      : chr  "AUSTRALIA" "AUSTRALIA" "AUSTRALIA" "AUSTRALIA" ...
##  $ driverName: chr  "Jenson Button" "Lewis Hamilton" "Nico Rosberg" "Michael Schumacher" ...
##  $ year      : chr  "2012" "2012" "2012" "2012" ...
##  $ sectortime: chr  "29.184" "29.190" "29.514" "29.583" ...
```


To correct this we need to cast the column types explicitly:


```r
p1sectors = dbGetQuery(f1, ("SELECT * FROM p1Sectors"))
p1sectors$sectortime = as.double(p1sectors$sectortime)
str(p1sectors)
```

```
## 'data.frame':	8633 obs. of  7 variables:
##  $ sector    : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ driverNum : chr  "3" "4" "8" "7" ...
##  $ pos       : chr  "1" "2" "3" "4" ...
##  $ race      : chr  "AUSTRALIA" "AUSTRALIA" "AUSTRALIA" "AUSTRALIA" ...
##  $ driverName: chr  "Jenson Button" "Lewis Hamilton" "Nico Rosberg" "Michael Schumacher" ...
##  $ year      : chr  "2012" "2012" "2012" "2012" ...
##  $ sectortime: num  29.2 29.2 29.5 29.6 29.6 ...
```


Using the individual sector times, we can calculate the ultimate lap for each driver as the sum of their best sector times.

To do this we need to generate the sum of the sector times recorded for each driver in each race of each year.

In pseudo-code, we might imagine a recipe for achieving this sort of operation taking the form:

`for each year:
  for each race:
    for each driver:
      calculate the sum of the dirver's sector times`


An alternative way to each a similar task is to adopt a *split-apply-combine* strategy. Using the `plyr` library, we can call on a particular function, `ddply`, that allows us to split a data frame into groups based on the values of one or more columns, and then perform a summarising operation across the members of each grouping.

In this case, we need to split the data into groups corresponding to the data rows associated with each particular driver in each particular race of each year. This should result in three rows for each group, one row for each of the three sectors. The summarising operation we then need to perform is to calculate the sum of the sector times in each grouping.


```r
library(plyr)
ultimate = function(d) {
    ddply(d, c("year", "race", "driverName"), summarise, ultimate = sum(sectortime, 
        na.rm = T))
}
ult = ultimate(p1sectors)
kable(head(ult))
```

```
## |year  |race       |driverName         |  ultimate|
## |:-----|:----------|:------------------|---------:|
## |2006  |AUSTRALIA  |Alexander Wurz     |     89.06|
## |2006  |AUSTRALIA  |Anthony Davidson   |     87.89|
## |2006  |AUSTRALIA  |Christian Klien    |     89.60|
## |2006  |AUSTRALIA  |Christijan Albers  |     90.94|
## |2006  |AUSTRALIA  |David Coulthard    |     89.37|
## |2006  |AUSTRALIA  |Felipe Massa       |     88.89|
```


We can compare the ultimate laptimes for each driver in a session to the best laptime they recorded in the session.

Let's just check the data we can pull in from the session results tables:


```r
p1results = dbGetQuery(f1, ("SELECT * FROM p1Results"))
p1results$laps = as.integer(p1results$laps)
str(p1results)
```

```
## 'data.frame':	2986 obs. of  11 variables:
##  $ team      : chr  "McLaren-Mercedes" "McLaren-Mercedes" "Mercedes" "Ferrari" ...
##  $ laps      : int  11 14 17 21 21 22 23 16 8 26 ...
##  $ driverNum : chr  "3" "4" "7" "5" ...
##  $ year      : chr  "2012" "2012" "2012" "2012" ...
##  $ pos       : chr  "1" "2" "3" "4" ...
##  $ natGap    : int  0 0 0 0 0 1 1 1 2 2 ...
##  $ race      : chr  "AUSTRALIA" "AUSTRALIA" "AUSTRALIA" "AUSTRALIA" ...
##  $ driverName: chr  "Jenson Button" "Lewis Hamilton" "Michael Schumacher" "Fernando Alonso" ...
##  $ time      : num  87.6 87.8 88.2 88.4 88.5 ...
##  $ gap       : int  0 0 0 0 0 1 1 1 2 2 ...
##  $ natTime   : chr  "1:27.560" "1:27.805" "1:28.235" "1:28.360" ...
```


One way of comparing the ultimate lap time with actual laptime for each driver in a particular race is to plot the result on to a two dimensional scatterplot. The easiest way to plot this is from a dataframe that contains the data corresponding to the ultimate lap time in one column and the actual laptime in another.

At the moment, we have the data in two separate tables, *ult* and *p1results*. We can merge the data into a single dataframe using the *year*, *race* and *driverName* columns as merge keys:


```r
p1results_merge = merge(p1results, ult, by = c("year", "race", "driverName"))
kable(head(p1results, n = 5))
```

```
## |team                     |  laps|driverNum  |year  |pos  |  natGap|race       |driverName          |   time|  gap|natTime   |
## |:------------------------|-----:|:----------|:-----|:----|-------:|:----------|:-------------------|------:|----:|:---------|
## |McLaren-Mercedes         |    11|3          |2012  |1    |       0|AUSTRALIA  |Jenson Button       |  87.56|    0|1:27.560  |
## |McLaren-Mercedes         |    14|4          |2012  |2    |       0|AUSTRALIA  |Lewis Hamilton      |  87.81|    0|1:27.805  |
## |Mercedes                 |    17|7          |2012  |3    |       0|AUSTRALIA  |Michael Schumacher  |  88.23|    0|1:28.235  |
## |Ferrari                  |    21|5          |2012  |4    |       0|AUSTRALIA  |Fernando Alonso     |  88.36|    0|1:28.360  |
## |Red Bull Racing-Renault  |    21|2          |2012  |5    |       0|AUSTRALIA  |Mark Webber         |  88.47|    0|1:28.467  |
```


We can then plot directly from the merged dataset. Let's take a subset of the data, focussing on the 2012 Australian Grand Prix:


```r
library(ggplot2)
gp_2012_aus_p1_results = subset(p1results_merge, year == "2012" & race == "AUSTRALIA")
ggplot(gp_2012_aus_p1_results) + geom_point(aes(x = time, y = ultimate))
```

![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9.png) 


So what's wrong with this chart? Two things immediately come to mind. Firstly, there is an outlier: one of the drivers appears not to have a session time recorded. Unfortunately, which don't know which driver this time occurs for, which leads to the second problem: which point corresponds to which driver? 

One way of addressing the outlier problem is to filter out drivers for whom no time is recorded in the session (if they do record a time, they will also necessarily have separate sector times, and hence an ultimate laptime, recorded). We can also check that the time is not recorded as absent, that is, as `NA`.


```r
gp_2012_aus_p1_results = subset(gp_2012_aus_p1_results, time > 0 & !is.na(time))
```


To address the other issue, that of not knowing which driver each point refers to, we can instead use a text plot. This requires using an extra aesthetic parameter, `label`, that identifies which column's values should be displayed as the text label for each plotted marker.


```r
ggplot(gp_2012_aus_p1_results) + geom_text(aes(x = time, y = ultimate, label = driverName))
```

![plot of chunk unnamed-chunk-11](figure/unnamed-chunk-11.png) 


This chart suggests that the ultimate times broadly follow the session times, which makes sense. However, it's virtually impossible to tell whether a driver's session time matched their ultimate time, or whether it was some way away from it. Several factors contribute to this lack of clarity:

* we can't tell what is being used as the registration point for each label - that is, which part of the label marks the `(time, ultimate)` co-ordinates.
* the length of the labels covers a wide range. If the registration point is the mid-point of the label, where is that exactly?
* the font size used for the labels is quite large, meaning that labels obscure each other;
* the name labels have overflowed the plotting area;
* some of the labels appear to fall outside the area displayed by the chart, making them difficult to read;
* it's hard to tell where the line corresponding to equal ultimate and session laptimes lies. The grid is probably too coarse grained to be able to take accurate measurements for each marker, even if we could tell where the registration point is.

Let's work through the problems one at a time. ggplot supports layering in plots, with the layer order determined by the order in which layers are added to the plot. ??By default?? The first layer is the lowest layer, the last layer the highest. We can mark the registration point using a `geom_point()` layer.

Let's add the point *underneath* the corresponding label, which means adding the `geom_point()` to a lower level than the `geom_text()` by adding it to the ggplot chart *before* the `geom_text()`.

Whilst we could identify the values to be used as *x* and *y* aesthetics in each layer, we can also declare them in the base ploy and allow their values to be inherited by the chart layers

We can also assign the plot to a variable, and build it up a layer at a time, before plotting the final compound chart.


```r
g = ggplot(gp_2012_aus_p1_results, aes(x = time, y = ultimate))

# Add the points layer
g = g + geom_point()

# Add the text layer on top of the chart
g = g + geom_text(aes(label = driverName))

# Plot the chart
g
```

![plot of chunk unnamed-chunk-12](figure/unnamed-chunk-12.png) 




```r
g = g + geom_abline(col = "grey")
g
```

![plot of chunk unnamed-chunk-13](figure/unnamed-chunk-13.png) 


??rankings of the session laptime and ultimate laptime

radar chart showing team ranking for each sector
http://stackoverflow.com/questions/9614433/creating-radar-chart-a-k-a-star-plot-spider-plot-using-ggplot2-in-r


We can also generate a range of other reference laptimes, such as:

* the best overall session laptime;
* the best overall session laptime in a team;
* the best ulimate lap in a team;
* the ultimate lap for a team (based on the best recorded sector times across a team);
* the ultimate ultimate lap, based on the best sector times recorded across all drivers.






