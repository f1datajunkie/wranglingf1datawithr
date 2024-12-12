# Introduction




## Preamble

*This book is a hands-on guide to wrangling and visualising data, put together to encourage you to start working with Formula One data yourself using a range of free, open source tools and, wherever possible, openly licensed data. But this book isn't just a book for F1 fans. It's a book full of recreational data puzzles and examples that explore how to twist and bend data into shapes that tell stories. And it's crammed full of techniques that aren't just applicable to motorsport data. So if you find a technique or visualisation you think you may be able to use, or improve, with your own data, wheresoever it comes from, then go for it!*

Formula One is a fast paced sport - and industry. Cars are originally developed over relatively short time-periods: when the season is on the race to update and improve car performance is as fast moving and ferocious in the pits and factories as it is on the track. F1 is also, increasingly, a data driven sport. Vast amounts of telemetry data are streamed in realtime from cars to pits and back to the home factories over the course of a race weekend, and throughout the race itself. Data plays a key role in car design: computational fluid dynamics (not something we shall cover here!) complements wind tunnel time for checking the aerodynamic performance of evolving car designs. And data plays a key role in developing race strategies: race simulations are run not just on the track but also in 'mission control' centres, not just in advance of the race but during the race itself, as strategies evolve, and 'events, dear boy, events' take their toll.

In many sports, "performance stats" and historical statistics provide an easy fill for commentators looking to add a little colour or context to a report, but where do the commentary teams find the data, or the stories in the data?

The focus in these pages will be primarily on what we might term *sports statistics* or *sports stats*: descriptive summary statistics about previous races, previous championships, and the performance of current or previous drivers. Sports statistics are unusual compared to many datasets in that they are exact and unambiguous in terms of what they record: the results are the actual results of actual races, rather than sampled results based on uncertain opinion polls, for example.

We'll see where those stats come from, and how to create fun facts and figures of your own to rival the apparently boundless knowledge of the professional commentators, or professional motorsport statisticians such as @virtualstatman, Sean Kelly. If you fancy the occasional flutter on an F1 race or final championship standing, you may even be able to get some of the stats to work for you...

As well as sports stats, we'll have a look at some simple statistical modeling, taking inspiration from academic papers on economics and statistics and seeing whether we can build explanatory or predictive models about various aspects of Formula One. Academic papers are supposedly written to provide detailed enough explanations that a third party can attempt to reproduce any claimed findings, a practice that we shall put to the test several times!  (It is only in recent years that publishing code to support research papers has become more widespread, in part through the advocacy of the Open Science movement.)

I'm also hoping you may try to develop your own visualisations and analyses, joining a week-on-week race to develop, refine, improve and build on the work in these pages as well as your own. And I have another hope, too - that you may find some of the ideas about how to visualise data, how to work with data, how to have *conversations* with data of some use outside of F1 fandom, maybe in your workplace, maybe in your local community, or maybe in other areas of motorsport.

## What are we trying to do with the data?

As well as using Formula One data to provide a context for learning how to wrangle and visualise data in general, it's also the case that we want to use these techniques to learn something about the world of F1. You might quite reasonably ask why we should even bother looking at the data, given the wide variety of practice and qualifying session, as well as race and championship reports that are produced around each race and across the course of a season. When interpreted correctly, data can provide a valuable source of stories that can help us better under what actually happened in a particular race or over the course of a particular season, as well as highlighting stories that we might otherwise have missed. A good example of this is in the midfield of a particular race, where the on-track action may not receive much television coverage, no matter how exciting it is, particularly if the race at the head of the field is fierce.

So what is the data actually good for?

