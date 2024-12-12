library(DBI)
library(ggplot2)
library(plyr)

getLapPos=function(ergastdb,year,round){
  q=paste('SELECT driverRef, l.driverId AS driverId, d.code AS code, lap, position 
          FROM lapTimes l JOIN drivers d JOIN races r
          ON l.driverId=d.driverId AND l.raceId=r.raceId
          WHERE year=',year,' AND round="',round,'"',sep='')
  lapPos=dbGetQuery(ergastdb,q)
  #Set the driverRef to be a factor
  lapPos$driverRef=factor(lapPos$driverRef)
  lapPos
}

getResults=function(ergastdb,year,round){
  q=paste('SELECT driverRef, code, rs.driverId AS driverId, grid, position, laps, statusId 
          FROM results rs JOIN drivers d JOIN races r
          ON rs.driverId=d.driverId AND rs.raceId=r.raceId
          WHERE r.year=',year,' AND r.round="',round,'"',sep='')
  results=dbGetQuery(ergastdb,q)
  #Again, we want the driverRef to have factor levels
  #results$driverRef=factor(results$driverRef)
  status=dbGetQuery(ergastdb,'SELECT * FROM status')
  merge(results,status, by='statusId')
}

getPitStops=function(ergastdb,year,round){ 
  q=paste('SELECT driverRef, p.driverId AS driverId, d.code AS code, lap 
          FROM pitStops p JOIN drivers d JOIN races r
          ON p.driverId=d.driverId AND p.raceId=r.raceId
          WHERE r.year=',year,' AND r.round="',round,'"',sep='')
  pitStops=dbGetQuery(ergastdb,q)
  pitStops
}

getFullRacePos=function(lapPos,results){
  fullRacePos=lapPos[,c('driverRef','code','lap','position')]
  gridPos=results[,c('driverRef','code','grid')]
  gridPos$lap=-1
  names(gridPos)=c('driverRef','code','position','lap')
  #rbind can align the columns by name
  #The columns do not need to be presented in the same order
  fullRacePos=rbind(fullRacePos,gridPos)
  arrange(fullRacePos,code,lap)
}

lapCharter.chart=function(year,round){
  ergastdb =dbConnect(RSQLite::SQLite(), './ergastdb13.sqlite')
  
  results=getResults(ergastdb,year,round)
  lapPos= getLapPos(ergastdb,year,round) 
  
  fullRacePos=getFullRacePos(lapPos,results)
  
  pitStops=getPitStops(ergastdb,year,round)
  pitStops=merge(pitStops,
                 lapPos[,c("driverRef","code","lap","position")],
                 by=c("driverRef","code","lap"))
  
  results.status=subset(results,select=c('driverRef','status','laps'))
  lapPos.status=merge(lapPos,
                      results.status,
                      by.x=c('driverRef','lap'),
                      by.y=c('driverRef','laps'))
  
  g=ggplot(fullRacePos)
  g=g+geom_line(aes(x=lap,y=position,group=code,col=code))
  g=g+geom_vline(xintercept=0,colour='grey')
  g=g+geom_point(data=pitStops,aes(x=lap,y=position,colour=factor(code)),alpha=0.6)
  g=g+geom_text(data=subset(lapPos.status,status!='Finished'),
                aes(x=lap,y=position,label=status),
                size=3,
                angle=45,
                col='red', alpha=0.5)
  g
}