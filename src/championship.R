#Load in the core utility functions to access ergast API
source('ergastR-core.R')


API_PATH="http://ergast.com/api/fe/"

#Get the standings after each of the first 17 rounds of the 2014 season
df=data.frame()
for (j in seq(1,12)){
  dft=seasonStandings(2014,j)
  dft$round=j
  df=rbind(df,dft)
}

library(ggplot2)
library(directlabels)
championship_charter=function(g,labelplace="last.points") {
  #Generate a line chart
  g=g+geom_line()
  #Remove axis labels and colour legend
  g=g+ylab(NULL)+xlab(NULL)+guides(color=FALSE)
  #Add a title
  g=g+ggtitle("FormulaE Drivers' Championship Race, 2014-5")
  #Add the line labels, resized (cex), and with an x-value offset
  g=g+geom_dl(aes(label=driverId),list(labelplace,cex=0.7,dl.trans(x=x+0.2)))
  #Add right hand side padding to the chart so the labels don't overflow
  g=g+scale_x_continuous(limits=c(1,12),breaks=c(5))
  g
}



g=ggplot(df,aes(x=round,y=pos,group=driverId))
g=championship_charter(g); g

#Sort by ascending round
df=arrange(df,round)
#Derive how many points each driver scored in each race
df=ddply(df,.(driverId),transform,racepoints=diff(c(0,points)))

#g+geom_text(data=df,aes(label=racepoints),vjust=-0.4,size=3)

#g+geom_text(data=df,aes(label=racepoints,col=racepoints),vjust=-0.4,size=3)

g+geom_text(data=df,aes(label=points,col=racepoints),vjust=-0.4,size=3)+scale_color_continuous(high='red')
