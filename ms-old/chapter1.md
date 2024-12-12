# Chapter One - The Tools We're Working With





## Preamble

As a hands-on guide, one of my main aims in producing this book was to encourage you to start working with Formula One data yourself using a range of free, open source tools and, wherever possible, openly licensed data.

As far as the data analysis and visualisation tools go, I wanted to choose an approach that would allow you to …


A programming/data analysis language that would allow you to manipulate data relatively easily - ingesting it from whatever data source we might be using (a downloaded file, an online API, or a database management system); an integrated development environment that would let you develop your own analyses in an interactive fashion, allowing you to see graphical results alongside any code used to generate them, as well as a way of easily previewing the data you were working with.

There were two main options that … R/RStudio/ggplot2  and python/ipython notebook/matplotlib


In the ended, I opted for the R/RStudio/ggplot2 route, not least because I'd already played with a wide range of simple analyses and visualisations in the environment on the f1datajunkie blog. blah also RCharts, an R library that makes it easy to create a wide range of interactive browser based visualisations built on top of a variety of Javascript based data visualisation libraries.

*(There's also a possibility that once finished, I may try to produce a version of this book that follows the python/ipython notebook/matplotlib route, maybe again with a few extensions that support the use of Javascript charting libraries.;-)*  


## The RStudio Environment

## The Data Sources

### Ergast Motor Racing Database - Overview

The [ergast experimental Motor Racing Developer API](http://ergast.com/mrd/) provides a historical record of Formula One results data dating back to 1950. The data is organised into a set of 11 database tables:


  * Season List - a list of the seasons for which data is available
  * Race Schedule - the races that took place in each given season
  * Race Results
  * Qualifying Results
  * Standings
  * Driver Information
  * Constructor Information
  * Circuit Information
  * Finishing Status
  * Lap Times ( from the 2011 season onwards)
  * Pit Stops

### Ergast Motor Racing Database - Detail

With each table, the Ergast API supports a wide range of filtering options that allow us to obtain different slices of data from the database. In this section, we will review the filtering options that are available and review some of the questions that these options allow us to explore. Note that the questions identified are likely to represent only a fraction of the possible questions we can potentially ask of the API. You are encouraged to explore the API yourself to identify further questions that may be of particular interest to you.

#### Season List - a list of the seasons for which data is available

#### Race Schedule - the races that took place in each given season

#### Race Results


#### Qualifying Results

#### Standings

#### Driver Information


#### Constructor Information

#### Circuit Information

#### Finishing Status

#### Lap Times ( from the 2011 season onwards)

#### Pit Stops

## Getting the Data into RStudio

## The Rest of This Book...
