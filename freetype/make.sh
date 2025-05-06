#!/bin/sh

source ../.common

# 版本和下载的链接有关系，需要自己区分
# x export CONFIG_FREETYPE_VERSION=2.4.12
# x export CONFIG_FREETYPE_DOWNLOAD_URL=https://download.savannah.gnu.org/releases/freetype/freetype-old

#export CONFIG_FREETYPE_VERSION=2.10.4
#export CONFIG_FREETYPE_DOWNLOAD_URL=https://download.savannah.gnu.org/releases/freetype

#export FREETYPE_OUTPUT_PATH=${OUTPUT_PATH}/${FREETYPE}
#export FREETYPE_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/${FREETYPE}

make_freetype
#make_freetype_host
