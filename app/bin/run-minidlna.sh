#!/bin/bash

# error codes

# default values
DEFAULT_MINIDLNA_PORT=8200

CONFIG_FILE=/app/conf/minidlna.conf

echo "# MINIDLNA CONFIG" >> $CONFIG_FILE

for i in {1..5}
do
    for t in {A,P,V}
    do
        ENV_NAME=MINIDLNA_DIR_$t_$i
        if [ -n $ENV_NAME ]; then
            echo "media_dir=$t,$ENV_NAME" > $CONFIG_FILE
        fi
    done
done

for i in {1..5}
do
    ENV_NAME=MINIDLNA_DIR_CUSTOM_$i
    if [ -n $ENV_NAME ]; then
        echo "media_dir=$ENV_NAME" > $CONFIG_FILE
    fi
done

if [ -n $MINIDLNA_MERGE_MEDIA_DIRS ]; then
    if [ $MINIDLNA_MERGE_MEDIA_DIRS^^ = "Y" ] || [ $MINIDLNA_MERGE_MEDIA_DIRS^^ = "YES"] || [ $MINIDLNA_MERGE_MEDIA_DIRS = "1" ]; then
        echo "merge_media_dirs=yes" > $CONFIG_FILE
    else 
        echo "merge_media_dirs=no" > $CONFIG_FILE
    fi
fi

echo "db_dir=/db" > $CONFIG_FILE
echo "log_dir=/log" > $CONFIG_FILE

if [ -z $MINIDLNA_PORT ]; then
    MINIDLNA_PORT=$DEFAULT_MINIDLNA_PORT
fi

echo "port=$MINIDLNA_PORT" > $CONFIG_FILE

if [ -n $MINIDLNA_FRIENDLY_NAME ]; then
    echo "friendly_name=$MINIDLNA_FRIENDLY_NAME" > $CONFIG_FILE
fi

if [ -n $MINIDLNA_SERIAL ]; then
    echo "serial=$MINIDLNA_SERIAL" > $CONFIG_FILE
fi

if [ -n $MINIDLNA_MODEL_NAME ]; then
    echo "model_name=$MINIDLNA_MODEL_NAME" > $CONFIG_FILE
fi

if [ -n $MINIDLNA_MODEL_NUMBER ]; then
    echo "model_number=$MINIDLNA_MODEL_NUMBER" > $CONFIG_FILE
fi

if [ -n $MINIDLNA_ENABLE_INOTIFY ]; then
    if [ $MINIDLNA_ENABLE_INOTIFY^^ = "Y" ] || [ $MINIDLNA_ENABLE_INOTIFY^^ = "YES"] || [ $MINIDLNA_ENABLE_INOTIFY = "1" ]; then
        echo "inotify=yes" > $CONFIG_FILE
    fi
fi

cat /app/conf/album-art.conf.snippet > $CONFIG_FILE

if [ -n $MINIDLNA_STRICT_DLNA ] then;
    if [ $MINIDLNA_STRICT_DLNA^^ = "Y" ] || [ $MINIDLNA_STRICT_DLNA^^ = "YES"] || [ $MINIDLNA_STRICT_DLNA = "1" ]; then
        echo "strict_dlna=yes" > $CONFIG_FILE
    else
        echo "strict_dlna=no" > $CONFIG_FILE
    fi
fi



CMD_LINE="/usr/sbin/minidlnad -f $CONFIG_FILE"
eval $CMD_LINE