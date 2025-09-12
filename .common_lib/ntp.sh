
export NTP=ntp
export CONFIG_NTP_VERSION=4.2.8p17
export NTP_VERSION=${NTP}-${CONFIG_NTP_VERSION}

# 通过y/n来配置ntp是否附带openssl选项（其实并不能关闭openssl选项）
export USING_OPENSSL_FOR_NTP
#export CONFIG_NTP_SERVER_IP
#export CONFIG_NTP_OTHER_SERVER_IP
#export CONFIG_NTP_SERVER_DRIFTFILE
#export CONFIG_NTP_SERVER_PIDFILE
#export CONFIG_NTP_SERVER_LOGFILE

export CONFIG_NTP_SERVER_IP_DEFAULT="192.168.1.1"
export CONFIG_NTP_OTHER_SERVER_IP_DEFAULT="192.168.1.2"
export CONFIG_NTP_SERVER_DRIFTFILE_DEFAULT="/var/ntp/drift"
export CONFIG_NTP_SERVER_PIDFILE_DEFAULT="/var/run/ntpd.pid"
export CONFIG_NTP_SERVER_LOGFILE_DEFAULT="/var/log/ntp.log"

export NTP_OUTPUT_PATH=${OUTPUT_PATH}/${NTP}
export NTP_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/${NTP}

function _sync_export_var_udhcp()
{
    export USING_OPENSSL_FOR_NTP=y # openssl必须打开，否则编译失败
    export OPENSSL_FOR_NTP="yes"
    #if [ "$USING_OPENSSL_FOR_NTP" = "n" ];then
    #    export OPENSSL_FOR_NTP="no"
    #else
    #    export OPENSSL_FOR_NTP="yes"
    #fi
    if [ -z "$CONFIG_NTP_SERVER_IP" ];then
        export CONFIG_NTP_SERVER_IP="$CONFIG_NTP_SERVER_IP_DEFAULT"
    fi
    if [ -z "$CONFIG_NTP_OTHER_SERVER_IP" ];then
        export CONFIG_NTP_OTHER_SERVER_IP="$CONFIG_NTP_OTHER_SERVER_IP_DEFAULT"
    fi
    if [ -z "$CONFIG_NTP_SERVER_DRIFTFILE" ];then
        export CONFIG_NTP_SERVER_DRIFTFILE="$CONFIG_NTP_SERVER_DRIFTFILE_DEFAULT"
    fi

    if [ -z "$CONFIG_NTP_SERVER_PIDFILE" ];then
        export CONFIG_NTP_SERVER_PIDFILE="$CONFIG_NTP_SERVER_PIDFILE_DEFAULT"
    fi
    if [ -z "$CONFIG_NTP_SERVER_LOGFILE" ];then
        export CONFIG_NTP_SERVER_LOGFILE="$CONFIG_NTP_SERVER_LOGFILE_DEFAULT"
    fi
    export NTP_OUTPUT_PATH=${OUTPUT_PATH}/${NTP}
    export NTP_OUTPUT_PATH_HOST=${OUTPUT_PATH_HOST}/${NTP}
}

#下载包
download_ntp () {
    _sync_export_var_udhcp
    if [ "$OPENSSL_FOR_NTP" = "yes" ];then
        get_ssl
    fi
    #echo "https://downloads.nwtime.org/ntp/"

    # e.g :
    ##  https://downloads.nwtime.org/ntp/4.2.8/ntp-4.2.8p17.tar.gz
    ##  4.2.8p17 -> 4.2.8
    config_ntp_version_for_url=`echo $CONFIG_NTP_VERSION| cut -f 1 -d "p" `

    tget  https://downloads.nwtime.org/ntp/${config_ntp_version_for_url}/${NTP_VERSION}.tar.gz
}


mk_ntp () {
    _sync_export_var_udhcp
    local build_for_host="$1" # say anything for host

    local build_for_host_part_arg=""
    local build_for_openssl_dir_part_arg=""
    local output_dir=""
    local openssl_dir="${OPENSSL_OUTPUT_PATH}"
    local build_type="target"
    local make_for_host_part_arg_gcc=""
    local make_for_cflags_part_arg=""

    if [  "$build_for_host" != '' ];then
        build_for_host_part_arg="CC=gcc"
        openssl_dir="${OPENSSL_OUTPUT_PATH_HOST}"
        output_dir="$NTP_OUTPUT_PATH_HOST"
        make_for_host_part_arg_gcc=""
        build_type="host"
    else
        build_for_host_part_arg="--host=${BUILD_HOST} --target=arm-linux"
        openssl_dir="${OPENSSL_OUTPUT_PATH}"
        output_dir="$NTP_OUTPUT_PATH"
        make_for_host_part_arg_gcc="LD=${_LD} CC=${_CC}"
        build_type="target"
    fi
    if [ "$OPENSSL_FOR_NTP" != "yes" ]; then
        make_for_cflags_part_arg="CFLAGS=\"-ldl -fPIC\""
    else
        make_for_cflags_part_arg="CFLAGS=\"-L${openssl_dir}/lib -I${openssl_dir}/include -lssl -lcrypto -ldl -fPIC\""
    fi

    #if [ "$OPENSSL_FOR_NTP" != "yes" ];then
    #    build_for_openssl_dir_part_arg="--without-openssl"
    #    make_for_cflags_part_arg="CFLAGS=\"-ldl -fPIC\""
    #else
    #    build_for_openssl_dir_part_arg="--with-openssl-libdir=${openssl_dir}/lib --with-openssl-incdir=${openssl_dir}/include"
    #    if [ "$CONFIG_OPENSSL_STATIC_BULID" != "n" ]; then
    #        make_for_cflags_part_arg="CFLAGS=\"-ldl -fPIC\""
    #    else
    #        make_for_cflags_part_arg="CFLAGS=\"-L${openssl_dir}/lib -I${openssl_dir}/include -lssl -lcrypto -ldl -fPIC\""
    #    fi
    #fi

    cd ${CODE_PATH}/${NTP_VERSION}
(
    cat <<EOF
    ./configure $build_for_host_part_arg \
        --prefix=${output_dir}  \
    --disable-shared --with-yielding-select=no \
    ${build_for_openssl_dir_part_arg}
    #--without-sntp --with-ntpsnmpd=no

    make $make_for_host_part_arg_gcc $MKTHD $make_for_cflags_part_arg || exit
    make install
EOF
) > .build.ntp.${build_type}.sh

    bash .build.ntp.${build_type}.sh
}

