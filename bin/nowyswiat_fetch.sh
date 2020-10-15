#!/bin/bash

cd $HOME/tmp/nowyswiat/

export TZ=Poland

FOLDER=$HOME/tmp/nowyswiat/`date +"%Y-%m-%d"`
TIME=`date +"%Y-%m-%d_%H%M"`
TIME_DB=`date +"%Y-%m-%d %H:%M"`

echo mkdir -p $FOLDER
mkdir -p $FOLDER

rm -f NOW.mp3
ln -s t/$TIME.mp3 NOW.mp3

echo streamripper "https://n17.rcs.revma.com/ypqt40u0x1zuv?rj-ttl=5&rj-tok=AAABdOqDgP4AN2Hs-3mRpeh6Mg" -a t/$TIME.mp3 -A -l 3605
streamripper "https://n17.rcs.revma.com/ypqt40u0x1zuv?rj-ttl=5&rj-tok=AAABdOqDgP4AN2Hs-3mRpeh6Mg" -a t/$TIME.mp3 -A -l 3605 | sed 's/\[.*\]  -  \[ *\(.*\)\]/ \1/' | tr -d '\n' &

PID_MP3=$!

sleep 300

TITLE=`$HOME/bin/nowyswiat_get_title.py`

# 60 minutes - 10 seconds
wait $PID_MP3


FINAL_PATH="$FOLDER/${TIME} $TITLE.mp3"

mv t/$TIME.mp3 "$FINAL_PATH"
