#!/bin/sh

source ../.common

#export CONFIG_TAR_VERSION=1.35
#export TAR_OUTPUT_PATH=${OUTPUT_PATH}/${TAR}

export GZIP_OUTPUT_PATH=${TAR_OUTPUT_PATH}

make_tar
make_gzip
