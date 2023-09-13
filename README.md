# minidlna-docker

A Docker image for `minidlna`.

## Available Archs on Docker Hub

- linux/amd64
- linux/arm64/v8
- linux/arm/v7
- linux/arm/v5

## Reference

GitHub repository of the project: [here](https://github.com/azatoth/minidlna).
## Links

Source: [GitHub](https://github.com/giof71/minidlna-docker)  
Images: [DockerHub](https://hub.docker.com/r/giof71/minidlna)

## Why

I prepared this Dockerfile because I wanted to be able to install `minidlna` easily on any machine (provided the architecture is amd64 or arm). Also I wanted to be able to configure and govern the parameters easily, through environment variables. Configuring the container is easy through a webapp like Portainer.

## Prerequisites

You need to have Docker up and running on a Linux machine, and the current user must be allowed to run containers (this usually means that the current user belongs to the "docker" group).

You can verify whether your user belongs to the "docker" group with the following command:

`getent group | grep docker`

This command will output one line if the current user does belong to the "docker" group, otherwise there will be no output.

The Dockerfile and the included scripts have been tested on the following distros:

- Manjaro Linux with Gnome (amd64)

As I test the Dockerfile on more platforms, I will update this list.

## Get the image

Here is the [repository](https://hub.docker.com/repository/docker/giof71/minidlna) on DockerHub.

Getting the image from DockerHub is as simple as typing:

`docker pull giof71/minidlna`

## Usage

### Environment Variables

Name|Description
:---|:---
MINIDLNA|Web Interface Port, defaults to `8200`
MINIDLNA_FRIENDLY_NAME|Defaults to `hostname: username`
MINIDLNA_SERIAL|Serial number the server reports to clients. Defaults to the MAC address of nework interface
MINIDLNA_MODEL_NAME|Model name the server reports to clients
MINIDLNA_MODEL_NUMBER|Model number the server reports to clients. Defaults to the version number of minidlna.
MINIDLNA_ENABLE_INOTIFY|Automatic discovery of new files in the media_dir directory
MINIDLNA_NOTIFY_INTERVAL|Set the notify interval, in seconds. The default is 895 seconds.
MINIDLNA_STRICT_DLNA|Strictly adhere to DLNA standards
MINIDLNA_ROOT_CONTAINER|Possible values are `.` (Default), `B` (Browse), `M` (Music), `V` (Vidoes), `P` (Pictures)
MINIDLNA_FORCE_SORT_CRITERIA|Always set SortCriteria to this value, regardless of the SortCriteria passed by the client e.g. force_sort_criteria=+upnp:class,+upnp:originalTrackNumber,+dc:title
USER_MODE|Set to `Y` or `YES` to enable user mode
PUID|User id, defaults to `1000`
PGID|Group id, defaults to `1000`
MINIDLNA_DIR_A_1|Audio Path #1
MINIDLNA_DIR_A_2|Audio Path #2
MINIDLNA_DIR_A_3|Audio Path #3
MINIDLNA_DIR_A_4|Audio Path #4
MINIDLNA_DIR_A_5|Audio Path #5
MINIDLNA_DIR_V_1|Video Path #1
MINIDLNA_DIR_V_2|Video Path #2
MINIDLNA_DIR_V_3|Video Path #3
MINIDLNA_DIR_V_4|Video Path #4
MINIDLNA_DIR_V_5|Video Path #5
MINIDLNA_DIR_P_1|Picture Path #1
MINIDLNA_DIR_P_2|Picture Path #2
MINIDLNA_DIR_P_3|Picture Path #3
MINIDLNA_DIR_P_4|Picture Path #4
MINIDLNA_DIR_P_5|Picture Path #5
MINIDLNA_MERGE_MEDIA_DIRS|Set this to merge all media_dir base contents into the root container. The default is `no`.

### Volumes

Volume|Description
:---|:---
/db|Database directory
/log|Log directory

### Examples

My docker-compose file on my desktop system, dedicated to music. But this might suggest your configuration with videos and pictures as well.

```text
---
version: "3"

services:
  minidlna-desktop:
    image: giof71/minidlna
    container_name: minidlna-desktop
    network_mode: host
    environment:
      - MINIDLNA_ROOT_CONTAINER=M
      - MINIDLNA_DIR_A_1=/music/library1
      - MINIDLNA_DIR_A_2=/music/library2
      - MINIDLNA_DIR_A_3=/music/library3
      - MINIDLNA_ENABLE_INOTIFY=YES
      - MINIDLNA_FRIENDLY_NAME=minidlna-desktop
      - MINIDLNA_FORCE_SORT_CRITERIA=+upnp:class,-dc:date,+upnp:album,+upnp:originalTrackNumber,+dc:title
      - PUID=1000
      - PGID=1000
    volumes:
      - /mnt/disk1/library:/music/library1
      - /mnt/disk2/library:/music/library2
      - /mnt/disk3/library:/music/library3
      - ./config/log:/log
      - ./config/db:/db
    restart: unless-stopped
```

## Build

You can build (or rebuild) the image by opening a terminal from the root of the repository and issuing the following command:

`docker build . -t giof71/minidlna`

It will take very little time even on a Raspberry Pi. When it's finished, you can run the container following the previous instructions.  
Just be careful to use the tag you have built.

## Change History

Date|Major Changes
:---|:---
2023-09-13|Switch to debian stable, see [#8](https://github.com/GioF71/minidlna-docker/issues/8)
2023-09-13|Add support to notify interval, see [#6](https://github.com/GioF71/minidlna-docker/issues/6)
2023-07-24|Switch to bookworm, see [#2](https://github.com/GioF71/minidlna-docker/issues/2)
2022-10-23|Initial release
