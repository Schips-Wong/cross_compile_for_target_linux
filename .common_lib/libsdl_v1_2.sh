LIBSDL_V1_2=SDL
export CONFIG_LIBSDL_V1_2_VERSION=1.2.15
export LIBSDL_V1_2_VERSION=${LIBSDL_V1_2}-${CONFIG_LIBSDL_V1_2_VERSION}

export LIBSDL_V1_2_OUTPUT_PATH=${OUTPUT_PATH}/${LIBSDL_V1_2}
export LIBSDL_V1_2_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/${LIBSDL_V1_2}

## for others
export LIBSDL_V1_2_FILE_NAME=${LIBSDL_V1_2_VERSION}.tar.gz
export LIBSDL_V1_2_ARCH_PATH=$ROOT_DIR/libsdl/compressed/${LIBSDL_V1_2_FILE_NAME}

function _sync_export_var_libsdl_v1_2()
{
    export LIBSDL_V1_2_VERSION=${LIBSDL_V1_2}-${CONFIG_LIBSDL_V1_2_VERSION}
    export LIBSDL_V1_2_FILE_NAME=${LIBSDL_V1_2_VERSION}.tar.gz
    export LIBSDL_V1_2_ARCH_PATH=$ROOT_DIR/libsdl/compressed/${LIBSDL_V1_2_FILE_NAME}
}

function get_libsdl_v1_2 () {
    _sync_export_var_libsdl_v1_2
    tget_package_from_arch_with_rename  $LIBSDL_V1_2_ARCH_PATH $ARCHIVE_PATH/$LIBSDL_V1_2_FILE_NAME \
        https://github.com/libsdl-org/SDL-1.2/archive/refs/tags/release-$CONFIG_LIBSDL_V1_2_VERSION.tar.gz $LIBSDL_V1_2_FILE_NAME
}

function mk_libsdl_v1_2 () {
    local build_for_host="$1" # say any for host
    local libsdl_output_dir=""
    local build_libsdl_cc_arg=""
    _sync_export_var_libsdl_v1_2

    if [ -z "$build_for_host" ];then
        libsdl_output_dir=${LIBSDL_V1_2_OUTPUT_PATH}
        build_libsdl_cc_arg="CC=${_CC} CXX=${_CXX} --host=arm-linux"
    else
        libsdl_output_dir=${LIBSDL_V1_2_OUTPUT_PATH_HOST}
        build_libsdl_cc_arg=""
    fi

    cd ${CODE_PATH}/SDL-1.2-release-${CONFIG_LIBSDL_V1_2_VERSION}
    cat <<EOF > $tmp_config
    ./autogen.sh
    ./configure  --prefix=${libsdl_output_dir} $build_libsdl_cc_arg  \
    --disable-alsa --disable-pulseaudio --enable-esd=no \
    --disable-x --disable-pulseaudio --enable-esd=no\
    --disable-audio     \
    --disable-video     \
    --disable-joystick  \
    --disable-cdrom     \
    --disable-cpuinfo   \
    --disable-assembly  \
    --disable-oss       \
    --disable-x         \
    --disable-alsa

    make clean
    make $MKTHD && make install
EOF
    bash $tmp_config
}

function make_libsdl_v1_2 () {
    _sync_export_var_libsdl_v1_2
    get_libsdl_v1_2
    tar_package       || return 1
    mk_libsdl_v1_2
}

function make_libsdl_v1_2_host () {
    _sync_export_var_libsdl_v1_2
    get_libsdl_v1_2
    tar_package       || return 1
    mk_libsdl_v1_2 host
}
