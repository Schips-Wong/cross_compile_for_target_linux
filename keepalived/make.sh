source ../.common

export CONFIG_OPENSSL=1.1.1u
#export CONFIG_KEEPALIVED_VERSION=2.2.8
# https://www.keepalived.org/download.html

#export KEEPALIVED_OUTPUT_PATH=${OUTPUT_PATH}/${KEEPALIVED}
export OPENSSL_OUTPUT_PATH=${KEEPALIVED_OUTPUT_PATH}
export OPENSSL_OUTPUT_PATH_HOST=${KEEPALIVED_OUTPUT_PATH_HOST}

make_keepalived
#make_keepalived_host
