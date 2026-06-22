# radio_archive

A personal system for automatically recording, processing, and serving Polish radio broadcasts as podcasts with a web-based player.

## Supported stations

| Station | Source | Method |
|---|---|---|
| **Trójka** (Polskie Radio 3) | `stream3.polskieradio.pl:8904` | Hourly cron recording |
| **Radio Nowy Świat** | `n17.rcs.revma.com` | Hourly cron recording |
| **Weszło FM** | `radio.weszlo.fm` | Continuous live stream capture |

## How it works

### 1. Recording (`bin/`)

`trojka_fetch.sh` and `nowyswiat_fetch.sh` run hourly via cron. Each:
- Records ~1 hour of audio using `streamripper`
- Scrapes the current program title from the station's website (`*_get_title.py`)
- Renames the file with timestamp and title
- Generates an RSS podcast feed

Trójka additionally:
- Downloads a higher-quality OGG from an external archival server
- Converts OGG → MP3 + WAV spectrogram (via `ffmpeg` and `sox`)
- Detects ad breaks using audio fingerprinting against known jingles (`make_markers.py`)
- Cuts an ad-free version (`*.noads.mp3`) using `mp3cut`
- Encodes an AAC variant (`*.noads.mp3.m4a`) using `ffmpeg + libfdk_aac`
- Tags all files with ID3 metadata (`id3v2`)
- Logs program and file metadata to a MySQL database
- Cleans up recordings older than 60 days

`weszlo_copy.sh` and `nowyswiat_copy.sh` are triggered every 3 minutes on completed segment files:
- Organize files into `YYYY-MM-DD/` dated directories under `~/public_html/`
- Concatenate short segments into the running file
- Maintain a `NOW.mp3` symlink to the latest recording
- Regenerate the RSS feed

### 2. Ad detection (`python/make_markers.py`)

Compares the mono spectrogram of a recording against small reference images of known jingles (`t/*.wav.png`) using pixel-level image difference. Outputs timestamps for detected jingle occurrences.

Jingles used for Trójka: `zegnamy`, `zapraszamy`, `autopromocja`, `trojka`, `trojkashort`, `spoleczne`.

The markers are used to find the boundaries of ad blocks and cut a clean ad-free version.

### 3. Podcast feeds (`python/feed.py`)

Generates RSS feeds consumable by any podcast app. Three variants per station:
- `feed.xml` — full recording
- `feed.noads.xml` — ad-free MP3
- `feed.aac.xml` — ad-free AAC 128k

Covers the last 7 days of recordings and 14 days of publication window.

### 4. Web frontend (`www/`)

| File | Purpose |
|---|---|
| `index.php` | Main page: live stream, latest 10 recordings, last 7 days, podcast feed links, search |
| `subdir.php` | Per-day directory listing (symlinked into each dated folder) |
| `player.php` | Audio player with spectrogram image overlay, playback position indicator, and marker navigation |
| `search.php` | Full-text search across recording filenames |

The player shows a spectrogram as a background image and draws a playhead indicator on a canvas overlay. Clicking the spectrogram seeks to that position. If a `.markers.txt` file exists, detected jingle timestamps are listed as clickable navigation links.

## Directory layout

```
bin/
  trojka_fetch.sh         # hourly recorder for Trójka
  trojka_get_title.py     # scrapes current show title from polskieradio.pl
  nowyswiat_fetch.sh      # hourly recorder for Radio Nowy Świat
  nowyswiat_get_title.py  # scrapes current show title from nowyswiat.online
  nowyswiat_copy.sh       # post-processing for Nowy Świat segments
  weszlo_copy.sh          # post-processing for Weszło FM segments
python/
  feed.py                 # RSS/podcast feed generator
  make_markers.py         # jingle detection via spectrogram comparison
www/
  index.php               # main web UI
  player.php              # audio player
  subdir.php              # per-day listing (deployed as symlinks)
  search.php              # search page
  style.css               # stylesheet
crontab                   # crontab entries for scheduling
```

## Dependencies

**System tools:**
- `streamripper` — stream recording
- `ffmpeg` — audio conversion and OGG/WAV processing
- `sox` — spectrogram generation
- `mp3cut` — lossless MP3 cutting
- `id3v2` — ID3 tagging
- `mp3info` — MP3 duration querying
- `buffer` — buffering for piped OGG processing
- MySQL client

**Python packages:**
- `feedgen` — RSS/podcast feed generation
- `eyed3`, `mutagen` — MP3 tag reading
- `imageio`, `numpy` — spectrogram image comparison
- `requests`, `beautifulsoup4`, `lxml` — web scraping
- `python-dateutil` — timezone handling

## Crontab

```cron
@reboot  while [ 1 == 1 ]; do streamripper http://streams.radio.co:80/s7d70a7895/listen --codeset-metadata=utf-8 -d ~/tmp/weszlo -t -r 8023; done
0 * * * *  nice ~/bin/trojka_fetch.sh
*/3 * * * *  find ~/tmp/weszlo -mmin +2 -type f -iname '*.mp3' -exec ~/bin/weszlo_copy.sh {} \;
```

Trójka and Nowy Świat recordings are triggered hourly. Weszło FM segments are processed every 3 minutes after they finish writing.

## Web deployment

The `www/` PHP files are deployed to `~/public_html/{trojka,weszlo,nowyswiat}/`. Each dated recording directory gets a `index.php` symlink pointing to `../subdir.php`.

The web UI is served at `https://www.simx.mobi/{trojka,weszlo}/`.
