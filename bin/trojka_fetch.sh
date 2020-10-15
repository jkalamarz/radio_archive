#!/bin/bash

cd $HOME/tmp/trojka/

sleep 10

export TZ=Poland

FOLDER=$HOME/tmp/trojka/`date +"%Y-%m-%d"`
TIME=`date +"%Y-%m-%d_%H%M"`
TIME_DB=`date +"%Y-%m-%d %H:%M"`
OGG_PATH_PREFIX="http://33storage.dktr.pl:8888/$(date +"%d_%m_%Y/rec-%H-00-")"

echo mkdir -p $FOLDER
mkdir -p $FOLDER

rm -f NOW.mp3
ln -s t/$TIME.mp3 NOW.mp3

echo streamripper http://stream3.polskieradio.pl:8904/ -a t/$TIME.mp3 -A -l 3595
streamripper http://stream3.polskieradio.pl:8904/ -a t/$TIME.mp3 -A -l 3595 | sed 's/\[.*\]  -  \[ *\(.*\)\]/ \1/' | tr -d '\n' &

PID_MP3=$!

# 20 minutes
sleep 1200
TITLE20=`$HOME/bin/trojka_get_title.py`
TITLE="$TITLE20"

# 40 minutes
sleep 1200
TITLE40=`$HOME/bin/trojka_get_title.py`
[ "$TITLE20" == "$TITLE40" ] || TITLE="$TITLE, $TITLE40"

# 55 minutes
sleep 900
TITLE55=`$HOME/bin/trojka_get_title.py`
[ "$TITLE20" == "$TITLE55" -o "$TITLE40" == "$TITLE55" ] || TITLE="$TITLE, $TITLE55"

# 60 minutes - 10 seconds
wait $PID_MP3

echo
echo "20 - $TITLE20"
echo "40 - $TITLE40"
echo "55 - $TITLE55"

FINAL_PATH="$FOLDER/${TIME} $TITLE.mp3"

#OGG_URL=`curl http://3.dktr.pl/last.php`
for i in 1 2 3 4 0 5 6 7 8 9 NULL
do
  OGG_URL="${OGG_PATH_PREFIX}0${i}.ogg"
  curl -I "$OGG_URL" | grep '200 OK' && break
done

echo ln -s ../subdir.php '"'$FOLDER/index.php'"'
[ -f "$FOLDER/index.php" ] || ln -s ../subdir.php "$FOLDER/index.php"

if [[ "$OGG_URL" != *"NULL"* ]]; then
  echo Convert OGG '"'$OGG_URL'"'
  
  wget -O- --progress=dot:mega "$OGG_URL" | buffer | tee >(cat > "$FINAL_PATH.ogg") | ffmpeg -nostats -f ogg -i pipe: -f wav pipe: | tee >(ffmpeg -nostats -f wav -i pipe: -b:a 192k "$FINAL_PATH") >(sox -t wav - -n rate 35k remix - spectrogram -X 30 -y 257 -m -r -o "$FINAL_PATH.mono.png") | sox -t wav - -n rate 35k remix - spectrogram -x 5000 -d 10000 -y 257 -o "$FINAL_PATH.png"
fi

C=`find "$FINAL_PATH" -size +50M -size -95M | wc -l`

if [ $C == 1 ]; then
  echo rm t/$TIME.mp3 
  rm -f t/$TIME.mp3 
else
  rm -f "$FINAL_PATH" "$FINAL_PATH.png"
  echo Fallback: OGG broken, use MP3
  echo mv t/$TIME.mp3 '"'$FINAL_PATH'"'
  mv t/$TIME.mp3 "$FINAL_PATH"
fi

echo id3v2 '-a' '"'Trójka'"' '-t' '"'$TITLE'"' '"'$FINAL_PATH'"'
id3v2 -a "Trójka" -t "$TITLE" "$FINAL_PATH"

echo python feed.py 3
python feed.py 3

echo python make_markers.py '"'$FINAL_PATH.mono.png'"' '>' '"'$FINAL_PATH.markers.txt'"'
touch "$FINAL_PATH.markers.txt"
python make_markers.py "$FINAL_PATH.mono.png" zegnamy 19.2 >> "$FINAL_PATH.markers.txt" &
python make_markers.py "$FINAL_PATH.mono.png" zapraszamy 19.5 >> "$FINAL_PATH.markers.txt" &
python make_markers.py "$FINAL_PATH.mono.png" autopromocja 17.5 >> "$FINAL_PATH.markers.txt" &
python make_markers.py "$FINAL_PATH.mono.png" trojka 18.5 >> "$FINAL_PATH.markers.txt" &
python make_markers.py "$FINAL_PATH.mono.png" trojkashort 19.1 >> "$FINAL_PATH.markers.txt" &
python make_markers.py "$FINAL_PATH.mono.png" spoleczne 18.5 >> "$FINAL_PATH.markers.txt" &

