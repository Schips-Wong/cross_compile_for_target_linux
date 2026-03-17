#!/bin/sh
source ../.common

# history version (YYYY.MM.DD): https://download.videolan.org/pub/contrib/live555/
# current version (latest)    : https://download.live555.com/live555-latest.tar.gz

#export CONFIG_LIVE555_VERSION=2025.01.17
export CONFIG_LIVE555_VERSION=latest


export OPENSSL_OUTPUT_PATH=${OUTPUT_PATH}/${LIVE555}
#export LIVE555_OUTPUT_PATH=${OUTPUT_PATH}/${LIVE555}

make_live555_host
