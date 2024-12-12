
# Race Summary Chart
Each of the charts used to sumamrise a race highlights different features of the race: race summary charts clearly identify the laps on which positions changed and race history charts show the relative time differencing between drivers as the race progresses.

The *race summary chart* is a new chart style I have been exploring that tries to summarise several key *position related* features of a race: the driver's position on the grid, at the end of the first lap, at the end of the race, and the amount of time driver spent in each position.

The Race Summary Chart is intended to provide an at glance summary of driver positions at notable parts of the race: on the grid, at the end of the first lap, at the end of the race. The range and density of race positions held throughout the race is also shown using a statistical graphics technique known as a a violin plot.


```r
library(RJSONIO)
library(plyr)
 
#racechart
 
#Helper functions
getNum=function(x){as.numeric(as.character(x))}
timeInS=function(tStr){
  x=unlist(strsplit(tStr,':'))
  tS=60*getNum(x[1])+getNum(x[2])
}
 
#ggplot chart helpers
xRot=function(g,s=5,lab=NULL) g+theme(axis.text.x=element_text(angle=-90,size=s))+xlab(lab)
 
 
#My cacheing attempt is broken
#messing up scope somewhere?
#race.cache=list()
 
##factorise this to pieces, just in case...?
#def get race URL
getLapsURL=function(raceNum){
  paste("http://ergast.com/api/f1/2012/",raceNum,"/laps.json?limit=2500",sep='')
}
 
getRaceResultsURL=function(raceNum){
  paste("http://ergast.com/api/f1/2012/",raceNum,"/results.json",sep='')
}
 
getDriversURL=function(year){
  paste("http://ergast.com/api/f1/",year,"/drivers.json",sep='')
}
 
getDriversData=function(year){
  drivers.data=data.frame(
    name=character(),
    driverId=character()
  )
  drivers.json=fromJSON(getDriversURL(year),simplify=FALSE)
  drivers=drivers.json$MRData$DriverTable$Drivers
  for (i in 1:length(drivers)){
    drivers.data=rbind(drivers.data,data.frame(
      driverId=drivers[[i]]$driverId,
      name=drivers[[i]]$familyName
    ))
  }
  drivers.data
}
 
getRacesData.full=function(year='2012'){
  racesURL=paste("http://ergast.com/api/f1/",year,".json",sep='')
  races.json=fromJSON(racesURL,simplify=FALSE)
  races.json
}
 
getRacesData=function(year){
  races.data=data.frame(
    round=numeric(),
    racename=character(),
    circuitId=character()
  )
  rd=getRacesData.full(year)
  races=rd$MRData$RaceTable$Races
  for (i in 1:length(races)){
    races.data=rbind(races.data,data.frame(
      round=races[[i]]$round,
      racename=races[[i]]$raceName,
      circuitId=races[[i]]$Circuit$circuitId
    ))
  }
  races.data
}
 
getRaceResultsData.full=function(raceNum){
  raceResultsURL=getRaceResultsURL(raceNum)
  raceResults.json=fromJSON(raceResultsURL,simplify=FALSE)
  raceResults.json
}
 
getLapsData.full=function(raceNum){
  print('grabbing data')
  lapsURL=getLapsURL(raceNum)
  laps.json=fromJSON(lapsURL,simplify=FALSE)
  laps.json
}
 
#getLapsData.full.cache=function(raceNum,race.cache=list()){
#  if (as.character(raceNum) %in% names( race.cache )){
#      print('using cache')
#      #laps.json=race.cache[as.character(raceNum)][[1]]
#  } else {
#    print('grabbing data')
#    laps.json=getLapsData.full(raceNum)
#    print('cacheing')
#    rn=as.character(raceNum)
#    race.cache[[rn]]=laps.json
#  }
#  race.cache
#}
 
getLapsData=function(rd){
  laps.data=rd$MRData$RaceTable$Races[[1]]$Laps
  laps.data
}
 
 
hack1=function(crap){
  if (length(crap$FastestLap)>0)
    getNum(crap$FastestLap$lap)
  else NA
}
hack2=function(crap){
  if (length(crap$FastestLap)>0)
    timeInS(crap$FastestLap$Time$time)
  else NA
}
hack3=function(crap){
  if (length(crap$FastestLap)>0)
    getNum(crap$FastestLap$rank)
  else NA
}
 
formatRaceResultsData=function(rrd){
  race.results.data=data.frame(
    carNum=numeric(),
    pos=numeric(),
    driverId=character(),
    constructorId=character(),
    grid=numeric(),
    laps=numeric(),
    status=character(),
    millitime=numeric(),
    fastlapnum=numeric(),
    fastlaptime=character(),
    fastlaprank=numeric()
    )
  
  for (i in 1:length(rrd)){
    race.results.data=rbind(race.results.data,data.frame(
      carNum=as.integer(as.character(rrd[[i]]$number)),
      pos=as.integer(as.character(rrd[[i]]$position)),
      driverId=rrd[[i]]$Driver$driverId,
      constructorId=rrd[[i]]$Constructor$constructorId,
      grid=as.integer(as.character(rrd[[i]]$grid)),
      laps=as.integer(as.character(rrd[[i]]$laps)),
      status=rrd[[i]]$status,
      #millitime=rrd[[i]]$Time$millis,
      fastlapnum=hack1(rrd[[i]]),
      fastlaptime=hack2(rrd[[i]]),
      fastlaprank=hack3(rrd[[i]])
    ))
  }
  race.results.data$driverId=reorder(race.results.data$driverId, race.results.data$carNum)
  race.results.data
}
 
getResults.df=function(raceNum){
  rrj=getRaceResultsData.full(raceNum)
  rrd=rrj$MRData$RaceTable$Races[[1]]$Results
  formatRaceResultsData(rrd)
}
 
getWinner=function(raceNum){
  wURL=paste("http://ergast.com/api/f1/2012/",raceNum,"/results/1.json",sep='')
  wd=fromJSON(wURL,simplify=FALSE)
  wd$MRData$RaceTable$Races[[1]]$Results[[1]]$Driver$driverId
}
 
formatLapData=function(rd){
  #initialise lapdata frame
  lap.data <- data.frame(lap=numeric(),
                       driverID=character(), 
                       position=numeric(), strtime=character(),rawtime=numeric(),
                       stringsAsFactors=FALSE)
 
  for (i in 1:length(rd)){
    lapNum=getNum(rd[[i]]$number)
    for (j in 1:length(rd[[i]]$Timings)){
      lap.data=rbind(lap.data,data.frame(
        lap=lapNum,
        driverId=rd[[i]]$Timings[[j]]$driverId,
        position=as.integer(as.character(rd[[i]]$Timings[[j]]$position)),
        strtime=rd[[i]]$Timings[[j]]$time,
        rawtime=timeInS(rd[[i]]$Timings[[j]]$time)
      ))
    }
  }
  
  lap.data=ddply(lap.data,.(driverId),transform,cuml=cumsum(rawtime))
  
  #via http://stackoverflow.com/a/7553300/454773
  lap.data$diff <- ave(lap.data$rawtime, lap.data$driverId, FUN = function(x) c(NA, diff(x)))
  
  lap.data=ddply(lap.data,.(driverId),transform,decmin=rawtime-min(rawtime))
  lap.data$topdelta=lap.data$rawtime-min(lap.data$rawtime)
  lap.data
}
 
getLapsdataframe=function(rd){
  ld=getLapsData(rd)
  laps.data=formatLapData(ld)
  laps.data
}
 
getLaps.df=function(raceNum){
  rd=getLapsData.full(raceNum)
  ld=getLapsData(rd)
  laps.data=formatLapData(ld)
  laps.data
}
 
df=getRacesData('2012')
```




