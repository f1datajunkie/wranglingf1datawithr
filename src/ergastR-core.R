#The list of packages to be loaded
list.of.packages <- c("RJSONIO","plyr")

#You should be able to simply reuse the following lines of code as is
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages,function(x){library(x,character.only=TRUE)})

#Helper functions

#' Convert a string to a numeric
#' 
#' \code{getNum}
#' @param object item to be converted to a numeric
#' @return string or factor cast as numeric
getNum=function(x){as.numeric(as.character(x))}

#' Test whether a driver code exists and if so, return it
#' 
#' \code{driverCodeExists}
#' @param list item that may or may not contain a code sublist
#' @return driver code
driverCodeExists=function(x) {if (is.null(x$code)) return('') else return(x$code)}

#' Generate time in seconds from min:seconds format
#' 
#' \code{timeInS}
#' @param string time in format minutes:seconds
#' @return time in seconds as numeric
timeInS=function(tStr){
  if (is.na(tStr)) tS=NA
  else {
    x=unlist(strsplit(tStr,':'))
    if (length(x)==1) tS=getNum(x[1])
    else if (length(x)==2) tS=60*getNum(x[1])+getNum(x[2])
    else if (length(x)==3) tS=3600*getNum(x[1])+60*getNum(x[2])+getNum(x[3])
    else tS=NA

  }
  tS
}


#My cacheing attempt is broken
#messing up scope somewhere?
#race.cache=list()

##==========  URL BUILDERS

API_PATH="http://ergast.com/api/f1/"
#API_PATH="http://ergast.com/api/fe/"

#?include a format adder function?

#' Get URL for races by year
#' 
#' \code{getRacesDataByYear.URL}
#' @param integer season year for required data
#' @param character data format (json, XML)
#' @return a URL
getRacesDataByYear.URL=function(year,format='json'){
  #Need additional callback parameter and handler if accept jsonp
  paste(API_PATH,year,".",format,sep='')
}

#' Get URL for pits by race-and-year
#' 
#' \code{getPitsByYearRace.URL}
#' @param integer season year 
#' @param integer race number in year
#' @param character data format (json, XML)
#' @return a URL
getPitsByYearRace.URL=function(year,raceNum,format='json'){
  paste(API_PATH,year,"/",raceNum,"/pitstops.",format,"?limit=1000",sep='')
}

#' Get URL for laps by race-and-year
#' 
#' \code{getLapsByYearRace.URL}
#' @param integer season year 
#' @param integer race number in year
#' @param character data format (json, XML)
#' @return a URL
getLapsByYearRace.URL=function(year,raceNum,format='json',offset=0){
  paste(API_PATH,year,"/",raceNum,"/laps.",format,"?limit=1000","&offset=",offset,sep='')
}

#' Get URL for laps by race-and-year-and-driver
#' 
#' \code{getLapsByYearRaceDriver.URL}
#' @param integer season year 
#' @param integer race number in year
#' @param character driver
#' @param character data format (json, XML)
#' @return a URL
getLapsByYearRaceDriver.URL =function(year,raceNum,driverId,format='json'){
  paste(API_PATH,year,"/",raceNum,"/drivers/",driverId,"/laps.",format,"?limit=1000",sep='')
}

#' Get URL for qualifying
#' 
#' \code{getQuali.URL}
#' @param integer season year
#' @param integer race number in year
#' @param character driverRef
#' @param character data format (json, XML)
#' @return a URL
getQuali.URL =function(year=NA,raceNum=NA,driverRef=NA,constructorRef=NA,format='json'){
  url=paste(API_PATH,sep='')
  if (!is.na(year)) {
    url=paste(url,year,'/',sep='')
    if (!is.na(raceNum)) url=paste(url,raceNum,'/',sep='')
  }
  if (!is.na(driverRef)) url=paste(url,'drivers/',driverRef,'/',sep='')
  if (!is.na(constructorRef)) url=paste(url,'constructors/',constructorRef,'/',sep='')
  url=paste(url,"qualifying.",format,"?limit=2500",sep='')
  url
}

#' Get URL for results by race-and-year
#' 
#' \code{getRaceResultsByYearRace.URL}
#' @param integer season year 
#' @param integer race number in year
#' @param character data format (json, XML)
#' @return a URL
getRaceResultsByYearRace.URL=function(year,raceNum,format="json"){
  paste(API_PATH,year,"/",raceNum,"/results.",format,"?limit=2500",sep='')
}

#' Get URL for results by race-and-year
#' 
#' \code{getDriversByYear.URL}
#' @param integer season year
#' @param character data format (json, XML)
#' @return a URL
getDriversByYear.URL=function(year,format='json'){
  paste(API_PATH,year,"/drivers.",format,"?limit=2500",sep='')
}

