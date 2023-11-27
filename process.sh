#!/bin/bash

AUDIO="audio"
VIDEO="video"
SRC="source"
VOLUME_SRC="0.03"
VOLUME_TRANS="1.5"

function process_source () {
    ## SOURCE AUDIO
    ## extract audio and lower it .3%

    MP4=$1
    AAC=$2
    AAC_LOW=$3

    echo "Processing $MP4"
    echo "Extracting audio to $AAC"

    # extract audio from mp4
    ffmpeg -i $MP4 -map 0:0 -acodec copy $AAC

    # lower level of audio to 0.03%
    ffmpeg -i $AAC -filter:a "volume=$VOLUME_SRC" $AAC_LOW
}


function mix_translation_audio () {
    ## TRANSLATION
    # extract audio, rise level, mix with source audio, and mix result with video


    TRANS_MP4=$1
    LANG=$2
    SOURCE_AAC_LOW=$3
    MIX_AAC=$4

    TRANS_AAC="$AUDIO-$LANG.aac"
    TRANS_AAC_LOUD="$AUDIO-loud-$LANG.aac"

    #  extract audio from translation
    ffmpeg -i $TRANS_MP4 -map 0:0 -acodec copy $TRANS_AAC

    # rise volume of translation
    ffmpeg -i $TRANS_MP4 -filter:a "volume=$VOLUME_TRANS" $TRANS_AAC_LOUD

    ffmpeg -i $SOURCE_AAC_LOW  -i $TRANS_AAC_LOUD -filter_complex "[0:a][1:a]amix=inputs=2"  $MIX_AAC

    rm $TRANS_AAC
    rm $TRANS_AAC_LOUD
}

function mix_translation_video () {
    ## TRANSLATION
    # extract audio, rise level, mix with source audio, and mix result with video

    SOURCE_VIDEO=$1
    MIX_TRAD_AAC=$2
    MIX_TRAD_VIDEO=$3

    ffmpeg -i $SOURCE_VIDEO -i $MIX_TRAD_AAC -c:v copy -map 0:v:0 -map 1:a:0 $MIX_TRAD_VIDEO
}

DIR=$1
DAY=$2
OPT=(eu asia)
LANG_EU=(ar bg cs da de en es et fr hr hu hy ja la lt nl ro ru uk no pl)
LANG_AS=(cn en fr hu ind ja ro ru tl es)
NAME=$3

if [ -z "$DIR" ]; then
    echo "Usage: $0 <dir> <day> <name>"
    exit 1
fi

if [ -z "$DAY" ]; then
    echo "Usage: $0 <dir> <day> <name>"
    exit 1
fi

if [ -z "$NAME" ]; then
    echo "Usage: $0 <dir> <day> <name>"
    exit 1
fi

if [ ! -d "$DIR" ]; then
    echo "Directory $DIR does not exist"
    exit 1
fi

if [ ! -f "$DIR/$SRC-$VIDEO.mp4" ]; then
    echo "No $SRC-$VIDEO.mp4 in $DIR"
    exit 1
fi

if [ ! -f "$DIR/$SRC-$AUDIO.mp4" ]; then
    echo "No $SRC-$AUDIO.mp4 in $DIR"
    exit 1
fi

if [ ! -f "$DIR/$SRC-$AUDIO-low.aac" ]; then
    process_source "$DIR/$SRC-$AUDIO.mp4" "$DIR/$SRC-$AUDIO.aac" "$DIR/$SRC-$AUDIO-low.aac"
fi


if [[ ! ("$DAY" == "eu" || "$DAY" == "asia" ) ]]; then
    echo "Day must be eu or asia"
    exit 1
fi

if [[ "$DAY" == "asia" ]]; then
    for i in "${LANG_AS[@]}"; do
        if [ ! -f "$DIR/$AUDIO-$i.mp4" ]; then
            echo "No $AUDIO-$i.mp4 in $DIR"
            exit 1
        fi

        if [ ! -f "$DIR/mix-$i.aac" ]; then
            mix_translation_audio "$DIR/$AUDIO-$i.mp4" "$i" "$DIR/$SRC-$AUDIO-low.aac" "$DIR/mix-$i.aac"
        fi

        if [ ! -f "$DIR/$i-$NAME.mp4" ]; then
            mix_translation_video "$DIR/$SRC-$VIDEO.mp4" "$DIR/mix-$i.aac" "$DIR/$i-$NAME.mp4"
        fi

    done
fi

if [[ "$DAY" == "eu" ]]; then
    for i in "${LANG_EU[@]}"; do
        if [ ! -f "$DIR/$AUDIO-$i.mp4" ]; then
            echo "No $AUDIO-$i.mp4 in $DIR"
            exit 1
        fi

        if [ ! -f "$DIR/mix-$i.aac" ]; then
            mix_translation_audio "$DIR/$AUDIO-$i.mp4" "$i" "$DIR/$SRC-$AUDIO-low.aac" "$DIR/mix-$i.aac"
        fi

        if [ ! -f "$DIR/$i-$NAME.mp4" ]; then
            mix_translation_video "$DIR/$SRC-$VIDEO.mp4" "$DIR/mix-$i.aac" "$DIR/$i-$NAME.mp4"
        fi

    done
fi
