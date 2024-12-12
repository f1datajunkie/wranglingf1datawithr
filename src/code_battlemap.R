source('ergastR-core.R')

battlemap_encoder=function(lapTimes){
  lapTimes=rename(lapTimes, c("cuml"="acctime"))
  
  #Order the rows by accumulated lap time
  lapTimes=arrange(lapTimes,acctime)
  #This ordering need not necessarily respect the ordering by lap.
  
  #Flag the leader of a given lap - this will be the first row in new leader lap block
  lapTimes$leadlap= (lapTimes$position==1)
  
  #Calculate a rolling count of leader lap flags.
  #Recall that the cars are ordered by accumulated race time.
  #The accumulated count of leader flags is the lead lap number each driver is on.
  lapTimes$leadlap=cumsum(lapTimes$leadlap)
  lapTimes$lapsbehind=lapTimes$leadlap-lapTimes$lap 
  
  lapTimes=arrange(lapTimes,leadlap,acctime)
  lapTimes=ddply(lapTimes,.(leadlap),transform,
                 trackpos=1:length(position))
  
  #Order the drivers by lap and position
  lapTimes=arrange(lapTimes,lap,position)
  #Calculate the DIFF between each pair of consecutively placed cars at the end of each race lap
  #Then calculate the GAP to the leader as the sum of DIFF times
  lapTimes=ddply(lapTimes, .(lap), mutate,
                 diff=c(0,diff(acctime)),
                 gap=cumsum(diff)  )
  
  #Order the drivers by lap and reverse position
  lapTimes=arrange(lapTimes,lap, -position)
  #Calculate the DIFF between each pair of consecutively reverse placed cars at the end of each race lap
  lapTimes=ddply(lapTimes, .(lap), mutate,
                 chasediff=c(0,diff(acctime)) )
  
  
  lapTimes$tradgap=as.character(lapTimes$gap)
  lapsbehind=function(lap,leadlap,gap){
    if (lap==leadlap) return(gap)
    paste("LAP+",as.character(leadlap-lap),sep='')
  }
  
  lapTimes$tradgap=mapply(lapsbehind,lapTimes$lap,lapTimes$leadlap,lapTimes$gap)
  
  
  #http://en.wikipedia.org/wiki/Template:F1stat
  driverCodes=c("hamilton"= "HAM", "vettel"= "VET", "rosberg"= "ROS", "ricciardo"= "RIC",
                "kvyat"= "KVY", "max_verstappen"= "VES", "massa" = "MAS", "grosjean"= "GRO",
                "bottas"= "BOT", "ericsson"= "ERI", "raikkonen"= "RAI", "maldonado" = "MAL",
                "hulkenberg"= "HUL", "perez"= "PER", "sainz"= "SAI", "nasr"= "NAS",
                "button" = "BUT", "alonso"= "ALO", "merhi"= "MER", "stevens"="STE",
                "gutierrez" = "GUT","wehrlein" = "WEH","jolyon_palmer" = "PAL",
                "haryanto" = "HAR","kevin_magnussen"="MAG")
  driverCode=function(name) unname(driverCodes[name])
  lapTimes['code']=apply(lapTimes['driverId'],2,function(x) driverCode(x))
  
  #TO DO - need to add something to add a dummy label if we get a mismatch
  
  #Arrange the drivers in terms of increasing accumulated race time
  lapTimes = arrange(lapTimes, acctime)
  #For each car, calculate the DIFF time to the car immediately ahead on track
  lapTimes$car_ahead=c(0,diff(lapTimes$acctime))
  #Identify the code of the driver immediately ahead on track
  lapTimes$code_ahead=c(NA,head(lapTimes$code,n=-1))
  #Identify the race position of the driver immediately ahead on track
  lapTimes$position_ahead=c(NA,head(lapTimes$position,n=-1))
  
  #Now arrange the drivers in terms of decreasing accumulated race time
  lapTimes = arrange(lapTimes, -acctime)
  #For each car, calculate the DIFF time to the car immediately behind on track
  lapTimes$car_behind=c(0,diff(lapTimes$acctime))
  #Identify the code of the driver immediately behind on track
  lapTimes$code_behind=c(NA,head(lapTimes$code,n=-1))
  #Identify the race position of the driver immediately behind on track
  lapTimes$position_behind=c(NA,head(lapTimes$position,n=-1))
  
  #put the lapTimes dataframe back to increasing accumulated race time order.
  lapTimes = arrange(lapTimes, acctime)
  
  lapTimes = arrange(lapTimes, lap,position)
  lapTimes = ddply(lapTimes,.(lap),transform,
                   code_raceahead=c(NA,head(code,n=-1)))
  
  lapTimes = arrange(lapTimes, -lap,-position)
  lapTimes = ddply(lapTimes,.(lap),transform,
                   code_racebehind=c(NA,head(code,n=-1)))
  
  arrange(lapTimes, acctime)
}

