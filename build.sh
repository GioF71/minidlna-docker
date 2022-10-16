#!/bin/bash

# error codes
# 2 Invalid base image
# 3 Invalid proxy parameter

declare -A base_images

base_images[sid]=debian:sid-slim
base_images[bookworm]=debian:bookworm-slim
base_images[bullseye]=debian:bullseye-slim
base_images[buster]=debian:buster-slim
base_images[jammy]=ubuntu:jammy

DEFAULT_BASE_IMAGE=bullseye
DEFAULT_TAG=local
DEFAULT_USE_PROXY=N

download=$DEFAULT_SOURCEFORGE_DOWNLOAD
tag=$DEFAULT_TAG

while getopts b:t:p: flag
do
    case "${flag}" in
        b) base_image=${OPTARG};;
        t) tag=${OPTARG};;
        p) proxy=${OPTARG};;
    esac
done

echo "base_image: $base_image";
echo "tag: $tag";
echo "proxy: [$proxy]";

if [ -z "${base_image}" ]; then
  base_image=$DEFAULT_BASE_IMAGE
fi

expanded_base_image=${base_images[$base_image]}
if [ -z "${expanded_base_image}" ]; then
  echo "invalid base image ["${base_image}"]"
  exit 2
fi

if [ -z "${proxy}" ]; then
  proxy="N"
fi
if [[ "${proxy}" == "Y" || "${proxy}" == "y" ]]; then  
  proxy="Y"
elif [[ "${proxy}" == "N" || "${proxy}" == "n" ]]; then  
  proxy="N"
else
  echo "invalid proxy parameter ["${proxy}"]"
  exit 3
fi


echo "Base Image: ["$expanded_base_image"]"
echo "Tag: ["$tag"]"
echo "Proxy: ["$proxy"]"

docker build . \
    --build-arg BASE_IMAGE=${expanded_base_image} \
    --build-arg USE_APT_PROXY=${proxy} \
    -t giof71/minidlna:$tag
