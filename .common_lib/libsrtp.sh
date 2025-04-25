LIBSRTP=libsrtp
export CONFIG_LIBSRTP_VERSION=2.5.0
export LIBSRTP_VERSION=${LIBSRTP}-${CONFIG_LIBSRTP_VERSION}

export LIBSRTP_OUTPUT_PATH=${OUTPUT_PATH}/${LIBSRTP}
export LIBSRTP_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/${LIBSRTP}

## for others
export LIBSRTP_FILE_NAME=${LIBSRTP_VERSION}.tar.gz
export LIBSRTP_ARCH_PATH=$ROOT_DIR/libsrtp/compressed/${LIBSRTP_FILE_NAME}

function _sync_export_var_libsrtp()
{
    export LIBSRTP_VERSION=${LIBSRTP}-${CONFIG_LIBSRTP_VERSION}
    export LIBSRTP_FILE_NAME=${LIBSRTP_VERSION}.tar.gz
    export LIBSRTP_ARCH_PATH=$ROOT_DIR/libsrtp/compressed/${LIBSRTP_FILE_NAME}
}

function get_libsrtp () {
    _sync_export_var_libsrtp
    tget_package_from_arch_with_rename  $LIBSRTP_ARCH_PATH $ARCHIVE_PATH/$LIBSRTP_FILE_NAME https://github.com/cisco/libsrtp/archive/refs/tags/v${CONFIG_LIBSRTP_VERSION}.tar.gz $LIBSRTP_FILE_NAME
}

function mk_libsrtp () {
    local build_for_host="$1" # say anything for host

    local build_for_host_part_arg=""
    local output_dir="${LIBSRTP_OUTPUT_PATH}"
    local ssl_install_dir="${OPENSSL_OUTPUT_PATH}"

    _sync_export_var_libsrtp

    if [  "$build_for_host" != '' ];then
        build_for_host_part_arg=""
        output_dir="$LIBSRTP_OUTPUT_PATH_HOST"
        ssl_install_dir="${OPENSSL_OUTPUT_PATH_HOST}"
    else
        build_for_host_part_arg="--host=${BUILD_HOST}"
        output_dir="$LIBSRTP_OUTPUT_PATH"
        ssl_install_dir="${OPENSSL_OUTPUT_PATH}"
    fi

    cd ${CODE_PATH}/${LIBSRTP_VERSION}
    cat <<EOF > $tmp_config
    ./configure $build_for_host_part_arg --prefix=${output_dir} \
    --enable-openssl crypto_LIBS="-L${ssl_install_dir}/lib" crypto_CFLAGS="-I${ssl_install_dir}/include" 

    make clean
    make $MKTHD && make install
EOF
    bash $tmp_config
}

function make_libsrtp () {
    _sync_export_var_libsrtp
    get_libsrtp
    tar_package       || return 1
    make_openssl
    mk_libsrtp
}

function make_libsrtp_host () {
    _sync_export_var_libsrtp
    get_libsrtp
    tar_package       || return 1
    make_openssl_host
    mk_libsrtp host
}
