#!/usr/bin/python3
import requests
from bs4 import BeautifulSoup as Soup

html = requests.get('https://www.polskieradio.pl/9,Trojka').content

soup = Soup(html, features="lxml")

print(soup.select('#onAirModern .live-audition .title')[0].text)
