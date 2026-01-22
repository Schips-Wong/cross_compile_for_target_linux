GZIP=gzip
export CONFIG_GZIP_VERSION=1.14
export GZIP_VERSION=${GZIP}-${CONFIG_GZIP_VERSION}

export GZIP_OUTPUT_PATH=${OUTPUT_PATH}/${GZIP}


function _sync_export_var_gzip()
{
    export GZIP_VERSION=${GZIP}-${CONFIG_GZIP_VERSION}
}

function get_gzip () {
    _sync_export_var_gzip
    tget https://ftp.gnu.org/gnu/gzip/${GZIP_VERSION}.tar.gz
}

function mk_gzip () {
    _sync_export_var_gzip
	sh_file=./build_${GZIP}.sh
(
cat<<EOF
    cd ${CODE_PATH}/${GZIP_VERSION}
    CC=${_CC} ./configure --prefix=${GZIP_OUTPUT_PATH} --host=$BUILD_HOST  \
	 --disable-nls  --enable-static
    make clean
    make $MKTHD && make install
EOF
) > ${sh_file}

    source ${sh_file} || return 1
}

function make_gzip () {
    _sync_export_var_gzip
    get_gzip
    tar_package       || return 1
    mk_gzip
}