Firstly, we can use the data as a knowledgeable source we can have a conversation with about F1, if we know how to phrase the questions in the right way and we know how to interpret the answers. *Conversations with data* is how I refer to this. You're probably already in the habit of having a conversation with Google about a particular topic, although you may not think of it in such terms: you put in a keyword, Google gives you some links back. You skim some of them, refine your query, ask again. One link looks interesting so you follow it; the web page gives you another idea, back to Google, a new search query, and so on. In the sense that the Google search engine is just a big database, you've had some sort of conversation with it and in doing so developed your own understanding of the topic, mediated by the questions you asked, the responses you got, and the follow-on questions they provoked. After reading this book, you'll hopefully be similarly able to have a conversation with some raw datasets!

In the second case, we can look for stories in the data that tell us about *what has happened* in a particular race, championship season or driver career - the drivers who have won the most races, or taken the most pole positions; which the most successful teams were, or are, for some definition of "successful"; how many laps each driver led a particular race for; how a particular race or championship battle evolved. And so on. This is one of the main motivations for developing the charts described in this book - trying to find ways of visualising the story so that we can more easily see the stories that may be hidden in the data. It's often said that a picture can save a thousand words; but if those thousand words are a race review, how can a picture help us tell that story, and how can we find that story in, or read it from, that picture?

Thirdly, we can use the data to try to *predict* what will happen in the future: who is most likely to win the championship this year, or a particular race given the performance in that weekend's practice and qualifying sessions. For the teams, predicting the possible ways a race might evolve can the strategy or tactics employed by the team during a race. For the gambler, forecasts may influence betting strategy, not something I will cover in this book, except to say that one should always remember that previous outcomes are no guarantee of future success! For the commentator, knowing how a race may evolve can help add context to a commentary whilst trying to explain the actions of a particular driver or team. Modeling and predicting races is not something that is covered in this particular book, though I hope to cover it in a future one.

## Choosing the tools

As far as the data analysis and visualisation tools go, I wanted to choose an approach that would allow you to work on any major platform (Windows, Mac, Linux) using the same, free tools (ideally open source) irrespective of platform. Needless to say, it was essential that you should be able to create a wide range of data visualisations across a range of Formula One related datasets. At the back of my mind was the idea that a browser based UI would present the ideal solution: in the first case, browsers are nowadays ubiquitous; secondly, separating out a browser based user interface from an underlying server means that you can run the underlying server either on your own computer, in a virtual machine on your own computer, or on a remote server elsewhere on the web.

Tied to the choice of development environment was the the choice of programming language. There were two major candidates - R and Python. What I was looking for was a programming/data analysis language that would:

* allow you to manipulate data relatively easily - ingesting it from whatever data source we might be using (a downloaded file, an online API, or a database management system);

* be supported by an integrated development environment that would let you develop your own analyses in an interactive fashion, allowing you to see graphical results alongside any code used to generate them, as well as a way of easily previewing the data you were working with.

There were two main options to the language/development environment/visualisation approach that I considered: *R/RStudio/ggplot2* and *python/IPython notebook/matplotlib*. Both these triumvirates are popular among those emerging communities of data scientists and data journalists. A third possibility was to run the R code from within an IPython notebook.

In the end, I opted for the *R/RStudio/ggplot2* route, not least because I'd already played with a wide range of simple analyses and visualisations using that combination of tools on the *f1datajunkie.com* blog. The R milieu has also benefited in recent months from Ramnath Vaidyanathan's pioneering work on the RCharts library that makes it easy to create a wide range of interactive browser based visualisations built on top of a variety of Javascript based data visualisation libraries, including several based on Mike Bostock's powerful d3.js library.

The RStudio development environment can run as a cross-platform standalone application, or run as a server accessed via a web browser, and presents a well designed environment within which to explore data wrangling with R. Whilst you do not have to use RStudio to run any of the analysis or produce any of the visualisations produced herein, I would recommend it: it's a joy to use.


