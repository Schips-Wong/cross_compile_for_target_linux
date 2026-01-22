E2FSPROGS=e2fsprogs
export CONFIG_E2FSPROGS_VERSION=1.47.3
export E2FSPROGS_VERSION=${E2FSPROGS}-${CONFIG_E2FSPROGS_VERSION}

export E2FSPROGS_OUTPUT_PATH=${OUTPUT_PATH}/${E2FSPROGS}

function _sync_export_var_e2fsprogs()
{
    export E2FSPROGS_VERSION=${E2FSPROGS}-${CONFIG_E2FSPROGS_VERSION}
}

function download_e2fsprogs () {
    _sync_export_var_e2fsprogs
    tget_and_rename https://github.com/tytso/e2fsprogs/archive/refs/tags/v${CONFIG_E2FSPROGS_VERSION}.tar.gz e2fsprogs-${CONFIG_E2FSPROGS_VERSION}.tar.gz
}
function get_e2fsprogs () {
    download_e2fsprogs
}

function mk_e2fsprogs () {
	sh_file=build_${E2FSPROGS}.sh

    _sync_export_var_e2fsprogs

    cd ${CODE_PATH}/${E2FSPROGS_VERSION}

    # 编译安装 e2fsprogs
(
cat<<EOF
    CC=${_CC} ./configure --host=arm-linux --enable-elf-shlibs --prefix=${E2FSPROGS_OUTPUT_PATH} --without-libintl-prefix

    make $MKTHD && make install-libs LDCONFIG=echo
    mkdir ${E2FSPROGS_OUTPUT_PATH}/include/uuid -p
    cp lib/uuid/uuid.h ${E2FSPROGS_OUTPUT_PATH}/include/uuid
EOF
) > ${sh_file}

    source ./${sh_file} || return 1
}

function make_e2fsprogs () {
    _sync_export_var_e2fsprogs
    get_e2fsprogs
    tar_package       || return 1
    mk_e2fsprogs
}

