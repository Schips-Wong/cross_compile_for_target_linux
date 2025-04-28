VSFTPD=vsftpd
export CONFIG_VSFTPD_VERSION=3.0.5
export VSFTPD_VERSION=${VSFTPD}-${CONFIG_VSFTPD_VERSION}

export VSFTPD_OUTPUT_PATH=${OUTPUT_PATH}/${VSFTPD}
export VSFTPD_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/${VSFTPD}

## for others
export VSFTPD_FILE_NAME=${VSFTPD_VERSION}.tar.gz
export VSFTPD_ARCH_PATH=$ROOT_DIR/vsftpd/compressed/${VSFTPD_FILE_NAME}

function _sync_export_var_vsftpd()
{
    export VSFTPD_VERSION=${VSFTPD}-${CONFIG_VSFTPD_VERSION}
    export VSFTPD_FILE_NAME=${VSFTPD_VERSION}.tar.gz
    export VSFTPD_ARCH_PATH=$ROOT_DIR/vsftpd/compressed/${VSFTPD_FILE_NAME}
}

function get_vsftpd () {
    _sync_export_var_vsftpd
    get_libcap
    get_openssl
    tget_package_from_arch  $VSFTPD_ARCH_PATH $ARCHIVE_PATH/$VSFTPD_FILE_NAME  https://security.appspot.com/downloads/${VSFTPD_VERSION}.tar.gz
}

function mk_vsftpd () {
    local build_for_host="$1" # say any for host

    _sync_export_var_vsftpd
    cd ${CODE_PATH}/${VSFTPD_VERSION}

    local new_makefile=Makefile.build_for.$build_for_host
    local vsftpd_install_dir=""
    local real_gcc=""

    if [  "$build_for_host" != '' ];then
        vsftpd_install_dir=$VSFTPD_OUTPUT_PATH_HOST
        real_gcc="gcc"
    else
        vsftpd_install_dir=$VSFTPD_OUTPUT_PATH
        real_gcc="${_CC}"
    fi

    cat <<EOF  > schips_findlibs.sh
echo "-L$vsftpd_install_dir/lib -L$vsftpd_install_dir/lib64 -lcrypt  -lcap"
EOF
    chmod +x schips_findlibs.sh

    cat  <<EOF > $tmp_config
    export vsftpd_install_dir=$vsftpd_install_dir
    cp Makefile $new_makefile
    sed -i "s|gcc|${real_gcc}|g"                          $new_makefile
    sed -i "s|vsf_findlibs.sh|schips_findlibs.sh|g"       $new_makefile
    sed -i "s|/usr//sbin|\${vsftpd_install_dir}/sbin|g"   $new_makefile
    sed -i "s|/usr/local|\${vsftpd_install_dir}|g"        $new_makefile
    sed -i "s|/usr/share|\${vsftpd_install_dir}/share|g"  $new_makefile
    sed -i "s|/etc/|\${vsftpd_install_dir}/etc/|g"        $new_makefile
    make -f $new_makefile clean
    make $MKTHD -f $new_makefile || exit 1
    mkdir $vsftpd_install_dir/sbin/ -p
    mkdir $vsftpd_install_dir/share/man/man5/ -p
    mkdir $vsftpd_install_dir/etc/xinetd.d/ -p
    cp vsftpd.conf $vsftpd_install_dir
    make install -f $new_makefile
EOF
    bash $tmp_config || return 1
    gen_vsftpd_helper > $vsftpd_install_dir/install_help.sh

    cat <<EOF >>  $vsftpd_install_dir/vsftpd.conf
# 添加一个有效用户
ftp_username=root

seccomp_sandbox=NO
isolate_network=NO
allow_writeable_chroot=YES
EOF
}

function gen_vsftpd_helper()
{
    cat <<EOF
cp     vsftpd.conf /etc/vsftpd.conf
chmod    775       /etc/vsftpd.conf
mkdir    -p        /usr/share/empty

mkdir    -p        /var/ftp
chmod 755          /var/ftp
chown root:root    /var/ftp

mkdir    -p        /etc/vsftpd/
touch /etc/vsftpd/chroot_list

cp sbin/vsftpd     /sbin/
rm   lib/*.a
rm lib64/*.a

cp lib64/*         /lib64/  2>/dev/null
cp   lib/*         /lib/  2>/dev/null
mkdir    -p        /var/log

echo "adding user [nobody]"
adduser            nobody
EOF
}

function make_vsftpd () {
    _sync_export_var_vsftpd
    get_vsftpd
    tar_package       || return 1
    make_libcap       || return 1
    make_openssl      || return 1
    mk_vsftpd
}

function make_vsftpd_host () {
    _sync_export_var_vsftpd
    get_vsftpd
    tar_package       || return 1
    make_libcap_host  || return 1
    make_openssl_host || return 1
    mk_vsftpd host
}
