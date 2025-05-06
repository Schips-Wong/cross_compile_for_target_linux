#!/bin/sh

source ../.common

####################### V1 #######################
# 不建议修改SDLv1.2的版本
# x export CONFIG_LIBSDL_V1_2_VERSION=1.2.15
#export LIBSDL_V1_2_OUTPUT_PATH=${OUTPUT_PATH}/${LIBSDL_V1_2}
#export LIBSDL_V1_2_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/${LIBSDL_V1_2}

make_libsdl_v1_2
#make_libsdl_v1_2_host

####################### V2 #######################

#export CONFIG_LIBSDL_V2_VERSION=2.0.12
#export LIBSDL_V1_2_OUTPUT_PATH=${OUTPUT_PATH}/${LIBSDL_V1_2}
#export LIBSDL_V1_2_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/${LIBSDL_V1_2}

make_libsdl_v2
#make_libsdl_v2_host
