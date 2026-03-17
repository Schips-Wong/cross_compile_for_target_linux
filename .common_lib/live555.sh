export LIVE555=live555

#export CONFIG_LIVE555_VERSION=2025.01.17
export CONFIG_LIVE555_VERSION=latest

export LIVE555_VERSION=${LIVE555}-${CONFIG_LIVE555_VERSION}

export LIVE555_OUTPUT_PATH=${OUTPUT_PATH}/${LIVE555}
export LIVE555_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/${LIVE555}

function get_live555 () {
    if [ "$CONFIG_LIVE555_VERSION" = "latest" ]; then
        tget https://download.live555.com/live555-latest.tar.gz
    else
        tget https://download.videolan.org/pub/contrib/live555/live.${CONFIG_LIVE555_VERSION}.tar.gz
    fi
}

function mk_live555 () {
	local build_for="$1"
    cd ${CODE_PATH}/live || return 1

    local output_dir=""
    local openssl_dir=""
    local mk_file_name=""
    local using_cross_compile_arg=""

    if [ "$build_for" != "host" ];then
        output_dir=$LIVE555_OUTPUT_PATH
        openssl_dir=${OPENSSL_OUTPUT_PATH}
        mk_file_name=armlinux
        using_cross_compile_arg="CROSS_COMPILE=${BUILD_HOST_}"
    else
        output_dir=$LIVE555_OUTPUT_PATH_HOST
        openssl_dir=${OPENSSL_OUTPUT_PATH_HOST}
        mk_file_name=linux-64bit
        using_cross_compile_arg=""
    fi

read -r -d '' NEW_COPTS <<- EOF
\$(INCLUDES)   \
-I. \
-IliveMedia/include/ \
-I${openssl_dir}/include \
-L${openssl_dir}/lib \
-O2 -DSOCKLEN_T=socklen_t -DNO_SSTREAM=1 -D_LARGEFILE_SOURCE=1 -D_FILE_OFFSET_BITS=64 \
-DNO_STD_LIB -lssl -lcrypto
EOF

    ./genMakefiles  $mk_file_name || return 1

    export NEW_LIBS_CONSOLE="-I${openssl_dir}/include -L${openssl_dir}/lib -lssl -lcrypto"
    #bash << EOF #BUG
    export COMPILE_OPTS="${NEW_COPTS}"
    export LIBS_FOR_CONSOLE_APPLICATION="${NEW_LIBS_CONSOLE}"
    make clean
    make ${using_cross_compile_arg} \
        COMPILE_OPTS="${NEW_COPTS}" \
        LIBS_FOR_CONSOLE_APPLICATION="${NEW_LIBS_CONSOLE}" \
        $MKTHD && make install PREFIX=${output_dir}
    #EOF
}


function make_live555 () {
    rm ${CODE_PATH}/live -rf
    get_live555
    get_ssl

    tar_package       || return 1
    make_openssl
    mk_live555
}


function make_live555_host () {
    rm ${CODE_PATH}/live -rf
    get_live555
    get_ssl

    tar_package       || return 1
    make_openssl_host
    mk_live555 "host"
}

