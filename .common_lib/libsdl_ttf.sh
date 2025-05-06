LIBSDL_TTF=SDL2_ttf
export CONFIG_LIBSDL_TTF_VERSION=2.0.15
export LIBSDL_TTF_VERSION=${LIBSDL_TTF}-${CONFIG_LIBSDL_TTF_VERSION}

export LIBSDL_TTF_OUTPUT_PATH=${OUTPUT_PATH}/${LIBSDL_TTF}
export LIBSDL_TTF_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/${LIBSDL_TTF}

## for others
export LIBSDL_TTF_FILE_NAME=${LIBSDL_TTF_VERSION}.tar.gz
export LIBSDL_TTF_ARCH_PATH=$ROOT_DIR/libsdl/compressed/${LIBSDL_TTF_FILE_NAME}

function _sync_export_var_libsdl_ttf()
{
    export LIBSDL_TTF_VERSION=${LIBSDL_TTF}-${CONFIG_LIBSDL_TTF_VERSION}
    export LIBSDL_TTF_FILE_NAME=${LIBSDL_TTF_VERSION}.tar.gz
    export LIBSDL_TTF_ARCH_PATH=$ROOT_DIR/libsdl/compressed/${LIBSDL_TTF_FILE_NAME}
}

function get_libsdl_ttf () {
    _sync_export_var_libsdl_ttf
    get_freetype
    get_libsdl_v2
    tget_package_from_arch  $LIBSDL_TTF_ARCH_PATH $ARCHIVE_PATH/$LIBSDL_TTF_FILE_NAME \
        https://github.com/libsdl-org/SDL_ttf/releases/download/release-$CONFIG_LIBSDL_TTF_VERSION/$LIBSDL_TTF_VERSION.tar.gz
}

function mk_libsdl_ttf () {
    local build_for_host="$1" # say any for host
    local output_dir=""
    local cc_arg=""
    _sync_export_var_libsdl_ttf
    cd ${CODE_PATH}/SDL2_ttf-${CONFIG_LIBSDL_TTF_VERSION}
    local pkg_config_path_add=""

    if [ -z "$build_for_host" ];then
        libsdl_v2_output_path="$LIBSDL_V2_OUTPUT_PATH"
        freetype_output_path="$FREETYPE_OUTPUT_PATH"
        output_dir=${LIBSDL_TTF_OUTPUT_PATH}
        cc_arg="CC=${_CC} CXX=${_CXX} --host=$BUILD_HOST"
    else
        libsdl_v2_output_path="$LIBSDL_V2_OUTPUT_PATH_HOST"
        freetype_output_path="$FREETYPE_OUTPUT_PATH_HOST"
        output_dir=${LIBSDL_TTF_OUTPUT_PATH_HOST}
        cc_arg=""
    fi

    pkg_config_path_add="$libsdl_v2_output_path/lib/pkgconfig:$pkg_config_path_add";
    pkg_config_path_add="$freetype_output_path/lib/pkgconfig:$pkg_config_path_add";

    cat <<EOF > $tmp_config
    export PKG_CONFIG_PATH="$pkg_config_path_add:\$PKG_CONFIG_PATH"
    ./autogen.sh
    ./configure  --prefix=$output_dir  $cc_arg \
    --with-sdl-prefix=$libsdl_v2_output_path --with-sdl-exec-prefix=$libsdl_v2_output_path \
    --with-ft-exec-prefix=$freetype_output_path/ --with-ft-prefix=$freetype_output_path \
    FT2CONFIG=$freetype_output_path/bin/freetype-config \
    SDLCONFIG=$libsdl_v2_output_path/bin/sdl-config \
    LDFLAGS="-L$libsdl_v2_output_path/lib -L$freetype_output_path/lib" \
    CFLAGS="-I$libsdl_v2_output_path/include -I$freetype_output_path/include" \
    --enable-shared=no --enable-static=yes

    make clean
    make $MKTHD && make install
EOF
    bash $tmp_config
}

function make_libsdl_ttf () {
    _sync_export_var_libsdl_ttf
    get_libsdl_ttf
    tar_package       || return 1
    make_libsdl_v2
    make_freetype
    mk_libsdl_ttf
}

function make_libsdl_ttf_host () {
    _sync_export_var_libsdl_ttf
    get_libsdl_ttf
    tar_package       || return 1
    make_libsdl_v2_host
    make_freetype_host
    mk_libsdl_ttf host
}
