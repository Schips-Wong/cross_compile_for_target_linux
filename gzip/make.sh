#!/bin/sh

source ../.common

#export CONFIG_GZIP_VERSION=1.14
#export GZIP_OUTPUT_PATH=${OUTPUT_PATH}/${GZIP}
export TAR_OUTPUT_PATH=${GZIP_OUTPUT_PATH}


make_gzip
make_tar