wait `jobs -p`

L23=$(echo `(cat "$FINAL_PATH.markers.txt" | grep '\*\*\*\*\*'; echo '1380 23M 0 0'; echo '0000 00m00s P 0'; echo '3660 61m00s K 0';) | sort | grep -C1 '23M'` | cut -d' ' -f2,10 | tr 'ms.' ': +' | sed 's/  /-/')
L45=$(echo `(cat "$FINAL_PATH.markers.txt" | grep '\*\*\*\*\*'; echo '2700 45M 0 0'; echo '0000 00m00s P 0'; echo '3660 61m00s K 0';) | sort | grep -C1 '45M'` | cut -d' ' -f2,10 | tr 'ms.' ': +' | sed 's/  /-/')
FF23=`echo $L23 | sed 's/-6/-1:0/' | tr '+' '.' | sed 's/-/ -to /' | sed 's/^/-ss /'`
FF45=`echo $L45 | sed 's/-6/-1:0/' | tr '+' '.' | sed 's/-/ -to /' | sed 's/^/-ss /'`

if [ "$L23" == "$L45" ]; then
  mp3cut -o "$FINAL_PATH.noads.mp3" -t $L23 "$FINAL_PATH"
else
  mp3cut -o "$FINAL_PATH.noads.mp3" -t $L23 "$FINAL_PATH" -t $L45 "$FINAL_PATH"
fi

echo id3v2 '-a' '"'Trójka'"' '-t' '"'$TITLE'"' '"'$FINAL_PATH.noads.mp3'"'
id3v2 -a "Trójka" -t "$TITLE" "$FINAL_PATH.noads.mp3"

WEEKOLD=`date +"%Y-%m-%d" --date '60 days ago'`
echo rm -r $HOME/public_html/trojka/$WEEKOLD
[ -d $HOME/public_html/trojka/$WEEKOLD ] && rm -r $HOME/public_html/trojka/$WEEKOLD

echo python feed.py 3 noads feed.noads.xml
python feed.py 3 noads feed.noads.xml

if [ "$L23" == "$L45" ]; then
  ~/bin/ffmpeg -nostats -i "$FINAL_PATH.ogg" $FF23 -c:a libfdk_aac -b:a 128k "$FINAL_PATH.noads.mp3.m4a"
else
  ~/bin/ffmpeg -nostats -i "$FINAL_PATH.ogg" $FF23 -c:a copy "$FINAL_PATH.23.ogg" &
  ~/bin/ffmpeg -nostats -i "$FINAL_PATH.ogg" $FF45 -c:a copy "$FINAL_PATH.45.ogg" &
  echo "file '../$FINAL_PATH.23.ogg'" > t/concat.txt
  echo "file '../$FINAL_PATH.45.ogg'" >> t/concat.txt
  wait `jobs -p`
  ~/bin/ffmpeg -f concat -safe 0 -i t/concat.txt -c:a libfdk_aac -b:a 128k "$FINAL_PATH.noads.mp3.m4a"
  rm "$FINAL_PATH.23.m4a" "$FINAL_PATH.45.m4a" t/concat.txt
fi

echo python feed.py 3 noads.aac feed.aac.xml
python feed.py 3 noads.aac feed.aac.xml

#insert into program(timestamp, title, author, radio_id)

#insert into file(file_type_id, path, program_id)


echo "insert into program(timestamp, author, title, radio_id) values('$TIME_DB', 'Trójka', '$TITLE', 1);" | mysql -u radioapi -pjoanna5 radio
PROG_ID=`echo 'select id from program where radio_id=1 order by id desc limit 1' | mysql -Ns -u radioapi -pjoanna5 radio`
echo "insert into file(file_type_id, path, program_id) values(2, '$FINAL_PATH.ogg', $PROG_ID),(3, '$FINAL_PATH', $PROG_ID),(4, '$FINAL_PATH.noads.mp3', $PROG_ID),(5, '$FINAL_PATH.noads.mp3.m4a', $PROG_ID),(6, '$FINAL_PATH.png', $PROG_ID);" | mysql -u radioapi -pjoanna5 radio
