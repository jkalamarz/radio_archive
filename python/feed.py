#!/usr/bin/python
# -*- coding: utf-8 -*-

from feedgen.feed import FeedGenerator
import datetime
import os
import time
from os import listdir
from os.path import isfile, isdir, join, islink
from eyed3.id3 import Tag
import platform
from mutagen.mp3 import MP3
import time 
import sys
import urllib

def creation_date(path_to_file):
    if platform.system() == 'Windows':
        return os.path.getctime(path_to_file)
    else:
        stat = os.stat(path_to_file)
        try:
            return stat.st_birthtime
        except AttributeError:
            return stat.st_mtime

fg = FeedGenerator()
fg.load_extension('podcast')
fg.language('pl')
fg.podcast.itunes_explicit('no')

if (len(sys.argv) > 1 and sys.argv[1] == '3'):
    fg.title(u'Trójka') 
    fg.podcast.itunes_author(u'Trójka')
    fg.link(href='https://www.polskieradio.pl/9,Trojka', rel='alternate')
    fg.subtitle(u'Nieoficjalny podcast Trójki')
    fg.copyright('cc-by-PolskieRadio')
    fg.podcast.itunes_summary(u'Podcast Trójki')
    fg.image('https://www.simx.mobi/trojka/trojka.jpg')
    fg.podcast.itunes_image('https://www.simx.mobi/trojka/trojka.jpg')
    fg.podcast.itunes_category('International', 'Polish')
    url = u'https://www.simx.mobi/trojka/'
else:
    fg.title(u'Weszło FM') 
    fg.podcast.itunes_author(u'Weszło FM')
    fg.link(href='http://weszlo.fm/', rel='alternate')
    fg.subtitle(u'Nieoficjalny podcast WeszłoFM')
    fg.copyright('cc-by-Weszlo')
    fg.podcast.itunes_summary(u'Podcast WeszłoFM')
    fg.podcast.itunes_owner('Krzysztof Stanowski', 'krzysztof.stanowski@weszlo.com')
    fg.image('https://i1.sndcdn.com/avatars-000421118988-38c4cq-t200x200.jpg')
    fg.podcast.itunes_image('https://i1.sndcdn.com/avatars-000421118988-38c4cq-t200x200.jpg')
    fg.podcast.itunes_category('Sport', 'Sport News')
    url = u'https://www.simx.mobi/weszlo/'

ads = not (len(sys.argv) > 2 and sys.argv[2].startswith('noads'))
aac = len(sys.argv) > 2 and sys.argv[2].endswith('aac')
output_file = sys.argv[3] if len(sys.argv) > 3 else 'feed.xml'

fg.link(href=url, rel='self')

root_path = os.getcwd() + "/"
only_folders_from_root_path = [f for f in listdir(
    root_path) if isdir(join(root_path, f)) and f.startswith('20') and not f.startswith('.')]

items = []

for path_folder in sorted(only_folders_from_root_path)[-7:]:
    path_files = unicode(root_path + path_folder)
    only_files = [f for f in listdir(path_files) if isfile(join(path_files, f)) and not islink(join(path_files, f)) and f.endswith('.mp3') and (ads and not f.endswith('.noads.mp3') or not ads and f.endswith('.noads.mp3'))]
    for path in only_files:
        full_path = path_files + "/" + path
        tag = Tag()
        tag.parse(full_path)
        if not tag.artist and not tag.title:
            continue
        
        item = fg.add_entry()
        item.id(url + path_folder + "/" + path)
        item.title(path[11:13] + ':' + path[13:15] + ' ' + (tag.title or ''))
        item.podcast.itunes_summary(tag.artist or '')
        item.podcast.itunes_subtitle(tag.artist or '')
        item.podcast.itunes_author(tag.artist or '')
        size = '%i' % os.path.getsize(full_path)
        path_for_url = path if not aac else (path + '.m4a')
        item.enclosure(url + path_folder + "/" + urllib.quote(path_for_url.encode('utf8')), size, 'audio/mpeg')
        
        try:
            audio = MP3(full_path)  
            rr = audio.info.length
        except:
            print u"Cannot parse:", full_path.encode('utf-8')
        normTime = time.strftime('%H:%M:%S', time.gmtime(audio.info.length))
        item.podcast.itunes_duration(normTime)
        
        dat = creation_date(path_files + "/" + path) 
        item.pubDate(str(datetime.datetime.fromtimestamp(dat)) + time.strftime("%z"))
        if (datetime.datetime.now() - datetime.datetime.fromtimestamp(dat) < datetime.timedelta(14)):
            items.append(item)

fg.rss_file(output_file, pretty=True)
