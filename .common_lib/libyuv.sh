LIBYUV=libyuv

LIBYUV_INSTALL=${OUTPUT_PATH}/libyuv
LIBYUV_INSTALL_HOST=${OUTPUT_PATH_HOST}/libyuv

#下载包
download_libyuv () {
    # unofficial libyuv mirror
    tgit  https://github.com/lemenkov/libyuv
}

_mk_libyuv () {
    local type="$1"
    local istall_path="$2"

    local sh_file=build_${LIBYUV}.sh

    local cc_arg=""
    if [ "$type" != "target" ];then
        cc_arg=""
        sh_file=build_${LIBYUV}.host.sh
    else
        cc_arg="CROSS_COMPILE=${BUILD_HOST_}"
        sh_file=build_${LIBYUV}.target.sh
    fi
    cd ${CODE_PATH}/libyuv || return 1
(
   cat <<EOF

    local LIBYUV_DIR=\`pwd\`

    cp ${META_PATH}/Makefile \${LIBYUV_DIR}
    make clean
    make ${cc_arg} TYPE=so
    make ${cc_arg} TYPE=a
    mkdir ${istall_path} -p
    cp -rfv \${LIBYUV_DIR}/include/ ${istall_path}

    mkdir ${istall_path}/lib -p
    cp -rfv \$LIBYUV_DIR/libyuv.so ${istall_path}/lib
    cp -rfv \$LIBYUV_DIR/libyuv.a ${istall_path}/lib
EOF
) > $sh_file
    source ./${sh_file} || return 1
}
mk_libyuv () {
   _mk_libyuv "target"  ${LIBYUV_INSTALL}
}
mk_libyuv_host () {
   _mk_libyuv "host"  ${LIBYUV_INSTALL_HOST}
}


make_libyuv ()
{
    make_dirs
    download_libyuv || { echo >&2 "download_libyuv "; exit 1; }
    tar_package
    mk_libyuv
}

make_libyuv_host ()
{
    make_dirs
    download_libyuv || { echo >&2 "download_libyuv "; exit 1; }
    tar_package
    mk_libyuv_host 
}