#' Get URL for results by year and driver
#' 
#' \code{getDriverResultsByYear.URL}
#' @param integer season year
#' @param character driverRef
#' @param character data format (json, XML)
#' @return a URL
getDriverResultsByYear.URL=function(year,driverRef=NA,format='json'){
  url=paste(API_PATH,year,'/',sep='')
  if (!is.na(driverRef)) url=paste(url,"drivers/",driverRef,'/',sep='')
  url=paste(url,"results.",format,"?limit=2500",sep='')
  url
}

##==========  URL BUILDERS END

##==========  JSON GRABBERS

#' Get JSON data
#' 
#' \code{getJSONbyURL}
#' @param character URL for data request
#' @return JSON data from ergast API
getJSONbyURL=function(URL){
  #Don't abuse the ergast API
  Sys.sleep(0.25)
  
  fromJSON(URL,simplify=FALSE)
}

##==========  JSON GRABBERS END

##==========  JSON PARSERS

#' Format laps data
#' 
#' \code{formatLapData}
#' @param object containing laps data
#' @return dataframe containing laps data
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
  
  #lap.data=ddply(lap.data,.(driverId),transform,decmin=rawtime-min(rawtime))
  #lap.data$topdelta=lap.data$rawtime-min(lap.data$rawtime)
  lap.data
}

#' Extract Laps data from race data JSON object
#' 
#' \code{getLapsData.path}
#' @param object containg race data
#' @return object containing laps data
getLapsData.path=function(rd.laps){
  laps.data=rd.laps$MRData$RaceTable$Races[[1]]$Laps
  laps.data
}

#' Generate dataframe containing lap data for a given race
#' 
#' \code{lapsData.df}
#' @param integer season year for required data
#' @param integer round number for required data
#' @param character data format (json, XML)
#' @return dataframe containing lap data for a specific race
lapsData.df=function(year,raceNum,format='json'){
  rd.laps=getJSONbyURL(getLapsByYearRace.URL(year,raceNum))
  ld=getLapsData.path(rd.laps)
  tmp=formatLapData(ld)
  if (as.integer(rd.laps$MRData$total)>1000){
    rd.laps=getJSONbyURL(getLapsByYearRace.URL(year,raceNum,offset=1000))
    ld=c(ld,getLapsData.path(rd.laps))
  }
  formatLapData(ld)
}

#' Generate dataframe containing lap data for a specified driver
#' 
#' \code{lapsDataDriver.df}
#' @param integer season year for required data
#' @param integer round number for required data
#' @param character driverId for specified driver
#' @param character data format (json, XML)
#' @return dataframe containing lap data for a specific race
lapsDataDriver.df=function(year,raceNum,driver,format='json'){
  rd.laps=getJSONbyURL(getLapsByYearRaceDriver.URL(year,raceNum,driver))
  ld=getLapsData.path(rd.laps)
  formatLapData(ld)
}


#' Extract and format pits data from JSON object
#' 
#' \code{formatPitsData}
#' @param object containg race data
#' @return object containing laps data
formatPitsData=function(rd.pits){
  pd <- rd.pits$MRData$RaceTable$Races[[1]]$PitStops
  pits.data <- data.frame(lap=numeric(),
                         driverID=character(),
                         stopnum=numeric(),
                         duration=numeric(), 
                         strtime=character(),rawtime=numeric(),
                         strduration=character(),rawduration=numeric(),
                         milliseconds=numeric(),
                         stringsAsFactors=FALSE)
  
  for (i in 1:length(pd)){
    pits.data=rbind(pits.data,data.frame(
      lap=getNum(pd[[i]]$lap),
      driverId=pd[[i]]$driverId,
      stopnum=as.integer(as.character(pd[[i]]$stop)),
      strtime=pd[[i]]$time, rawtime=timeInS(pd[[i]]$time),
      strduration=pd[[i]]$duration, rawduration=timeInS(pd[[i]]$duration),
      milliseconds=1000 * timeInS(pd[[i]]$duration)
    ))
  }
  pits.data
}

#' Generate dataframe containing pit data for a specified year and round
#' 
#' \code{pitsData.df}
#' @param integer season year for required data
#' @param integer round number for required data
#' @param character data format (json, XML)
#' @return dataframe containing lap data for a specific race
pitsData.df=function(year,raceNum,format='json'){
  rd.pits=getJSONbyURL(getPitsByYearRace.URL(year,raceNum))
  formatPitsData(rd.pits)
}