*(There's also a possibility that once finished, I may try to produce a version of this book that follows the python/ipython notebook/matplotlib route, maybe again with a few extensions that support the use of Javascript charting libraries.;-)*  


### The RStudio Environment

RStudio is an integrated development environment (IDE) for the R programming language. R is a free, open source (GPL licensed) programming language that was originally developed for statistical computing and analysis. R is supported by an active community of contributors who have developed a wide variety of packages for running different sorts of of statistical analysis. R also provides rich support for the production of high quality statistical charts and graphics and is increasingly used in the production of complex data visualisations.

The RStudio IDE is cross-platform application available in a free, open source edition as well as commercially supported versions. Whilst capable of running as a standalone desktop application, RStudio can also run as a server, making the IDE available via a web browser with R code executing on the underlying server. This makes packaging RStudio in a virtual machine, running it as a service, and accessing it through a browser on a host machine, a very tractable affair (for example, [RStudio AMI shared by Louis Aslett](http://www.louisaslett.com/RStudio_AMI/) or [Running RStudio via Docker in the Cloud](http://www.magesblog.com/2014/09/running-rstudio-via-docker-in-cloud.html)). Producing a virtual machine pre-populated with tools, scripts and datasets is very much on the roadmap for future revisions of this book.

## The Data Sources

There are several sources of F1 data that I will be drawing on throughout this book, including the *ergast motor racing results database* and data scraped from official FIA and Formula One sources.

### *ergast* Motor Racing Database - Overview

The [ergast experimental Motor Racing Developer API](http://ergast.com/mrd/) provides a historical record of Formula One results data dating back to 1950.

The data is organised into a set of 11 database tables:

  * *Season List* - a list of the seasons for which data is available
  * *Race Schedule* - the races that took place in each given season
  * *Race Results* - the final classification for each race
  * *Qualifying Results* - the results of each qualifying session from 2003 onward
  * *Standings* - driver and constructor championship standings after each race
  * *Driver Information* - information about each driver and their race career
  * *Constructor Information* - details about the race history of each team
  * *Circuit Information* - information about each circuit and its competition history
  * *Finishing Status* - describes the finishing status for each competitor
  * *Lap Times* - race lap times from the 2011 season onward
  * *Pit Stops* - pit stop data for each race from 2012 onward

Chris Newell, maintainer of the *ergast* website, publishes the results data via both a machine readable online API and via a database dump. We will see how to work with both these sources to generate a wide range of charts.

### formula1.com Results Data
Although not published as open licensed data, or indeed as data in a data format, it is possible to scrape data from official online websites and put it into a database, such as a SQLite database.

Up until the start of the 2015 season, the formula1.com website published current season and historical results data dating back to 1950.  From 1950 to 2002 only race results were provided. Since 2003, the data included results from practice and qualifying sessions. From 2004, best sector times and speed trap data was also available for practice and qualifying sessions, and fastest laps and pit stop information for the race.

At the start of the 2015 season, a redesign of the official Formula One website  removed all but classification results from the public areas of the site at least. As such, the official website is now of little use to the F1 data junkie. However, the current season results that used to previously appear on the F1 website now appear on pages on the FIA website.

In the original drafts of this book, an appendix described a python screenscraper used to scrape the data from the Formula One website. With the historical results pages no longer available (although you could always try the Internet Archive...), I have posted an archival version of the data as a SQLite database (`f1com_results_archive.sqlite`) in the github repository along with a copy of the original scraper (*code/f1-megascrapercode.py*).

In place of the screenscraper, I have produced a set of R functions that scrape the race classification pages on the FIA website so that it can be worked with *as data*.


### FIA Event Information and Timing Data
Over the course of a race weekend, as well as live timing via the F1 website and the F1 official app, the FIA publish timing information for each session via a series of PDF documents. These documents are published on the FIA.com website over the course of the race weekend and intended for use primarily by the media. These documents represent a primary source for F1 timing information - experience shows that results data posted to the results tables on the public facing F1 and FIA websites is not always correct...

Until 2012, the FIA timing sheet documents for each race would remain available until the next race, at which point they would disappear from the public FIA website. From 2013, an [archive site](http://www.fia.com/championships/archives/formula-1-world-championship/2013) kept the documents available although following a redesign of the FIA website at the start of 2015, trying to track down any archived event and timing information documents, if indeed they are still available, has become all but impossible.

Timing and event information for the 2015 season is currently available from URLs rooted on *http://www.fia.com/events/fia-formula-1-world-championship/season-2015/*. Documents for the first race can be found at `event-timing-information`, for the second race `event-timing-information-0`, for the third `event-timing-information-1` and so on. As well as official PDF timing sheets, the FIA website also publishes session classification tables for each sessions and summary tables for qualifying and the race.

Downloading the official PDF documents needs to be done one document at a time. To support the bulk downloading of documents for particular race weekend, I have described a short python program in one of the appendices that can download all the PDF documents associated with a particular race.

The documents published by the FIA for each race are as follows:

* *Stewards Biographies* - brief text based biography for each steward
* *Event Information*	- brief introduction to the race, quick facts, summary of standings to date, circuit map
* *Circuit Information*	- graphics of FIA circuit map, F1 circuit map
* *Timing Information*	- a range of timing information for each session of the race weekend
* *FIA Communications*	- for example, notes to teams
* *Technical Reports* - for example, updates from the FIA Formula 1 Technical Delegate 
* *Press Conference Transcripts*- transcripts from each of the daily press conferences (Thursday, Friday, Saturday, Sunday)
* *National Press Office*	- Media Kit from the local press office
* *Stewards Decisions* - notices about Stewards' decisions for each day, with information broke down into separate list items (No/Driver, Competitor (i.e. the team), Time, Session, Fact, Offence, Decision, Reason)
* *Championship Standings* - drivers and constructors championship standings once the race result is confirmed

#### The FIA PDF Timing Sheets in Detail

The following list identifies the timing data is available for each of the sessions:

* **Practice**
  * Classification
  * Lap Times

* **Qualifying**
  * Speed Trap
  * Best Sector Times
  * Maximum Speeds
  * Lap Times
  * Preliminary Classification
  * Provisional Classification
  * Official Classification

* **Race**
  * Starting Grid - Provisional
  * Starting Grid - Official
  * Pit Stop Summary
  * Maximum Speeds
  * Speed Trap
  * Lap Analysis
  * Best Sector Times
  * Lap Chart
  * History Chart
  * Fastest Laps
  * Preliminary Classification
  * Provisional Classification
  * Official Classification

Some of this data was historically also published as HTML data tables on the previously mentioned formula1.com *results* data area; from 2015, the HTML summary tables appear on the FIA website.

#### Using the FIA Event Information

Getting the data from the PDF documents into a usable form is a laborious procedure that requires scraping the data from the corresponding timing sheet and then either adding it to a database or making it otherwise available in a format that allows us to read it into an R data frame.

Several tools are available that can help extract data directly from PDF documents. For example, [*Tabula*](http://tabula.technology/), open source, cross-platform desktop application or the Scraperwiki [*PDFTables*](https://pdftables.com/) service, which is commercial, although with a limited free tier. Several programming libraries are also available if you want to write your own scrapers.

Getting the HTML webpage data is much easier and a webscraper will be described that shows how the web page datatables can be automatically captured into an R dataframe.

Note that we can recreate data sets corresponding to some of the sheets from other data sources, such as the *ergast API*. However, other data sets must be grabbed by scraping the FIA sheets directly.

*Descriptions of how to scrape from the FIA PDFs, or analyses of data only available from that source, will not be covered in the first few editions of this book.*

## Additional Data Sources

Several additional data sources are also available that interested readers may like to explore, though the list is subject to change as new websites come online and others disappear or lapse by the wayside.

### Viva F1 - Race Penalties
For the 2012 and 2013 seasons, the [Viva F1](http://www.vivaf1.com) site publish a summary list of [race penalties](http://www.vivaf1.com/penalties.php) awarded during the course of a race weekend, and then use this information to generate a visualisation of the penalties. Whilst not broken down as *data*, it is possible to make use of the common way in which the penalties are described to parse out certain "data elements" from the penalty descriptions.


### Race Telemetry

Between 2010 and 2013, the McLaren race team published a live driver dashboard that relayed some of the telemetry data from their cars to an interactive, web based dashboard. (Mercedes also had a dashboard that streamed live telemetry.) The data was pulled into the web page by polling a McLaren data source once per second. At the time, it was possible to set up a small data logging script that would similarly call this source once a second and produce a data log containing telemetry data collected over a whole session. This data could then be used to analyse performance over the course of a session, or provide a statistical view over the data based on samples collected at similar locations around the track across one or more sessions.

The current F1 app includes live information about track position and tyre selection, as well as a limited amount of cornering speed information, but the data is not made openly available. The commercial licensing decisions surrounding this particular set of F1 data thus makes fan driven innovation around it very difficult.

### A Note on Data Licensing
Although an increasing number of publishers, such as the *ergast* data service, make data available under a permissive open license that allows the data to be freely shared and reused, rights to much of the data associated with motorsport extends no further than fair use conditions that apply to copyrighted material released with no additional license terms other than a standard "All Rights Reserved" limitation. Data may be used for timely reporting or personal research, and the educational use of copyrighted material also benefits from certain freedoms. Restrictions may still apply to sharing of data so used, however, which is why I have tried to avoid the sharing of data that may have rights associated with it that prevent sharing. In such cases, I have tried to describe ways in which you might be able to get hold of the data, *as such*, so that you can analyse it *as data* yourself.

## Getting the Data into RStudio

The *ergast* API publishes data in two data formats - JSON (Javascript Object Notation) and XML. Calls are made to the API via a web URL, and the data is returned in the requested format. To call the API therefore requires a live web connection. To support this book, I have started to develop an R library, currently available as *ergastR-core.R* from the [*wranglingf1datawithr* repository](https://github.com/psychemedia/wranglingf1datawithr/blob/master/src/ergastR-core.R). The routines in this library can be used to request data from the *ergast API* in JSON form, and then cast it into an R data frame.

Historical data for all *complete* seasons to date is available as a MySQL database export file that is downloadable from the *ergast* website. Whilst R can connect to a MySQL database, using this data does require the that the data is uploaded to a MySQL database, and that the database is configured with whatever permissions are required to allow R to access the data. To simplify the database route, I have converted to the MySQL export file to a SQLite database file. This simple database solution allows R to connect to the SQLite database directly. The appendix *Converting the ergast Database to SQLite* describes how to generate a sqlite3 version of the database from the original MySQL data export file. *A docker container image containing the sqlite version of database, along with scripts for importing the SQL database from the *ergast* website is also available as part of a bundle associated with this book on the Leanpub website.*

We will see how to use both the *ergast* API and the explored *ergast* database as the basis for F1 stats analyses and data visualisations.

A> Sample datasets (in sqlite form) can be downloaded from [github/psychemedia/wranglingf1datawithr](https://github.com/psychemedia/wranglingf1datawithr/tree/master/src) as:
A> * *ergast* database - *ergastdb13.sqlite*
A> * F1 results scrape (original version) - *scraperwiki.sqlite*
A> * F1 results scrape (archive to end of 2014) - *f1com_results_archive.sqlite*

## Example F1 Stats Sites

Several websites produce comprehensive stats reports around F1 that can provide useful inspiration for developing our own analyses and visualisations, or act as a basis for trying to replicate the analyses produced by other people.

I have already mentioned the [intelligentF1](http://intelligentf1.wordpress.com/) website, which used to analyse race history charts from actual races as well as second practice race simulations in an attempt to identify possible race strategies, particularly insofar as they relate to tyre wear and, from the 2014 season, fuel saving. The [James Allen On F1](jamesallenonf1.com) features a strategy review of each race a day or two after each race.

Applied mathematician Andrew Phillips' [F1Metrics blog](https://f1metrics.wordpress.com/) describes a wealth of detailed analyses of F1 data and provides a far more rigorous and formal approach than the approaches described in this book; it represents an excellent resource if for taking some of the ideas hinted at in these pages further. And in some cases, *much* further!

For tracking a season on the race stats side, [F1fanatic](http://www.f1fanatic.co.uk/statistics/2014-f1-statistics/) produces a wide range of browser based interactive season and race summary charts, some of which we'll have a go at replicating throughout this book.

During race weekends, data fragments tend to appear in the race week end thread on the relevant *f1technical.net* forum.

Over the 2015 season, the *f1forensics* tag on [*The Judge13*](http://thejudge13.com/category/f1-forensics/) website collated reviews of laptimes and technical documentation associated with each race, with the associated [Chancery](http://thejudge13.com/f1-forensics/) archive maintaining a running database covering a range of measures including engine usage and the distances run by a variety of technical components on a per car basis. The spreadsheet associated with that archive looks to be a hugely valuable resource, although I discovered it too late to include any analyses based on the data in this edition of the book.

Although not an F1 stats site *per se*, I always enjoy visiting [sidepodcast.net](http://sidepodcast.net).

## How to Use This Book

This book is filled with bits and pieces of R code that have been used to directly generate all the analyses and visualisations shown in these pages. All the tables and all the charts are produced directly from code snippets described in the text. You should be able to copy the code and run it in your own version of RStudio assuming you have downloaded and installed the appropriate R packages, and that the necessary data files are available (whether by downloading them or accessing them via a live internet/web connection).

Explanations of how the code works is presented in both the text and as comments in the inline code. You are encouraged to read the program code to get a feel for how it works, and then experiment with changing recognisable bits of the code yourself. Non-executed code comments are used to introduce and explain various code elements where appropriate, so by not reading the code fragments you may miss out on learning some handy tips and tricks that are not introduced explicitly in the main text.

Several of the chapters include one or more *Exercise* sections that describe recreational data puzzles and exercises for you to practice some of the things covered in the chapter, or that suggest ways of applying or extending the ideas in new ways. During the production of this book, some sections originally included *TO DO* items; these reflected the work-in-progress nature of the book and provided placeholders for activities or analyses be included in future rolling editions of the text. *TO DO* items often went beyond simply rehearsing or stretching the ideas covered in the respective chapter and typically required some new learning to be done, problems to be solved, or things to be figured out!

## The Rest of This Book...

For the first 12 months of its existence, this book was largely a living book, which meant that it was subject to change on a regular basis. The book has now reached a relatively stable state of development and henceforth will be subject mainly to revisions arising from errata or code improvements. A version of the book will also be made available in paperback form on *Lulu.com* when any remaining errata have been rectified. Any significant new chapters will be included in a new book: *More Motorsport Data Wrangling With R*.

The chapters are grouped as follows:

* *getting started* sections - introducing the technical tools we'll be using, R and RStudio, and the datasets we'll be playing with, in particular the *ergast* data.
* *race weekend analysis* - a look at data from over a race weekend, how to start analysing it and how we can visualise it;
* *season analysis* sections - looking at season reviews and tools and techniques for analysing and visualising results across a championship and comparing performances year on year;

Original versions of the book hinted at the inclusion of chapters on:

* *map views* - a look at how what geo and GPS data is available, and how we might be able to make use of it;
* *interactive web charts* using a variety of d3.js inspired HTML5 charting libraries via the rCharts library;  
* *application development* - how to develop simple interactive applications with the shiny R library.

With this version of the book already reaching several hundred pages, the description of interactive data displays will now appear in *More Motorsport Data Wrangling With R* with live demonstrations on an associated website.

If you spot any problems with the code included in this book, please post an issue to [Wrangling F1 Data with R - github](https://github.com/psychemedia/wranglingf1datawithr/issues).

If you would like to buy this book, or make a donation to support its development, please visit [Wrangling F1 Data with R - leanpub](https://leanpub.com/wranglingf1datawithr).
