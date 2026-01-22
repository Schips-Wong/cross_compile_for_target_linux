LZO=lzo
export CONFIG_LZO_VERSION=2.08
export LZO_VERSION=${LZO}-${CONFIG_LZO_VERSION}
export LZO_OUTPUT_PATH=${OUTPUT_PATH}/${LZO}


function _sync_export_var_lzo()
{
    export LZO_VERSION=${LZO}-${CONFIG_LZO_VERSION}
}

function download_lzo () {
    _sync_export_var_lzo
    tget http://www.oberhumer.com/opensource/lzo/download/${LZO_VERSION}.tar.gz
}

function get_lzo () {
    download_lzo
}

#编译
function mk_lzo () {
	sh_file=build_${LZO}.sh

    _sync_export_var_lzo

    # 编译安装 lzo
    cd ${CODE_PATH}/${LZO_VERSION}

(
cat<<EOF
    CC=${_CC} ./configure --host=arm-linux  --prefix=${LZO_OUTPUT_PATH}
    make clean
    make $MKTHD && make install
EOF
) > ${sh_file}

    source ./${sh_file} || return 1
}

function make_lzo () {
    _sync_export_var_lzo
    get_lzo
    tar_package       || return 1
    mk_lzo
}