```r
require(ggplot2)
```

```
## Loading required package: ggplot2
```

```r
racenum=4

driverN=getWinner(racenum)
laps.data=getLaps.df(racenum)
```

```
## [1] "grabbing data"
```

```r
driverNtimes=subset(laps.data,driverId==driverN,select=c('rawtime'))
winnerMean=colMeans(driverNtimes)
laps.data$raceHistory=winnerMean*laps.data$lap-laps.data$cuml
laps=laps.data

results=getResults.df(racenum) #results.data()

    
    #The first point is just a fudge to set driver order by driver number (factor order relates to results$driverId)
    ##results$driverId=reorder(results$driverId, results$carNum)
    #Also eg
    #results$driverId=reorder(results$driverId, results$pos)
    #or by grid classification
    results$driverId=reorder(results$driverId, results$grid)
    #Maybe set the order from a user control?
    
    g=ggplot(results)

    g=g+geom_point(aes(x=driverId, y=grid)) 
 
    g=g+geom_point(aes(x=driverId, y=grid),size=6, ,colour='lightblue') 
g=g+geom_jitter(data=laps,aes(x=driverId,y=position),col='grey',size=1,height=0)
    #g=g+geom_linerange(data=tt,aes(x=driverId,ymin=min,ymax=max))
    g=g+geom_violin(data=laps,aes(x=driverId,y=position))
    g=g+geom_point(data=subset(laps,lap==1),aes(x=driverId, y=position), pch=3, size=4)
    #If we add this in, is it too distracting?
    #g=g+geom_point(aes(x=driverId, y=grid),size=1, ,colour='lightblue')

    g=g+geom_point(aes(x=driverId, y=pos), col='red',size=2.5) + ylab("Position")
    g=xRot(g,8)
    g=g+labs(title="red = final pos, blue = grid, - = end lap 1, | = pos distribution")
    print(g)
```

![](images/ergastdata-unnamed-chunk-2-1.png) 

Here's an example of a race summary chart for ... 
