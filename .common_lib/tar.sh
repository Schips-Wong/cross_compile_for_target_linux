TAR=tar
export CONFIG_TAR_VERSION=1.35
export TAR_VERSION=${TAR}-${CONFIG_TAR_VERSION}

export TAR_OUTPUT_PATH=${OUTPUT_PATH}/${TAR}

function _sync_export_var_tar()
{
    export TAR_VERSION=${TAR}-${CONFIG_TAR_VERSION}
}

function get_tar () {
    _sync_export_var_tar
	# https://www.gnu.org/software/tar/
    tget https://ftp.gnu.org/gnu/tar/${TAR_VERSION}.tar.xz
}

function mk_tar () {
    _sync_export_var_tar
	sh_file=./build_${TAR}.sh
(
cat<<EOF
    cd ${CODE_PATH}/${TAR_VERSION}
    CC=${_CC} ./configure --prefix=${TAR_OUTPUT_PATH} --host=arm-linux
    make clean
    make $MKTHD && make install
EOF
) > ${sh_file}

    source ${sh_file} || return 1
}

function make_tar () {
    _sync_export_var_tar
    get_tar
    tar_package       || return 1
    mk_tar
}
