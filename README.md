# Process video and audio file from zoom

Zoom interpretation feature will produce a series of audio files with out any
audio mixing.

This script, which assume you have downloaded all your media file into
a directory following the convention:
- source-audio.mp4
- source-video.mp4
- audio-en.mp4
- audio-cn.mp4
- etc.


It also assume you have 2 options for languages set
- asia
- europe
(easily configurable)

## Dependancy 
- ffmpeg

## Usage

```
./process.sh <media-dir> <language-set> <filename>
```


