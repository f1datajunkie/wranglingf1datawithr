

practiceGapChart=function(fp){
  dd=ddply(fp[fp['lapNumber']>1,],.(name),summarise,time=min(stime))
  dd['pos']=rank(dd['time'])

  line10=(dd[dd['pos']==10,'time']+dd[dd['pos']==11,'time'])/2
  line15=(dd[dd['pos']==15,'time']+dd[dd['pos']==16,'time'])/2
  g=ggplot(dd) + geom_point(aes(x=time,y="Time"),shape=1)
  #Add in some intercept lines using the values we used before
  g=g+geom_vline(xintercept=line10,col='grey',linetype="dotted")
  g=g+geom_vline(xintercept=line15,col='grey',linetype="dotted")

  #Split the drivers into two groups - odd position number and even position number
  #Use each group as a separate y-axis categorical value
  g=g+geom_text(data=subset(dd,subset=(pos %% 2!=0)),aes(x=time,y="1,3,5,...",label=paste(name,' (',time,')',sep='')),size=3)
  g=g+geom_text(data=subset(dd,subset=(pos %% 2==0)),aes(x=time,y="2,4,6,...",label=paste(name,' (',time,')',sep='')),size=3)
  #Tweak the theme
  g=g+theme_classic() + ylab(NULL) +xlab('Laptime (s)')
  #Flip the co-ordinates
  g=g+coord_flip() 
  g
}

##dd from scrape
#practiceGapChart(dd)