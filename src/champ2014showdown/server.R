#Elegant loader - http://rscriptsandtips.blogspot.co.uk/2014/02/install-and-load-missing.html
#library.guaranteed=function(need){
#  ins<-installed.packages()[,1] #find out which packages are installed
#  Get<-need[which(is.na(match(need,ins)))] # check if the needed packages are installed
#  if(length(Get)>0){install.packages(Get)} #install the needed packages if they are not-installed
#  eval(parse(text=paste("library('",need,"')",sep='')))#load the needed packages
#}

#library.guaranteed(c("ggplot2","reshape","shiny"))

library(shiny)
library(reshape)
library(ggplot2)

# Define server logic required to generate and plot a random distribution
shinyServer(function(input, output) {
  points=data.frame(pos=1:11,val=c(25,18,15,12,10,8,6,4,2,1,0))
  #points[[1,2]]
  h=316
  r=292
  
  pospoints=function(h,r,pdiff,points){
    pp=matrix(ncol = nrow(points), nrow = nrow(points))
    for (i in 1:nrow(points)){
      for (j in 1:nrow(points))
        pp[[i,j]]=r-h+pdiff[[i,j]]
    }
    pp
  }
  
  #pdiff identifies the points difference between positions
  pdiff=matrix(ncol = nrow(points), nrow = nrow(points))
  for (i in 1:nrow(points)){
    for (j in 1:nrow(points))
      pdiff[[i,j]]=points[[i,2]]-points[[j,2]]
  }
  
  #There are double points available in the final race
  pdiff.final=matrix(ncol = nrow(points), nrow = nrow(points))
  for (i in 1:nrow(points)){
    for (j in 1:nrow(points))
      pdiff.final[[i,j]]=2*points[[i,2]]-2*points[[j,2]]
  }
  
  ppx=pospoints(h,r,pdiff,points)
  
  winmdiff=function(hrdiff,pdiff,points){
    win=matrix(ncol = nrow(points), nrow = nrow(points))
    for (i in 1:nrow(points)){
      for (j in 1:nrow(points))
        if (i==j) win[[i,j]]=''
      else if ((hrdiff+pdiff[[i,j]])>0) win[[i,j]]=hrdiff+pdiff[[i,j]] #'ROS'
      else win[[i,j]]=hrdiff+pdiff[[i,j]] #'HAM'
    }
    win
  }
  
  # Function that generates a plot of the distribution. The function
  # is wrapped in a call to reactivePlot to indicate that:
  #
  #  1) It is "reactive" and therefore should be automatically 
  #     re-executed when inputs change
  #  2) Its output type is a plot 
  #
  output$distPlot <- renderPlot({
    wmd=winmdiff(ppx[[input$ros,input$ham]],pdiff.final,points)
    wmdm=melt(wmd)
    g=ggplot(wmdm)+geom_text(aes(X1,X2,label=value,col=-sign(as.integer(as.character(value)))))
    g=g+xlab('ROS position in Abu Dhabi')+ ylab('HAM position in Abu Dhabi')
    g=g+labs(title="Championship outcomes in Abu Dhabi")
    g=g+ theme(legend.position="none")
    g=g+scale_x_continuous(breaks=seq(1, 11, 1))+scale_y_continuous(breaks=seq(1, 11, 1))
    print(g)#+coord_flip() )
  })
})