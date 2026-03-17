##
#    Copyright By Schips, All Rights Reserved
#    https://gitee.com/schips/
#    File Name:  make.sh
##
#!/bin/sh

source ../.common


#export LIBYUV_INSTALL=${OUTPUT_PATH}/libyuv
#export LIBYUV_INSTALL_HOST=${OUTPUT_PATH_HOST}/libyuv

make_libyuv
make_libyuv_host
