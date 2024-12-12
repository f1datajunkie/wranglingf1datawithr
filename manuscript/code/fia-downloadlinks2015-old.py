#Load in some libraries to handle the web page requests and the web page parsing...
import requests
from bs4 import BeautifulSoup

#Note - I'm in Python3
from urllib.parse import parse_qs

#This script is for scraping the current season
#Modifications may be required for scraping reports from archived years
url='http://www.fia.com/events/fia-formula-1-world-championship/season-2015/formula-one'
response = requests.get(url,params={})

soup=BeautifulSoup(response.content)
events=soup.findAll('div',{'class':'past-event'})

#urls will contain the list of URLs for event reports for current season
urls=[]
for event in events:
    item=event.previousSibling
    print(item.parent.attrs['href'])
    urls.append(item.parent.attrs['href'])

import re
def getPdfList(url):
    response = requests.get(url,params={})
    soup=BeautifulSoup(response.content)
    links=soup.find_all('a')
    pdflinks=[]
    tmp=[]
    filetypes=['pdf']
    for l in links:
        la=l.attrs['href']
        for t in filetypes:
            if t in la:
                if la not in tmp:
                    tmp.append(la)
                    pdflinks.append((la,l.text.encode('utf-8')))
    return pdflinks
    
import csv
scrapelist=[]
for url in urls:
    stub=url.split('2014/')[1].replace('2014-','').split('-')[0]
    f=open(stub+'_2014_doclinks.txt','w')
    writer = csv.writer(f)
    links=[]
    response = requests.get("http://fia.com"+url,params={})
    soup=BeautifulSoup(response.content)
    x=soup.find('a',text  = re.compile('TIMING'))
    try:
        print("http://fia.com"+x.attrs['href'])
        links=links+getPdfList("http://fia.com"+x.attrs['href'])
    except:
        print('..',url)
        x=soup.find('a',text  = re.compile('EVENT INFORMATION'))
        #print("http://fia.com"+x.attrs['href'])
        links=links+getPdfList("http://fia.com"+x.attrs['href'])
        #print(links)
        response = requests.get("http://fia.com"+x.attrs['href'],params={})
        soup=BeautifulSoup(response.content)
        for xx in ['Pre-Race','Practices','Qualifying','Race']:
            xxx=soup.find('a',text  = re.compile('^'+xx+'$'))
            #print(xxx)
            links=links+getPdfList("http://fia.com"+xxx.attrs['href'])
    writer.writerows(links)
    f.close()
    for link in links:
        scrapelist.append("http://fia.com"+link[0])
f=open('big_2014_doclinks.txt','w')
f.write("\n".join(scrapelist))
f.close()


#The harvest can then be achieved using:
## wget -i big_2014_doclinks.txt

#NOTE - we really should create a way of generating a separate download folder 
# for each race. In addition, it might make sense to standardise the URLs, or
# create a database that uses appropriate metadata to relate a particular sort
# of report to a particular file stored as PATH/FILENAME    