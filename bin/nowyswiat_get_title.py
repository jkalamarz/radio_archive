#!/usr/bin/python3
import requests
import datetime
from bs4 import BeautifulSoup as Soup
from dateutil.tz import gettz

html = requests.get('https://nowyswiat.online/').content
soup = Soup(html, features="lxml")

CEST= gettz('Europe/Warsaw')
n=datetime.datetime.now().astimezone(CEST).strftime("%H:%M")

for e in soup.select('.elementor-element-099f140'):
    if n>=e.select('.elementor-element-b20fd4d')[0].text and n<e.select('.elementor-element-fee4c79')[0].text[2:]:
        print(e.select('.elementor-element-dd5b769')[0].text, "-", e.select('.elementor-element-0d4b516')[0].text)
