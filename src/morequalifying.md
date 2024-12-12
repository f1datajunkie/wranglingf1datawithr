

# More Qualifying

In the chapter on *Reviewing the Practice Sessions*, we generated a "Flipped and dodged chart showing separation of lap times" labeled by team" and split across two columns, simulating a "weighted grid"" layout but with distances based on the gap between each car and the car that achieved the fastest session laptime.

We can use a similar approach to chart the classified laptimes for each session in qualifying using a simplified form of the original function and a "hack" to map the column names associated with the qualifying data on to the column names used to generate the original chart. (The column names are essentially arbitrary lbels - it's what the data in the columns represents - that is, its *semantics*  - that we're interested in.)

eg http://f1datajunkie.blogspot.co.uk/2012/11/f1-2012-abu-dhabi-qualifying-summary.html

#need to add colour to show who goes through to next session
#dd is from ergast quali results?
sessiongrid=function(dd,txtsize=3){
  #Basic dot plot - shape=1 is an empty circle
  #See for example: http://www.cookbook-r.com/Graphs/Shapes_and_line_types/
  g=ggplot(dd) + geom_point(aes(x=time,y="Time"),shape=1)
  #Split the drivers into two groups - odd position number and even position number
  #Use each group as a separate y-axis categorical value
  g=g+geom_text(data=subset(dd,subset=(pos %% 2!=0)),aes(x=time,y="1,3,5,...",label=team),size=txtsize)
  g=g+geom_text(data=subset(dd,subset=(pos %% 2==0)),aes(x=time,y="2,4,6,...",label=team),size=txtsize)
  #add lines to show slope to pos ahead and behind: 1-2, 3-2, 3-4, etc
 # g=g+geom_segment(x=1.1,xend=1.9,
  #                 aes(y=pos,yend=q2pos,group=driverName),
  #                 colour='slategrey')
  #Tweak the theme
  g=g+theme_classic() + ylab(NULL) +xlab('Laptime (s)')

  #Flip the co-ordinates
  g+coord_flip()
}






ddmod=function(chq,qn,qsize){
  ddpos=paste(qn,'pos',sep='')
  ddtime=paste(qn,'time',sep='')
  dd=chq[chq[ddpos]<=qsize & !is.na(chq[ddpos]),]
  dd['pos']=dd[ddpos]
  dd['time']=dd[ddtime]
  dd['team']=paste(dd$driverName," (",dd[['time']],")",sep='')
  dd
}

dd=ddmod(chq,'q2',10)

It's perhaps also worth noting that this style of chart could be used to represent other datasets, with suitable column heading mappings, and, if necessary, sensible label changes on the axes. For example, we might use the chart to imagine how the gird might look if it were based on particular sector times, or even speed trap measurements.

  sessionbest=ddply(df[!df['pit'] & !df['outlap'],],
              .(qsession),
              summarise,
              sbest=min(stime),
              sb107=1.07*sbest)
              
              
 ??table shwoing qualisession rank evolution:
new col for each lap showing classification order; each cell: code, laptime,currbest Highlight corresponding to new lap, in bold if no change in relative rank & bg light blue with rank pos cell corresponding to time in pink, or if rank change green bg for new cell and yellow for old;
http://chepec.se/2014/11/16/element-data.html
