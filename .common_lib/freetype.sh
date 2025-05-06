FREETYPE=freetype

# 版本和下载的连接有关系，需要区分
#export CONFIG_FREETYPE_VERSION=2.4.12
#export CONFIG_FREETYPE_DOWNLOAD_URL=https://download.savannah.gnu.org/releases/freetype/freetype-old
export CONFIG_FREETYPE_VERSION=2.10.4
export CONFIG_FREETYPE_DOWNLOAD_URL=https://download.savannah.gnu.org/releases/freetype

export FREETYPE_VERSION=${FREETYPE}-${CONFIG_FREETYPE_VERSION}

export FREETYPE_OUTPUT_PATH=${OUTPUT_PATH}/${FREETYPE}
export FREETYPE_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/${FREETYPE}

## for others
export FREETYPE_FILE_NAME=${FREETYPE_VERSION}.tar.gz
export FREETYPE_ARCH_PATH=$ROOT_DIR/freetype/compressed/${FREETYPE_FILE_NAME}

function _sync_export_var_freetype()
{
    export FREETYPE_VERSION=${FREETYPE}-${CONFIG_FREETYPE_VERSION}
    export FREETYPE_FILE_NAME=${FREETYPE_VERSION}.tar.gz
    export FREETYPE_ARCH_PATH=$ROOT_DIR/freetype/compressed/${FREETYPE_FILE_NAME}
}

function get_freetype () {
    _sync_export_var_freetype
    tget_package_from_arch  $FREETYPE_ARCH_PATH $ARCHIVE_PATH/$FREETYPE_FILE_NAME  $CONFIG_FREETYPE_DOWNLOAD_URL/${FREETYPE_VERSION}.tar.gz
}

function mk_freetype () {
    local build_for_host="$1" # say any for host
    local output_dir=""
    local cc_arg=""
    local host_arg=""

    _sync_export_var_freetype

    if [ -z "$build_for_host" ];then
        output_dir=${FREETYPE_OUTPUT_PATH}
        cc_arg="CC=${_CC} CXX=${_CXX} LD=${_LD} AR=${_AR}"
        host_arg="--host=arm-linux"
    else
        output_dir=${FREETYPE_OUTPUT_PATH_HOST}
        cc_arg=""
        host_arg=""
    fi

    cd ${CODE_PATH}/${FREETYPE_VERSION}
    cat <<EOF > $tmp_config
    ./autogen.sh
     ./configure \
    --prefix=${output_dir} $cc_arg $host_arg \
    --enable-freetype-config \
    --without-zlib --with-zlib=no \
    --without-bzip2 --with-bzip2=no \
    --without-harfbuzz --with-harfbuzz=no \
    --without-brotli --with-brotli=no \
    --without-png --with-png=no  || exit 
    sed 'freetype2/freetype/internal s|.*|\t@echo skip|' -i builds/unix/install.mk
    make clean
    $cc_arg \
    make  $MKTHD && make install
    echo ""
EOF
    bash $tmp_config
}

function make_freetype () {
    _sync_export_var_freetype
    get_freetype
    tar_package       || return 1
    mk_freetype
}

function make_freetype_host () {
    _sync_export_var_freetype
    get_freetype
    tar_package       || return 1
    mk_freetype host
}