#' Get dataframe for races by year
#' 
#' \code{racesData.df}
#' @param integer season year for required data
#' @return dataframe containing race data for each year
racesData.df=function(year){
  races.data=data.frame(
    round=numeric(),
    racename=character(),
    circuitId=character()
  )
  rd=getJSONbyURL(getRacesDataByYear.URL(year))
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

#' Get dataframe for drivers by year
#' 
#' \code{driversData.df}
#' @param integer season year for required data
#' @return dataframe containing race data for each year
driversData.df=function(year){
  drivers.data=data.frame(
    name=character(),
    driverId=character()
  )
  drivers.json=fromJSON(getDriversByYear.URL(year))
  drivers=drivers.json$MRData$DriverTable$Drivers
  for (i in 1:length(drivers)){
    if (is.na(drivers[[i]]['permanentNumber'])) permNumber=NA
    else permNumber=drivers[[i]]['permanentNumber']
    
    drivers.data=rbind(drivers.data,data.frame(
      driverId=drivers[[i]]['driverId'],
      name=drivers[[i]]['familyName'],
      code=drivers[[i]]['code'],
      permNumber=permNumber
    ))
  }
  drivers.data
}


#' Parse dataframe containing qualifying results
#' 
#' \code{qualiResultsParse.df}
#' @parameter character url URL of the API call
#' @return dataframe containing qualifying results
qualiResultsParse.df=function(url){
  drj=getJSONbyURL(url)
  drdr=drj$MRData$RaceTable$Races
  
  quali.results.data=data.frame(
    season=numeric(),
    round=numeric(),
    driverId=character(),
    code=character(),
    constructorId=character(),
    position=numeric(),
    Q1=character(),
    Q2=character(),
    Q3=character(),
    Q1_time=numeric(),
    Q2_time=numeric(),
    Q3_time=numeric()
  )
    
  for (i in 1:length(drdr)){
    season=as.integer(drdr[[i]]$season)
    round=as.integer(drdr[[i]]$round)
    
    for (j in 1:length(drdr[[i]]$QualifyingResults)) {
      drd=drdr[[i]]$QualifyingResults[[j]]
      if ("Q1" %in% names(drd)) Q1=as.character(drd$Q1) else Q1=NA
      if ("Q2" %in% names(drd)) Q2=as.character(drd$Q2) else Q2=NA
      if ("Q3" %in% names(drd)) Q3=as.character(drd$Q3) else Q3=NA
      quali.results.data=rbind(quali.results.data,data.frame(
        driverId=as.character(drd$Driver$driverId),
        code=as.character(driverCodeExists(drd$Driver)),
        constructorId=as.character(drd$Constructor$constructorId),
        position=as.integer(drd$position),
        Q1=Q1,
        Q2=Q2,
        Q3=Q3,
        Q1_time=timeInS(Q1),
        Q2_time=timeInS(Q2),
        Q3_time=timeInS(Q3),
        season=season,
        round=round
      ))
    }
  }
  
  quali.results.data['Q1_rank']=rank(quali.results.data['Q1_time'],na.last='keep')
  quali.results.data['Q2_rank']=rank(quali.results.data['Q2_time'],na.last='keep')
  quali.results.data['Q3_rank']=rank(quali.results.data['Q3_time'],na.last='keep')
  
  quali.results.data
}

#' Parse dataframe containing qualifying results
#' 
#' \code{qualiResults.df}
#' @parameter character url URL of the API call
#' @return dataframe containing qualifying results
qualiResults.df=function(year=NA,raceNum=NA,driverRef=NA,constructorRef=NA,format='json'){
  url=getQuali.URL(year=year,
                   raceNum=raceNum,
                   driverRef=driverRef,
                   constructorRef=constructorRef,
                   format=format)
  qualiResultsParse.df(url)
}

#' Get dataframe containing results by driver
#' 
#' \code{driverResults.df}
#' @param integer season year
#' @param character driverRef reference code for specified driver
#' @return dataframe containing results data for a particular driver in a particular year
driverResults.df=function(year,driverRef=NA){
  drj=getJSONbyURL(getDriverResultsByYear.URL(year,driverRef))
  drdr=drj$MRData$RaceTable$Races
  
  driver.results.data=data.frame(
    driverId=character(),
    code=character(),
    constructorId=character(),
    grid=numeric(),
    laps=numeric(),
    position=numeric(),
    positionText=character(),
    points=numeric(),
    status=character(),
    season=numeric(),
    round=numeric()
  )
  
  for (i in 1:length(drdr)){
    season=as.integer(drdr[[i]]$season)
    round=as.integer(drdr[[i]]$round)
    drd=drdr[[i]]$Results[[1]]
    driver.results.data=rbind(driver.results.data,data.frame(
      driverId=as.character(drd$Driver$driverId),
      code=as.character(drd$Driver$code),
      constructorId=as.character(drd$Constructor$constructorId),
      grid=as.integer(drd$grid),
      laps=as.integer(drd$laps),
      position=as.integer(drd$position),
      positionText=as.character(drd$positionText),
      points=as.integer(drd$points),
      status=as.character(drd$status),
      season=season,
      round=round
    ))
  }
  
  driver.results.data
}

#' Get dataframe for races by year
#' 
#' \code{resultsData.df}
#' @param integer season year
#' @param integer race number in season
#' @return dataframe containing results data for a particular race
resultsData.df=function(year,raceNum){
  rrj=getJSONbyURL(getRaceResultsByYearRace.URL(year,raceNum))#getRaceResultsData.full(raceNum)
  rrd=rrj$MRData$RaceTable$Races[[1]]$Results
  
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

#' Get race winner by season and year
#' 
#' \code{raceWinner}
#' @param integer season year
#' @param integer race number
#' @return driverId for winner of a particular race
raceWinner=function(year,raceNum){
  dataPath=paste(year,raceNum,"results","1",sep='/')
  wURL=paste(API_PATH,dataPath,".json",sep='')
  
  wd=fromJSON(wURL,simplify=FALSE)
  wd$MRData$RaceTable$Races[[1]]$Results[[1]]$Driver$driverId
}

#' Parse JSON driver standings data
#' 
#' \code{_driverStandings.json.parse}
#' @param integer season year
#' @param integer race number
#' @return dataframe con
#' taining standings for each year, by race
ergast.json.parse.driverStandings.df=function(dURL){
  drj=getJSONbyURL(dURL)
  drd=drj$MRData$StandingsTable$StandingsLists
  driverStandings.data=data.frame()
  for (i in 1:length(drd)){
    for (j in 1:length(drd[[i]]$DriverStandings))
      driverStandings.data=rbind(driverStandings.data,data.frame(
        year=getNum(drd[[i]]$season),
        driverId=drd[[i]]$DriverStandings[[j]]$Driver$driverId,
        code=driverCodeExists(drd[[i]]$DriverStandings[[j]]$Driver),
        pos=getNum(drd[[i]]$DriverStandings[[j]]$position),
        points=getNum(drd[[i]]$DriverStandings[[j]]$points),
        wins=getNum(drd[[i]]$DriverStandings[[j]]$wins),
        car=drd[[i]]$DriverStandings[[j]]$Constructors[[1]]$constructorId)
      )
    
  }
  driverStandings.data
}


#' Get dataframe for season standings by year
#' 
#' \code{seasonStandings.df}
#' @param integer season year
#' @param integer race number
#' @return dataframe containing standings for each year, by race
seasonStandings=function(year,race=''){
  if (race=='')
    dURL= paste(API_PATH,year,'/driverStandings.json',sep='')
  else
    dURL= paste(API_PATH,year,'/',race,'/driverStandings.json',sep='')
  ergast.json.parse.driverStandings.df(dURL)
}

#' Get dataframe for individual driver standings by year
#' 
#' \code{driverCareerStandings.df}
#' @param character driverId
#' @return dataframe containing standings for each driver at the end of each year
driverCareerStandings.df=function(driverId){
  dURL=paste(API_PATH,'drivers/',driverId,'/driverStandings.json',sep='')
  ergast.json.parse.driverStandings.df(dURL)
}


#' Parse JSON driver standings data
#' 
#' \code{_constructorStandings.json.parse}
#' @param integer season year
#' @param integer race number
#' @return dataframe containing standings for each year, by race
ergast.json.parse.constructorStandings.df=function(dURL){
  drj=getJSONbyURL(dURL)
  drd=drj$MRData$StandingsTable$StandingsLists
  constructorStandings.data=data.frame()
  for (i in 1:length(drd)){
    constructorStandings=drd[[i]]$ConstructorStandings
    for (j in 1:length(constructorStandings)){
      constructorStanding=constructorStandings[[j]]
      constructorStandings.data=rbind(constructorStandings.data,data.frame(
        year=getNum(drd[[i]]$season),
        constructorId=constructorStanding$Constructor$constructorId,
        pos=getNum(constructorStanding$position),
        positionText=getNum(constructorStanding$positionText),
        points=getNum(constructorStanding$points),
        wins=getNum(constructorStanding$wins),
        name=constructorStanding$Constructor$name)
      )
    }
  }
  constructorStandings.data
}

#' Get dataframe for constructor final standings by year or race
#' 
#' \code{constructorStandings.df}
#' @param character constructorRef
#' @return dataframe containing standings for each driver at the end of each year
constructorStandings.df=function(year,race=''){
  if (race=='')
    dURL=paste(API_PATH,year,'/constructorStandings.json',sep='')
  else
    dURL= paste(API_PATH,year,'/',race,'/constructorStandings.json',sep='')
  
  ergast.json.parse.constructorStandings.df(dURL)
}

##==========  JSON PARSERS END



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