dirattr=function(attr,dir='ahead') paste(attr,dir,sep='')

#We shall find it convenenient later on to split out the initial data selection
##lapTimes=lapsData.df(2015,2)
battlemap_df_driverCode=function(lapTimes,driverCode){
  lapTimes[lapTimes['code']==driverCode,]
}

battlemap_core_chart=function(df,g,dir='ahead'){
  car_X=dirattr('car_',dir)
  code_X=dirattr('code_',dir)
  factor_X=paste('factor(position_',dir,'<position)',sep='')
  code_race_X=dirattr('code_race',dir)
  if (dir=='ahead') diff_X='diff' else diff_X='chasediff'
  
  if (dir=="ahead") drs=1 else drs=-1
  g=g+geom_hline(aes_string(yintercept=drs),linetype=5,col='grey')
  
  #Plot the offlap cars that aren't directly being raced
  g=g+geom_text(data=df[df[dirattr('code_',dir)]!=df[dirattr('code_race',dir)],],
                aes_string(x='lap',
                           y=car_X,
                           label=code_X,
                           col=factor_X),
                angle=45,size=2)
  #Plot the cars being raced directly
  g=g+geom_text(data=df,
                aes_string(x='lap',
                           y=diff_X,
                           label=code_race_X),
                angle=45,size=2)  
  g=g+scale_color_discrete(labels=c("Behind","Ahead"))
  g+guides(col=guide_legend(title="Intervening car"))
}

battlemap_theme=function(g){
  g
}

battlemapFull_byDriver=function(lapTimes,code,title,ylim=c(-50,25)){
  #eg title="F1 Malaysia 2015 - Rosberg's Race"
  battle_code=battlemap_df_driverCode(lapTimes,code)
  battle_code[["code_raceahead"]][is.na(battle_code[["code_raceahead"]])] = code
  g=battlemap_core_chart(battle_code[battle_code['code_raceahead']!=code,],ggplot(),'ahead')
  g=battlemap_core_chart(battle_code[battle_code['code_racebehind']!=code,],g,dir='behind')
  #g=g+geom_text(data=lapTimes[lapTimes['code']==code,],aes(x=lap,y=0,label=position),size=2)
  g=g+ylim(ylim)+ylab("Gap (s)")+xlab("Lap")
  g=g+theme_bw()+guides(colour=FALSE)#+ theme(legend.position="none")
  g=g+ggtitle(title)
  #battlemap_theme(g)
  g
}

quickbattlemapFull_byDriver=function(year,round,code,country){
  lapTimes=lapsData.df(year,round)
  lapTimes=battlemap_encoder(lapTimes)
  battlemapFull_byDriver(lapTimes,code,paste("F1",country,year,"-",code))
}
#lapTimes=lapsData.df(2015,2)
#lapTimes=battlemap_encoder(lapTimes)
#battle_ROS=battlemap_df_driverCode(lapTimes,"ROS")
#g=battlemap_core_chart(battle_ROS,ggplot(),'ahead')
#g
#g=g+battlemap_core_chart(battle_ROS,g,dir='behind')
#g=g+ylim(-50,25)+geom_text(data=battle_ROS[battle_ROS['code']=='ROS',],aes(x=lap,y=0,label=position),size=2)
#g+ylab("Gap (s)")+xlab("Lap")+theme_bw()+ theme(legend.position="none")+ggtitle("F1 Malaysia 2015 - Rosberg's Race")
