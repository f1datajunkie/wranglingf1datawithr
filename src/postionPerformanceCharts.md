
# Position Performance Charts


```r
library(DBI)
library(ggplot2)
ergastdb =dbConnect(RSQLite::SQLite(), './ergastdb13.sqlite')

#Find results for pairs of drivers in the same team and the same race
#At least one driver must score points
#r1 is placed ahead of r2 in terms of points haul
results=dbGetQuery(ergastdb,
                   'SELECT  year, constructorRef AS team,
                            r1.position AS r1pos,
                            r2.position AS r2pos, 
                            r1.points AS r1points, 
                            r2.points AS r2points, 
                            (r1.points+r2.points) AS points 
                   FROM results r1 JOIN results r2 JOIN races r JOIN constructors c 
                   WHERE r1.raceId=r2.raceId 
                        AND r1.constructorId=r2.constructorId 
                        AND c.constructorId=r2.constructorId 
                        AND r.raceId=r1.raceId 
                        AND r1.driverId!=r2.driverId 
                        AND r1.points>r2.points 
                        AND year >=2010')

points=c(25,18,15,12,10,8,6,4,2,1)

pos.points=data.frame(position=seq(10),
                      points=points,
                      maximiser.points=c(points[-1],0),
                      max.pts=points+c(points[-1],0))
```

```r
g=ggplot(results,aes(x=r1pos,y=r2pos,colour=year))
g=g+geom_jitter()
g=g+facet_wrap(~team)
#g=g+geom_line(data=pos.points,aes(x=points,y=maximiser.points),col='red')
#g=g+geom_line(data=teamPerformance,aes(x=pts,y=med_r2pts),col='magenta')
g=g+xlab('Position of higher classified member of team')
g+ylab('Position of lower classified member of team')
```

```
## Warning: Removed 12 rows containing missing values (geom_point).
```

```
## Warning: Removed 9 rows containing missing values (geom_point).
```

```
## Warning: Removed 11 rows containing missing values (geom_point).
```

```
## Warning: Removed 17 rows containing missing values (geom_point).
```

```
## Warning: Removed 17 rows containing missing values (geom_point).
```

```
## Warning: Removed 12 rows containing missing values (geom_point).
```

```
## Warning: Removed 8 rows containing missing values (geom_point).
```

```
## Warning: Removed 10 rows containing missing values (geom_point).
```

```
## Warning: Removed 8 rows containing missing values (geom_point).
```

```
## Warning: Removed 7 rows containing missing values (geom_point).
```

![](images/positionPerformance-unnamed-chunk-2-1.png) 

```r
g
```

```
## Warning: Removed 12 rows containing missing values (geom_point).
```

```
## Warning: Removed 9 rows containing missing values (geom_point).
```

```
## Warning: Removed 11 rows containing missing values (geom_point).
```

```
## Warning: Removed 17 rows containing missing values (geom_point).
```

```
## Warning: Removed 17 rows containing missing values (geom_point).
```

```
## Warning: Removed 12 rows containing missing values (geom_point).
```

```
## Warning: Removed 8 rows containing missing values (geom_point).
```

```
## Warning: Removed 10 rows containing missing values (geom_point).
```

```
## Warning: Removed 8 rows containing missing values (geom_point).
```

```
## Warning: Removed 7 rows containing missing values (geom_point).
```

![](images/positionPerformance-unnamed-chunk-2-2.png) 
