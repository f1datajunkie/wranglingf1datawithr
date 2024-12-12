library(shiny)

shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("F1 Driver Championship Scenarios 2014"),
  
  # Sidebar with a slider input for number of observations
  sidebarPanel(
    sliderInput("ham", 
                "HAM race pos in Brazilian Grand Prix:", 
                min = 1, 
                max = 11, 
                value = 2),
    sliderInput("ros", 
                "ROS race pos in Brazilian Grand Prix:", 
                min = 1, 
                max = 11, 
                value = 1),
    div("See also the ",
        a(href="https://leanpub.com/wranglingf1datawithr/","Wrangling F1 Data With R book"),
        " and the ", a(href="http://f1datajunkie.blogspot.co.uk/","F1DataJunkie blog"),"."
        )
  ),
  
  # Show a plot of the generated model
  mainPanel(
    plotOutput("distPlot")
  )
))