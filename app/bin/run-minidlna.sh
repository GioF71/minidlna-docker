#!/bin/bash

# error codes

# default values
DEFAULT_MINIDLNA_PORT=8200
DEFAULT_UID=1000
DEFAULT_GID=1000

CONFIG_FILE=/app/conf/minidlna.conf

echo "# MINIDLNA CONFIG" > $CONFIG_FILE

for i in {1..5}
do
    for t in A P V
    do
        echo "t=$t"
        ENV_NAME="MINIDLNA_DIR_${t}_${i}"
        echo "Processing media_dir for ENV_NAME=[${!ENV_NAME}]"
        if [ -n "${!ENV_NAME}" ]; then
            echo "media_dir=$t,${!ENV_NAME}" >> $CONFIG_FILE
        fi
    done
done

for i in {1..5}
do
    ENV_NAME="MINIDLNA_DIR_CUSTOM_$i"
    if [ -n "${!ENV_NAME}" ]; then
        echo "media_dir=${!ENV_NAME}" >> $CONFIG_FILE
    fi
done

if [ -n "$MINIDLNA_MERGE_MEDIA_DIRS" ]; then
    if [ "${MINIDLNA_MERGE_MEDIA_DIRS^^}" = "Y" ] || [ "${MINIDLNA_MERGE_MEDIA_DIRS^^}" = "YES" ] || [ "$MINIDLNA_MERGE_MEDIA_DIRS" = "1" ]; then
        echo "merge_media_dirs=yes" >> $CONFIG_FILE
    else 
        echo "merge_media_dirs=no" >> $CONFIG_FILE
    fi
fi

echo "db_dir=/db" >> $CONFIG_FILE
echo "log_dir=/log" >> $CONFIG_FILE

if [ -n "${MINIDLNA_ROOT_CONTAINER}" ]; then
    echo "root_container=${MINIDLNA_ROOT_CONTAINER}" >> $CONFIG_FILE
fi

if [ -z "${MINIDLNA_PORT}" ]; then
    MINIDLNA_PORT=$DEFAULT_MINIDLNA_PORT
fi

echo "port=$MINIDLNA_PORT" >> $CONFIG_FILE

if [ -n "${MINIDLNA_FRIENDLY_NAME}" ]; then
    echo "friendly_name=${MINIDLNA_FRIENDLY_NAME}" >> $CONFIG_FILE
fi

if [ -n "${MINIDLNA_SERIAL}" ]; then
    echo "serial=${MINIDLNA_SERIAL}" >> $CONFIG_FILE
fi

if [ -n "${MINIDLNA_MODEL_NAME}" ]; then
    echo "model_name=${MINIDLNA_MODEL_NAME}" >> $CONFIG_FILE
fi

if [ -n "${MINIDLNA_MODEL_NUMBER}" ]; then
    echo "model_number=${MINIDLNA_MODEL_NUMBER}" >> $CONFIG_FILE
fi

if [ -n "${MINIDLNA_ENABLE_INOTIFY}" ]; then
    if [ "${MINIDLNA_ENABLE_INOTIFY^^}" = "Y" ] || [ "${MINIDLNA_ENABLE_INOTIFY^^}" = "YES" ] || [ $MINIDLNA_ENABLE_INOTIFY = "1" ]; then
        echo "inotify=yes" >> $CONFIG_FILE
    fi
fi

if [ -n "${MINIDLNA_NOTIFY_INTERVAL}" ]; then
    echo "notify_interval=${MINIDLNA_NOTIFY_INTERVAL}" >> $CONFIG_FILE
fi

cat /app/conf/album-art.conf.snippet >> $CONFIG_FILE

if [ -n "${MINIDLNA_STRICT_DLNA}" ]; then
    if [ "${MINIDLNA_STRICT_DLNA^^}" = "Y" ] || [ "${MINIDLNA_STRICT_DLNA^^}" = "YES" ] || [ $MINIDLNA_STRICT_DLNA = "1" ]; then
        echo "strict_dlna=yes" >> $CONFIG_FILE
    else
        echo "strict_dlna=no" >> $CONFIG_FILE
    fi
fi

USE_USER_MODE=N

if [ -n "${PUID}" ] || [ [ "${USER_MODE^^}" = "Y" ] || [ "${USER_MODE^^}" = "YES" ] ]; then
    USE_USER_MODE=Y
    if [ -z "${PUID}" ]; then
        PUID=$DEFAULT_UID;
        echo "Setting default value for PUID: ["$PUID"]"
    fi
    if [ -z "${PGID}" ]; then
        PGID=$DEFAULT_GID;
        echo "Setting default value for PGID: ["$PGID"]"
    fi
    USER_NAME=minidlna-user
    GROUP_NAME=minidlna-user
    HOME_DIR=/home/$USER_NAME
    ### create home directory and ancillary directories
    if [ ! -d "$HOME_DIR" ]; then
        echo "Home directory [$HOME_DIR] not found, creating."
        mkdir -p $HOME_DIR
        chown -R $PUID:$PGID $HOME_DIR
        ls -la $HOME_DIR -d
        ls -la $HOME_DIR
    fi
    ### create group
    if [ ! $(getent group $GROUP_NAME) ]; then
        echo "group $GROUP_NAME does not exist, creating..."
        groupadd -g $PGID $GROUP_NAME
    else
        echo "group $GROUP_NAME already exists."
    fi
    ### create user
    if [ ! $(getent passwd $USER_NAME) ]; then
        echo "user $USER_NAME does not exist, creating..."
        useradd -g $PGID -u $PUID -s /bin/bash -M -d $HOME_DIR $USER_NAME
        id $USER_NAME
        echo "user $USER_NAME created."
    else
        echo "user $USER_NAME already exists."
    fi
fi

if [ -n ${MINIDLNA_FORCE_SORT_CRITERIA} ]; then
    #echo "force_sort_criteria=+upnp:class,+dc:date,+upnp:album,+upnp:originalTrackNumber,+dc:title" >> $CONFIG_FILE
    echo "force_sort_criteria=$MINIDLNA_FORCE_SORT_CRITERIA" >> $CONFIG_FILE
fi

cat $CONFIG_FILE

CMD_LINE="/usr/sbin/minidlnad -S -f $CONFIG_FILE -P /app/minidlnad.pid"
echo "CMD_LINE=$CMD_LINE"

echo "USER_MODE=[${USE_USER_MODE}]"
if [ "${USE_USER_MODE}" = "Y" ]; then
    echo "USER_MODE with uid[$PUID] gid[$PGID]"
    su $USER_NAME -c "$CMD_LINE"
else
    eval $CMD_LINE
fi
