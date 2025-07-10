export CONFIG_KEEPALIVED_VERSION=2.2.8
#export CONFIG_KEEPALIVED_SYSCONFDIR=/etc

KEEPALIVED=keepalived
KEEPALIVED_VERSION=keepalived-${CONFIG_KEEPALIVED_VERSION}


export KEEPALIVED_OUTPUT_PATH=${OUTPUT_PATH}/${KEEPALIVED}
export KEEPALIVED_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/${KEEPALIVED}

function _sync_export_var_keepalived()
{
    export KEEPALIVED_VERSION=keepalived-${CONFIG_KEEPALIVED_VERSION}
}

#下载包
download_keepalived () {
    _sync_export_var_keepalived
    get_openssl
    tget  https://www.keepalived.org/software/${KEEPALIVED_VERSION}.tar.gz
}

mk_keepalived () {
    local build_for_host="$1" # say y for host

	## TODO : can not build static
    #local build_with_static=n
    ## 如果ssl是so库，在后续的很多时候都会需要考虑环境变量的问题
    ##echo "ALLOW STATIC LINK ONLY"
    #local build_with_static_cmd_part=""
    #if [ "$build_with_static" != "y" ]; then
    #    build_with_static_cmd_part=""
    #else
    #    build_with_static_cmd_part="-static -ldl -pthread"
    #fi
    local build_with_target_arch_cmd_part=""
    local openssl_install_dir=""
    local output_dir=""
    if [  "$build_for_host" == 'y' ];then
        openssl_install_dir="$OPENSSL_OUTPUT_PATH_HOST"
        build_with_target_arch_cmd_part=""
        output_dir=${KEEPALIVED_OUTPUT_PATH_HOST}
    else
        openssl_install_dir="$OPENSSL_OUTPUT_PATH"
        build_with_target_arch_cmd_part="--host=${BUILD_HOST}  CC=${_CC}"
        output_dir=${KEEPALIVED_OUTPUT_PATH}
    fi

    bash <<EOF
    cd ${CODE_PATH}/${KEEPALIVED_VERSION}
    ./configure ${build_with_target_arch_cmd_part}\
    --prefix=${output_dir} \
    --with-ssl-dir=${openssl_install_dir} \
    CFLAGS="-I${openssl_install_dir}/include" LDFLAGS="-L${openssl_install_dir}/lib" \
    --disable-maintainer-mode --disable-dependency-tracking --disable-fwmark \
    --enable-sha1 --enable-json --enable-bfd --enable-debug --enable-log-file \
    --disable-systemd --with-systemdsystemunitdir=${output_dir}/systemd || exit \$?

	#--sysconfdir=${CONFIG_KEEPALIVED_SYSCONFDIR} 

    rm -rf ${openssl_install_dir}/{bin,share,ssl}
    #if [ "$build_with_static" != "y" ]; then
    #    echo "do nothing as dy"
    #else
    #    rm -v -rf ${output_dir}/lib/*.so*
    #fi


    KA_LIBS="-lm -lssl -lcrypto $build_with_static_cmd_part" make  && make install
EOF
}

gen_target_linux_cmd_keepalived () {
    (
    cat <<EOF
mkdir -p /etc/keepalived
#cp -v keepalived/etc/keepalived/samples/keepalived.conf.PING_CHECK    /etc/keepalived/keepalived.conf
cp -v keepalived/etc/keepalived/keepalived.conf.sample  /etc/keepalived/keepalived.conf
cp -v keepalived/sbin/keepalived            /sbin/keepalived

mkdir -p /etc/sysconfig
cp -v keepalived/etc/sysconfig/keepalived   /etc/sysconfig
EOF
) > ${OUTPUT_PATH}/install.keepalived
    chmod +x ${OUTPUT_PATH}/install.keepalived
}

make_keepalived ()
{
    download_keepalived
    tar_package
    make_openssl   || { echo >&2 "make_openssl "; exit 1; }
    mk_keepalived  || { echo >&2 "mk_keepalived "; exit 1; }
    gen_target_linux_cmd_keepalived
}

make_keepalived_host ()
{
    download_keepalived
    tar_package
    make_openssl_host  || { echo >&2 "make_openssl "; exit 1; }
    mk_keepalived y    || { echo >&2 "mk_keepalived "; exit 1; }
    gen_target_linux_cmd_keepalived
}
