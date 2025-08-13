UDHCP=udhcp
export CONFIG_UDHCP_VERSION=0.9.8
export UDHCP_VERSION=${UDHCP}-${CONFIG_UDHCP_VERSION}

export UDHCP_OUTPUT_PATH=${OUTPUT_PATH}/${UDHCP}
export UDHCP_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/${UDHCP}


function _sync_export_var_udhcp()
{
    export UDHCP_VERSION=${UDHCP}-${CONFIG_UDHCP_VERSION}
}

download_package_udhcp () {
    _sync_export_var_udhcp
    tget https://udhcp.busybox.net/source/${UDHCP_VERSION}.tar.gz
}

mk_udhcp () {
    _sync_export_var_udhcp
    local build_for_host="$1" # say anything for host

    local build_for_host_part_arg=""
    local build_type="target"
    local output_dir="${UDHCP_OUTPUT_PATH}"

    if [  "$build_for_host" != '' ];then
        build_for_host_part_arg=""
        output_dir="$UDHCP_OUTPUT_PATH_HOST"
		build_type="host"
    else
        build_for_host_part_arg="CROSS_COMPILE=${BUILD_HOST_}"
        output_dir="$UDHCP_OUTPUT_PATH"
		build_type="target"
    fi
    cd ${CODE_PATH}/${UDHCP_VERSION}
(
    cat <<EOF
sed -i '5, 12{s/COMBINED_BINARY=/#COMBINED_BINARY=/}'               Makefile
sed -i '5, 12{s/##COMBINED_BINARY=/#COMBINED_BINARY=/}'             Makefile

sed -i '130, 135{s/case INIT_SELECTING:/case INIT_SELECTING:;/}'    dhcpc.c
sed -i '130, 135{s/case INIT_SELECTING:;;/case INIT_SELECTING:;/}'  dhcpc.c
make $build_for_host_part_arg
EOF
) > .build.${build_type}.sh
    bash ./.build.${build_type}.sh
    do_copy_udhcp $output_dir ${build_type}
}

do_copy_udhcp () {

    echo "Install to [$1]"
    local install_top="$1"
    local build_type="$2"
(
    cat <<EOF
install_top="$install_top"
udhcp_top=${CODE_PATH}/${UDHCP_VERSION}

mkdir \${install_top} -p
mkdir \${install_top}/sbin -p
mkdir \${install_top}/config -p


cp \${udhcp_top}/udhcpc                \${install_top}/sbin -v
cp \${udhcp_top}/udhcpd                \${install_top}/sbin -v
# 默认的配置路径 /usr/share/udhcpc/default.script
# 写进了代码中 dhcpc.c:62:#define DEFAULT_SCRIPT       "/usr/share/udhcpc/default.script"
cp \${udhcp_top}/samples/simple.script \${install_top}/config/default.script -v
cp \${udhcp_top}/samples/udhcpd.conf   \${install_top}/config/ -v
EOF
) > .install.${build_type}.sh
    bash ./.install.${build_type}.sh

(
    cat <<EOF
install_top="/usr/share/udhcpc"

mkdir \${install_top} -p

chmod +x  config/default.script
cp  config/default.script          "\${install_top}/default.script"
EOF
) > $install_top/install_client.sh
    chmod +x  $install_top/install_client.sh

(
    cat <<EOF
install_top="/etc"

mkdir \${install_top} -p
mkdir /var/run/   /var/lib/misc/    -p
touch /var/lib/misc/udhcpd.leases

cp  config/udhcpd.conf          "\${install_top}/udhcpd.conf"
EOF
) > $install_top/install_server.sh
    chmod +x  $install_top/install_server.sh

}

make_udhcp ()
{
    make_dirs
    download_package_udhcp
    tar_package
    mk_udhcp
}

make_udhcp_host ()
{
    make_dirs
    download_package_udhcp
    tar_package
    mk_udhcp host
}