gen_ntp_usage()
{
    echo "Install to [$1]"
    local install_top="$1"
    network_ip=`echo ${CONFIG_NTP_SERVER_IP%.*}.0`
(
    cat<<EOF
CONFIG_NTP_SERVER_IP=$CONFIG_NTP_SERVER_IP
# 修改时区(可选, 嵌入式设备应该将此行写入 /etc/profile 中)
export TZ="UTC-08:00"

# 同步时间服务器的时间
killall ntpdate > /dev/null 2>&1 && sleep 1
./bin/ntpdate   $CONFIG_NTP_SERVER_IP
#./bin/ntpdate   time.buptnet.edu.cn

# 显示时间
date

# 显示UTC时间
date -u

# 保存时间到本地（如果有硬件RTC）
hwclock -w
EOF
)   > ${install_top}/client.sh
    chmod +x ${install_top}/client.sh

(
    cat<<EOF
while true
do
    ./client.sh
    echo "Waiting 600s for next update"
    sleep 600
done
EOF
)   > ${install_top}/client_loop.sh
    chmod +x ${install_top}/client_loop.sh

(
    cat<<EOF
#配置：为同网络的其他设备提供NTP服务，无上级NTP-Server连接
## 注意：ntp服务器开启后五到十几分钟才能在客户端系统中执行以下命令，
## 否则时间同步会失败，提示'no server suitable for synchronization found'

# 指定时间漂移记录文件
# 作用：如果ntpd停止并重新启动，它将从该文件初始化频率，并避免可能的长时间间隔重新学习校正。
driftfile ${CONFIG_NTP_SERVER_DRIFTFILE}

pidfile   ${CONFIG_NTP_SERVER_PIDFILE}
logfile   ${CONFIG_NTP_SERVER_LOGFILE}

### 拒绝所有来源的任何访问(未启用)
## restrict default kod nomodify notrap nopeer noquery
## restrict -6 default kod nomodify notrap nopeer noquery

# 开放本机的任何访问
restrict 127.0.0.1
restrict -6 ::1

# 允许 ${network_ip}/24 网段主机进行时间同步
restrict ${network_ip} mask 255.255.255.0 nomodify notrap

# 允许以本地时间作为时间服务
server   127.127.1.0 # local clock
# 本地时间的精准度等级
fudge    127.127.1.0 stratum 5


### 允许上层时间服务器主动修改本机时间(目前未成功)
## restrict $CONFIG_NTP_OTHER_SERVER_IP nomodify notrap noquery
## server   $CONFIG_NTP_OTHER_SERVER_IP prefer iburst minpoll 4 maxpoll 10


# 广播延迟
broadcastdelay 0.008
# 配置key
keys /etc/ntp/keys

### 引入指定目录下的配置
## includefile /etc/ntp/crypto/pw
EOF
)   > ${install_top}/ntpd.conf


(
    cat<<EOF
# 创建有关文件
## Drift 文件
mkdir -p \`dirname  $CONFIG_NTP_SERVER_DRIFTFILE\`
touch    $CONFIG_NTP_SERVER_DRIFTFILE
## PID 文件
mkdir -p \`dirname  $CONFIG_NTP_SERVER_PIDFILE\`
touch    $CONFIG_NTP_SERVER_PIDFILE
## LOG 文件
mkdir -p \`dirname  $CONFIG_NTP_SERVER_LOGFILE\`
touch    $CONFIG_NTP_SERVER_LOGFILE

# 启动server
./bin/ntpd -c ntpd.conf
sleep 2; cat $CONFIG_NTP_SERVER_LOGFILE
EOF
)   > ${install_top}/server.sh
    chmod +x ${install_top}/server.sh

}

make_ntp ()
{
    _sync_export_var_udhcp
    download_ntp
    tar_package
    if [ "$OPENSSL_FOR_NTP" = "yes" ];then
        make_openssl
    fi
    mk_ntp  || { echo >&2 "mk_ntp "; exit 1; }
    gen_ntp_usage $NTP_OUTPUT_PATH
}

make_ntp_host ()
{
    _sync_export_var_udhcp
    download_ntp
    tar_package
    if [ "$OPENSSL_FOR_NTP" = "yes" ];then
        make_openssl_host
    fi

    mk_ntp host || { echo >&2 "mk_ntp host"; exit 1; }
    gen_ntp_usage $NTP_OUTPUT_PATH_HOST
}

