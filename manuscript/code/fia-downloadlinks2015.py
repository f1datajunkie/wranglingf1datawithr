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
events=soup.findAll('div',{'class':'event-item past'})

timing=[x.lower() for x in ['Official Classification', 'Provisional Classification', 'Preliminary Classification', 'Fastest Laps', 'History Chart', 'Lap Chart', 'Lap Analysis', 'Pit Stop Summary', 'Best Sector Times', 'Maximum Speeds', 'Official Starting Grid', 'Provisional Starting Grid', 'Qualifying Session','Official Classification', 'Provisional Classification', 'Speed Trap', 'Preliminary Classification', 'Lap Times', 'Provisionnal Classification', 'Provisionnal Starting Grid', 'Speed Trap', 'Classification']]

import os
domain="http://www.fia.com"

import re

def download_file(url,f):
    response = re.urlopen(url)
    file = open("document.pdf", 'w')
    file.write(response.read())
    file.close()
    print("Completed")

for event in events[7:]:
    prev=''
    phase='R'
    gp=event.find('div',{'class':'event-name'}).text.replace('Grand Prix of ','').strip()
    c=event.find('div',{'class':'country-name'}).text.strip()
    l=event.find('div',{'class':'event-location'}).text.strip()
    u=event.find('div',{'class':'event cell'}).find('a')['href']
    
    print(gp,c,l)
    d='eventTiming/{}'.format(c)
    if not os.path.exists(d):
        os.makedirs(d) 
    url='{}{}'.format(domain,u)
    print(url)
    eventpage=requests.get(url)
    eventsoup=BeautifulSoup(eventpage.content)
    print(eventsoup.find('a',text='Event & Timing information')['href'])
    pdfsoup=BeautifulSoup(requests.get('{}{}'.format(domain,eventsoup.find('a',text='Event & Timing information')['href'])).content)
    middle=pdfsoup.find('div',{'class':'content'}).find('div',{'class':'middle'})

    for maybe in middle.findAll("a"):
        #print(maybe['href'])
        prepath=maybe.text.encode('ascii', 'ignore').strip()
        #print('fing path*{}*'.format(prepath))
        if prepath.lower() in timing:
            if (prev=='Official Starting Grid' and prepath=='Lap Times'): phase='P3'
            path='{} - {}'.format(phase,prepath)
            if prepath=='Provisional Starting Grid' or prepath=='Provisionnal Starting Grid':
                phase='Q'
            elif (phase=='Q' and prepath=='Maximum Speeds') or (phase=='Q' and (c=='MYS' or c=='CHN') and prepath=='Provisionnal Classification'):
                phase='P3'
            elif phase=='P3' and prepath=='Classification' :
                phase='P2'
            elif phase=='P2' and prepath=='Classification':
                phase='P1'
        else:
            path=prepath
        prev=prepath
        p='{d}/{path}.pdf'.format(d=d,path=path.replace('/','_'))

        #print(p)
        if not os.path.isfile(p):
            print("downloading",d,maybe.text.encode('ascii', 'ignore'))
            os.system('wget {url} -O "{p}"'.format(url='{}{}'.format(domain,maybe['href']),p=p))


