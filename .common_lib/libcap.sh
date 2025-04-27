export LIBCAP=libcap

export CONFIG_LIBCAP_VERSION=2.67 # 03-Feb-2023 05:20
export LIBCAP_VERSION=${LIBCAP}-$CONFIG_LIBCAP_VERSION  # 03-Feb-2023 05:20

export LIBCAP_OUTPUT_PATH=${OUTPUT_PATH}/${LIBCAP}
export LIBCAP_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/${LIBCAP}

## for others
export LIBCAP_FILE_NAME=${LIBCAP_VERSION}.tar.gz
export LIBCAP_ARCH_PATH=$ROOT_DIR/libcap/compressed/${LIBCAP_FILE_NAME}

function _sync_export_var_vsftpd()
{
    export LIBCAP_VERSION=${LIBCAP}-$CONFIG_LIBCAP_VERSION
    export LIBCAP_FILE_NAME=${LIBCAP_VERSION}.tar.gz
    export LIBCAP_ARCH_PATH=$ROOT_DIR/libcap/compressed/${LIBCAP_FILE_NAME}
}

function get_libcap () {
    _sync_export_var_vsftpd
    # https://mirrors.edge.kernel.org/pub/linux/libs/security/linux-privs/libcap2/
    tget_package_from_arch  $LIBCAP_ARCH_PATH $ARCHIVE_PATH/$LIBCAP_FILE_NAME  https://mirrors.edge.kernel.org/pub/linux/libs/security/linux-privs/libcap2/${LIBCAP_VERSION}.tar.gz
}

function mk_libcap () {
    libcap_dir=${CODE_PATH}/${LIBCAP_VERSION}
    cd $libcap_dir;
    cat <<EOF > $tmp_config
    export GOLANG=no # 让libcap不通过go来编译，采取常规编译比较快
    make clean -C $libcap_dir
    CROSS_COMPILE=${BUILD_HOST_} BUILD_CC=gcc make prefix=${LIBCAP_OUTPUT_PATH} install  -C $libcap_dir
EOF
    bash $tmp_config
}

function mk_libcap_host () {
    libcap_dir=${CODE_PATH}/${LIBCAP_VERSION}
    cd $libcap_dir;
    cat <<EOF > $tmp_config
    export GOLANG=no # 让libcap不通过go来编译，采取常规编译比较快
    make clean -C $libcap_dir
    CROSS_COMPILE="" BUILD_CC=gcc make prefix=${LIBCAP_OUTPUT_PATH_HOST} install  -C $libcap_dir
EOF
    bash $tmp_config
}

function make_libcap ()
{
    _sync_export_var_vsftpd
    get_libcap  || return 1
    tar_package || return 1

    mk_libcap
}

function make_libcap_host ()
{
    _sync_export_var_vsftpd
    get_libcap  || return 1
    tar_package || return 1

    mk_libcap_host
}

