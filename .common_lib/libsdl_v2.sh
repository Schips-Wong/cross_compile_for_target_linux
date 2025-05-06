LIBSDL_V2=SDL2
export CONFIG_LIBSDL_V2_VERSION=2.0.12
export LIBSDL_V2_VERSION=${LIBSDL_V2}-${CONFIG_LIBSDL_V2_VERSION}

export LIBSDL_V2_OUTPUT_PATH=${OUTPUT_PATH}/${LIBSDL_V2}
export LIBSDL_V2_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/${LIBSDL_V2}

## for others
export LIBSDL_V2_FILE_NAME=${LIBSDL_V2_VERSION}.tar.gz
export LIBSDL_V2_ARCH_PATH=$ROOT_DIR/libsdl/compressed/${LIBSDL_V2_FILE_NAME}

function _sync_export_var_libsdl_v2()
{
    export LIBSDL_V2_VERSION=${LIBSDL_V2}-${CONFIG_LIBSDL_V2_VERSION}
    export LIBSDL_V2_FILE_NAME=${LIBSDL_V2_VERSION}.tar.gz
    export LIBSDL_V2_ARCH_PATH=$ROOT_DIR/libsdl/compressed/${LIBSDL_V2_FILE_NAME}
}

function get_libsdl_v2 () {
    _sync_export_var_libsdl_v2
    tget_package_from_arch  $LIBSDL_V2_ARCH_PATH $ARCHIVE_PATH/$LIBSDL_V2_FILE_NAME \
        https://github.com/libsdl-org/SDL/releases/download/release-$CONFIG_LIBSDL_V2_VERSION/SDL2-$CONFIG_LIBSDL_V2_VERSION.tar.gz
}

function mk_libsdl_v2 () {
    local build_for_host="$1" # say any for host
    _sync_export_var_libsdl_v2
    local build_libsdl_cc_arg=""
    local libsdl_output_dir=""

    if [ -z "$build_for_host" ];then
        build_libsdl_cc_arg="CC=${_CC} CXX=${_CXX} --host=$BUILD_HOST"
        libsdl_output_dir=${LIBSDL_V2_OUTPUT_PATH}
    else
        libsdl_output_dir=""
        libsdl_output_dir=${LIBSDL_V2_OUTPUT_PATH_HOST}
    fi

    cd ${CODE_PATH}/SDL2-${CONFIG_LIBSDL_V2_VERSION}
    cat <<EOF > $tmp_config
    ./configure $build_libsdl_cc_arg  \
        --enable-shared=no --enable-static=yes --disable-pulseaudio\
        --prefix=$libsdl_output_dir

    make clean
    make $MKTHD && make install
EOF
    bash $tmp_config
}

function make_libsdl_v2 () {
    _sync_export_var_libsdl_v2
    get_libsdl_v2
    tar_package       || return 1
    mk_libsdl_v2
}

function make_libsdl_v2_host () {
    _sync_export_var_libsdl_v2
    get_libsdl_v2
    tar_package       || return 1
    mk_libsdl_v2 host
}
