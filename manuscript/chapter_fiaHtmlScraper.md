



```r
#install.packages("rvest")
library(rvest)

library(stringr)

#Parse out the time
timeInS=function(t){
  if (is.na(t)) return(NA)
  xx=str_match_all(t, "([0-9]*):(.*)")[[1]]
  60*as.numeric(xx[,2])+as.numeric(xx[,3])
}


#URL of the HTML webpage we want to scrape
url="http://www.fia.com/events/formula-1-world-championship/season-2015/qualifying-classification"

fiaPageGrabber=function(url,num){
  #Grab the page
  hh=html(url)
  #Parse HTML
  cc=html_nodes(hh, xpath = "//table")[[num]] %>% html_table(fill=TRUE)
  #TO DO - extract table name
  
  #Set the column names
  colnames(cc) = cc[1, ]
  cc=Filter(function(x)!all(is.na(x)), cc[-1,])
  #Fill blanks with NA
  cc=apply(cc, 2, function(x) gsub("^$|^ $", NA, x))
  #would the dataframe cast handle the NA?
  cc=as.data.frame(cc)
}

fiaQualiClassTidy=function(cc){
  for (q in c('Q1','Q2','Q3')){
    cn=paste(q,'time',sep='')
    cc[cn]=apply(cc[q],1,timeInS)
  }
  
  cc=dplyr:::rename(cc, Q1_laps=LAPS)
  cc=dplyr:::rename(cc, Q2_laps=LAPS.1)
  cc=dplyr:::rename(cc, Q3_laps=LAPS.2)
  cc
}
```


```r
#URL of the HTML webpage we want to scrape
url="http://www.fia.com/events/formula-1-world-championship/season-2015/qualifying-classification"

xx=fiaPageGrabber(url,1)
xx
```

```
##    POS               DRIVER       Q1 LAPS       Q2 LAPS.1       Q3 LAPS.2
## 2    1       Lewis Hamilton 1:39.269    3 1:41.517      3 1:49.834      7
## 3    2     Sebastian Vettel 1:39.814    3 1:39.632      3 1:49.908      7
## 4    3         Nico Rosberg 1:39.374    3 1:39.377      3 1:50.299      7
## 5    4     Daniel Ricciardo 1:40.504    6 1:41.085      3 1:51.541      7
## 6    5         Daniil Kvyat 1:40.546    6 1:41.665      3 1:51.951      7
## 7    6       Max Verstappen 1:40.793    6 1:41.430      3 1:51.981      7
## 8    7         Felipe Massa 1:40.543    7 1:41.230      3 1:52.473      7
## 9    8      Romain Grosjean 1:40.303    8 1:41.209      3 1:52.981      7
## 10   9      Valtteri Bottas 1:40.249    4 1:40.650      3 1:53.179      7
## 11  10      Marcus Ericsson 1:40.340    8 1:41.748      3 1:53.261      7
## 12  11       Kimi Raikkonen 1:40.415    4 1:42.173      3     <NA>   <NA>
## 13  12     Pastor Maldonado 1:40.361    8 1:42.198      3     <NA>   <NA>
## 14  13      Nico Hulkenberg 1:40.830    6 1:43.023      3     <NA>   <NA>
## 15  14         Sergio Perez 1:41.036    8 1:43.469      3     <NA>   <NA>
## 16  15     Carlos Sainz Jr. 1:39.814    6 1:43.701      3     <NA>   <NA>
## 17  16          Felipe Nasr 1:41.308    7     <NA>   <NA>     <NA>   <NA>
## 18  17        Jenson Button 1:41.636    8     <NA>   <NA>     <NA>   <NA>
## 19  18      Fernando Alonso 1:41.746    8     <NA>   <NA>     <NA>   <NA>
## 20  19 Roberto Merhi Muntan 1:46.677    7     <NA>   <NA>     <NA>   <NA>
```


```r
fiaQualiClassTidy(xx)
```

```
##    POS               DRIVER       Q1 Q1_laps       Q2 Q2_laps       Q3
## 2    1       Lewis Hamilton 1:39.269       3 1:41.517       3 1:49.834
## 3    2     Sebastian Vettel 1:39.814       3 1:39.632       3 1:49.908
## 4    3         Nico Rosberg 1:39.374       3 1:39.377       3 1:50.299
## 5    4     Daniel Ricciardo 1:40.504       6 1:41.085       3 1:51.541
## 6    5         Daniil Kvyat 1:40.546       6 1:41.665       3 1:51.951
## 7    6       Max Verstappen 1:40.793       6 1:41.430       3 1:51.981
## 8    7         Felipe Massa 1:40.543       7 1:41.230       3 1:52.473
## 9    8      Romain Grosjean 1:40.303       8 1:41.209       3 1:52.981
## 10   9      Valtteri Bottas 1:40.249       4 1:40.650       3 1:53.179
## 11  10      Marcus Ericsson 1:40.340       8 1:41.748       3 1:53.261
## 12  11       Kimi Raikkonen 1:40.415       4 1:42.173       3     <NA>
## 13  12     Pastor Maldonado 1:40.361       8 1:42.198       3     <NA>
## 14  13      Nico Hulkenberg 1:40.830       6 1:43.023       3     <NA>
## 15  14         Sergio Perez 1:41.036       8 1:43.469       3     <NA>
## 16  15     Carlos Sainz Jr. 1:39.814       6 1:43.701       3     <NA>
## 17  16          Felipe Nasr 1:41.308       7     <NA>    <NA>     <NA>
## 18  17        Jenson Button 1:41.636       8     <NA>    <NA>     <NA>
## 19  18      Fernando Alonso 1:41.746       8     <NA>    <NA>     <NA>
## 20  19 Roberto Merhi Muntan 1:46.677       7     <NA>    <NA>     <NA>
##    Q3_laps  Q1time  Q2time  Q3time
## 2        7  99.269 101.517 109.834
## 3        7  99.814  99.632 109.908
## 4        7  99.374  99.377 110.299
## 5        7 100.504 101.085 111.541
## 6        7 100.546 101.665 111.951
## 7        7 100.793 101.430 111.981
## 8        7 100.543 101.230 112.473
## 9        7 100.303 101.209 112.981
## 10       7 100.249 100.650 113.179
## 11       7 100.340 101.748 113.261
## 12    <NA> 100.415 102.173      NA
## 13    <NA> 100.361 102.198      NA
## 14    <NA> 100.830 103.023      NA
## 15    <NA> 101.036 103.469      NA
## 16    <NA>  99.814 103.701      NA
## 17    <NA> 101.308      NA      NA
## 18    <NA> 101.636      NA      NA
## 19    <NA> 101.746      NA      NA
## 20    <NA> 106.677      NA      NA
```
