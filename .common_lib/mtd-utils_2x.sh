MTD_UTILS_2X=mtd-utils
export CONFIG_MTD_UTILS_VERSION_2X=2.1.2
export MTD_UTILS_VERSION_2X=${MTD_UTILS_2X}-${CONFIG_MTD_UTILS_VERSION_2X}

export MTD_UTILS_OUTPUT_PATH_2X=${OUTPUT_PATH}/${MTD_UTILS_2X}

function _sync_export_var_mtd_utils_2x()
{
	_sync_export_var_zlib
	_sync_export_var_lzo
	_sync_export_var_e2fsprogs
    export MTD_UTILS_VERSION_2X=${MTD_UTILS_2X}-${CONFIG_MTD_UTILS_VERSION_2X}
}

function download_mtd_utils_2x () {
    _sync_export_var_mtd_utils_2x

    get_zlib
	download_lzo
	download_e2fsprogs

	# http://linux-mtd.infradead.org/
	tget ftp://ftp.infradead.org/pub/mtd-utils/${MTD_UTILS_VERSION_2X}.tar.bz2
}

function mk_mtd_utils_2x () {

    _sync_export_var_mtd_utils_2x
	sh_file=build_${MTD_UTILS_2X}.sh

    cd ${CODE_PATH}/${MTD_UTILS_VERSION_2X}
(
cat <<EOF

    export ZLIBCPPFLAGS="-I${ZLIB_OUTPUT_PATH}/include"
    export  LZOCPPFLAGS="-I${LZO_OUTPUT_PATH}/include -I{$OUTPUT_PATH}/${E2FSPROGS}/include/"
    export  ZLIBLDFLAGS="-L${ZLIB_OUTPUT_PATH}/lib"
    export   LZOLDFLAGS="-L${LZO_OUTPUT_PATH}/lib"
    export   UUIDLDLIBS="-L${E2FSPROGS_OUTPUT_PATH}/lib"

    export LDFLAGS="\${ZLIBLDFLAGS} \${LZOLDFLAGS}/ \${UUIDLDLIBS}"
    export CFLAGS="\${ZLIBCPPFLAGS} \${LZOCPPFLAGS}/"
    # 编译安装 mtd-utils
    ./configure --host=${BUILD_HOST} CC=${CC} --prefix=${MTD_UTILS_OUTPUT_PATH_2X}/ \
        WITHOUT_XATTR=1   --without-crypto --without-zstd \
        LDFLAGS="\${LDFLAGS}"\
        CFLAGS="\${CFLAGS} -g -O2"\
        LZO_CFLAGS="\${LZOCPPFLAGS}" \
        ZLIB_CFLAGS="\${ZLIBCPPFLAGS}" \
        UUID_CFLAGS="-I\${E2FSPROGS_OUTPUT_PATH}/include -I\${E2FSPROGS_OUTPUT_PATH}/include/uuid"
    make WITHOUT_XATTR=1 $MKTHD
    make install
EOF
) > $sh_file
    source ./${sh_file} || return 1
}

function make_mtd_utils_2x ()
{
    _sync_export_var_mtd_utils_2x
    download_mtd_utils_2x
    tar_package || return 1

    #make_zlib  || return 1
    #make_lzo  || return 1
    #make_e2fsprogs  || return 1
    mk_mtd_utils_2x  || return 1
}

